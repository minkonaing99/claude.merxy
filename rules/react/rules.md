# React / Next.js Rules

Source: vercel-labs/agent-skills (react-best-practices, composition-patterns).
Apply in priority order. Full detail: `react-best-practices` skill.

## 1. No waterfalls (CRITICAL)
- Independent async work: `Promise.all()`, never sequential awaits.
- Start promises early, await late. Move `await` into the branch that uses it.
- Check cheap sync conditions before awaiting remote values.
- Use `<Suspense>` boundaries to stream; don't block the whole page on one fetch.
- Server components: restructure so sibling fetches run in parallel.

## 2. Bundle size (CRITICAL)
- Import directly from source. No barrel files (`index.ts` re-exports).
- Heavy or rarely used components: `next/dynamic` / `React.lazy`.
- Load analytics, logging and third-party scripts after hydration.
- Load feature modules only when the feature activates. Preload on hover/focus.
- Keep import paths statically analyzable.

## 3. Server (HIGH)
- Authenticate and validate every server action like an API route.
- `React.cache()` for per-request dedup; LRU for cross-request caching.
- No module-level mutable state that holds request data.
- Pass only needed fields to client components. Don't serialize the same data twice.
- Hoist static I/O (fonts, logos) to module level. Use `after()` for non-blocking work.

## 4. Client data (MEDIUM-HIGH)
- Use SWR / TanStack Query for dedup and caching. No hand-rolled fetch-in-effect.
- Deduplicate global event listeners. Scroll/touch listeners `{ passive: true }`.
- Version and minimize anything stored in localStorage.

## 5. Re-renders (MEDIUM)
- Derive state during render. Never sync state with `useEffect`.
- Interaction logic goes in event handlers, not effects.
- Never define components inside components.
- Functional `setState` for updates based on previous state.
- Lazy init for expensive `useState`: `useState(() => compute())`.
- Primitive effect dependencies. Split hooks with independent deps.
- Subscribe to derived booleans, not whole objects. Don't subscribe to state only read in callbacks.
- `startTransition` / `useDeferredValue` for non-urgent updates.
- Refs for frequent transient values (mouse position, timers).
- With React Compiler on: skip manual `useMemo`/`useCallback`/`memo`. Without it: memo only measured hot spots, never trivial expressions.

## 6. Rendering (MEDIUM)
- Conditional render with ternary, not `&&` when the left side can be `0` or `''`.
- Hoist static JSX out of components.
- `content-visibility: auto` for long lists; animate a wrapper div, not the SVG.
- Use `<Activity>` for show/hide that keeps state. `useTransition` for loading state.
- Avoid hydration flicker with an inline script for client-only values.

## 7. Component design
- No boolean prop proliferation (`isCompact`, `showX`, `hasY`). Use composition or explicit variant components.
- Complex components: compound components sharing context (`<Card.Header>`).
- Provider owns state; consumers see a `{ state, actions, meta }` interface.
- Lift state into a provider when siblings need it.
- Prefer `children` over `renderX` props.
- React 19+: no `forwardRef` (ref is a prop); `use(Context)` over `useContext`.

## 8. JS performance (LOW, apply when it's free)
- `Map`/`Set` for repeated lookups. Early returns.
- `toSorted()` / `toReversed()` / spread; never mutate props or state.
- Hoist RegExp out of loops. `flatMap` over `filter().map()` on hot paths.

## Security
- Never put secrets in client components or `NEXT_PUBLIC_*` vars.
- Validate all input on the server (zod or equivalent). Never trust client data.
- No `dangerouslySetInnerHTML` with untrusted content.

## Testing
- Vitest/Jest + React Testing Library. Query by role/label, not test IDs or classnames.
- Test behavior the user sees, not implementation.
- Playwright for critical flows.
