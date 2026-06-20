# CLAUDE.md

## Hard Rules

- Never mutate. Return new copies.
- 200-400 lines/file. <50 lines/fn.
- Research (GitHub, registries, docs) before writing anything new.
- No hardcoded secrets. Validate all input.
- 80%+ test coverage.

## Workflow Gates

1. Unclear task? Stop. Ask. State assumptions before coding.
2. Non-trivial work? Planner agent first.
3. Multiple interpretations? Present them. Don't pick silently.
4. After code: run code-reviewer. Fix CRITICAL + HIGH.
5. Before commit: run security-reviewer.

## Change Discipline

- Touch only what request requires.
- Match existing style. Don't improve adjacent code.
- Remove only orphans YOUR changes created.
- Simpler solution exists? Say so before implementing.

## TDD

RED -> GREEN -> REFACTOR. Failing test first. Always.

## Language Rules (load only on demand)

- TS/JS: `rules/typescript/{coding-style,patterns,testing,security}.md`
- Python: `rules/python/{coding-style,patterns,testing,security}.md`
- Swift: `rules/swift/{coding-style,patterns,testing,security}.md`
- Java: `rules/java/{coding-style,patterns,testing,security}.md`
- PHP: `rules/php/{coding-style,patterns,testing,security}.md`

@rules/common/standards.md
@rules/common/development-workflow.md

## Project Init

- On new project: create `.gitignore`, add `CLAUDE.md` to it.
- Create `docs/` folder. All docs go there (api.md, database.md, release_notes.md, architecture.md, etc.). README.md stays at root only.

## Docs Rule

- Need to read docs? Check `docs/` first, not source code.
- Creating new doc? Always write to `docs/`. Never scatter docs at root.
- `docs/` is single source of truth for all project documentation.

## Project Defaults

- Websites: speed + minimal deps
- Dashboards: use existing charting libs
- APIs: RESTful + OpenAPI docs

## Output

- Code first. Explanation after, only if non-obvious.
- No inline prose. Comments only where logic unclear.
- No boilerplate unless requested.

## Code Rules

- Simplest working solution. No over-engineering.
- No abstractions for single-use ops.
- No speculative features.
- Read file before modifying. Never edit blind.
- No docstrings/type annotations on unchanged code.
- No error handling for impossible scenarios.
- Three similar lines > premature abstraction.

## Review Rules

- State bug. Show fix. Stop.
- No suggestions beyond review scope.
- No compliments before or after.

## Debugging Rules

- Never speculate without reading relevant code first.
- State what found, where, fix. One pass.
- Cause unclear? Say so. Don't guess.

## Formatting

- No em dashes, smart quotes, decorative Unicode.
- Plain hyphens + straight quotes only.
- Natural language chars (accented, CJK) fine when content needs them.
- Code output must be copy-paste safe.
