# merxys-claude

Personal Claude Code configuration - agents, commands, hooks, skills, plugins, and rules.

---

## Install on New Machine

```bash
git clone https://github.com/minkonaing99/merxys-claude.git ~/.claude
cd ~/.claude/hooks && npm install
```

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
├── agents/                 # Subagent definitions
├── commands/               # Slash commands (/plan, /tdd, etc.)
├── hooks/                  # Lifecycle hook scripts (Node.js)
├── plugins/                # Plugin registry (none installed)
├── rules/                  # Coding standards loaded per language
│   ├── typescript/
│   └── python/
└── skills/                 # Skill definitions (user-invocable tools)
```

---

## Plugins

None installed.

---

## Hooks

None configured.

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
| `/security-review` | Language-appropriate security audit (npm audit, pip-audit, etc.). Checks OWASP Top 10. |
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

Skills are richer tools beyond commands. Located in `skills/`.

### Dev Workflow Skills

| Skill | What it does |
|-------|-------------|
| `/test-coverage [path] [--threshold N]` | Coverage gap analysis + generate missing tests |
| `/playwright-cli` | Playwright test generation and browser automation |
| `/next-best-practices` | (auto) Next.js best practices - App Router patterns, RSC, caching |
| `/nextjs-seo` | Next.js SEO setup - metadata, OG, sitemap, robots.txt |
| `/react-best-practices` | (auto) React patterns, hooks discipline, performance |
| `/api-design-patterns` | (auto) REST/GraphQL API design patterns |

### Design / UI Skills

| Skill | What it does |
|-------|-------------|
| `/emil-design-eng` | (auto) Emil Kowalski's UI polish philosophy - animation, invisible details |

### Utility Skills

| Skill | What it does |
|-------|-------------|

---

## Rules

Rules in `rules/` loaded by Claude on demand. `CLAUDE.md` specifies when to load each set.

### Language Rules (loaded per language)

Each language folder (`typescript/`, `python/`) contains `coding-style.md`, `patterns.md`, `testing.md`, `security.md`.

---

## Settings (`settings.json`)

**Permissions** - pre-approved tools that skip prompts:
`Read`, `Write`, `Edit`, `Glob`, `Grep`, `git`, `gh`, `npm`, `node`, `python3`, `swift`, `find`, `grep`, `ls`, `pnpm`, `tsc`, `npx`

**Statusline** - runs `statusline-command.sh` in the terminal.

**Hooks** - none.

**Plugins** - none installed.

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
