---
paths:
  - "**/*.php"
  - "**/composer.lock"
  - "**/composer.json"
---
# PHP Security

> Extends [common/security.md](../common/security.md) with PHP content.

## Input and Output

- Validate request input at framework boundary (`FormRequest`, Symfony Validator, or explicit DTO validation).
- Escape output in templates by default; raw HTML rendering is an exception that must be justified.
- Never trust query params, cookies, headers, or uploaded file metadata without validation.

## Database Safety

- Use prepared statements (`PDO`, Doctrine, Eloquent query builder) for all dynamic queries.
- Avoid string-building SQL in controllers/views.
- Scope ORM mass-assignment carefully; whitelist writable fields.

## Secrets and Dependencies

- Load secrets from environment variables or secret manager, never from committed config files.
- Run `composer audit` in CI; review new package maintainer trust before adding dependencies.
- Pin major versions deliberately; remove abandoned packages quickly.

## Auth and Session Safety

- Use `password_hash()` / `password_verify()` for password storage.
- Regenerate session identifiers after authentication + privilege changes.
- Enforce CSRF protection on state-changing web requests.

## Reference

See skill: `laravel-security` for Laravel security.
