# Development Workflow

## Feature Implementation Workflow

0. **Research & Reuse** _(mandatory before any new implementation)_
   - **GitHub code search first:** Run `gh search repos` and `gh search code` to find existing implementations.
   - **Library docs second:** Use Context7 or primary vendor docs to confirm API behavior and version details.
   - **Exa only when the first two are insufficient.**
   - **Check package registries:** npm, PyPI, crates.io before writing utility code.
   - Prefer adopting or porting a proven approach over writing net-new code.

1. **Plan First** — Use **planner** agent. Generate PRD, architecture, system_design, tech_doc, task_list.

2. **TDD** — Use **tdd-guide** agent. Write tests first (RED), implement (GREEN), refactor (IMPROVE). Verify 80%+ coverage.

3. **Code Review** — Use **code-reviewer** agent immediately after writing code. Fix CRITICAL and HIGH issues.

4. **Commit & Push**

## Commit Message Format

```
<type>: <description>

<optional body>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci

Note: Attribution disabled globally via ~/.claude/settings.json.

## Pull Request Workflow

1. Analyze full commit history (not just latest commit)
2. Use `git diff [base-branch]...HEAD` to see all changes
3. Draft comprehensive PR summary
4. Include test plan with TODOs
5. Push with `-u` flag if new branch
