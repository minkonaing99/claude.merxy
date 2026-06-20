---
paths:
  - "**/*.php"
  - "**/composer.json"
---
# PHP Coding Style

> Extends [common/coding-style.md](../common/coding-style.md) with PHP content.

## Standards

- Follow **PSR-12** formatting + naming.
- Prefer `declare(strict_types=1);` in app code.
- Use scalar type hints, return types, typed properties everywhere new code permits.

## Immutability

- Prefer immutable DTOs + value objects for data crossing service boundaries.
- Use `readonly` properties or immutable constructors for request/response payloads where possible.
- Keep arrays for simple maps; promote business-critical structures into explicit classes.

## Formatting

- Use **PHP-CS-Fixer** or **Laravel Pint** for formatting.
- Use **PHPStan** or **Psalm** for static analysis.
- Keep Composer scripts checked in so same commands run locally + CI.

## Imports

- Add `use` statements for all referenced classes, interfaces, traits.
- Avoid global namespace unless project prefers fully qualified names.

## Error Handling

- Throw exceptions for exceptional states; avoid returning `false`/`null` as hidden error channels in new code.
- Convert framework/request input into validated DTOs before domain logic.

## Reference

See skill: `backend-patterns` for service/repository layering.
