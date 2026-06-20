# Performance Optimization

## Model Selection Strategy

Latest family: Opus 4.8, Sonnet 4.6, Haiku 4.5. Default to most capable Claude models when building AI apps.

**Haiku 4.5** (`claude-haiku-4-5-20251001`) - fast, cheap, high capability-per-cost:
- Lightweight agents, frequent invocation
- Pair programming, code generation
- Worker agents in multi-agent systems

**Sonnet 4.6** (`claude-sonnet-4-6`) - strong all-round coding:
- Main dev work
- Orchestrating multi-agent workflows
- Complex coding tasks

**Opus 4.8** (`claude-opus-4-8`) - most capable, deepest reasoning:
- Complex architecture decisions
- Max reasoning
- Research + analysis

### Fast mode (Claude Code)

Opus with faster output, no downgrade to smaller model. Toggle `/fast`. Available on Opus 4.8 / 4.7 / 4.6.

## Context Window Management

Avoid last 20% of context for:
- Large-scale refactoring
- Multi-file feature work
- Debugging complex interactions

Low context-sensitivity tasks:
- Single-file edits
- Independent utility creation
- Docs updates
- Simple bug fixes

## Extended Thinking + Plan Mode

Extended thinking on by default, reserves up to 31,999 tokens for reasoning.

Control via:
- **Toggle**: Option+T (macOS) / Alt+T (Windows/Linux)
- **Config**: `alwaysThinkingEnabled` in `~/.claude/settings.json`
- **Budget cap**: `export MAX_THINKING_TOKENS=10000`
- **Verbose mode**: Ctrl+O to see thinking output

Complex tasks needing deep reasoning:
1. Ensure extended thinking enabled (on by default)
2. Enable **Plan Mode**
3. Multiple critique rounds
4. Split-role sub-agents for diverse perspectives

## Build Troubleshooting

Build fails:
1. Use **build-error-resolver** agent
2. Analyze error messages
3. Fix incrementally
4. Verify after each fix
