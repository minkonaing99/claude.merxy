# merxys-claude

Personal Claude Code configuration - agents, commands, hooks, skills, plugins, and rules.

---

## Install on New Machine

```bash
git clone --recurse-submodules https://github.com/minkonaing99/merxys-claude.git ~/.claude
cd ~/.claude/hooks && npm install
```

> `--recurse-submodules` pulls the caveman plugin from `JuliusBrussee/caveman`.

**Requirements:** Node.js (for hooks), Claude Code CLI.

---

## What Gets Ignored (not in repo)

| Path | Why excluded |
|------|-------------|
| `history.jsonl` | Session conversation history |
| `sessions/`, `session-env/` | Runtime session state |
| `projects/` | Machine-specific path data |
| `cache/`, `paste-cache/` | Temporary cache |
| `backups/` | Auto-generated backups |
| `tasks/`, `telemetry/`, `ide/` | Runtime artifacts |
| `plugins/cache/`, `plugins/data/` | Plugin download cache |
| `plugins/installed_plugins.json` | Regenerated on `claude plugin install` |

---

## Directory Structure

```
~/.claude/
├── CLAUDE.md               # Global rules Claude follows in every project
├── settings.json           # Permissions, hooks, statusline config
├── statusline-command.sh   # Terminal statusline script
├── skills-lock.json        # Locked skill versions
├── agents/                 # Subagent definitions
├── commands/               # Slash commands (/plan, /tdd, etc.)
├── hooks/                  # Lifecycle hook scripts (Node.js)
├── plugins/                # Plugin marketplace config
│   └── marketplaces/
│       ├── caveman/        # Caveman plugin (JuliusBrussee/caveman)
│       ├── ponytail/       # Ponytail plugin (DietrichGebert/ponytail)
│       └── apple-skills/   # Apple/iOS skills (local, disabled by default)
├── rules/                  # Coding standards loaded per language
│   ├── common/             # Universal rules (always loaded)
│   ├── typescript/
│   ├── python/
│   ├── swift/
│   ├── java/
│   └── php/
└── skills/                 # Skill definitions (user-invocable tools)
```

---

## Plugins

| Plugin | Source | Status | Purpose |
|--------|--------|--------|---------|
| `caveman` | `JuliusBrussee/caveman` (GitHub) | Active | Token compression mode |
| `ponytail` | `DietrichGebert/ponytail` (GitHub) | Active | Lazy-senior dev mode (YAGNI enforcer) |
| `apple-skills` | Local directory | Disabled by default | 151 iOS/Apple dev skills |

### Caveman

Compressed communication mode - drops ~75% of response tokens while keeping all technical substance.

| Mode | Description |
|------|------------|
| `lite` | Drop filler words, keep full sentences |
| `full` | Drop articles + filler, fragments OK (default) |
| `ultra` | Maximum compression, minimal words |
| `wenyan-lite/full/ultra` | Classical Chinese compression style |

Activate: `/caveman [lite|full|ultra]` - Stop: `stop caveman` or `normal mode`

### Ponytail

Lazy senior dev mode. Enforces YAGNI via a ladder: does it need to exist? -> stdlib? -> native platform feature? -> existing dep? -> one line? -> minimum code. Marks deliberate shortcuts with `// ponytail:` comments naming the ceiling and upgrade path.

Activate: `/ponytail [lite|full|ultra]` - Stop: `stop ponytail` or `normal mode`

### Apple Skills

151 iOS/Apple development skills. Disabled by default to avoid polluting non-iOS sessions.

Enable for iOS work: `claude plugin enable apple-skills`

---

## Hooks

Node.js scripts in `hooks/` wired via `settings.json`.

### `SessionStart` - `caveman-activate.js`

- Reads configured caveman mode, injects ruleset as system context
- Writes `.caveman-active` flag (statusline reads this)
- Config resolution: `CAVEMAN_DEFAULT_MODE` env var -> `~/.config/caveman/config.json` -> defaults to `full`

### `UserPromptSubmit` - `caveman-mode-tracker.js`

- Watches for `/caveman`, mode switches, `stop caveman`, etc.
- Also detects natural language: "activate caveman", "turn off caveman"
- Updates `.caveman-active` flag so statusline stays in sync

### Supporting files

| File | Purpose |
|------|---------|
| `caveman-config.js` | Shared config loader |
| `caveman-stats.js` | Token usage stats reader |
| `caveman-statusline.sh` | Bash statusline output (macOS/Linux) |
| `caveman-statusline.ps1` | PowerShell statusline (Windows) |

---

## Agents

Subagents Claude spawns for specialized work. Defined in `agents/`. Claude invokes automatically or you can ask explicitly.

| Agent | Model | When Claude uses it |
|-------|-------|---------------------|
| `architect` | Opus | System design, scalability decisions, architectural planning |
| `build-error-resolver` | Sonnet | Build failures, TypeScript errors - minimal diffs only |
| `code-reviewer` | Sonnet | After every code change - quality, security, maintainability |
| `dependency-checker` | Sonnet | Auditing npm/pip/SwiftPM packages for vulnerabilities |
| `doc-updater` | Haiku | Updating codemaps and docs, generating `docs/CODEMAPS/*` |
| `e2e-runner` | Sonnet | Playwright E2E tests - generate, run, capture artifacts |
| `migration-guide` | Sonnet | Major version upgrades, breaking change analysis, codemods |
| `perf-profiler` | Sonnet | Runtime bottlenecks, memory leaks, bundle size, slow queries |
| `planner` | Opus | Feature planning before coding - PRD, architecture, task list |
| `refactor-cleaner` | Sonnet | Dead code removal using knip/depcheck/ts-prune |
| `security-reviewer` | Sonnet | Secrets, SSRF, injection, OWASP Top 10 before commits |
| `tdd-guide` | Sonnet | Enforces RED->GREEN->REFACTOR, ensures 80%+ coverage |

**Workflow gates from `CLAUDE.md`:** planner before non-trivial work, code-reviewer after every change, security-reviewer before commits.

---

## Commands (Slash Commands)

Commands live in `commands/`. Invoke with `/command-name` in any session.

| Command | What it does |
|---------|-------------|
| `/plan` | Spawns `planner`. Restates requirements, assesses risks, creates step-by-step plan. Waits for confirm before touching code. |
| `/tdd` | Spawns `tdd-guide`. Writes failing tests first, then minimal implementation. Enforces 80%+ coverage. |
| `/code-review` | Reviews uncommitted changes. Reports CRITICAL/HIGH issues. |
| `/security-review` | Language-appropriate security audit (npm audit, pip-audit, etc.). Checks OWASP Top 10. |
| `/test-coverage` | Measures coverage, generates missing tests to hit 80%+. |
| `/build-fix` | Runs build, fixes errors incrementally with minimal diffs. |
| `/lint` | Detects linting tools (ESLint, Ruff, SwiftLint, etc.), auto-fixes what's possible. |
| `/deps` | Audits npm/pip/SwiftPM for outdated, vulnerable, and unused packages. |
| `/e2e` | Spawns `e2e-runner`. Generates and runs Playwright E2E tests, captures screenshots/videos/traces. |
| `/refactor-clean` | Finds dead code with knip/depcheck/ts-prune, removes safely with test verification. |
| `/update-docs` | Syncs documentation with codebase. |
| `/update-codemaps` | Scans project structure, generates token-lean architecture docs in `docs/CODEMAPS/`. |
| `/necessary-docs` | Scaffolds full `docs/` structure: api.md, database.md, architecture.md, release_notes.md. |

---

## Skills

Skills are richer tools beyond commands. Located in `skills/`. Plugin skills come from their respective marketplaces. Symlinked skills (`->`) come from a shared `.agents/skills/` pack.

### Caveman Skills

| Skill | What it does |
|-------|-------------|
| `/caveman [mode]` | Activate caveman compression mode |
| `/caveman-help` | Show all caveman commands and modes |
| `/caveman-commit` | Ultra-compressed conventional commit messages (subject <= 50 chars) |
| `/caveman-review` | One-line-per-finding PR review. Format: `path:line: severity: problem. fix.` |
| `/caveman-compress FILE` | Compress CLAUDE.md or memory files into caveman format |
| `/caveman-stats` | Real token usage and estimated savings for the session |
| `/cavecrew` | (auto) Decision guide for spawning caveman-compressed subagents |

### Ponytail Skills

| Skill | What it does |
|-------|-------------|
| `/ponytail [mode]` | Activate lazy-senior mode (YAGNI + shortest-path enforcement) |
| `/ponytail-help` | Show ponytail commands and the YAGNI ladder |
| `/ponytail-audit` | Audit current code for over-engineering and unnecessary abstractions |
| `/ponytail-debt` | Surface `// ponytail:` tagged shortcuts and their upgrade paths |
| `/ponytail-review` | Review diff/PR for complexity debt |

### Dev Workflow Skills

| Skill | What it does |
|-------|-------------|
| `/security-audit [scope] [path]` | Full codebase security audit - secrets, injection, OWASP Top 10 across TS/Python/Swift/Java/PHP |
| `/dep-audit [--fix] [--unused] [--licenses]` | Dependency vulnerabilities, outdated packages, unused deps, license risks |
| `/test-coverage [path] [--threshold N]` | Coverage gap analysis + generate missing tests |
| `/hostinger-deploy [scaffold\|deploy\|checklist] [name]` | Deploy to Hostinger shared hosting via rsync |
| `/playwright-cli` | Playwright test generation and browser automation |
| `/next-best-practices` | (auto) Next.js best practices - App Router patterns, RSC, caching |
| `/nextjs-seo` | Next.js SEO setup - metadata, OG, sitemap, robots.txt |
| `/react-best-practices` | (auto) React patterns, hooks discipline, performance |
| `/api-design-patterns` | (auto) REST/GraphQL API design patterns |
| `/php-best-practices` | (auto) PHP patterns and idioms |
| `/php-error-handling` | (auto) PHP error handling patterns |
| `/php-security` | (auto) PHP security pitfalls and mitigations |
| `/php-testing` | (auto) PHP testing with PHPUnit/Pest |

### Design / UI Skills

| Skill | What it does |
|-------|-------------|
| `/design-bakeoff` | Full website design pipeline - diverging variants, objective gates, real-pixel judging, taste profile |
| `/impeccable [target]` | Frontend UI review - UX, visual hierarchy, accessibility, motion, design systems |
| `/design-an-interface` | Design a UI interface from scratch |
| `/emil-design-eng` | (auto) Emil Kowalski's UI polish philosophy - animation, invisible details |

### Video / Motion Skills

| Skill | What it does |
|-------|-------------|
| `/hyperframes` | Hyperframes video framework (core orchestrator) |
| `/remotion` | Remotion video creation in React |
| `/remotion-to-hyperframes` | (auto) Migrate Remotion projects to Hyperframes |
| `/motion-graphics` | Motion graphics design and animation |
| `/gsap-core` | (auto) GSAP animation library - core, ScrollTrigger, timeline, plugins, React, performance, utils |
| `/general-video` | General video production workflow |
| `/faceless-explainer` | Faceless explainer video creation |
| `/embedded-captions` | Burn subtitles/captions into video |
| `/graphic-overlays` | Motion graphic overlays for video |
| `/pr-to-video` | Convert PR/diff into explainer video |
| `/product-launch-video` | Product launch video production |
| `/website-to-video` | Convert website/design to video walkthrough |
| `/slideshow` | Create animated slideshow |
| `/stitch-skill` | (auto) Stitch video clips together |

### Utility Skills

| Skill | What it does |
|-------|-------------|
| `/humanizer` | Remove AI-sounding patterns from text |
| `/grill-me` | Stress-test a plan via relentless interviewing |
| `/grill-with-docs` | Grill mode with documentation context |
| `/handoff` | Compact conversation into handoff doc for another agent |
| `/write-a-skill` | Generate a new skill definition |

---

## Rules

Rules in `rules/` loaded by Claude on demand. `CLAUDE.md` specifies when to load each set.

### Common Rules (always active via `@rules/common/`)

| File | What it enforces |
|------|-----------------|
| `standards.md` | Immutability, file size limits (<800 lines), error handling, input validation |
| `development-workflow.md` | Research -> Plan -> TDD -> Review -> Commit order, commit format, PR process |
| `coding-style.md` | No mutation, high cohesion/low coupling, <50 line functions |
| `testing.md` | TDD mandatory, 80%+ coverage, unit + integration + E2E |
| `security.md` | Pre-commit checklist: no secrets, parameterized queries, XSS prevention, rate limiting |
| `performance.md` | Model selection (Haiku/Sonnet/Opus), context window management |
| `patterns.md` | Repository pattern, API response envelope, skeleton project approach |
| `agents.md` | Parallel agent execution, multi-perspective analysis roles |
| `hooks.md` | Hook types, TodoWrite best practices, auto-accept guidance |

### Language Rules (loaded per language)

Each language folder (`typescript/`, `python/`, `swift/`, `java/`, `php/`) contains `coding-style.md`, `patterns.md`, `testing.md`, `security.md`.

---

## Settings (`settings.json`)

**Permissions** - pre-approved tools that skip prompts:
`Read`, `Write`, `Edit`, `Glob`, `Grep`, `git`, `gh`, `npm`, `node`, `python3`, `swift`, `find`, `grep`, `ls`, `pnpm`, `tsc`, `npx`, select Chrome extension tools

**Statusline** - runs `statusline-command.sh` to show caveman mode indicator in terminal.

**Hooks** - wires `caveman-activate.js` (SessionStart) and `caveman-mode-tracker.js` (UserPromptSubmit).

**Plugins** - caveman and ponytail enabled; apple-skills disabled by default.

---

## CLAUDE.md (Global Rules Summary)

- Never mutate - always return new copies
- Files 200-400 lines typical, functions <50 lines
- Research before writing anything new (GitHub, registries, docs)
- No hardcoded secrets, validate all input at boundaries
- 80%+ test coverage, TDD mandatory (RED -> GREEN -> REFACTOR)
- Touch only what the request requires
- State bug, show fix, stop - no extra suggestions during review
- No em dashes or smart quotes in output
- `docs/` is single source of truth for all project documentation
