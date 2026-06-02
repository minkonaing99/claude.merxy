---
name: security-audit
description: Run a comprehensive security audit of the current codebase. Checks for hardcoded secrets, injection vulnerabilities, insecure dependencies, auth issues, and OWASP Top 10 risks across TypeScript, Python, Swift, Java, and PHP. Use when preparing for a release, after adding auth/payment features, or before any commit touching sensitive code paths.
user-invocable: true
argument-hint: "[scope: full|auth|deps|secrets] [path (optional)]"
---

Run a thorough security audit of the codebase. Cover all OWASP Top 10 categories relevant to the project's language stack.

## Scope

If an argument is provided, focus accordingly:
- `full` (default) — all categories below
- `auth` — authentication and authorization only
- `deps` — dependency vulnerabilities only
- `secrets` — hardcoded secrets and credential leaks only

If a path argument is provided, scope the audit to that directory/file.

## 1. Secret Scanning

Search for hardcoded secrets, tokens, and credentials:

- Scan for patterns: API keys, JWT secrets, passwords, private keys, connection strings
- Check: source files, config files, test fixtures, scripts
- Flag any file containing: `sk-`, `ghp_`, `Bearer `, `password =`, `secret =`, `api_key =`, `-----BEGIN`, base64-encoded strings that look like keys
- Check `.env` files are in `.gitignore`
- Verify secrets are loaded from environment variables, not hardcoded

**Report:** file path, line number, pattern matched, severity (CRITICAL if actual key format, HIGH otherwise)

## 2. Injection Vulnerabilities

### SQL Injection
- Find string-concatenated queries (non-parameterized)
- Flag: `"SELECT ... " + variable`, f-strings in queries, `%s % variable` in SQL
- Verify ORM usage is parameterized (no raw string interpolation in `.raw()`, `.query()`)

### Command Injection
- Find `exec()`, `shell_exec()`, `subprocess` calls with user-controlled input
- Flag unvalidated strings passed to shell commands

### XSS
- Find `innerHTML`, `dangerouslySetInnerHTML`, `document.write()` with unescaped user input
- Check template engines for unescaped output (`{!! !!}` in Blade, `| safe` in Jinja2)

## 3. Authentication & Authorization

- Check for missing auth middleware on sensitive routes
- Verify password storage uses bcrypt/argon2 (never MD5, SHA1, plain text)
- Check session management: regeneration after login, secure/httpOnly cookie flags
- Look for missing authorization checks (IDOR vulnerabilities)
- Verify JWT validation: algorithm check, expiry check, signature verification

## 4. Input Validation

- Check API endpoints and form handlers for missing validation at system boundaries
- Find direct use of user input in file paths (path traversal risk)
- Check for missing type/format validation on request bodies

## 5. Dependency Audit

Run available scanners based on project type:
- **Node.js**: `npm audit --json 2>/dev/null` — report HIGH and CRITICAL CVEs
- **Python**: `pip-audit 2>/dev/null || safety check 2>/dev/null` — report vulnerabilities
- **PHP**: `composer audit 2>/dev/null` — report vulnerabilities
- **Swift/iOS**: Check Package.resolved for known vulnerable versions

Report: package name, CVE ID, severity, fix version available.

## 6. Error Handling & Information Disclosure

- Find stack traces or internal paths exposed in API responses
- Check error handlers don't return raw exception messages to clients
- Verify debug mode / verbose logging is off in production config

## 7. CSRF & Security Headers

- Check state-changing endpoints have CSRF protection
- Verify security headers are configured: `Content-Security-Policy`, `X-Frame-Options`, `X-Content-Type-Options`, `Strict-Transport-Security`

## Output Format

Produce a structured report:

```
## Security Audit Report
**Date:** <today>
**Scope:** <scope>
**Project:** <detected language/framework>

### CRITICAL (must fix before commit)
- [FILE:LINE] Description — recommendation

### HIGH (fix before release)
- [FILE:LINE] Description — recommendation

### MEDIUM (fix soon)
- [FILE:LINE] Description — recommendation

### LOW / INFORMATIONAL
- [FILE:LINE] Description — recommendation

### Summary
- X critical, X high, X medium, X low issues found
- Dependency scan: X vulnerable packages
- Recommendation: [PASS / FAIL — do not commit until criticals resolved]
```

After reporting, use the **security-reviewer** agent to apply fixes for any CRITICAL issues found.
