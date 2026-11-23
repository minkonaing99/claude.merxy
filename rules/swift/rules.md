# Swift / SwiftUI Rules

Source: bama `swift-swiftui` skill (installed) + Swift 6 language guide.
For macOS app design and flow, load the `bama:*` skills on demand.

## Baseline
- Swift 6 language mode. Zero warnings is the bar.
- Fix the first compiler error first; later ones often follow from it.

## Concurrency
- Main-actor default isolation for app targets. UI, views, view models stay on the main actor.
- CPU-heavy pure work: `nonisolated` func marked `@concurrent`.
- Shared mutable state off the main thread: an `actor`.
- Data crossing actors is `Sendable`: structs/enums of Sendable values or `final class` with only `let`.
- `Task {}` inherits the actor; `Task.detached` only when it must not.
- Fix data-race errors at the type. `@unchecked Sendable` / `nonisolated(unsafe)` only as last resort, with a comment.
- Closures passed to Dispatch, CoreAudio, AVPlayer observers from a `@MainActor` type: write `{ @Sendable in ... }` or the app crashes at runtime.
- C callbacks: `nonisolated static func` that hops back with `Task { @MainActor in ... }`.

## State
- `@Observable` classes for models. `@State` in the owning view, `@Bindable` to bind, `.environment(model)` to share.
- `@ObservationIgnored` on caches, timers, handles.
- `@State` for view-local values, `@AppStorage` for small prefs, Keychain for secrets.
- `ForEach(items)`, never `ForEach($items)` for deletable data. Look up bindings by id.

## SwiftData
- `@Model`, `.modelContainer` on the scene, `@Query` in views, `@Environment(\.modelContext)` to write.
- Every new property has a default value so old stores still open.
- Own `uid: UUID` per model; `persistentModelID` changes on first save.
- Register undo manually; automatic undo is unreliable.
- Need SQL, a CLI, or multi-process access? SQLite with WAL instead.

## Naming
- Never name types `Task`, `View`, `Color`, `Image`, `Text`, `Section`, `Label`, `Menu`, `Group`, `Settings`.
- Swift API Design Guidelines: clarity at call site, `lowerCamelCase` members, `UpperCamelCase` types, booleans read as assertions (`isEmpty`).

## Code style
- `let` over `var`. Value types (struct/enum) by default; `final class` when reference semantics needed.
- No force unwrap `!` or `try!` outside tests. Use `guard let` / `if let` / `??`.
- Typed errors with `enum ... : Error`; `throws` over optional returns when failure has a reason.
- Split big view bodies into subviews when the type checker struggles.
- Access control: `private` by default, widen only when needed.

## AppKit bridges (macOS)
- Non-activating floating panels: `NSPanel` + `.nonactivatingPanel` hosting SwiftUI.
- Custom text: `NSViewRepresentable` around `NSTextView`.
- Event monitors: remove when the view goes away.
- No Delete, Return or arrow keys as menu shortcuts; use `.onDeleteCommand` / `.onKeyPress`.

## Security
- Secrets in Keychain only. Never in UserDefaults, plist or source.
- Validate all external input (files, URLs, network JSON) with `Codable` + checks.
- ATS on; HTTPS only.

## Testing
- Swift Testing (`@Test`, `#expect`) for new tests; XCTest only where already used.
- Tests never touch real user data: store path override via env.
