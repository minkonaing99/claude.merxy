# Lint and Fix

Run project linters and auto-fix what's possible.

1. Detect linting tools in the project:

   | Config File | Linter | Fix Command |
   |-------------|--------|-------------|
   | `.eslintrc*` / `eslint.config.*` | ESLint | `npx eslint . --fix` |
   | `prettier` in package.json / `.prettierrc*` | Prettier | `npx prettier --write .` |
   | `.swiftlint.yml` | SwiftLint | `swiftlint lint --fix` |
   | `pyproject.toml` with `[tool.ruff]` | Ruff | `ruff check --fix .` |
   | `setup.cfg` / `.flake8` | Flake8 | `flake8 .` (no auto-fix) |
   | `.rubocop.yml` | RuboCop | `rubocop -a` |
   | `clippy` (Rust) | Clippy | `cargo clippy --fix` |
   | `checkstyle` (Java) | Checkstyle | report only |

2. Run the auto-fix command for each detected linter.

3. Run the linter again in check mode to find remaining issues.

4. For unfixable issues, report:
   | File | Line | Rule | Message | Severity |

5. Suggest fixes for the top issues that couldn't be auto-fixed.

Only modify files — never change linter configuration unless explicitly asked.
