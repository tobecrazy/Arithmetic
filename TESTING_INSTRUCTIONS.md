# Instructions for Adding Unit Tests to Arithmetic Project

## Overview
I have created comprehensive unit tests for all functions in the `/Utils/` directory. The tests are located in the `/Tests/` directory and cover:

1. DeviceUtilsTests.swift
2. ImageCacheManagerTests.swift 
3. LocalizationManagerTests.swift
4. NavigationUtilTests.swift
5. ProgressViewUtilsTests.swift
6. QuestionGeneratorTests.swift
7. SystemInfoManagerTests.swift
8. TTSHelperTests.swift
9. UtilsTests.swift (a consolidated file with all tests)

## How to Add Tests to Your Xcode Project

1. Open your Arithmetic.xcodeproj in Xcode.

2. In the Project Navigator (left panel), right-click on the "Arithmetic" project (not a folder/group) and select "New Target".

3. Select "iOS" under the "Platform" tab, then select "Unit Testing Bundle" under "Test" section.

4. Name your test target "ArithmeticTests" (or any name you prefer).

5. Make sure the "Arithmetic" app target is selected as the "Host Application".

6. In the newly created test target, you'll see a default test file. You can delete it if you want.

7. Now, add our test files to this test target:
   - Select all the test files in the `/Tests/` folder
   - Drag them to Xcode under the test target
   - Make sure "Add to target" is checked and select your test target (e.g., "ArithmeticTests")

8. In your test target's Build Settings, make sure:
   - "Test Host" is set to your app
   - "Bundle Loader" is set to your app

9. Now you can run the tests by:
   - Pressing Cmd+U, or
   - Going to Product > Test

## Coverage Summary

The test files provide comprehensive coverage for:

- **DeviceUtils**: Tests for device type detection and orientation checks
- **ImageCacheManager**: Tests for caching, retrieval, download and clear operations
- **LocalizationManager**: Tests for language switching and localization functionality
- **NavigationUtil**: Tests for navigation controller utilities
- **ProgressViewUtils**: Tests for progress bar views, modifiers, and progress manager
- **QuestionGenerator**: Tests for question generation, validation, and utility functions
- **SystemInfoManager**: Tests for system information gathering and formatting
- **TTSHelper**: Tests for text-to-speech conversion, speaking, and language support

## Running Tests

After adding the test files to your Xcode test target, you can run them by:
1. Selecting the test target
2. Using the keyboard shortcut Cmd+U
3. Or choosing Product > Test from the menu

The tests will validate that all utility functions operate as expected and handle both normal and edge cases appropriately.