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

# Run tests
xcodebuild test -project Arithmetic.xcodeproj -scheme Arithmetic -destination 'platform=iOS Simulator,name=iPhone 15'

# Clean build
xcodebuild clean -project Arithmetic.xcodeproj -scheme Arithmetic
```

### Debug and Analyze
```bash
# Run static analyzer
xcodebuild analyze -project Arithmetic.xcodeproj -scheme Arithmetic

# Generate build logs with verbose output
xcodebuild -project Arithmetic.xcodeproj -scheme Arithmetic build -verbose
```

## Architecture Overview

### MVVM Pattern
The app follows the Model-View-ViewModel pattern:
- **Models**: `Question`, `GameState`, `DifficultyLevel` - Core data structures
- **Views**: SwiftUI views in `/Views` directory for UI components
- **ViewModels**: `GameViewModel` - Business logic and state management

### Core Data Integration
The app uses a sophisticated CoreData system for persistence:
- **CoreDataManager**: Singleton managing CoreData stack with programmatic model creation
- **GameProgressManager**: Handles game save/load functionality
- **WrongQuestionManager**: Tracks incorrect answers for adaptive learning
- **Entities**: `GameProgressEntity`, `WrongQuestionEntity` with automatic migration support

### Question Generation System
- **QuestionGenerator**: Creates math problems based on difficulty levels
- **Adaptive Learning**: Integrates wrong questions (30% of total) into new game sessions
- **Solution Methods**: Advanced pedagogical approaches including:
  - 凑十法 (Making Ten Method) for addition
  - 破十法 (Breaking Ten Method) for subtraction
  - 乘法口诀法 (Multiplication Table Method)
  - 分解乘法 (Decomposition Multiplication)

### Multi-language Support
- **LocalizationManager**: Handles language switching with real-time UI updates
- **Localized Solutions**: Mathematical solution steps adapt to current language
- **TTS Integration**: Text-to-speech supports multiple languages via `TTSHelper`

### Key Services
- **TTSHelper**: Text-to-speech for reading math expressions aloud
- **ImageCacheManager**: Caching system for UI assets
- **NavigationUtil**: Custom navigation management
- **ProgressViewUtils**: UI utilities for progress indicators

## Development Guidelines

### Working with Questions
- All division operations must result in whole numbers - use `Question.isValid()` to verify
- Three-number operations follow mathematical order of operations (PEMDAS)
- Wrong questions are automatically tracked and resurface in future sessions

### CoreData Considerations
- The CoreData model is created programmatically in `CoreDataManager.createManagedObjectModel()`
- Automatic migration handles schema changes gracefully
- Always test persistence operations with different difficulty levels

### Localization
- Use `String+Localized` extension for all user-facing text
- Solution steps use complex formatting with `localizedFormat()` for mathematical expressions
- Language changes trigger real-time UI updates via NotificationCenter

### Game State Management
- Games can be paused once per session (with score penalty)
- Progress auto-saves to CoreData for session recovery
- Timer management tied to game state changes via Combine publishers

### Testing Strategy
- Test question generation across all difficulty levels
- Verify mathematical correctness of solution methods
- Test CoreData migration scenarios
- Validate TTS functionality across supported languages

## Code Patterns

### Difficulty-Based Logic
Each `DifficultyLevel` has specific properties:
- Question count and time limits
- Number ranges for operands
- Available mathematical operations
- Specialized solution methods

### Observable State Management
- `GameState` and `GameViewModel` use `@Published` properties
- UI updates automatically via SwiftUI bindings
- Complex state changes managed through Combine publishers

### Error Handling
- CoreData operations include fallback and migration strategies
- Question validation prevents mathematical errors
- TTS failures gracefully degrade without crashing gameplay