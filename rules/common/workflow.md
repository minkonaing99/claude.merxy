# Development Workflow

## Feature Implementation Order
0. **Research** — `gh search code`, check package registries, read docs. Reuse over reinvent.
1. **Plan** — Use **planner** agent for non-trivial work.
2. **TDD** — Tests first, implement, refactor. 80%+ coverage.
3. **Review** — Use **code-reviewer** agent. Fix CRITICAL/HIGH issues.
4. **Commit** — Format: `<type>: <description>`. Types: feat, fix, refactor, docs, test, chore, perf, ci.

## Agents
Definitions in `~/.claude/agents/`. Use parallel execution for independent operations.

## Model Selection
- **Haiku 4.5**: Lightweight/worker agents, frequent invocations
- **Sonnet 4.6**: Main dev work, orchestration
- **Opus 4.6**: Complex architecture, deep reasoning
