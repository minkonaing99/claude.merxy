# Dependency Audit

Check for outdated, vulnerable, and unused dependencies.

1. Detect package managers in the project:
   - `package.json` → npm/pnpm/yarn
   - `requirements.txt` / `pyproject.toml` → pip
   - `Package.swift` → SwiftPM
   - `Cargo.toml` → cargo
   - `composer.json` → composer
   - `Gemfile` → bundler
   - `go.mod` → go

2. For each detected ecosystem, run:
   - **Vulnerability scan**: `npm audit`, `pip-audit`, `cargo audit`, `composer audit`
   - **Outdated check**: `npm outdated`, `pip list --outdated`, `cargo outdated`
   - **Unused detection**: `npx depcheck` (Node.js), grep-based for others

3. Summarize findings in a table:

   **Vulnerabilities:**
   | Severity | Package | Current | Fixed In | CVE |

   **Outdated:**
   | Package | Current | Latest | Update Type (major/minor/patch) |

   **Unused:**
   | Package | Notes |

4. Suggest update commands (do NOT run them automatically):
   - Group safe updates (patch/minor) into one command
   - List major updates separately with changelog links

5. Flag any packages with restrictive or incompatible licenses.
