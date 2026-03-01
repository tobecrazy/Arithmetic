# Arithmetic App - Qwen Code Context

## Project Overview

The Arithmetic app is an intelligent arithmetic learning application built with SwiftUI for elementary students to master basic mathematical operations. It features a comprehensive 7-level difficulty system, intelligent question generation, detailed solution explanations with multiple problem-solving methods, TTS (Text-to-Speech) functionality, and a sophisticated error question collection system.

## Key Features

### 1. 7-Level Difficulty System
- **Level 1**: Addition/Subtraction within 10
- **Level 2**: Addition/Subtraction within 20 (with 4 solution methods)
- **Level 3**: Addition/Subtraction within 50
- **Level 4**: Multiplication/Division within 10
- **Level 5**: Multiplication/Division within 50
- **Level 6**: Mixed operations within 1000
- **Level 7**: Fraction operations within 100 (NEW)

### 2. Intelligent Solution Methods
- **Addition**: Making Ten Method (凑十法)
- **Subtraction**: Breaking Ten Method (破十法), Borrowing Ten Method (借十法), Leveling Ten Method (平十法)
- **Multiplication**: Multiplication Table Method (乘法口诀法), Decomposition Multiplication (分解乘法)
- **Division**: Division Verification (除法验算法), Grouping Division (分组除法)

### 3. TTS (Text-to-Speech) System
- Native iOS TTS engine integration
- Bilingual support (Chinese and English)
- Mathematical expression reading with proper operator pronunciation
- Question read-aloud functionality in the game interface
- Singleton TTSHelper class for managing speech synthesis

### 4. Error Question Collection
- Automatic collection of incorrect answers
- Categorization by difficulty level
- Detailed statistics (display count, error count)
- Smart identification of mastered questions (70%+ accuracy)
- Priority practice for error questions
- Manual management (delete single/all/mastered questions)

### 5. Nine-Nine Multiplication Table
- Complete 9×9 multiplication table display
- Color-coded difficulty levels
  - Blue: Same number multiplication (1×1, 2×2, etc.)
  - Green: Results ≤10
  - Orange: Results 11-50
  - Red: Results >50
- Responsive grid layout
- Bilingual TTS support

### 6. Game Progress Saving
- Automatic game progress saving
- Resume functionality
- Complete session state preservation (difficulty, score, time, question progress)

### 7. Adaptive UI
- Responsive design for iPhone and iPad
- Landscape mode optimization for iPad
- Device-specific layout adjustments
- Dynamic text sizing and adaptive fonts

### 8. Additional Features
- **Math Bank PDF Generation**: Printable problem banks with answer keys
- **QR Code Scanner**: Camera and photo library QR code scanning
- **Math Formula Guide**: Comprehensive elementary math formulas
- **System Information Monitor**: Real-time device info, battery, network status
- **Settings Page**: Dark mode toggle, TTS control, language selection
- **Firebase Crashlytics**: Real-time crash monitoring and reporting

## Architecture

### MVVM Design Pattern
- **Model**: Question.swift, DifficultyLevel.swift, GameState.swift, Fraction.swift
- **View**: All files in the Views/ directory and Views/Components/
- **ViewModel**: GameViewModel.swift

### Core Data Integration
- **WrongQuestionEntity**: Stores error question data
- **GameProgressEntity**: Stores game session data
- **CoreDataManager**: Singleton for Core Data stack management
- Automatic data migration for schema changes

### Project Structure
```
Arithmetic/
├── App/                      # App entry point
│   └── ArithmeticApp.swift
├── Views/                    # SwiftUI views
│   ├── Components/          # Reusable view components
│   ├── ContentView.swift
│   ├── GameView.swift
│   ├── ResultView.swift
│   ├── WrongQuestionsView.swift
│   ├── MultiplicationTableView.swift
│   ├── SettingsView.swift
│   ├── MathBankView.swift
│   ├── FormulaGuideView.swift
│   ├── QrCodeToolView.swift
│   ├── SystemInfoView.swift
│   └── ...
├── Models/                   # Data models
│   ├── Question.swift
│   ├── DifficultyLevel.swift
│   ├── GameState.swift
│   └── Fraction.swift
├── ViewModels/               # View models
│   └── GameViewModel.swift
├── CoreData/                 # Data persistence
│   ├── ArithmeticModel.swift
│   ├── CoreDataManager.swift
│   ├── WrongQuestionEntity.swift
│   ├── WrongQuestionManager.swift
│   ├── GameProgressEntity.swift
│   └── GameProgressManager.swift
├── Utils/                    # Utility classes
│   ├── LocalizationManager.swift
│   ├── QuestionGenerator.swift
│   ├── TTSHelper.swift
│   ├── MathBankPDFGenerator.swift
│   ├── DeviceUtils.swift
│   ├── SystemInfoManager.swift
│   └── ...
├── Extensions/               # Swift extensions
│   ├── String+Localized.swift
│   ├── Color+Theme.swift
│   ├── Font+Adaptive.swift
│   └── ...
├── Tests/                    # Unit and UI tests
│   ├── GameViewModelTests.swift
│   ├── QuestionTests.swift
│   ├── LocalizationTests.swift
│   └── ...
├── Resources/                # Assets and localizations
│   ├── zh-Hans.lproj/
│   └── en.lproj/
└── scripts/                  # Build and test scripts
```

## Building and Running

### Prerequisites
- Xcode 15.0+ (iOS 26.0+ SDK)
- iOS 15.0+ deployment target
- Swift 5.5+
- SwiftUI 3.0+
- CocoaPods for Firebase dependencies

### Setup Instructions
1. Clone the repository:
   ```bash
   cd /Users/I321533/XcodeProject/Arithmetic
   ```

2. Install dependencies (if using CocoaPods):
   ```bash
   pod install
   ```

3. Open the workspace in Xcode:
   ```bash
   open Arithmetic.xcworkspace
   ```

4. Select a target device (iPhone/iPad simulator or physical device)

5. Build and run:
   ```bash
   xcodebuild -project Arithmetic.xcodeproj -scheme Arithmetic -destination 'platform=iOS Simulator,name=iPhone 16' build
   ```

### Testing
Run all tests using the provided script:
```bash
./scripts/run_all_tests.sh
```

Or run specific test types:
```bash
# Unit tests only
./scripts/run_all_tests.sh --only-unit

# UI tests only
./scripts/run_all_tests.sh --only-ui

# Skip localization checks
./scripts/run_all_tests.sh --skip-localization
```

### Key Configuration
- The app supports Chinese and English localizations
- Core Data is used for persistent storage of error questions and game progress
- Firebase Crashlytics is integrated for crash monitoring
- The app uses native iOS TTS for question reading functionality

## Development Conventions

### Code Style
- Follow Swift official coding guidelines
- Use meaningful variable and function names
- Add comments for complex logic where necessary
- Maintain consistent formatting

### Testing Practices
- Unit tests for models, utilities, and view models
- UI tests for critical user flows
- Localization checks for bilingual support
- All tests should pass before committing changes

### Accessibility
- The app includes TTS functionality for auditory learning
- Supports various screen sizes and orientations
- Clear visual feedback for user interactions

### Localizations
- Support for Chinese (zh-Hans) and English (en) languages
- Use of localized strings throughout the app via `String+Localized.swift` extension
- Dynamic language switching support
- Full localization of solution content in both languages
- Run `./scripts/check_localizations.sh` to verify localization completeness

## Core Components

### Question Generation
- Ensures integer results for all operations (except Level 7 fractions)
- Implements difficulty-appropriate operation patterns
- Guarantees 100% integer division results using reverse generation
- Avoids simple operations like multiplication by 1 or same-number operations
- Supports fraction operands for Level 7

### TTS Helper
- Converts mathematical expressions to natural speech
- Handles operator pronunciation correctly in both languages
- Converts numbers to spelled-out form for better pronunciation
- Singleton pattern for efficient resource management

### Device Adaptation
- Responsive layouts for different screen sizes
- iPad-optimized landscape mode
- Dynamic font sizing based on device type
- Number pad input for answer entry

### Fraction Support (Level 7)
- Fraction input with separate numerator/denominator fields
- Vertical fraction display format
- Fraction arithmetic (addition, subtraction, multiplication, division)
- Automatic simplification of results
- Bilingual fraction name conversion for TTS

## Testing

### Test Coverage
- **Unit Tests**: Models (Question, Fraction, DifficultyLevel, GameState), ViewModels (GameViewModel), Utils (LocalizationManager, TTSHelper, MathBankPDFGenerator)
- **UI Tests**: Game flow, navigation, user interactions
- **Core Data Tests**: Entity creation, persistence, migration
- **Localization Tests**: String completeness, key consistency

### Running Tests
```bash
# Full test suite
./scripts/run_all_tests.sh

# With verbose output
./scripts/run_all_tests.sh --verbose

# Skip UI tests for faster execution
./scripts/run_all_tests.sh --skip-ui
```

## Notes
- The project is well-documented with comprehensive README.md and ChangeLogs.md
- Regular updates include new features and bug fixes
- The app has been optimized for educational use in elementary arithmetic learning
- The project follows modern SwiftUI and iOS development best practices
- Recent updates are tracked in ChangeLogs.md, not in README.md
- Firebase is configured for crash reporting and analytics
