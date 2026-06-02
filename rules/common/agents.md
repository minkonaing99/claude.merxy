# Agent Orchestration

Agent definitions live in `~/.claude/agents/`. Read agent files for full details — don't duplicate them here.

## Parallel Task Execution

ALWAYS use parallel Task execution for independent operations. Never run sequentially what can run concurrently.

## Multi-Perspective Analysis

For complex problems, use split role sub-agents:
- Factual reviewer
- Senior engineer
- Security expert
- Consistency reviewer
- Redundancy checker
