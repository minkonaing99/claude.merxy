# TypeScript / JavaScript Rules

Sources: tsconfig/bases (`strictest`, `node24`, `next`, `react-native`), typescript-eslint `strict-type-checked` + `stylistic-type-checked` flat configs.
Applies to all TS/JS. React code also follows `rules/react/rules.md`.

## Compiler
- New projects extend a base: `@tsconfig/strictest` plus the platform base (`@tsconfig/node24`, `@tsconfig/next`, `@tsconfig/react-native`).
- Strictest flags: `strict`, `exactOptionalPropertyTypes`, `noUncheckedIndexedAccess`, `noPropertyAccessFromIndexSignature`, `noImplicitReturns`, `noImplicitOverride`, `noFallthroughCasesInSwitch`, `noUnusedLocals`, `noUnusedParameters`, `allowUnreachableCode: false`, `allowUnusedLabels: false`, `isolatedModules`.
- Node 24: `module: nodenext`, `moduleResolution: node16`, `target: es2024`, `types: ["node"]`.
- Next.js: `module: esnext`, `moduleResolution: bundler`, `jsx: preserve`, `noEmit`, `plugins: [{ name: "next" }]`.
- Existing projects: keep their tsconfig; don't add strictest flags unless asked.
- ESM for new Node code. `import type` for type-only imports.
- Code passes `tsc --noEmit` and ESLint with zero warnings.

## Lint (typescript-eslint)
- Config: `tseslint.configs.strictTypeChecked` + `stylisticTypeChecked`, with `parserOptions.projectService: true`.
- Key rules it enforces, so write code that passes them:
  - no `any`; no `no-unsafe-*` (assignment, call, member-access, return, argument) leaks from `any`.
  - no floating or misused promises; `await` only thenables; `require-await`; `return-await` in try/catch.
  - no non-null `!`; no unnecessary conditions, type assertions or type arguments.
  - `only-throw-error`, `prefer-promise-reject-errors`, `use-unknown-in-catch-callback-variable`.
  - `restrict-template-expressions`, `restrict-plus-operands`, `no-base-to-string`.
  - `no-deprecated`, `no-dynamic-delete`, `no-extraneous-class`, `no-namespace`, `no-require-imports`, `unbound-method`.
  - `ban-ts-comment`: `@ts-expect-error` only with a description; never `@ts-ignore`.
  - stylistic: `prefer-nullish-coalescing`, `prefer-optional-chain`, `consistent-type-definitions`, `consistent-type-assertions`, `array-type`, `prefer-includes`, `prefer-find`, `prefer-for-of`.

## Types
- No `any`. Use `unknown` and narrow. No `as` casts except at proven boundaries, with a comment.
- No non-null `!`. Handle the null case.
- Infer local types; annotate exported function params and return types.
- `type` for unions/aliases, `interface` for object shapes meant to be extended. Pick one per project and stay consistent.
- Model states as discriminated unions (`{ status: "ok"; data } | { status: "error"; error }`), not optional-field bags.
- Exhaustive `switch` with a `never` check in `default`.
- `as const` objects or union literals over `enum`.
- `readonly` props and `ReadonlyArray<T>` for data you don't change.
- `satisfies` to check a value's shape without widening it.

## Runtime safety
- Validate all external input (HTTP bodies, env, JSON, files, URL params) with zod / valibot at the boundary. Infer types from the schema.
- Parse env once at startup into a typed config object. Fail fast if missing.
- `===` only. `??` over `||` for defaults. Optional chaining for maybe-missing values.

## Async
- Never leave a promise floating: `await`, return, or `void` with a reason.
- `Promise.all` for independent work; `Promise.allSettled` when partial failure is OK.
- `async` functions only when they `await`. No `await` inside loops for independent work.
- `AbortController` for cancellable fetch/timeouts.

## Errors
- Throw `Error` subclasses, never strings. Catch as `unknown`, narrow before use.
- Don't swallow errors. Log with context or rethrow.
- Expected failures in domain logic: return a result union instead of throwing.

## Immutability and style
- `const` by default. Never mutate args; spread, `toSorted()`, `toSpliced()`, `structuredClone`.
- Named exports. No default exports except where a framework requires them (Next.js pages).
- No barrel files in apps. Small modules, one concern each.
- Pure functions for logic; side effects at the edges.
- `Map`/`Set` for lookups. Early returns over nested `if`.

## Node / backend
- RESTful routes, OpenAPI spec in `docs/api.md` or generated.
- Parameterized queries only (see `rules/sql/rules.md`). Never string-built SQL.
- Hash passwords with argon2id or bcrypt. Secrets from env, never in code or logs.
- Set timeouts on every outbound request. Rate limit public endpoints.
- `node:` prefix for built-ins (`node:fs/promises`).

## Tooling
- Package manager: whatever the lockfile says. New projects: pnpm.
- Prettier or Biome for format.
- `npm audit` / `pnpm audit` before release. Pin exact versions for apps.

## Testing
- Vitest (or the project's runner). 80%+ coverage.
- Test public behavior; no testing private functions.
- Mock at network/boundary (msw), not internal modules.
