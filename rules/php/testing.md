---
paths:
  - "**/*.php"
  - "**/phpunit.xml"
  - "**/phpunit.xml.dist"
  - "**/composer.json"
---
# PHP Testing

> Extends [common/testing.md](../common/testing.md) with PHP content.

## Framework

Use **PHPUnit** as default test framework. If **Pest** configured, prefer Pest for new tests; avoid mixing frameworks.

## Coverage

```bash
vendor/bin/phpunit --coverage-text
# or
vendor/bin/pest --coverage
```

Prefer **pcov** or **Xdebug** in CI; keep coverage thresholds in CI, not tribal knowledge.

## Test Organization

- Separate fast unit tests from framework/database integration tests.
- Use factory/builders for fixtures, not large hand-written arrays.
- Keep HTTP/controller tests on transport + validation; move business rules into service-level tests.

## Inertia

If project uses Inertia.js, prefer `assertInertia` with `AssertableInertia` to verify component names + props, not raw JSON assertions.

## Reference

See skill: `tdd-workflow` for repo-wide RED -> GREEN -> REFACTOR loop.
See skill: `laravel-tdd` for Laravel testing (PHPUnit + Pest).
