import Foundation
import AVFoundation

class TTSHelper: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    
    // MARK: - Private Methods
    
    /// Returns operator replacement patterns for the specified language
    private func operatorReplacements(for language: LocalizationManager.Language) -> [(pattern: String, replacement: String)] {
        switch language {
        case .chinese:
            return [
                ("=", " 等于 "),
                ("×", " 乘以 "),
                ("\\*", " 乘以 "),
                ("/", " 除以 "),
                ("÷", " 除以 "),
                ("\\+", " 加 "),
                ("-", " 减 ")
            ]
        case .english:
            return [
                ("=", " equals "),
                ("×", " times "),
                ("\\*", " times "),
                ("/", " divided by "),
                ("÷", " divided by "),
                ("\\+", " plus "),
                ("-", " minus ")
            ]
        }
    }
    
    /// Converts a number string to its spelled-out form in the specified language
    private func spelledOutNumber(_ numberString: String, language: LocalizationManager.Language) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        
        let localeIdentifier: String
        switch language {
        case .chinese:
            localeIdentifier = "zh-CN"
        case .english:
            localeIdentifier = "en-US"
        }
        
        formatter.locale = Locale(identifier: localeIdentifier)
        
        // Handle both integers and decimals
        if let decimal = Decimal(string: numberString, locale: Locale(identifier: "en_US_POSIX")) {
            let nsNumber = NSDecimalNumber(decimal: decimal)
            if let spelled = formatter.string(from: nsNumber) {
                // For English, replace hyphens with spaces for smoother pronunciation
                if case .english = language {
                    let cleaned = spelled.replacingOccurrences(of: "-", with: " ")
                        .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    return cleaned
                } else {
                    return spelled
                }
            }
        }
        
        // Fallback: return original string
        return numberString
    }
    
    /// Gets the appropriate voice language identifier
    private func voiceLanguageIdentifier(for language: LocalizationManager.Language) -> String {
        switch language {
        case .chinese:
            return "zh-CN"
        case .english:
            return "en-US"
        }
    }
    
    // MARK: - Public Methods
    
    /// Converts a mathematical expression to natural spoken text in the specified language
    func convertMathExpressionToSpoken(_ input: String, language: LocalizationManager.Language) -> String {
        // 1. Normalize whitespace
        var result = input.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 2. Replace operators with language-specific spoken equivalents
        for (pattern, replacement) in operatorReplacements(for: language) {
            result = result.replacingOccurrences(of: pattern, with: replacement, options: .regularExpression)
        }
        
        // 3. Convert numbers to spelled-out form
        let numberRegex: NSRegularExpression
        do {
            numberRegex = try NSRegularExpression(pattern: "\\d+(?:\\.\\d+)?", options: [])
        } catch {
            print("Error creating number regex: \(error.localizedDescription)")
            return result // Return original string if regex creation fails
        }
        
        let range = NSRange(result.startIndex..<result.endIndex, in: result)
        let matches = numberRegex.matches(in: result, options: [], range: range)
        
        // Process matches in reverse order to maintain string indices
        for match in matches.reversed() {
            if let matchRange = Range(match.range, in: result) {
                let numberString = String(result[matchRange])
                let spelledNumber = spelledOutNumber(numberString, language: language)
                result.replaceSubrange(matchRange, with: spelledNumber)
            }
        }
        
        // 4. Clean up extra whitespace
        result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return result
    }
    
    /// Speaks the given text using the appropriate voice for the specified language
    func speak(text: String, language: LocalizationManager.Language, rate: Float = AVSpeechUtteranceDefaultSpeechRate) {
        // Check if TTS is enabled
        guard UserDefaults.standard.bool(forKey: "isTtsEnabled") else {
            return
        }

        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: voiceLanguageIdentifier(for: language))
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    /// Speaks a mathematical expression in the specified language
    func speakMathExpression(_ expression: String, language: LocalizationManager.Language, rate: Float = AVSpeechUtteranceDefaultSpeechRate) {
        let spokenText = convertMathExpressionToSpoken(expression, language: language)
        speak(text: spokenText, language: language, rate: rate)
    }
    
    /// Stops any current speech
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    /// Checks if the synthesizer is currently speaking
    var isSpeaking: Bool {
        return synthesizer.isSpeaking
    }

    /// Converts a fraction to natural spoken text in the specified language
    func speakFraction(_ fraction: Fraction, language: LocalizationManager.Language) -> String {
        // Check for whole number
        if fraction.numerator % fraction.denominator == 0 {
            let whole = fraction.numerator / fraction.denominator
            return spelledOutNumber("\(whole)", language: language)
        }

        // Check for mixed number
        if let mixed = fraction.toMixedNumber() {
            let wholePart = spelledOutNumber("\(mixed.whole)", language: language)
            let fractionPart = speakSimpleFraction(numerator: mixed.fraction.numerator,
                                                   denominator: mixed.fraction.denominator,
                                                   language: language)
            switch language {
            case .chinese:
                return "\(wholePart) 又 \(fractionPart)"
            case .english:
                return "\(wholePart) and \(fractionPart)"
            }
        }

        // Simple fraction
        return speakSimpleFraction(numerator: fraction.numerator,
                                   denominator: fraction.denominator,
                                   language: language)
    }

    /// Converts a simple fraction (not mixed) to natural spoken text
    private func speakSimpleFraction(numerator: Int, denominator: Int, language: LocalizationManager.Language) -> String {
        switch language {
        case .chinese:
            return speakFractionChinese(numerator: numerator, denominator: denominator)
        case .english:
            return speakFractionEnglish(numerator: numerator, denominator: denominator)
        }
    }

    /// Speaks a fraction in Chinese
    private func speakFractionChinese(numerator: Int, denominator: Int) -> String {
        // In Chinese, fractions are read as "分母分之分子"
        // e.g., 1/2 = "二分之一", 2/3 = "三分之二"
        let numeratorText = spelledOutNumber("\(numerator)", language: .chinese)
        let denominatorText = spelledOutNumber("\(denominator)", language: .chinese)
        return "\(denominatorText)分之\(numeratorText)"
    }

    /// Speaks a fraction in English
    private func speakFractionEnglish(numerator: Int, denominator: Int) -> String {
        // Handle common fractions with special names
        if numerator == 1 {
            switch denominator {
            case 2: return "one half"
            case 3: return "one third"
            case 4: return "one quarter"
            case 5: return "one fifth"
            case 6: return "one sixth"
            case 7: return "one seventh"
            case 8: return "one eighth"
            case 9: return "one ninth"
            case 10: return "one tenth"
            default: break
            }
        } else if numerator == 2 && denominator == 3 {
            return "two thirds"
        } else if numerator == 3 && denominator == 4 {
            return "three quarters"
        }

        // General case: "numerator denominator-ths"
        let numeratorText = spelledOutNumber("\(numerator)", language: .english)
        let denominatorText = spelledOutNumber("\(denominator)", language: .english)

        // Add ordinal suffix for denominator
        let denominatorOrdinal: String
        if denominator == 2 {
            denominatorOrdinal = numerator > 1 ? "halves" : "half"
        } else if denominator == 3 {
            denominatorOrdinal = denominatorText + (numerator > 1 ? " thirds" : " third")
        } else if denominator == 4 {
            denominatorOrdinal = denominatorText + (numerator > 1 ? " quarters" : " quarter")
        } else {
            denominatorOrdinal = denominatorText + (numerator > 1 ? " ths" : " th")
        }

        return "\(numeratorText) \(denominatorOrdinal)"
    }
}

// MARK: - Singleton Instance
extension TTSHelper {
    static let shared = TTSHelper()
}
