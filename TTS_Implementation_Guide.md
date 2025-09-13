# TTS (Text-to-Speech) Implementation for 9×9 Multiplication Table

## Overview

This implementation adds bilingual text-to-speech functionality to the 9×9 multiplication table in the Arithmetic app. When users click on any multiplication button, the app will automatically speak the mathematical expression in the current language.

## Features

- **Bilingual Support**: Supports both Chinese (中文) and English
- **Automatic Language Detection**: Uses the app's current language setting
- **Natural Speech**: Converts mathematical expressions to natural spoken language
- **Number Spelling**: Converts digits to spoken words (e.g., "7" → "seven" / "七")
- **Operator Translation**: Converts symbols to spoken words (e.g., "×" → "times" / "乘以")

## Implementation Details

### 1. TTSHelper Class (`Utils/TTSHelper.swift`)

The core TTS functionality is implemented in the `TTSHelper` class:

```swift
class TTSHelper: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    
    // Main conversion function
    func convertMathExpressionToSpoken(_ input: String, language: LocalizationManager.Language) -> String
    
    // Speech function
    func speakMathExpression(_ expression: String, language: LocalizationManager.Language)
}
```

**Key Features:**
- Integrates with existing `LocalizationManager.Language` enum
- Uses `NumberFormatter` with `.spellOut` style for number conversion
- Supports both Chinese (zh-CN) and English (en-US) locales
- Handles mathematical operators: +, -, ×, ÷, =

### 2. MultiplicationTableView Integration (`Views/MultiplicationTableView.swift`)

The multiplication table view has been enhanced with TTS functionality:

**Changes Made:**
1. Added `@StateObject private var ttsHelper = TTSHelper.shared`
2. Converted static VStack items to clickable Button elements
3. Added `extractMathExpression()` function to generate proper math expressions
4. Integrated with existing `LocalizationManager` for language detection

**Button Action:**
```swift
Button(action: {
    let mathExpression = extractMathExpression(from: item.0, at: index)
    ttsHelper.speakMathExpression(mathExpression, language: localizationManager.currentLanguage)
}) {
    // Button content
}
```

### 3. Language-Specific Mappings

#### Chinese (中文)
- `×` → `乘以`
- `=` → `等于`
- `7` → `七`
- `21` → `二十一`

**Example:** `7 × 3 = 21` → `七 乘以 三 等于 二十一`

#### English
- `×` → `times`
- `=` → `equals`
- `7` → `seven`
- `21` → `twenty one`

**Example:** `7 × 3 = 21` → `seven times three equals twenty one`

## Usage

### For Users
1. Navigate to the 9×9 Multiplication Table
2. Tap any multiplication equation button
3. The app will automatically speak the equation in the current language
4. Change language in settings to hear equations in different languages

### For Developers
```swift
// Basic usage
let ttsHelper = TTSHelper.shared
ttsHelper.speakMathExpression("7 × 3 = 21", language: .chinese)

// Convert without speaking
let spokenText = ttsHelper.convertMathExpressionToSpoken("7 × 3 = 21", language: .english)
// Result: "seven times three equals twenty one"
```

## Technical Implementation

### Number Conversion
Uses `NumberFormatter` with `.spellOut` style:
```swift
let formatter = NumberFormatter()
formatter.numberStyle = .spellOut
formatter.locale = Locale(identifier: "zh-CN") // or "en-US"
```

### Operator Replacement
Uses regular expressions to replace mathematical symbols:
```swift
private func operatorReplacements(for language: LocalizationManager.Language) -> [(pattern: String, replacement: String)] {
    switch language {
    case .chinese:
        return [("×", " 乘以 "), ("=", " 等于 ")]
    case .english:
        return [("×", " times "), ("=", " equals ")]
    }
}
```

### Speech Synthesis
Uses `AVSpeechSynthesizer` with appropriate voice:
```swift
let utterance = AVSpeechUtterance(string: text)
utterance.voice = AVSpeechSynthesisVoice(language: voiceLanguageIdentifier(for: language))
synthesizer.speak(utterance)
```

## Testing

A test file (`Utils/TTSTest.swift`) is provided to verify functionality:

```swift
func testTTSMultiplicationTable() {
    let ttsHelper = TTSHelper.shared
    let result = ttsHelper.convertMathExpressionToSpoken("7 × 3 = 21", language: .chinese)
    // Expected: "七 乘以 三 等于 二十一"
}
```

## Integration with Existing Code

The implementation seamlessly integrates with the existing codebase:
- Uses existing `LocalizationManager` for language detection
- Maintains existing UI design and layout
- No breaking changes to existing functionality
- Follows existing code patterns and conventions

## Future Enhancements

Potential improvements:
1. Add speech rate control in settings
2. Add option to disable TTS
3. Support for more mathematical operations
4. Audio feedback for button presses
5. Export spoken equations as audio files

## Dependencies

- `AVFoundation` framework for speech synthesis
- Existing `LocalizationManager` for language management
- iOS 13.0+ for `AVSpeechSynthesizer` features

## Files Modified/Added

### New Files:
- `Utils/TTSHelper.swift` - Core TTS functionality
- `Utils/TTSTest.swift` - Test functions
- `TTS_Implementation_Guide.md` - This documentation

### Modified Files:
- `Views/MultiplicationTableView.swift` - Added TTS integration

The implementation is complete and ready for use. Users can now click on any multiplication table button to hear the mathematical expression spoken in their preferred language.
