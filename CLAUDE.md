# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Arithmetic is an iOS math quiz app designed for children to practice arithmetic operations with increasing difficulty levels. The app features text-to-speech support, adaptive learning through wrong question tracking, and a comprehensive multi-language system. Built with SwiftUI and MVVM architecture, it integrates Firebase Crashlytics and supports 6 progressive difficulty levels with 8 pedagogical solution methods grounded in Chinese elementary math education.

## Development Commands

### Build and Test
```bash
# Build from command line
xcodebuild -project Arithmetic.xcodeproj -scheme Arithmetic build

# Build and run in simulator (iPhone 15)
xcodebuild -project Arithmetic.xcodeproj -scheme Arithmetic -destination 'platform=iOS Simulator,name=iPhone 15' build

# Run all tests
xcodebuild test -project Arithmetic.xcodeproj -scheme Arithmetic -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test file
xcodebuild test -project Arithmetic.xcodeproj -scheme Arithmetic -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ArithmeticTests/UtilsTests

# Run specific test class
xcodebuild test -project Arithmetic.xcodeproj -scheme Arithmetic -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ArithmeticTests/UtilsTests/QuestionGeneratorTests

# Run specific test method
xcodebuild test -project Arithmetic.xcodeproj -scheme Arithmetic -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ArithmeticTests/UtilsTests/QuestionGeneratorTests/testGenerateNonRepetitiveQuestions

# Clean build
xcodebuild clean -project Arithmetic.xcodeproj -scheme Arithmetic

# Run static analyzer
xcodebuild analyze -project Arithmetic.xcodeproj -scheme Arithmetic
```

### Localization and Build Scripts
```bash
# Check localization consistency and embed Git info
./scripts/check_localizations.sh
```

**Note**: This script validates that both `en.lproj` and `zh-Hans.lproj` contain identical keys, and also embeds Git commit information into the app bundle.

### Code Review
Use the **swift-code-reviewer agent** after implementing or modifying Swift code. This is especially important for:
- New SwiftUI views or ViewModels
- Core logic changes (GameViewModel, question generation)
- Division operations and mathematical calculations
- CoreData integration changes

## Architecture Overview

### MVVM with Reactive State Management

The app strictly follows **MVVM (Model-View-ViewModel)** pattern with reactive data flow via Combine. This separation enables testability, maintainability, and clear responsibility boundaries:

```
Views (SwiftUI)
    ↓ (bind to @Published properties)
ViewModels (GameViewModel, reactive state)
    ↓ (call methods, access state)
Business Logic (QuestionGenerator, TTSHelper, Managers)
    ↓ (read/write)
Models & Data Layer (Question, GameState, Core Data)
```

### Key Architectural Components

#### 1. Models Layer (`/Models/`)
- **Question**: Core mathematical problem with calculation methods and validation
  - `correctAnswer`: Respects PEMDAS for multi-number operations
  - `isValid()`: Guarantees all division operations produce integers
  - `SolutionMethod`: 8 pedagogical approaches (凑十法, 破十法, etc.)
- **GameState**: Complete game session state container
  - Tracks current question index, score, timer, user answers
  - Manages 30% wrong question integration into question set
- **DifficultyLevel**: Enum defining 6 levels with distinct ranges and operations

#### 2. ViewModel Layer (`/ViewModels/`)
- **GameViewModel**: Single central controller for all game logic
  - Uses `@Published` properties for reactive updates
  - Implements timer, TTS, solution display, progress persistence
  - Listens to language change notifications for real-time UI sync
  - Manages game lifecycle (start, pause, resume, end)

#### 3. Views Layer (`/Views/`)
Core screens:
- **GameView**: Question display, answer input, timer, TTS button
- **ResultView**: Post-game analytics and streak tracking
- **WrongQuestionsView**: Error tracking with filtering and deletion
- **SettingsView**: Configuration hub (dark mode, TTS, language, system info)
- **MultiplicationTableView**: 9×9 interactive reference
- **MathBankView**: PDF generation with custom difficulty selection
- **QrCodeToolView**: QR code scanning and generation
- **FormulaGuideView**: Elementary math formulas reference

Supplementary views:
- WelcomeView, LanguageSelectorView, SystemInfoView, AboutMeView, CachedAsyncImageView, ConfettiCelebrationView, OtherOptionsView

#### 4. Core Data Layer (`/CoreData/`)
Two persistent entities with programmatic model (no `.xcdatamodel` file):
- **WrongQuestionEntity**: Stores incorrect answers with statistics
  - Tracked via `combinationKey` to prevent duplicates
  - Updated with view count and wrong count for analytics
- **GameProgressEntity**: Serializes complete game state for resume functionality

Managers enforce singleton pattern:
- **CoreDataManager**: Controls persistence stack with automatic migration
- **WrongQuestionManager**: CRUD operations on wrong questions
- **GameProgressManager**: Game save/load operations

#### 5. Utilities Layer (`/Utils/`)
Core business logic services:
- **QuestionGenerator**: Intelligent question factory
  - Generates non-repetitive questions with 30% from wrong collection
  - Respects difficulty-specific probability distributions
  - Validates all division operations for integer results
- **TTSHelper**: Text-to-speech synthesis
  - Converts operators to spoken words (÷ → "divided by")
  - Adapts pronunciation to current language
  - Integrated with AVSpeechSynthesizer
- **LocalizationManager**: Runtime language switching
  - Posts LanguageChanged notifications for reactive UI updates
  - Manages current language state globally
- **MathBankPDFGenerator**: PDF generation for offline practice
  - Prioritizes wrong questions in output
  - Supports bilingual content
  - Optimized A4 layout with compact formatting
- **SystemInfoManager**: Device monitoring (CPU, memory, disk, battery, network)
- **ImageCacheManager**: Two-level caching (memory + disk)
- **HapticFeedbackHelper, SoundEffectsHelper**: User feedback generation
- **DeviceUtils, NavigationUtil, ProgressViewUtils**: Helper utilities

#### 6. Extensions (`/Extensions/`)
- **String+Localized**: `.localized` and `.localizedFormat()` convenience methods
- **Font+Adaptive, CGFloat+Adaptive**: Responsive sizing for iPhone/iPad
- **Color+Theme**: Dark/light mode color constants
- **View+Navigation**: Custom navigation modifiers

### Data Flow Example

```
User submits answer
    ↓
GameView calls gameViewModel.submitAnswer()
    ↓
GameViewModel validates via Question.isValid()
    ↓
Updates @Published properties (score, showSolution, etc.)
    ↓
View automatically re-renders
    ↓
GameProgressManager saves state to CoreData
    ↓
If answer wrong → WrongQuestionManager persists to CoreData
```

## Critical Implementation Details

### Question Generation Algorithm

The `QuestionGenerator` uses a sophisticated approach to ensure mathematical correctness and pedagogical value:

1. **Collect wrong questions** (up to 30% of requested count)
   - Filter by difficulty level
   - Validate each with `Question.isValid()`
   - Track in Set to prevent duplicates

2. **Generate new questions** to fill remaining count
   - Two-number operations: 60-100% depending on level
   - Three-number operations: 0-90% depending on level
   - Each operation respects PEMDAS precedence
   - All divisions guaranteed to produce integers

3. **Fallback** to simple addition if generation stalls

4. **Shuffle** result before returning

**Difficulty Distribution**:
| Level | Operations | Range | Questions | Two-Num % | Three-Num % |
|-------|------------|-------|-----------|-----------|------------|
| 1 | +/- | 1-10 | 20 | 100% | 0% |
| 2 | +/- | 1-20 | 25 | 60% | 40% |
| 3 | +/- | 1-50 | 50 | 40% | 60% |
| 4 | ×÷ | 1-10 | 20 | 100% | 0% |
| 5 | ×÷ | 1-20 | 25 | 100% | 0% |
| 6 | +/-×÷ | 1-100 | 100 | 10% | 90% |

### Division Safety Guarantee

**Critical Pattern**: All division operations must result in integers. This is enforced via **reverse generation**:

```swift
// ✅ CORRECT: Ensure divisibility before creating question
let quotient = Int.random(in: 1...10)
let divisor = Int.random(in: 1...10)
let dividend = quotient * divisor  // 100% guaranteed to divide evenly
let question = Question(num1: dividend, op1: .divide, num2: divisor)

// ❌ WRONG: Random dividend ÷ random divisor may not divide evenly
let num1 = Int.random(in: 1...10)
let num2 = Int.random(in: 1...10)
if num1 % num2 != 0 { return nil }  // Unnecessarily restrictive
```

### PEMDAS Compliance for Three-Number Operations

For expressions like `2 + 3 × 4`, the app strictly respects mathematical precedence:

- **Precedence Levels**: Addition/Subtraction = 1, Multiplication/Division = 2
- **Evaluation**: Higher precedence operations calculated first
- **Validation**: All intermediate divisions produce integers

```swift
// Example: 2 + 3 × 4
// Step 1: Identify precedence: + has precedence 1, × has precedence 2
// Step 2: Calculate × first: 3 × 4 = 12
// Step 3: Calculate +: 2 + 12 = 14 (NOT 20)
```

### Solution Methods System

The app implements 8 pedagogical solution methods grounded in Chinese elementary math education:

| Method | Levels | Operations | Example |
|--------|--------|------------|---------|
| 凑十法 (Making Ten) | 2 | Addition (< 20) | 7 + 8 = 7 + 3 + 5 = 15 |
| 破十法 (Breaking Ten) | 2 | Subtraction | 15 - 8 = 10 - 8 + 5 = 7 |
| 借十法 (Borrowing Ten) | 2 | Subtraction | 13 - 6 = 3 + 7 - 6 = 4 |
| 平十法 (Leveling Ten) | 2 | Subtraction | 16 - 8 = 6 - 8 + 10 = 8 |
| 乘法口诀法 (Multiplication Table) | 4-5 | Multiplication | 6 × 7 = 42 (memorized) |
| 分解乘法 (Decomposition) | 5 | Multiplication | 12 × 15 = 12 × (10 + 5) |
| 除法验算法 (Division Verification) | 4-5 | Division | 36 ÷ 6 = 6 (verify: 6 × 6 = 36) |
| 分组除法 (Grouping Division) | 4-5 | Division | 15 ÷ 3 = 5 (15 = 3+3+3+3+3) |

Each method generates localized step-by-step solution text in both Chinese and English.

### Multi-Language System

**Architecture**:
- Strings stored in `Resources/en.lproj/Localizable.strings` and `zh-Hans.lproj/Localizable.strings`
- `LocalizationManager` manages current language and posts notifications
- All UI strings use `String+Localized` extension
- Solution methods have dual-language explanations

**Usage Pattern**:
```swift
// Simple localization
Text("difficulty.level1".localized)

// Localization with format strings
Text("score_label".localizedFormat(finalScore))

// Listening for language changes
.onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))) { _ in
    // View re-renders with new language
}
```

### Text-to-Speech (TTS)

**TTSHelper** converts mathematical expressions to natural speech:

```
Input:  "15 + 8 = 23"
        ↓ (operator conversion)
"fifteen plus eight equals twenty-three"
        ↓ (language-specific voice selection)
AVSpeechUtterance sent to AVSpeechSynthesizer
        ↓
Audio output
```

**Key Features**:
- Operator conversion: +, -, ×, ÷ → spoken words
- Language adaptation: Detects current language for voice selection
- Global toggle: Users can disable TTS in Settings (stored in UserDefaults)
- Number formatting: Converts digits to spelled-out words

### Core Data Persistence

**Programmatic Model** (no `.xcdatamodel` file):
- Model defined in `ArithmeticModel.swift`
- Automatic migration: `shouldMigrateStoreAutomatically = true`
- Automatic inference: `shouldInferMappingModelAutomatically = true`
- Auto-recovery: Resets store if migration fails

**Singleton Access Pattern**:
```swift
// Correct usage
let context = CoreDataManager.shared.context
let manager = WrongQuestionManager.shared

// Never create contexts directly
```

## Project Structure and Key Files

```
Arithmetic/
├── App/
│   └── ArithmeticApp.swift          # Firebase init via AppDelegate, CoreData context injection
├── Models/
│   ├── Question.swift               # Math problem with PEMDAS calculation and validation
│   ├── GameState.swift              # Game session state container
│   └── DifficultyLevel.swift        # 6-level enum with ranges and operations
├── ViewModels/
│   └── GameViewModel.swift          # Central business logic, reactive state management
├── Views/
│   ├── ContentView.swift            # Main tab navigation
│   ├── GameView.swift               # Core game interface
│   ├── ResultView.swift             # Post-game analytics
│   ├── WrongQuestionsView.swift     # Error tracking and management
│   ├── SettingsView.swift           # Configuration hub
│   ├── MultiplicationTableView.swift # 9×9 reference table
│   ├── MathBankView.swift           # PDF generation
│   ├── QrCodeToolView.swift         # QR code scanning/generation
│   ├── FormulaGuideView.swift       # Math formulas reference
│   ├── SystemInfoView.swift         # Device monitoring
│   └── [other views]
├── CoreData/
│   ├── CoreDataManager.swift        # Persistence stack singleton
│   ├── WrongQuestionEntity.swift    # Wrong question data model
│   ├── WrongQuestionManager.swift   # Wrong question CRUD
│   ├── GameProgressEntity.swift     # Game save data model
│   ├── GameProgressManager.swift    # Game progress CRUD
│   └── ArithmeticModel.swift        # Programmatic Core Data model definition
├── Utils/
│   ├── QuestionGenerator.swift      # Smart question factory
│   ├── TTSHelper.swift              # Text-to-speech synthesis
│   ├── LocalizationManager.swift    # Runtime language switching
│   ├── MathBankPDFGenerator.swift   # PDF generation
│   ├── SystemInfoManager.swift      # Device monitoring
│   ├── ImageCacheManager.swift      # Two-level image caching
│   ├── HapticFeedbackHelper.swift   # Haptic feedback
│   ├── SoundEffectsHelper.swift     # Audio feedback
│   ├── DeviceUtils.swift            # Device characteristics detection
│   ├── NavigationUtil.swift         # Navigation management
│   └── ProgressViewUtils.swift      # Progress visualization
├── Extensions/
│   ├── String+Localized.swift       # Localization convenience methods
│   ├── Font+Adaptive.swift          # Responsive font sizing
│   ├── CGFloat+Adaptive.swift       # Responsive size utilities
│   ├── Color+Theme.swift            # Theme colors
│   └── View+Navigation.swift        # Navigation modifiers
├── Resources/
│   ├── en.lproj/Localizable.strings
│   ├── zh-Hans.lproj/Localizable.strings
│   └── [app icons, assets]
├── Tests/
│   ├── UtilsTests.swift             # Utility class unit tests
│   ├── GameViewModelTests.swift     # ViewModel tests
│   ├── QuestionTests.swift          # Question model tests
│   ├── DifficultyLevelTests.swift   # Difficulty tests
│   ├── GameStateTests.swift         # Game state tests
│   ├── CoreDataTests.swift          # Persistence tests
│   ├── LocalizationTests.swift      # Localization validation
│   ├── ExtensionsTests.swift        # Extension tests
│   └── ArithmeticUITests.swift      # Full app UI tests
├── scripts/
│   ├── check_localizations.sh       # Validate language files + embed Git info
│   ├── upload_dsyms.sh              # Firebase symbol upload
│   └── embed_git_info.sh            # Git commit injection
├── Arithmetic.xcodeproj             # Xcode project configuration
├── Info.plist                       # App metadata
├── GoogleService-Info.plist         # Firebase configuration (DO NOT COMMIT changes)
├── CLAUDE.md                        # This file
├── README.md                        # Project overview
├── TESTING_INSTRUCTIONS.md          # Test suite guide
└── ChangeLogs.md                    # Version history
```

## Common Patterns and Anti-Patterns

### ✅ Correct Patterns

1. **Division Validation**:
   ```swift
   // Always use reverse generation for division
   let quotient = Int.random(in: 1...10)
   let divisor = Int.random(in: 1...10)
   let dividend = quotient * divisor
   ```

2. **Optional Binding**:
   ```swift
   guard let value = optionalValue else { return }
   // Use value safely
   ```

3. **Localization**:
   ```swift
   Text("level_title".localized)
   Text("score_label".localizedFormat(score))
   ```

4. **CoreData Access**:
   ```swift
   let context = CoreDataManager.shared.context
   let manager = WrongQuestionManager.shared
   ```

5. **Reactive State**:
   ```swift
   @Published var currentScore: Int = 0
   // View automatically updates when changed
   ```

6. **Singleton Usage**:
   ```swift
   TTSHelper.shared.speakMathExpression(question.text)
   LocalizationManager.shared.currentLanguage = .chinese
   ```

### ❌ Anti-Patterns to Avoid

1. **Division without validation**: Generating "9 ÷ 2" (non-integer result)
2. **Force unwrapping**: `let value = optional!`
3. **Hardcoded ranges**: `if level == "hard" { max = 100 }`
4. **String literals for UI**: `Text("Score: \(score)")` instead of localized strings
5. **Direct CoreData context creation**: Creating new `NSManagedObjectContext` instances
6. **Multiple CoreData managers**: Each utility should use `CoreDataManager.shared`
7. **Ignoring PEMDAS**: Not respecting operation precedence in multi-number expressions
8. **Modifying GoogleService-Info.plist**: Never commit Firebase config changes

## Testing Strategy

### Test Files Overview

| File | Scope |
|------|-------|
| `UtilsTests.swift` | DeviceUtils, ImageCacheManager, LocalizationManager, QuestionGenerator, SystemInfoManager, TTSHelper, NavigationUtil, ProgressViewUtils |
| `GameViewModelTests.swift` | ViewModel initialization, game flow, timer, answer submission, state transitions |
| `QuestionTests.swift` | Question validation, correctAnswer calculation, solution methods |
| `DifficultyLevelTests.swift` | Level properties, operation support |
| `GameStateTests.swift` | Question generation, answer checking, score tracking |
| `CoreDataTests.swift` | Entity CRUD, migration validation |
| `LocalizationTests.swift` | Key existence in both languages, format string validation |
| `ExtensionsTests.swift` | Font/color/size adaptation |
| `ArithmeticUITests.swift` | Full app workflows, navigation, settings, language switching |

### Test Coverage Focus

- **Question Generation**: Uniqueness, mathematical correctness, integer division guarantee
- **Game Flow**: Pause/resume, answer submission, timer accuracy
- **CoreData**: Migration, CRUD operations, data integrity
- **Localization**: Key coverage, format strings, language switching
- **UI**: Navigation, state persistence, accessibility

## Pre-Commit Verification

Before committing changes:

```bash
# 1. Run all tests
xcodebuild test -project Arithmetic.xcodeproj -scheme Arithmetic -destination 'platform=iOS Simulator,name=iPhone 15'

# 2. Build successfully
xcodebuild -project Arithmetic.xcodeproj -scheme Arithmetic build

# 3. Check localizations
./scripts/check_localizations.sh

# 4. Review with swift-code-reviewer agent (for Swift changes)
```

**Critical Verifications**:
- ✅ All tests pass
- ✅ No build warnings
- ✅ Localization keys exist in both languages
- ✅ Division operations guaranteed to produce integers
- ✅ No hardcoded UI strings (use localization)
- ✅ CoreData access only via singleton managers
- ✅ PEMDAS respected for multi-number operations
- ✅ No force unwrapping of optionals

## Firebase Configuration

The project integrates Firebase for Crashlytics and Analytics:

- **Project ID**: `mobaimaster-fb0c8`
- **Bundle ID**: `com.dbyl.Arithmetic`
- **Configuration File**: `GoogleService-Info.plist`

**Important**: Never commit changes to `GoogleService-Info.plist`. For local development or testing with a different Firebase project, create a local override and add it to `.gitignore`.

## iOS Deployment Target

- **Minimum**: iOS 15.0+
- **Supported Orientations**:
  - iPhone: Portrait, Landscape Left/Right
  - iPad: All 4 orientations

## Dependencies

The project has no external package manager (CocoaPods, SPM). Firebase is integrated via Xcode configuration.

**Build Scripts**:
- `check_localizations.sh`: Validates localization consistency and embeds Git information
- `upload_dsyms.sh`: Uploads debug symbols to Firebase
- `embed_git_info.sh`: Injects Git commit info into app bundle
