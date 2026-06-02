---
name: test-coverage
description: Analyze test coverage gaps in the current project and generate missing tests to reach 80%+ coverage. Identifies untested functions, branches, and edge cases. Use after implementing features, before releases, or when coverage drops below threshold.
user-invocable: true
argument-hint: "[target: file or directory path] [--threshold 80]"
---

Analyze test coverage and generate missing tests to reach the 80% minimum threshold required by project standards.

## Step 1: Run Coverage

Detect the project type and run the appropriate coverage tool:

**TypeScript/JavaScript:**
```bash
npx jest --coverage --coverageReporters=json-summary 2>/dev/null || \
npx vitest run --coverage 2>/dev/null
```

**Python:**
```bash
python -m pytest --cov=. --cov-report=term-missing 2>/dev/null
```

**Swift:**
```bash
xcodebuild test -scheme <scheme> -enableCodeCoverage YES 2>/dev/null
```

**Java:**
```bash
./mvnw test jacoco:report 2>/dev/null || \
./gradlew test jacocoTestReport 2>/dev/null
```

**PHP:**
```bash
./vendor/bin/phpunit --coverage-text 2>/dev/null
```

If no test runner is configured, analyze the codebase statically to identify untested code.

## Step 2: Identify Gaps

Parse coverage output and identify:

1. **Uncovered files** — files with 0% coverage
2. **Uncovered functions** — functions never called by tests
3. **Uncovered branches** — conditional paths never exercised (if/else, switch, ternary)
4. **Uncovered error paths** — catch blocks, error handlers, validation failures never triggered

Prioritize by impact:
- **P1**: Business logic, auth, data validation, payment flows
- **P2**: API handlers, service layer, utilities with side effects
- **P3**: Pure utilities, helpers, formatters

## Step 3: Generate Missing Tests

For each gap, write tests following the project's existing test conventions (framework, file naming, structure).

### Test Requirements

Each generated test must:
- Follow RED → GREEN pattern (test the behavior, not the implementation)
- Cover the happy path AND at least one error/edge case
- Use the project's existing mocks/fixtures pattern
- Be placed in the correct test file location (co-located or `__tests__/` or `tests/` depending on project)
- Have a descriptive name: `describe('functionName') > it('should do X when Y')`

### Edge Cases to Always Cover

- Null/undefined/empty inputs
- Boundary values (0, -1, max int, empty string, empty array)
- Async error cases (rejected promises, thrown errors)
- Authorization failures (if function has auth checks)
- Concurrent/duplicate call behavior (if relevant)

## Step 4: Verify Coverage Improved

After writing tests, re-run coverage and confirm:
- Overall coverage ≥ 80%
- No new regressions introduced
- All new tests pass

## Output Format

```
## Test Coverage Report
**Before:** X% (X/X lines, X/X branches)
**Target:** 80%

### Gaps Found
- src/auth/login.ts: 42% — missing: error path when DB unavailable, rate limit exceeded
- src/utils/validate.ts: 0% — no tests at all

### Tests Written
- [FILE] test description → what it covers
- ...

### After Coverage
**After:** X% (+X%)
**Status:** PASS / NEEDS MORE WORK
```
