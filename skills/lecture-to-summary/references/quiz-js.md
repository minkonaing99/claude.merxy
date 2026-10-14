# Quiz mode (lecture.html, exam-prep.html)

Self-testing with a score, weak-topic links, saved progress, and a cover-formulas toggle. Plain HTML first: with JS off, every question is still a working `<details>` and every formula is visible. Copy the markup contract, CSS and script below; adapt only the colors to the page's variables.

## Contents

- [Markup contract](#markup-contract)
- [CSS](#css)
- [Script](#script)

## Markup contract

```html
<!-- score panel, once, at the top of the quiz section -->
<div id="quiz-score" class="score-panel" hidden>
  <p class="score"></p>
  <div class="weak-wrap" hidden><strong>Re-read:</strong><ul class="weak"></ul></div>
  <button type="button" class="reset">Reset progress</button>
</div>

<!-- one per question; data-id stable across regenerations -->
<details class="q" data-id="dsa-sign" data-topic="DSA" data-href="#dsa">
  <summary>Write the DSA signing equations. <span class="ref">slide 19</span></summary>
  <div class="ans"><p>...answer...</p></div>
</details>

<!-- cover-formulas toggle, once, fixed bottom-right -->
<button type="button" id="cover-toggle" class="cover-toggle" hidden>Cover formulas</button>
```

Formulas to cover carry `class="formula"`. `data-topic` is the label shown in the weak list; `data-href` is where it links.

## CSS

```css
.q .mark { display: flex; gap: .5rem; margin-top: .75rem; }
.q .mark button, .score-panel button, .cover-toggle {
  font: inherit; font-size: .85rem; padding: .35rem .8rem; border-radius: 6px;
  border: 1px solid var(--line); background: #fff; color: var(--text); cursor: pointer;
  transition: transform 120ms ease-out;
}
.q .mark button:active, .score-panel button:active, .cover-toggle:active { transform: scale(.97); }
.q[data-result="right"] > summary::after { content: "  \2713"; color: var(--ok); font-weight: 600; }
.q[data-result="wrong"] > summary::after { content: "  \2717"; color: var(--warn); font-weight: 600; }
.score-panel { position: sticky; top: env(safe-area-inset-top, 0px); z-index: 2; background: var(--bg);
  border: 1px solid var(--line); border-radius: 10px; padding: .8rem 1rem; margin-bottom: 1rem; }
.score-panel .score { font-weight: 600; margin: 0 0 .4rem; }
.cover-toggle { position: fixed; right: 1rem; bottom: calc(1rem + env(safe-area-inset-bottom, 0px)); z-index: 3;
  box-shadow: 0 2px 8px rgba(0,0,0,.08); }
body.covering .formula:not(.revealed) { filter: blur(6px); cursor: pointer; user-select: none; }
@media print { .cover-toggle, .score-panel, .q .mark { display: none; } }
```

## Script

```html
<script>
(() => {
  const KEY = 'quiz:' + location.pathname;
  let state = {};
  try { state = JSON.parse(localStorage.getItem(KEY)) || {}; } catch (e) {}
  const save = () => { try { localStorage.setItem(KEY, JSON.stringify(state)); } catch (e) {} };
  const qs = [...document.querySelectorAll('details.q')];
  const panel = document.getElementById('quiz-score');

  qs.forEach((q, i) => {
    q.dataset.id = q.dataset.id || 'q' + i;
    const bar = document.createElement('div');
    bar.className = 'mark';
    [['right', 'Got it'], ['wrong', 'Missed it']].forEach(([v, label]) => {
      const b = document.createElement('button');
      b.type = 'button';
      b.textContent = label;
      b.addEventListener('click', () => { state[q.dataset.id] = v; save(); render(); });
      bar.append(b);
    });
    q.querySelector('.ans').append(bar);
  });

  function render() {
    let right = 0, wrong = 0;
    const weak = new Map();
    qs.forEach(q => {
      const v = state[q.dataset.id] || '';
      q.dataset.result = v;
      if (v === 'right') right++;
      if (v === 'wrong') { wrong++; weak.set(q.dataset.topic, q.dataset.href); }
    });
    if (!panel) return;
    panel.hidden = false;
    panel.querySelector('.score').textContent =
      `${right} got it, ${wrong} missed, ${qs.length - right - wrong} to go (of ${qs.length})`;
    const list = panel.querySelector('.weak');
    list.replaceChildren(...[...weak].map(([topic, href]) => {
      const li = document.createElement('li');
      const a = document.createElement('a');
      a.href = href || '#';
      a.textContent = topic;
      li.append(a);
      return li;
    }));
    panel.querySelector('.weak-wrap').hidden = weak.size === 0;
  }

  panel?.querySelector('.reset').addEventListener('click', () => {
    state = {};
    save();
    qs.forEach(q => { q.open = false; });
    render();
  });

  const toggle = document.getElementById('cover-toggle');
  if (toggle) {
    toggle.hidden = false;
    toggle.addEventListener('click', () => {
      const on = document.body.classList.toggle('covering');
      toggle.textContent = on ? 'Show formulas' : 'Cover formulas';
      document.querySelectorAll('.formula.revealed').forEach(f => f.classList.remove('revealed'));
    });
    document.querySelectorAll('.formula').forEach(f =>
      f.addEventListener('click', () => f.classList.add('revealed')));
  }

  render();
})();
</script>
```
