// Custom-route renderer: paints window.seek(t) per frame in headless Chromium,
// pipes PNGs to ffmpeg (H.264 yuv420p CRF 16), muxes audio.
//
// Full render:   node render.mjs --html film.html --out out.mp4 --duration 12 [--audio a.wav]
// Single frames: node render.mjs --html film.html --frames 0,1.5,3 --frames-dir dir
// Options: --fps 30 --width 1920 --height 1080 --crf 16
// Playwright resolves from MOTION_HOME (default /Users/aurora/Documents/claude-motion).
import { createRequire } from 'node:module';
import { spawn } from 'node:child_process';
import { mkdirSync, existsSync, rmSync, writeFileSync } from 'node:fs';
import { resolve, join, dirname } from 'node:path';
import { pathToFileURL } from 'node:url';
import { parseArgs } from 'node:util';

const MOTION_HOME = process.env.MOTION_HOME || '/Users/aurora/Documents/claude-motion';
// Browser lives in MOTION_HOME/node_modules, safe from other tools' cache cleanup.
process.env.PLAYWRIGHT_BROWSERS_PATH ??= '0';
const { chromium } = createRequire(join(MOTION_HOME, 'package.json'))('playwright');

const { values: o } = parseArgs({
  options: {
    html: { type: 'string' }, out: { type: 'string' }, audio: { type: 'string' },
    duration: { type: 'string' }, fps: { type: 'string', default: '30' },
    width: { type: 'string', default: '1920' }, height: { type: 'string', default: '1080' },
    crf: { type: 'string', default: '16' },
    frames: { type: 'string' }, 'frames-dir': { type: 'string' },
  },
});

const num = (name, v, min, max = Infinity) => {
  const n = v === undefined || String(v).trim() === '' ? NaN : Number(v);
  if (!Number.isFinite(n) || n < min || n > max) throw new Error(`--${name} must be a number in [${min}, ${max}], got "${v}"`);
  return n;
};
const even = (name, v) => {
  const n = num(name, v, 16);
  if (!Number.isInteger(n) || n % 2) throw new Error(`--${name} must be an even integer (H.264 yuv420p), got ${v}`);
  return n;
};

function validate() {
  if (!o.html || !existsSync(o.html)) throw new Error('--html <existing file> is required');
  if (o.audio && !existsSync(o.audio)) throw new Error(`--audio not found: ${o.audio}`);
  const base = { fps: num('fps', o.fps, 1, 240), width: even('width', o.width), height: even('height', o.height) };
  if (o.frames) {
    if (!o['frames-dir']) throw new Error('--frames needs --frames-dir');
    return { ...base, mode: 'frames', times: o.frames.split(',').map((t) => num('frames', t, 0)) };
  }
  if (!o.out || !o.duration) throw new Error('full render needs --out and --duration');
  const duration = num('duration', o.duration, 0.01);
  if (Math.round(duration * base.fps) < 1) throw new Error('--duration is shorter than one frame');
  return { ...base, mode: 'video', duration, crf: num('crf', o.crf, 0, 51) };
}

async function openFilm(width, height) {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width, height }, deviceScaleFactor: 1 });
  await page.addInitScript(() => { window.__RENDER__ = true; });
  await page.goto(pathToFileURL(resolve(o.html)).href, { waitUntil: 'load' });
  await page.waitForFunction(() => window.__ready === true || window.__error, null, { timeout: 15000 })
    .catch(() => { throw new Error('film never set window.__ready = true (15 s)'); });
  const err = await page.evaluate(() => window.__error);
  if (err) throw new Error(`film init failed: ${err}`);
  return { browser, page };
}

// Fonts first needed after a seek must load before the shot; two rAFs flush layout and paint.
const paint = async (page, t) => {
  await page.evaluate(async (time) => {
    await window.seek(time);
    await document.fonts.ready;
    await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r)));
  }, t);
  return page.screenshot({ type: 'png' });
};

function startEncoder(cfg) {
  const args = ['-hide_banner', '-loglevel', 'error', '-y',
    '-f', 'image2pipe', '-framerate', String(cfg.fps), '-i', '-'];
  if (o.audio) args.push('-i', o.audio);
  args.push('-vf', 'scale=out_color_matrix=bt709:out_range=tv',
    '-c:v', 'libx264', '-preset', 'slow', '-crf', String(cfg.crf), '-pix_fmt', 'yuv420p',
    '-colorspace', 'bt709', '-color_primaries', 'bt709', '-color_trc', 'bt709', '-color_range', 'tv',
    '-r', String(cfg.fps), '-movflags', '+faststart');
  if (o.audio) args.push('-c:a', 'aac', '-b:a', '320k', '-t', String(cfg.duration));
  args.push(o.out);
  const ff = spawn('ffmpeg', args, { stdio: ['pipe', 'inherit', 'inherit'] });
  ff.stdin.on('error', () => {}); // a dead pipe surfaces through `done`
  const done = new Promise((res, rej) => ff.on('close', (c) => (c === 0 ? res() : rej(new Error(`ffmpeg exit ${c}`)))));
  done.catch(() => {});
  return { ff, done };
}

const write = (stream, buf) => new Promise((res, rej) =>
  stream.write(buf, (err) => (err ? rej(err) : res())));

async function renderVideo(page, cfg) {
  mkdirSync(dirname(resolve(o.out)), { recursive: true });
  const total = Math.round(cfg.duration * cfg.fps);
  const { ff, done } = startEncoder(cfg);
  try {
    for (let i = 0; i < total; i++) {
      if (ff.exitCode !== null) break;
      await write(ff.stdin, await paint(page, i / cfg.fps));
      if (i % Math.round(cfg.fps) === 0) process.stdout.write(`\rframe ${i}/${total}`);
    }
    ff.stdin.end();
    await done;
  } catch (e) {
    ff.kill('SIGKILL');
    rmSync(o.out, { force: true });
    throw e;
  }
  console.log(`\rrendered ${total} frames -> ${o.out}`);
}

async function renderFrames(page, cfg) {
  mkdirSync(o['frames-dir'], { recursive: true });
  for (const [i, t] of cfg.times.entries()) {
    const name = join(o['frames-dir'], `${String(i + 1).padStart(4, '0')}.png`);
    writeFileSync(name, await paint(page, t));
    console.log(`${name}  t=${t}`);
  }
}

try {
  const cfg = validate();
  const { browser, page } = await openFilm(cfg.width, cfg.height);
  try {
    await (cfg.mode === 'video' ? renderVideo(page, cfg) : renderFrames(page, cfg));
  } finally {
    await browser.close();
  }
} catch (e) {
  console.error(`render.mjs: ${e.message}`);
  process.exitCode = 1;
}
