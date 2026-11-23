# CLAUDE.md

## Hard Rules

- Prefer immutable data. Mutate only where the language or perf needs it (Swift `var` state, hot loops).
- <400 lines/file. <50 lines/fn.
- Research (GitHub, registries, docs) before adding a new dependency or an unfamiliar pattern.
- No hardcoded secrets. Validate all input.
- 80%+ test coverage for app/library code.

## Workflow Gates

0. Trivial change? Skip gates 2 and 4. Trivial = ALL of:
   - <=15 lines across <=2 files
   - no new deps
   - no auth/crypto/payment/input-parsing path
   - no public API or schema change
   Touches security path? NEVER trivial.
1. Unclear task? Stop. Ask. State assumptions before code.
2. New feature or cross-module change? Planner agent first. Otherwise plan inline.
3. Multiple interpretations? Present them. No silent pick.
4. After non-trivial code: run code-reviewer. Fix CRITICAL + HIGH.
5. Before commit: run security-reviewer (always; fast secrets/input scan on trivial).

## Change Discipline

- Touch only what request requires.
- Match existing style. No improve adjacent code.
- Remove only orphans YOUR changes created.

## TDD

RED -> GREEN -> REFACTOR. Failing test first for app/library code.
Exempt: scripts, prototypes, one-off tools, trivial tier (gate 0), pure docs/config/rename.

## Language Rules (load only on demand)

- TypeScript / JavaScript (all TS/JS): `rules/typescript/rules.md`
- React / Next.js: `rules/react/rules.md` (also apply TS rules)
- React Native / Expo (Android): `rules/react-native/rules.md` (also apply TS + React rules)
- Swift / SwiftUI: `rules/swift/rules.md`
- SQL (Postgres, MySQL): `rules/sql/rules.md`
- Python: `rules/python/rules.md`

## Project Init

- New project: create `.gitignore`, add `CLAUDE.md` to it.
- Create `docs/` folder. All docs go there (api.md, database.md, release_notes.md, architecture.md, etc.). README.md stays at root only.

## Docs Rule

- Need read docs? Check `docs/` first, not source code.
- Create new doc? Always write to `docs/`. Never scatter docs at root.
- `docs/` is single source of truth for all project docs.

## Database Rule

- Existing project needs DB change? No migration. No migration files, no migrate commands.
- Write the SQL to `docs/new-changes-db.sql` instead. File exists? Append.
- User applies DB changes manually.

## Project Defaults

- Websites: speed + minimal deps
- Dashboards: use existing charting libs
- APIs: RESTful + OpenAPI docs

## Output

- Code first. Explanation after, only if non-obvious.
- No prose mixed into code. Comments only where logic unclear.
- No boilerplate unless requested.

## Code Rules

- Simplest working solution. No over-engineering. Simpler option than asked? Say so before implement.
- No abstractions for single-use ops.
- No speculative features.
- Read file before modify. Never edit blind.
- No docstrings/type annotations on unchanged code.
- No error handling for impossible scenarios.
- Three similar lines > premature abstraction.

## Review Rules

- State bug. Show fix. Stop.
- No suggestions beyond review scope.
- No compliments before or after.

## Debugging Rules

- Never speculate without read relevant code first.
- State what found, where, fix. One pass.
- Cause unclear? Say so. No guess.

## Formatting

- No em dashes, smart quotes, decorative Unicode.
- Plain hyphens + straight quotes only.
- Natural language chars (accented, CJK) fine when content needs them.
- Code output must be copy-paste safe.

@RTK.md
