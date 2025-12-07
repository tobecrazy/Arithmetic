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

# Run tests (requires test target setup - see TESTING_INSTRUCTIONS.md)
xcodebuild test -project Arithmetic.xcodeproj -scheme Arithmetic -destination 'platform=iOS Simulator,name=iPhone 15'

# Clean build
xcodebuild clean -project Arithmetic.xcodeproj -scheme Arithmetic

# Run static analyzer
xcodebuild analyze -project Arithmetic.xcodeproj -scheme Arithmetic

# Generate build logs with verbose output
xcodebuild -project Arithmetic.xcodeproj -scheme Arithmetic build -verbose
```

### Localization Checks
```bash
# Check consistency between Chinese and English localization files
./scripts/check_localizations.sh
```

## Architecture Overview

### MVVM Pattern with Core Data Integration
The app follows the Model-View-ViewModel pattern with sophisticated CoreData integration:

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

## Development Guidelines

### Working with Questions
- **Integer Results**: All division must result in whole numbers - validated via `Question.isValid()`
- **Operation Order**: Three-number operations follow PEMDAS precedence rules
- **Wrong Question Tracking**: Automatically tracked and resurface in future sessions (30% priority)
- **Quality Control**: Avoids trivial operations (×1 reduced to 5%, ÷1 completely avoided)

### CoreData Considerations
- **Programmatic Model**: CoreData model created in `CoreDataManager.createManagedObjectModel()`
- **Automatic Migration**: Schema changes handled gracefully via automatic migration
- **Testing**: Always test persistence operations across different difficulty levels

### Localization Workflow
1. **Add Strings**: Use `"key".localized` or `"key".localizedFormat(...)` for formatting
2. **Run Checks**: `./scripts/check_localizations.sh` to verify key consistency
3. **Update Files**: Add translations to both `Resources/en.lproj/Localizable.strings` and `Resources/zh-Hans.lproj/Localizable.strings`

### Game State Management
- **Single Pause**: Games can be paused once per session (with score penalty)
- **Auto-save**: Progress auto-saves to CoreData for session recovery
- **Timer Integration**: Timer management tied to game state changes via Combine publishers

### Testing Strategy
- **Unit Tests**: Comprehensive tests for `/Utils/` directory (see TESTING_INSTRUCTIONS.md)
- **Question Validation**: Test generation across all 6 difficulty levels
- **Mathematical Correctness**: Verify solution methods produce accurate results
- **CoreData**: Test migration scenarios and persistence operations
- **TTS**: Validate functionality across supported languages

## Code Patterns

### Difficulty-Based Logic
Each `DifficultyLevel` defines:
- Question count and time limits
- Number ranges for operands
- Available mathematical operations (`supportedOperations`)
- Specialized solution methods applicable

### Observable State Management
- `GameState` and `GameViewModel` use `@Published` properties
- UI updates automatically via SwiftUI bindings
- Complex state changes managed through Combine publishers

### Error Handling Philosophy
- **CoreData**: Fallback and migration strategies for persistence failures
- **Question Validation**: Prevents mathematical errors before generation
- **TTS Failures**: Gracefully degrade without crashing gameplay
- **Network/System Info**: Handle unavailable data gracefully

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

## Common Development Tasks

### Adding New Features
1. **UI Components**: Add to `/Views/` with SwiftUI
2. **Business Logic**: Extend `GameViewModel` or create new ViewModel
3. **Data Models**: Add to `/Models/` or extend CoreData entities
4. **Utilities**: Add to `/Utils/` with comprehensive unit tests

### Modifying Question Logic
1. **Generation**: Modify `QuestionGenerator.swift` algorithms
2. **Validation**: Update `Question.isValid()` for new constraints
3. **Solution Methods**: Add new methods to `Question.SolutionMethod` enum
4. **Difficulty Settings**: Update `DifficultyLevel` properties

### Localization Updates
1. **Add Key**: Use `"key".localized` in code
2. **Translate**: Add to both language files
3. **Verify**: Run `./scripts/check_localizations.sh`
4. **Test**: Verify in both language modes

### Testing
1. **Unit Tests**: Follow patterns in `/Tests/` directory
2. **Integration**: Test CoreData persistence with different scenarios
3. **UI Testing**: Manually verify all views in both languages
4. **Performance**: Profile question generation and TTS operations