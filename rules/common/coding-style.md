# Coding Style

## Immutability (CRITICAL)

New objects, NEVER mutate. Return new copies, never modify in-place. Prevents hidden side effects, enables safe concurrency.

## File Organization

MANY SMALL FILES > FEW LARGE FILES:
- High cohesion, low coupling
- 200-400 lines typical, 800 max
- Extract utilities from big modules
- Organize by feature/domain, not type

## Error Handling

Handle errors comprehensive:
- Explicit at every level
- User-friendly messages in UI code
- Log detailed context server-side
- Never silently swallow

## Input Validation

Validate at system boundaries:
- Validate all user input before processing
- Schema-based validation where available
- Fail fast, clear messages
- Never trust external data (API responses, user input, file content)

## Code Quality Checklist

Before marking complete:
- [ ] Readable, well-named
- [ ] Functions small (<50 lines)
- [ ] Files focused (<800 lines)
- [ ] No deep nesting (>4 levels)
- [ ] Proper error handling
- [ ] No hardcoded values (use constants/config)
- [ ] No mutation (immutable patterns)
