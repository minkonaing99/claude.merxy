# Development Workflow

## Feature Implementation Workflow

0. **Research & Reuse** _(mandatory before any new implementation)_
   - **GitHub code search first:** Run `gh search repos` and `gh search code` for existing implementations.
   - **Library docs second:** Use Context7 or vendor docs to confirm API behavior + version.
   - **Exa only when first two insufficient.**
   - **Check package registries:** npm, PyPI, crates.io before writing utility code.
   - Adopt or port proven approach over net-new code.

1. **Plan First** - Use **planner** agent. Generate PRD, architecture, system_design, tech_doc, task_list.

2. **TDD** - Use **tdd-guide** agent. Tests first (RED), implement (GREEN), refactor (IMPROVE). Verify 80%+ coverage.

3. **Code Review** - Use **code-reviewer** agent right after writing code. Fix CRITICAL and HIGH.

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
2. Use `git diff [base-branch]...HEAD` for all changes
3. Draft full PR summary
4. Include test plan with TODOs
5. Push with `-u` flag if new branch
