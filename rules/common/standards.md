# Code Standards

## Style
- Immutable always - new copies, never mutate
- Files: 200-400 lines typical, 800 max. Functions: <50 lines
- Organize by feature/domain, not type
- Validate all input at system boundaries
- Handle errors explicitly - never swallow silently

## Security
Before commits: no hardcoded secrets, parameterized queries, sanitized HTML, auth verified, error messages don't leak data. Use **security-reviewer** agent. If issue found: stop, fix CRITICAL first, rotate exposed secrets.

## Testing
TDD mandatory: RED -> GREEN -> REFACTOR. 80%+ coverage. Unit + integration + E2E. Use **tdd-guide** agent proactively. Fix implementation, not tests (unless tests wrong).
