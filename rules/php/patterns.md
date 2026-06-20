---
paths:
  - "**/*.php"
  - "**/composer.json"
---
# PHP Patterns

> Extends [common/patterns.md](../common/patterns.md) with PHP content.

## Thin Controllers, Explicit Services

- Keep controllers on transport: auth, validation, serialization, status codes.
- Move business rules into application/domain services, testable without HTTP bootstrapping.

## DTOs and Value Objects

- Replace shape-heavy associative arrays with DTOs for requests, commands, external API payloads.
- Use value objects for money, identifiers, date ranges, other constrained concepts.

## Dependency Injection

- Depend on interfaces or narrow service contracts, not framework globals.
- Pass collaborators through constructors so services testable without service-locator lookups.

## Boundaries

- Isolate ORM models from domain decisions when model layer does more than persistence.
- Wrap third-party SDKs behind small adapters so codebase depends on your contract, not theirs.

## Reference

See skill: `api-design` for endpoint conventions + response shape.
See skill: `laravel-patterns` for Laravel architecture.
