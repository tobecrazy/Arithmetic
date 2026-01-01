# Arithmetic App - Qwen Code Context

## Project Overview

The Arithmetic app is an intelligent arithmetic learning application built with SwiftUI for elementary students to master basic mathematical operations. It features a comprehensive 6-level difficulty system, intelligent question generation, detailed solution explanations with multiple problem-solving methods, TTS (Text-to-Speech) functionality, and a sophisticated error question collection system.

## Key Features

### 1. 6-Level Difficulty System
- **Level 1**: Addition/Subtraction within 10
- **Level 2**: Addition/Subtraction within 20 (with 4 solution methods)
- **Level 3**: Addition/Subtraction within 50
- **Level 4**: Multiplication/Division within 10
- **Level 5**: Multiplication/Division within 20
- **Level 6**: Mixed operations within 100

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

## Architecture

### MVVM Design Pattern
- **Model**: Question.swift, DifficultyLevel.swift, GameState.swift
- **View**: All files in the Views/ directory
- **ViewModel**: GameViewModel.swift

### Core Data Integration
- WrongQuestionEntity: Stores error question data
- GameProgressEntity: Stores game session data
- CoreDataManager: Singleton for Core Data stack management
- Automatic data migration for schema changes

### Project Structure
```
Arithmetic/
├── App/                      # App entry point
├── Views/                    # SwiftUI views
│   ├── ContentView.swift
│   ├── GameView.swift
│   ├── ResultView.swift
│   ├── WrongQuestionsView.swift
│   ├── MultiplicationTableView.swift
│   ├── LanguageSelectorView.swift
│   ├── AboutMeView.swift
│   └── CachedAsyncImageView.swift
├── Models/                   # Data models
│   ├── Question.swift
│   ├── DifficultyLevel.swift
│   └── GameState.swift
├── ViewModels/              # View models
│   └── GameViewModel.swift
├── CoreData/                # Data persistence
│   ├── ArithmeticModel.swift
│   ├── CoreDataManager.swift
│   ├── WrongQuestionEntity.swift
│   ├── WrongQuestionManager.swift
│   ├── GameProgressEntity.swift
│   └── GameProgressManager.swift
├── Utils/                   # Utility classes
│   ├── LocalizationManager.swift
│   ├── QuestionGenerator.swift
│   ├── NavigationUtil.swift
│   ├── TTSHelper.swift
│   ├── DeviceUtils.swift
│   └── ImageCacheManager.swift
├── Extensions/              # Swift extensions
└── Resources/               # Assets and localizations
    ├── zh-Hans.lproj/
    └── en.lproj/
```

## Building and Running

### Prerequisites
- Xcode 13.0+
- iOS 15.0+
- Swift 5.5+
- SwiftUI 3.0+

### Setup Instructions
1. Clone the repository:
   ```bash
   git clone https://github.com/tobecrazy/Arithmetic.git
   cd Arithmetic
   ```

2. Open the project in Xcode:
   ```bash
   open Arithmetic.xcodeproj
   ```

3. Select a target device (iPhone/iPad simulator or physical device)
4. Build and run the app using `Cmd+R`

### Key Configuration
- The app supports Chinese and English localizations
- Core Data is used for persistent storage of error questions and game progress
- The app uses native iOS TTS for question reading functionality

## Development Conventions

### Code Style
- Follow Swift official coding guidelines
- Use meaningful variable and function names
- Add comments for complex logic where necessary
- Maintain consistent formatting

### Accessibility
- The app includes TTS functionality for auditory learning
- Supports various screen sizes and orientations
- Clear visual feedback for user interactions

### Localizations
- Support for Chinese (zh-Hans) and English (en) languages
- Use of localized strings throughout the app
- Dynamic language switching support
- Full localization of solution content in both languages

## Key Components

### Question Generation
- Ensures integer results for all operations
- Implements difficulty-appropriate problem patterns
- Guarantees 100% integer division results using reverse generation
- Avoids simple operations like multiplication by 1

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

## Testing
- The app has been validated to ensure all operations produce integer results
- Error question collection system has been tested with various problem types
- TTS functionality has been tested in both Chinese and English
- Responsive design has been validated on multiple device types and orientations

## Notes
- The project is well-documented with comprehensive README.md
- Regular updates include new features and bug fixes
- The app has been optimized for educational use in elementary arithmetic learning
- The project follows modern SwiftUI and iOS development best practices