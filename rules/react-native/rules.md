# React Native / Expo Rules

Sources: expo/skills (official), vercel-labs react-native-skills, callstackincubator react-native-best-practices.
React rules in `rules/react/rules.md` also apply (re-renders, composition, security).

## Workflow
- Try Expo Go first. Custom dev build only for local native modules, Apple targets, native libs missing from Expo Go, or config `app.json` can't express.
- Performance work: measure, optimize, re-measure, validate. No improvement? Revert.
- Check library versions before suggesting version-specific APIs (e.g. FlashList v2 drops `estimatedItemSize`).
- Don't flag `useMemo`/`useCallback` deps or stale closures without a repro or profiler evidence.

## Project structure
- App code under `src/`. `src/app/` is routes-only.
- Reusable UI in `src/components/`, one named export per file.
- Large screen bodies in `src/screens/<name>/`, private parts in `screens/<name>/components/`.
- API routes in `src/app/api/*+api.ts`; server helpers in `src/server/`.
- kebab-case file names. Path aliases (`@/...`) over deep relative imports.
- Platform differences: small = `Platform.select`; large = `file.tsx` + `file.web.tsx` with identical props.

## Library choices
- Check `@expo/ui` first for sheets, pickers, sliders, switches, menus, segmented controls.
- `expo-image`, not `Image`/`img`. `expo-audio` / `expo-video`, not `expo-av`.
- `react-native-safe-area-context`, never RN `SafeAreaView`.
- `expo-symbols` for SF Symbols on iOS (Material fallback on Android).
- `expo/fetch` over axios. TanStack Query for server state.
- `process.env.EXPO_OS` over `Platform.OS`. `React.use` over `useContext`.
- SDK 56+: import navigation from `expo-router/react-navigation`, not `@react-navigation/*`.
- Never use removed core modules (Picker, WebView, AsyncStorage from `react-native`) or `expo-permissions`.

## Lists (CRITICAL)
- Never map long data inside ScrollView. Use FlashList / FlatList / Legend List.
- Memoize item components. Stable callbacks; no inline objects or functions in items.
- Move expensive work out of items. Use item types for mixed lists.
- Screen whose root is a list: no outer ScrollView.

## Layout
- `contentInsetAdjustmentBehavior="automatic"` on ScrollView/FlatList instead of SafeAreaView.
- Flexbox and `useWindowDimensions`, never `Dimensions.get()`.
- `onLayout` over `measure()`. `StyleSheet.create` or NativeWind.
- All text inside `<Text>`. No `&&` with possibly falsy values (crashes on `0`).

## Navigation
- Native stack and native tabs over JS navigators. Native modals and context menus where possible.
- Preload expensive screens before navigating.

## Animation
- Reanimated worklets on UI thread. Animate only `transform` and `opacity`.
- `useDerivedValue` for computed animation values. Gesture Handler `Gesture.Tap` for animated presses.
- Otherwise `Pressable`, never `TouchableOpacity`.

## Data screens
- Every data screen designs four states: loading, error, empty, content.
- Loading is not empty. Keep stale content on refetch error with non-blocking retry.
- Gate root layout on hydrated auth/onboarding state.
- Pending mutation disables resubmit; failure keeps the draft.

## State and re-renders
- Minimize subscriptions. Atomic stores (Zustand/Jotai) when profiling shows broad context updates.
- React Compiler for auto-memoization; destructure functions, handle Reanimated shared values per compiler rules.
- Uncontrolled `TextInput` when typing lags.

## Bundle and startup
- No barrel imports. Hoist `Intl` objects.
- Remove Intl polyfills only after checking Hermes coverage.
- Android: enable R8. RN <= 0.78: disable JS bundle compression for Hermes mmap.
- Native deps live in the app package in monorepos; single version per dep.
- Measure TTI on cold start only.

## Native
- Heavy native work off main thread. Async Turbo Module methods over sync.
- Check 16KB page alignment of native libs for Google Play.

## Android (primary target)
- Test every change on Android first: physical mid-range device or emulator, release build for perf checks.
- Release builds: `minifyEnabled true` + `shrinkResources true` (R8). Add keep rules for reflection-based libs; obfuscation is not a security boundary.
- Ship AAB. Google Play (Android 15+) needs 16 KB page alignment: `zipalign -c -P 16 -v 4 app-release.apk` before release, fail CI on mismatch.
- Handle the system back button and predictive back; edge-to-edge insets via safe-area-context.
- Request runtime permissions at point of use, explain why, handle denial.
- Remote push in Expo needs a dev build on Android (not Expo Go, SDK 53+).
- Configure via `app.json` / config plugins; never hand-edit `android/` in a managed (CNG) project.
- Keystore and signing creds via EAS credentials or CI secrets, never committed.

## Security
- Secrets in `expo-secure-store`, never AsyncStorage or `EXPO_PUBLIC_*`.
- Remote code chunks only from HTTPS origins you control, pinned to app version.
- Pin dependency versions; review before running third-party scripts.

## Testing
- Jest + React Native Testing Library; query by role/text.
- Maestro or Detox for critical flows.
