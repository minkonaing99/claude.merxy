---
paths:
  - "**/*.py"
  - "**/*.pyi"
---
# Python Hooks

> Extends [common/hooks.md](../common/hooks.md) with Python content.

## PostToolUse Hooks

Configure in `~/.claude/settings.json`:

- **black/ruff**: Auto-format `.py` files after edit
- **mypy/pyright**: Run type checking after editing `.py` files

## Warnings

- Warn about `print()` statements in edited files (use `logging` module instead)
