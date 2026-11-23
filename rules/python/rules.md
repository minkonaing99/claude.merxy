# Python Rules

Source: trailofbits/skills modern-python (cookiecutter-python). Python >= 3.11.
Respect existing tooling if the project already uses something else and the user hasn't asked to migrate.

## Tooling
| Use | Not |
|-----|-----|
| `uv` | pip, virtualenv, pip-tools, pipx, pyenv, Poetry |
| `ruff` (lint + format) | flake8, black, isort, pyupgrade |
| `ty` | mypy, pyright |
| `pytest` + `pytest-cov` | unittest |
| `prek` | pre-commit |
| `pyproject.toml` / PEP 723 | requirements.txt, setup.py, setup.cfg |

## uv
- Add/remove deps with `uv add` / `uv remove`. Never hand-edit deps in pyproject.toml. Never `uv pip install`.
- Run everything with `uv run <cmd>`. Never activate a venv manually.
- Dev tools in `[dependency-groups]` (PEP 735), not `[project.optional-dependencies]`.
- One-off packages: `uv run --with <pkg>`.
- Commit `uv.lock`.

## Project layout
- Single-file script with deps: PEP 723 inline metadata, run with `uv run script.py`.
- App: `uv init`. Distributable package: `uv init --package` (src/ layout, `uv_build` backend).
- Makefile targets: `dev`, `lint`, `format`, `test`, `build`.

## Baseline pyproject.toml
```toml
[project]
requires-python = ">=3.11"

[dependency-groups]
dev = [{include-group = "lint"}, {include-group = "test"}, {include-group = "audit"}]
lint = ["ruff", "ty"]
test = ["pytest", "pytest-cov"]
audit = ["pip-audit"]

[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["ALL"]
ignore = ["D", "COM812", "ISC001"]

[tool.pytest]
addopts = ["--cov=<pkg>", "--cov-fail-under=80"]

[tool.ty.environment]
python-version = "3.11"

[tool.ty.terminal]
error-on-warning = true
```

## Code style
- Type-annotate all new public functions. Code must pass `ty check` with no warnings.
- Fix lint by changing code, not by adding `noqa` / ignore comments without a reason.
- Immutable by default: tuples, frozen dataclasses, return new objects.
- `pathlib` over `os.path`. f-strings. Context managers for resources.
- Specific exceptions; never bare `except:`.

## Quality gate before done
```bash
uv run ruff format --check && uv run ruff check && uv run ty check src/ && uv run pytest
```

## Security
- `detect-secrets` + `shellcheck` in pre-commit; `actionlint` + `zizmor` for GitHub workflows.
- `uv run pip-audit` in CI. Dependabot for updates.
- No secrets in code; read from env. Validate all external input (pydantic or equivalent).
- No `eval`/`exec`/`pickle` on untrusted data; no `shell=True` with user input; parameterized SQL only.

## Migration (only when asked)
- requirements.txt: `uv init --bare`, `uv add` each dep, delete requirements files and old venv.
- setup.py/cfg: move metadata to `[project]`, deps via `uv add`, delete old files.
- flake8/black/isort or mypy/pyright: `uv remove`, delete their config, add ruff/ty.
