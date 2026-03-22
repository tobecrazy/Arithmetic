# Repository Guidelines

## Project Structure & Module Organization
`App/ArithmeticApp.swift` is the entry point. UI screens live in `Views/`, with reusable pieces under `Views/Components/`. State and game flow belong in `ViewModels/`, core domain types in `Models/`, persistence in `CoreData/`, and shared helpers in `Utils/` and `Extensions/`. Localized strings are stored in `Resources/en.lproj` and `Resources/zh-Hans.lproj`. Images, colors, and app icons live in `Assets.xcassets`. Tests are in `Tests/`, and automation helpers live in `scripts/`.

## Build, Test, and Development Commands
`open Arithmetic.xcodeproj` opens the project in Xcode.

`xcodebuild -project Arithmetic.xcodeproj -scheme Arithmetic -destination 'platform=iOS Simulator,name=Any iOS Simulator Device' build` builds the app from the command line.

`./scripts/quick_test.sh` runs the fast `ArithmeticTests` pass for day-to-day feedback.

`./scripts/run_all_tests.sh --skip-ui` runs build, unit tests, localization checks, and static analysis without the slower UI pass.

`./scripts/check_localizations.sh` verifies that English and Simplified Chinese localization keys stay in sync.

## Coding Style & Naming Conventions
Follow the existing SwiftUI + MVVM structure. Use 4-space indentation, `PascalCase` for types, and `camelCase` for properties and functions. Keep filenames aligned with the main type, for example `GameViewModel.swift` or `Color+Theme.swift`. Use `// MARK:` to organize longer files. No `SwiftLint` or `SwiftFormat` config is committed, so match current Xcode formatting and keep comments short and useful.

## Testing Guidelines
Use `XCTest` in `Tests/` and name methods with the `test...` pattern. Add or update tests when changing question generation, persistence, localization, or game flow. If you add user-facing strings, update both `Localizable.strings` files and run `./scripts/check_localizations.sh`. For UI-heavy changes, verify the affected flow in the simulator even if the main automated pass is unit-test focused.

## Commit & Pull Request Guidelines
Recent commits use short, imperative subjects such as `Add Level 7 fraction display & TTS update`, `Fix mixed language issue in fraction question audio (TTS)`, and `Update Package.resolved`. Keep commits focused and descriptive. Pull requests should include a short summary, testing evidence, linked issues when relevant, and screenshots or GIFs for UI changes. Call out localization and Firebase configuration changes explicitly.
