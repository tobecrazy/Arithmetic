# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Arithmetic is an iOS math quiz app designed for children to practice arithmetic operations with increasing difficulty levels. The app features text-to-speech support, adaptive learning through wrong question tracking, and a comprehensive multi-language system.

## Development Commands

### Build and Test
```bash
# Open project in Xcode
open Arithmetic.xcodeproj

# Build from command line
xcodebuild -project Arithmetic.xcodeproj -scheme Arithmetic build

# Build and run in simulator
xcodebuild -project Arithmetic.xcodeproj -scheme Arithmetic -destination 'platform=iOS Simulator,name=iPhone 15' build

# Run all tests (requires test target setup - see TESTING_INSTRUCTIONS.md)
xcodebuild test -project Arithmetic.xcodeproj -scheme Arithmetic -destination 'platform=iOS Simulator,name=iPhone 15'

# Run single test class
xcodebuild test -project Arithmetic.xcodeproj -scheme Arithmetic -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing ArithmeticTests/QuestionGeneratorTests

# Run specific test method
xcodebuild test -project Arithmetic.xcodeproj -scheme Arithmetic -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing ArithmeticTests/QuestionGeneratorTests/testGenerateNonRepetitiveQuestions

# Clean build
xcodebuild clean -project Arithmetic.xcodeproj -scheme Arithmetic

# Run static analyzer
xcodebuild analyze -project Arithmetic.xcodeproj -scheme Arithmetic

# Generate build logs with verbose output
xcodebuild -project Arithmetic.xcodeproj -scheme Arithmetic build -verbose
```

### Localization Checks
```bash
# Check consistency between Chinese and English localization files and embed Git info
./scripts/check_localizations.sh
```
**Note**: This script validates that both `en.lproj` and `zh-Hans.lproj` contain identical keys, and also embeds Git commit information into the app bundle.

### Code Review
Use the **swift-code-reviewer agent** after writing or modifying Swift code. Launch it with:
```bash
Task: swift-code-reviewer (use this for Swift/SwiftUI code reviews)
```

**When to use the swift-code-reviewer agent:**
- After implementing new SwiftUI views or ViewModels
- Before committing changes to core logic (GameViewModel, question generation)
- When refactoring to ensure patterns align with project standards
- For critical business logic (division operations, CoreData access, state management)

**Review focuses on:**
- Swift naming conventions and API design guidelines
- SwiftUI state management (`@State`, `@StateObject`, `@ObservedObject`)
- CoreData integration using `CoreDataManager.shared` singleton
- Mathematical correctness (especially division operations)
- Memory management (weak self in closures, retain cycles)
- Localization using `String+Localized` extension

## Development Environment Setup

### Prerequisites
- **macOS**: 12.0+ (Monterey or later)
- **Xcode**: 13.0+ (with Swift 5.5+)
- **iOS Deployment Target**: 15.0+
- **Git**: For version control

### Initial Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/tobecrazy/Arithmetic.git
   cd Arithmetic
   ```
2. Open the project in Xcode:
   ```bash
   open Arithmetic.xcodeproj
   ```
3. Select target device (iPhone or iPad simulator, or physical device)
4. Build the project (Cmd+B)
5. Set up test target if needed (see TESTING_INSTRUCTIONS.md)

### Important Configuration Notes
- **Localization**: Project supports Chinese (Simplified) and English
- **CoreData**: Model is created programmatically with automatic migration
- **SwiftUI**: Uses SwiftUI 3.0+ for all UI components
- **Assets**: AppIcon configured in AppIcon.appiconset folder

## Architecture Overview

### MVVM Pattern with Core Data Integration
The app follows the **Model-View-ViewModel (MVVM)** pattern with sophisticated CoreData integration. This architecture ensures clear separation of concerns, testability, and maintainability:

**Layer Responsibilities:**

- **Models**: `Question`, `GameState`, `DifficultyLevel` - Core data structures with complex solution methods
- **Views**: SwiftUI views in `/Views` directory (e.g., `GameView`, `WrongQuestionsView`, `MultiplicationTableView`)
- **ViewModels**: `GameViewModel` - Business logic and state management using Combine
- **CoreData**: Programmatically created model with automatic migration support
  - `CoreDataManager` - Singleton managing CoreData stack
  - `GameProgressManager` - Handles game save/load
  - `WrongQuestionManager` - Tracks incorrect answers for adaptive learning

### Question Generation System
- **Intelligent Generation**: `QuestionGenerator` creates math problems based on difficulty levels with integer-only results
- **Adaptive Learning**: Integrates wrong questions (30% of total) into new game sessions
- **Solution Methods**: 8 specialized pedagogical approaches:
  - Addition: 凑十法 (Making Ten Method)
  - Subtraction: 破十法 (Breaking Ten Method), 借十法 (Borrowing Ten Method), 平十法 (Leveling Ten Method)
  - Multiplication: 乘法口诀法 (Multiplication Table Method), 分解乘法 (Decomposition Multiplication)
  - Division: 除法验算法 (Division Verification), 分组除法 (Grouping Division)
- **Integer Guarantee**: All division operations produce whole numbers via "quotient × divisor = dividend" reverse generation

### Multi-language System
- **Dynamic Switching**: `LocalizationManager` handles runtime language switching with real-time UI updates via NotificationCenter
- **Localized Solutions**: Mathematical solution steps adapt to current language using `String+Localized` extension
- **TTS Integration**: Text-to-speech supports multiple languages via `TTSHelper` with intelligent operator conversion

### Key Services
- **TTSHelper**: Text-to-speech for reading math expressions with operator-to-word conversion
- **SystemInfoManager**: Real-time monitoring of device specs, performance, battery, and network
- **MathBankPDFGenerator**: Generates printable math problem banks with wrong question prioritization
- **ImageCacheManager**: Two-level caching (memory + disk) for UI assets
- **NavigationUtil**: Custom navigation management

## Critical Implementation Details

### Question Generation Algorithm
1. **Uniqueness**: Uses `Set<Question>` to ensure no duplicate questions
2. **Integer Division**: Reverse generation (`quotient × divisor = dividend`) ensures 100% divisibility
3. **Three-number Operations**: 40% in Level 2, 60% in Level 3, with proper precedence handling
4. **Wrong Question Integration**: 30% of questions sourced from wrong question collection

### Solution Method Selection
- **Context-aware**: Methods selected based on difficulty level and numerical characteristics
- **Level 2 Specialization**: Only applies 凑十法, 破十法, 借十法, 平十法 for 20以内加减法
- **Three-number Operations**: For Level 2, applies methods in two-step approach

### TTS System
- **Intelligent Conversion**: Mathematical operators converted to spoken words in both languages
- **Expression Formatting**: Uses `speakMathExpression(_:language:)` with proper sentence structure
- **Language Awareness**: Automatically switches pronunciation based on current language

### PDF Generation
- **Wrong Question Priority**: Prioritizes questions from wrong question collection
- **Bilingual Support**: Generated PDFs include both Chinese and English content
- **A4 Optimization**: Print-friendly layout with separate question/answer pages

## Critical Anti-Patterns to Avoid
1. **Division without validation**: All division must result in integers
   - ❌ `Bad`: Generating "9 ÷ 2" which results in 4.5
   - ✅ `Good`: Using reverse generation "quotient × divisor = dividend"
2. **Force unwrapping**: Use optional binding instead
   - ❌ `Bad`: `let value = optionalValue!`
   - ✅ `Good`: `guard let value = optionalValue else { return }`
3. **Hardcoded operand ranges**: Use `DifficultyLevel` properties
   - ❌ `Bad`: `if level == "hard" { maxNum = 100 }`
   - ✅ `Good`: `maxNum = difficulty.maxOperand`
4. **String literals for UI text**: Use localization extension
   - ❌ `Bad`: `Text("Score: \(score)")`
   - ✅ `Good`: `Text("score_label".localizedFormat(score))`
5. **Direct CoreData context usage**: Use singleton manager
   - ❌ `Bad`: `NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)`
   - ✅ `Good`: `CoreDataManager.shared.persistentContainer.viewContext`

### Singleton Pattern (Used for Shared Resources)
Applied to:
- `CoreDataManager` - Manages CoreData persistence stack
- `LocalizationManager` - Handles runtime language switching
- `ImageCacheManager` - Manages two-level image caching
- `TTSHelper` - Manages text-to-speech synthesis

Usage pattern:
```swift
class SomeManager {
    static let shared = SomeManager()
    private init() { }
}
```

### PEMDAS Compliance for Multi-Number Operations
For three-number operations, always respect precedence:
- Multiplication and Division before Addition and Subtraction
- Apply operations left-to-right within same precedence level
- Validate intermediate results are integers when division is involved

## Project Structure Insights

```
Arithmetic/
├── App/ArithmeticApp.swift              # App entry with CoreData context injection
├── Views/                               # 18+ SwiftUI views for all screens
├── ViewModels/GameViewModel.swift       # Central business logic controller
├── Models/                              # Question, GameState, DifficultyLevel
├── CoreData/                            # Complete persistence layer
├── Utils/                               # 10+ utility classes (generators, managers, helpers)
├── Extensions/                          # Swift extensions for localization, fonts, etc.
├── Resources/                           # Localization files (en.lproj, zh-Hans.lproj)
├── Tests/                               # Unit tests for all Utils classes
└── scripts/check_localizations.sh       # Localization consistency checker
```

## Common Development Tasks

### Adding New Features
1. **UI Components**: Add to `/Views/` with SwiftUI
   - Extract complex UI logic into separate, reusable views
   - Use `@State` for local state, `@StateObject` for owned view models
   - Follow project naming conventions (e.g., `SomeFeatureView.swift`)
2. **Business Logic**: Extend `GameViewModel` or create new ViewModel
   - Keep view models focused on single responsibility
   - Use `@Published` for observable properties
3. **Data Models**: Add to `/Models/` or extend CoreData entities
   - Ensure all models follow MVVM pattern
   - Add validation methods to models
4. **Utilities**: Add to `/Utils/` with comprehensive unit tests
   - Each utility should have corresponding unit tests
   - Follow singleton pattern for shared resources (see `CoreDataManager`, `LocalizationManager`)

### Modifying Question Logic
1. **Generation**: Modify `QuestionGenerator.swift` algorithms
   - Always verify questions pass `Question.isValid()` before returning
   - Test generation across all 6 difficulty levels
   - Ensure mathematical correctness (especially for division operations)
2. **Validation**: Update `Question.isValid()` for new constraints
   - Validate that division operations result in whole numbers
   - Check PEMDAS precedence for multi-number operations
3. **Solution Methods**: Add new methods to `Question.SolutionMethod` enum
   - Provide solution text for both Chinese and English
   - Ensure pedagogically sound approaches
4. **Difficulty Settings**: Update `DifficultyLevel` properties
   - Verify operand ranges are appropriate
   - Test with `supportedOperations` property

### Localization Updates
1. **Add Key**: Use `"key".localized` in code
2. **Translate**: Add to both language files (`en.lproj` and `zh-Hans.lproj`)
3. **Verify**: Run `./scripts/check_localizations.sh` to check consistency
4. **Test**: Verify in both language modes by changing language in Settings
5. **Format Strings**: Use `"key".localizedFormat(...)` for variables

### Testing
1. **Unit Tests**: Follow patterns in `/Tests/` directory
   - Add tests for new utilities in `/Tests/`
   - Use XCTest framework following existing test patterns
2. **Question Generation**: Test with `QuestionGeneratorTests.swift`
   - Verify uniqueness across multiple generations
   - Test all 6 difficulty levels
   - Validate mathematical correctness
3. **CoreData**: Test persistence across different scenarios
   - Test migration between model versions
   - Verify CRUD operations work correctly
4. **UI Testing**: Manually verify all views in both languages
   - Test iPad landscape mode for responsive layouts
   - Verify TTS works in both languages
5. **Performance**: Profile question generation and TTS operations

### Pre-commit Checklist
Before committing changes, complete this checklist to maintain code quality:

1. **Run all tests**
   ```bash
   xcodebuild test -project Arithmetic.xcodeproj -scheme Arithmetic -destination 'platform=iOS Simulator,name=iPhone 15'
   ```
   - All tests must pass
   - Add new tests for any new utility functions

2. **Verify build succeeds**
   ```bash
   xcodebuild -project Arithmetic.xcodeproj -scheme Arithmetic build
   ```
   - No compilation errors or warnings
   - Check for any deprecation warnings

3. **Check localization consistency**
   ```bash
   ./scripts/check_localizations.sh
   ```
   - All new user-facing strings must be added to both `en.lproj` and `zh-Hans.lproj`
   - Run this script to verify consistency

4. **Review code with swift-code-reviewer agent**
   - For Swift/SwiftUI code changes, use the swift-code-reviewer agent
   - Focus on: naming conventions, state management, CoreData patterns, localization usage
   - Verify mathematical correctness for question generation changes

5. **Verify project-specific requirements**
   - **Division Operations**: All division results must be integers (use `Question.isValid()`)
   - **Localization**: Use `"key".localized` or `"key".localizedFormat()` for all user text
   - **CoreData**: Use `CoreDataManager.shared` singleton, never create contexts directly
   - **Difficulty Levels**: Use `DifficultyLevel` properties instead of hardcoded values
   - **TTS Usage**: All mathematical expressions should use `speakMathExpression()` method