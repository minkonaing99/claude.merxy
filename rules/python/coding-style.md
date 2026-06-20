---
paths:
  - "**/*.py"
  - "**/*.pyi"
---
# Python Coding Style

> Extends [common/coding-style.md](../common/coding-style.md) with Python content.

## Standards

- Follow **PEP 8** conventions
- Use **type annotations** on all function signatures

## Immutability

Prefer immutable data structures:

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class User:
    name: str
    email: str

from typing import NamedTuple

class Point(NamedTuple):
    x: float
    y: float
```

## Dependencies & Virtual Environment

- ALWAYS create a project-local `.venv` per project. Never install into system Python.
- Create + activate before installing:

```bash
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install <package>
```

- Pin installed deps to `requirements.txt`:

```bash
pip freeze > requirements.txt
```

- Add `.venv/` to `.gitignore`. Commit `requirements.txt`.

## Formatting

- **black** for code formatting
- **isort** for import sorting
- **ruff** for linting

## Reference

See skill: `python-patterns` for comprehensive Python idioms and patterns.
