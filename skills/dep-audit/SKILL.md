---
name: dep-audit
description: Audit project dependencies for vulnerabilities, outdated packages, unused deps, and license risks. Runs language-appropriate scanners and produces a prioritized remediation plan. Use monthly, before releases, or after adding new dependencies.
user-invocable: true
argument-hint: "[--fix] [--unused] [--licenses]"
---

Audit all project dependencies. Produce a prioritized report of vulnerabilities, outdated packages, and optionally unused deps and license issues.

## Step 1: Detect Project Type

Check for: `package.json`, `requirements.txt`/`pyproject.toml`, `Podfile`/`Package.swift`, `pom.xml`/`build.gradle`, `composer.json`.

Handle monorepos by scanning each sub-project.

## Step 2: Vulnerability Scan

Run the appropriate scanner(s):

**Node.js / npm:**
```bash
npm audit --json 2>/dev/null
```

**Node.js / yarn:**
```bash
yarn audit --json 2>/dev/null
```

**Python:**
```bash
pip-audit --format=json 2>/dev/null || \
safety check --json 2>/dev/null
```

**PHP:**
```bash
composer audit 2>/dev/null
```

**Java (Maven):**
```bash
./mvnw org.owasp:dependency-check-maven:check 2>/dev/null
```

**Java (Gradle):**
```bash
./gradlew dependencyCheckAnalyze 2>/dev/null
```

**Swift (SPM):**
Manually check Package.resolved entries against known advisories.

## Step 3: Outdated Packages

**Node.js:**
```bash
npm outdated --json 2>/dev/null
```

**Python:**
```bash
pip list --outdated --format=json 2>/dev/null
```

**PHP:**
```bash
composer outdated --format=json 2>/dev/null
```

**Java:**
```bash
./mvnw versions:display-dependency-updates 2>/dev/null
```

## Step 4: Unused Dependencies (if `--unused` flag)

**Node.js:**
```bash
npx depcheck 2>/dev/null || npx knip 2>/dev/null
```

**Python:**
```bash
pip-autoremove --list 2>/dev/null
```

Report packages that are declared but never imported/used.

## Step 5: License Check (if `--licenses` flag)

**Node.js:**
```bash
npx license-checker --summary 2>/dev/null
```

Flag: GPL/AGPL (copyleft) in commercial projects, unknown licenses, deprecated packages.

## Step 6: Remediation Plan

If `--fix` is passed, apply safe fixes:
- `npm audit fix` for Node.js (non-breaking only)
- Update patch versions that have no breaking changes

For breaking updates, list the changes needed without auto-applying.

## Output Format

```
## Dependency Audit Report
**Date:** <today>
**Project:** <name> (<language/package manager>)

### Vulnerabilities
| Package | Current | Fixed In | Severity | CVE | Action |
|---------|---------|----------|----------|-----|--------|
| lodash  | 4.17.19 | 4.17.21  | HIGH     | CVE-2021-23337 | npm audit fix |

**Summary:** X critical, X high, X moderate, X low

### Outdated Packages (top 10 by severity/age)
| Package | Current | Latest | Type | Breaking? |
|---------|---------|--------|------|-----------|
| react   | 18.2.0  | 19.0.0 | major | Yes |

### Unused Dependencies (if requested)
- package-name: declared in package.json, never imported

### License Issues (if requested)
- package-name: GPL-3.0 — review required for commercial use

### Recommended Actions
1. [IMMEDIATE] Fix critical CVEs: `npm audit fix`
2. [THIS SPRINT] Update: package@version (patch, safe)
3. [PLANNED] Major upgrades: react 18→19 (use migration-guide agent)
4. [REMOVE] Unused: package-name
```
