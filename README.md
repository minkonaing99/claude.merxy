# merxys-claude

Personal Claude Code configuration - agents, commands, hooks, skills, and rules.

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
├── statusline-command.sh   # Terminal statusline script (shows caveman mode)
├── skills-lock.json        # Locked skill versions
├── agents/                 # Subagent definitions
├── commands/               # Slash commands (/plan, /tdd, etc.)
├── hooks/                  # Lifecycle hook scripts (Node.js)
├── plugins/                # Plugin marketplace config
│   └── marketplaces/caveman/  # Caveman plugin (git submodule)
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

## Hooks

Hooks are Node.js scripts in `hooks/` that run automatically at lifecycle events. Configured in `settings.json`.

### `SessionStart` - `caveman-activate.js`

Runs every time a Claude Code session starts.

- Reads the configured caveman mode (default: `full`)
- Writes the active mode to `.caveman-active` flag file (statusline reads this)
- Injects the caveman ruleset as system context so Claude speaks compressed
- Nudges if statusline is not configured

**Config resolution order:**
1. `CAVEMAN_DEFAULT_MODE` environment variable
2. `~/.config/caveman/config.json` (or `%APPDATA%\caveman\config.json` on Windows)
3. Defaults to `full`

### `UserPromptSubmit` - `caveman-mode-tracker.js`

Runs on every user message before Claude sees it.

- Watches for `/caveman`, `/caveman lite`, `/caveman ultra`, `stop caveman`, etc.
- Also detects natural language: "activate caveman", "turn off caveman mode"
- Updates the `.caveman-active` flag so statusline stays in sync with the active mode

### Supporting files

| File | Purpose |
|------|---------|
| `caveman-config.js` | Shared config loader used by both hooks |
| `caveman-stats.js` | Token usage stats reader |
| `caveman-statusline.sh` | Bash statusline output (macOS/Linux) |
| `caveman-statusline.ps1` | PowerShell statusline (Windows) |

---

## Agents

Agents are subagents Claude can spawn for specialized work. Defined in `agents/`. Claude invokes these automatically based on context, or you can ask explicitly.

| Agent | Model | When Claude uses it |
|-------|-------|-------------------|
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

**Workflow gates from `CLAUDE.md`:**
- Non-trivial task? `planner` first.
- After writing code? `code-reviewer` runs.
- Before committing? `security-reviewer` runs.

---

## Commands (Slash Commands)

Commands live in `commands/`. Invoke with `/command-name` in any Claude Code session.

| Command | What it does |
|---------|-------------|
| `/plan` | Spawns `planner` agent. Restates requirements, assesses risks, creates step-by-step plan. **Waits for your confirm before touching code.** |
| `/tdd` | Spawns `tdd-guide`. Scaffolds interfaces, writes failing tests first, then minimal implementation. Enforces 80%+ coverage. |
| `/code-review` | Reviews uncommitted changes. Checks security, quality, correctness. Reports CRITICAL/HIGH issues. |
| `/security-review` | Runs language-appropriate security audit (npm audit, pip-audit, etc.). Checks OWASP Top 10. |
| `/test-coverage` | Detects test framework, measures coverage, generates missing tests to hit 80%+. |
| `/build-fix` | Detects build system, runs build, fixes errors incrementally with minimal diffs. |
| `/lint` | Detects linting tools (ESLint, Ruff, SwiftLint, etc.), runs them, auto-fixes what's possible. |
| `/deps` | Audits npm/pip/SwiftPM for outdated, vulnerable, and unused packages. |
| `/e2e` | Spawns `e2e-runner`. Generates and runs Playwright E2E tests, captures screenshots/videos/traces. |
| `/refactor-clean` | Finds dead code with knip/depcheck/ts-prune, removes safely with test verification. |
| `/update-docs` | Syncs documentation with codebase - generates from source-of-truth files. |
| `/update-codemaps` | Scans project structure, generates token-lean architecture docs in `docs/CODEMAPS/`. |
| `/necessary-docs` | Scaffolds full `docs/` structure: api.md, database.md, architecture.md, release_notes.md. |

---

## Skills

Skills are richer tools beyond commands - some are user-invocable, some are auto-triggered. Located in `skills/`. Caveman skills come from the `plugins/marketplaces/caveman` submodule.

### Caveman Skills (token optimization)

| Skill | Invoke | What it does |
|-------|--------|-------------|
| `/caveman` | `/caveman [lite\|full\|ultra]` | Ultra-compressed communication mode. Cuts ~75% of response tokens. Full = default. |
| `/caveman-help` | `/caveman-help` | Shows all caveman commands and modes. One-shot reference card. |
| `/caveman-commit` | `/caveman-commit` | Generates ultra-compressed conventional commit messages. Subject ≤50 chars. |
| `/caveman-review` | `/caveman-review` | One-line-per-finding PR review. Format: `path:line: severity: problem. fix.` |
| `/caveman-compress` | `/caveman-compress FILE` | Compresses CLAUDE.md or memory files into caveman format. Saves original as `.original.md`. |
| `/caveman-stats` | `/caveman-stats` | Shows real token usage and estimated savings for the session. |
| `/cavecrew` | auto | Decision guide for spawning caveman-compressed subagents (investigator/builder/reviewer). |

**Caveman modes:**

| Mode | Description |
|------|------------|
| `lite` | Drop filler words, keep full sentences |
| `full` | Drop articles + filler, fragments OK (default) |
| `ultra` | Maximum compression, minimal words |
| `wenyan-lite/full/ultra` | Classical Chinese compression style |

**Stop caveman:** say `stop caveman` or `normal mode`.

### Dev Skills

| Skill | Invoke | What it does |
|-------|--------|-------------|
| `/security-audit` | `/security-audit [full\|auth\|deps\|secrets] [path]` | Full codebase security audit - secrets, injection, OWASP Top 10 across TS/Python/Swift/Java/PHP |
| `/dep-audit` | `/dep-audit [--fix] [--unused] [--licenses]` | Dependency vulnerabilities, outdated packages, unused deps, license risks |
| `/test-coverage` | `/test-coverage [path] [--threshold 80]` | Coverage gap analysis + generate missing tests |
| `/hostinger-deploy` | `/hostinger-deploy [scaffold\|deploy\|checklist] [site-name]` | Deploy to Hostinger shared hosting - scaffolds structure, generates `deploy.sh` with rsync |

### UI/Design Skills

| Skill | Invoke | What it does |
|-------|--------|-------------|
| `/impeccable` | `/impeccable [target]` | Frontend UI review and improvement - UX, visual hierarchy, accessibility, motion, design systems |
| `/emil-design-eng` | auto | Emil Kowalski's UI polish philosophy - animation decisions, invisible details that make UI feel great |

### Utility Skills

| Skill | Invoke | What it does |
|-------|--------|-------------|
| `/humanizer` | `/humanizer` | Removes AI-sounding patterns from text |

---

## Rules

Rules in `rules/` are loaded by Claude on demand. `CLAUDE.md` tells Claude when to load each set.

### Common Rules (always active, loaded via `@rules/common/`)

| File | What it enforces |
|------|-----------------|
| `standards.md` | Immutability, file size limits (<800 lines), error handling, input validation |
| `workflow.md` | Research -> Plan -> TDD -> Review -> Commit order |
| `coding-style.md` | No mutation, high cohesion/low coupling, <50 line functions |
| `testing.md` | TDD mandatory, 80%+ coverage, unit + integration + E2E |
| `security.md` | Pre-commit checklist: no secrets, parameterized queries, XSS prevention, rate limiting |
| `performance.md` | Model selection strategy (Haiku/Sonnet/Opus), context window management |
| `patterns.md` | Repository pattern, API response envelope format, skeleton project approach |
| `agents.md` | Parallel agent execution, multi-perspective analysis roles |
| `hooks.md` | Hook types, TodoWrite best practices, auto-accept guidance |
| `development-workflow.md` | Full feature workflow with GitHub code search, commit format, PR process |

### Language Rules (loaded when working in that language)

Each language folder (`typescript/`, `python/`, `swift/`, `java/`, `php/`) contains:
- `coding-style.md` - language-specific style rules
- `patterns.md` - idiomatic patterns for that language
- `testing.md` - testing framework and approach
- `security.md` - language-specific security pitfalls
- `hooks.md` - hook patterns for that language

---

## Settings (`settings.json`)

Key sections:

**Permissions** - pre-approved tools that don't prompt:
`Read`, `Write`, `Edit`, `Glob`, `Grep`, `git`, `gh`, `npm`, `node`, `python3`, `swift`, `find`, `grep`, `ls`, `pnpm`, `tsc`, `npx`

**Statusline** - runs `statusline-command.sh` to show caveman mode indicator in terminal.

**Hooks** - wires `caveman-activate.js` (SessionStart) and `caveman-mode-tracker.js` (UserPromptSubmit).

**Plugins** - caveman plugin enabled (`caveman@caveman`), marketplace pointed at `JuliusBrussee/caveman`.

---

## CLAUDE.md (Global Rules)

Key rules Claude follows in every project:

- Never mutate - always return new copies
- Files 200-400 lines, functions <50 lines
- Research before writing anything new (GitHub, registries, docs)
- No hardcoded secrets, validate all input
- 80%+ test coverage minimum
- TDD: RED -> GREEN -> REFACTOR
- Touch only what the request requires
- State bug, show fix, stop - no extra suggestions during review
- No em dashes or smart quotes in output
