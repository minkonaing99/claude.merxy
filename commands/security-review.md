# Security Review

Run a comprehensive security audit on the current project.

1. Detect project type and run appropriate audit tools:
   - Node.js: `npm audit --audit-level=moderate`
   - Python: `pip-audit` or `safety check`
   - Swift: check for insecure patterns
   - Java: `mvn dependency:tree` for known vulnerable versions
   - PHP: `composer audit`

2. Scan for hardcoded secrets:
   - Search for patterns: API keys, tokens, passwords, private keys
   - Check `.env` files are in `.gitignore`
   - Verify no secrets in git history (last 10 commits)

3. Check OWASP Top 10 in changed files:
   - SQL injection (string-concatenated queries)
   - XSS (unsanitized user input in HTML)
   - Broken authentication (weak session handling)
   - Sensitive data exposure (logging PII, missing encryption)
   - Broken access control (missing auth checks on routes)
   - Security misconfiguration (debug mode, default creds)
   - SSRF (user-controlled URLs in server requests)

4. Review input validation:
   - All API endpoints validate input
   - File upload restrictions in place
   - Rate limiting configured

5. Generate report with severity ratings:
   - CRITICAL: Fix before commit
   - HIGH: Fix before merge
   - MEDIUM: Fix within sprint
   - LOW: Track for later

Block the workflow if any CRITICAL issues are found.
