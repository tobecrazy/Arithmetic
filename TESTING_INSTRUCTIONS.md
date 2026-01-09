# Arithmetic App - Test Suite Documentation

This document describes the test suite for the Arithmetic app, which includes unit tests for view models and UI tests for the application.

## Test Organization

The test suite is organized into multiple files:

### 1. UtilsTests.swift
Contains unit tests for utility classes:
- DeviceUtilsTests: Tests for device detection utilities
- ImageCacheManagerTests: Tests for image caching functionality
- LocalizationManagerTests: Tests for language switching
- NavigationUtilTests: Tests for navigation utilities
- ProgressViewUtilsTests: Tests for progress view components
- ViewExtensionTests: Tests for view modifier extensions
- QuestionGeneratorTests: Tests for question generation logic
- SystemInfoManagerTests: Tests for system information management
- TTSHelperTests: Tests for text-to-speech functionality

### 2. GameViewModelTests.swift
Comprehensive tests for GameViewModel functionality:
- Initialization and state management
- Game start, pause, resume, and reset functionality
- Answer submission (correct and incorrect)
- Timer functionality
- Question progression
- Solution display
- Progress saving and loading

### 3. ArithmeticUITests.swift
UI tests for the entire application:
- App launch and basic functionality
- Difficulty selection and game start
- Answer submission workflow
- Navigation between screens
- Settings access and configuration
- Language switching
- Accessibility features
- Timer functionality
- Result view verification

## Running Tests

To run the tests:

1. Open the project in Xcode
2. Press Cmd+U or select Product > Test from the menu
3. Alternatively, use the test navigator to run specific test classes or individual tests

## Test Coverage

The test suite aims to provide comprehensive coverage of:
- Business logic in utility classes
- Game state management
- User interactions
- UI flows
- Edge cases and error conditions
- Accessibility features
- Localization

## Adding New Tests

When adding new functionality to the app, please ensure that appropriate tests are added to maintain high test coverage:
1. Add unit tests for new utility classes in UtilsTests.swift
2. Add ViewModel tests in GameViewModelTests.swift
3. Add UI tests in ArithmeticUITests.swift
4. Update this documentation as needed