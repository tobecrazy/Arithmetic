//
//  Fraction.swift
//  Arithmetic
//
//  Created by Claude Code
//  Copyright © 2026 Arithmetic. All rights reserved.
//

import Foundation

/// Represents a mathematical fraction with automatic simplification support
struct Fraction: Equatable, Codable, CustomStringConvertible {
    let numerator: Int
    let denominator: Int

    // MARK: - Initialization

    /// Creates a fraction with the given numerator and denominator
    /// - Parameters:
    ///   - numerator: The top part of the fraction
    ///   - denominator: The bottom part of the fraction (must not be zero)
    init(numerator: Int, denominator: Int) {
        precondition(denominator != 0, "Denominator cannot be zero")
        self.numerator = numerator
        self.denominator = denominator
    }

    // MARK: - Computed Properties

    /// Returns true if this is an improper fraction (numerator >= denominator)
    var isImproper: Bool {
        return abs(numerator) >= abs(denominator)
    }

    /// String representation of the fraction
    var description: String {
        return "\(numerator)/\(denominator)"
    }

    /// Unicode representation of the fraction (e.g., ½, ⅓, ¼)
    /// Falls back to regular format if no Unicode equivalent exists
    var unicodeDescription: String {
        // Map of common fractions to Unicode characters
        let unicodeFractions: [String: String] = [
            "1/2": "½",
            "1/3": "⅓",
            "2/3": "⅔",
            "1/4": "¼",
            "3/4": "¾",
            "1/5": "⅕",
            "2/5": "⅖",
            "3/5": "⅗",
            "4/5": "⅘",
            "1/6": "⅙",
            "5/6": "⅚",
            "1/7": "⅐",
            "1/8": "⅛",
            "3/8": "⅜",
            "5/8": "⅝",
            "7/8": "⅞",
            "1/9": "⅑",
            "1/10": "⅒"
        ]

        let fractionString = "\(numerator)/\(denominator)"
        return unicodeFractions[fractionString] ?? description
    }

    /// Creates a Fraction from a Unicode fraction character or regular format
    /// Examples: "½" → Fraction(1,2), "1/3" → Fraction(1,3), "⅔" → Fraction(2,3)
    /// Also handles expressions like "1/2+3" by extracting the fractional part only
    static func from(string: String) -> Fraction? {
        // Map of Unicode characters to fractions
        let unicodeToFraction: [String: (Int, Int)] = [
            "½": (1, 2),
            "⅓": (1, 3),
            "⅔": (2, 3),
            "¼": (1, 4),
            "¾": (3, 4),
            "⅕": (1, 5),
            "⅖": (2, 5),
            "⅗": (3, 5),
            "⅘": (4, 5),
            "⅙": (1, 6),
            "⅚": (5, 6),
            "⅐": (1, 7),
            "⅛": (1, 8),
            "⅜": (3, 8),
            "⅝": (5, 8),
            "⅞": (7, 8),
            "⅑": (1, 9),
            "⅒": (1, 10)
        ]

        // First, check if it's a Unicode fraction (single character)
        if string.count == 1, let (num, denom) = unicodeToFraction[string] {
            return Fraction(numerator: num, denominator: denom)
        }

        // If the string contains operators (+, -, *, ÷), it's an expression, not a pure fraction
        // Only accept pure fractions (e.g., "1/2", "3/4")
        if string.contains("+") || string.contains("-") || string.contains("×") || string.contains("x") ||
           string.contains("*") || string.contains("÷") || string.contains("/") && string.filter({ $0 == "/" }).count > 1 {
            return nil
        }

        // Try parsing regular format "1/3"
        let components = string.split(separator: "/")
        guard components.count == 2,
              let numerator = Int(components[0]),
              let denominator = Int(components[1]),
              denominator != 0 else {
            return nil
        }

        return Fraction(numerator: numerator, denominator: denominator)
    }

    // MARK: - Methods

    /// Returns the simplified form of this fraction using GCD
    /// - Returns: A new Fraction in simplified form
    func simplified() -> Fraction {
        let gcdValue = greatestCommonDivisor(abs(numerator), abs(denominator))
        let simplifiedNumerator = numerator / gcdValue
        let simplifiedDenominator = denominator / gcdValue

        // Ensure denominator is always positive
        if simplifiedDenominator < 0 {
            return Fraction(numerator: -simplifiedNumerator, denominator: -simplifiedDenominator)
        }

        return Fraction(numerator: simplifiedNumerator, denominator: simplifiedDenominator)
    }

    /// Converts the fraction to a decimal value
    /// - Returns: The decimal representation of the fraction
    func toDecimal() -> Double {
        return Double(numerator) / Double(denominator)
    }

    /// Converts an improper fraction to a mixed number
    /// - Returns: A tuple containing the whole number part and the fractional part, or nil if not improper
    func toMixedNumber() -> (whole: Int, fraction: Fraction)? {
        guard isImproper && numerator != 0 else {
            return nil
        }

        let whole = numerator / denominator
        let remainder = numerator % denominator

        guard remainder != 0 else {
            // It's a whole number, no fractional part
            return nil
        }

        let fractionalPart = Fraction(numerator: abs(remainder), denominator: denominator)
        return (whole: whole, fraction: fractionalPart)
    }

    /// Returns a localized display string for the fraction
    /// - Parameter language: The target language for localization
    /// - Returns: A formatted string representing the fraction
    func localizedString(language: LocalizationManager.Language = LocalizationManager.shared.currentLanguage) -> String {
        // Check if it's a whole number
        if numerator % denominator == 0 {
            return "\(numerator / denominator)"
        }

        // Check if it should be displayed as a mixed number
        if let mixed = toMixedNumber() {
            if language == .chinese {
                return "\(mixed.whole)又\(mixed.fraction.numerator)/\(mixed.fraction.denominator)"
            } else {
                return "\(mixed.whole) \(mixed.fraction.numerator)/\(mixed.fraction.denominator)"
            }
        }

        return description
    }

    // MARK: - Private Helper

    /// Calculates the greatest common divisor using Euclidean algorithm
    /// - Parameters:
    ///   - a: First number
    ///   - b: Second number
    /// - Returns: The GCD of a and b
    private func greatestCommonDivisor(_ a: Int, _ b: Int) -> Int {
        guard b != 0 else {
            return a
        }
        return greatestCommonDivisor(b, a % b)
    }

    // MARK: - Equatable

    /// Two fractions are equal if their simplified forms are equal
    static func == (lhs: Fraction, rhs: Fraction) -> Bool {
        let lhsSimplified = lhs.simplified()
        let rhsSimplified = rhs.simplified()
        return lhsSimplified.numerator == rhsSimplified.numerator &&
               lhsSimplified.denominator == rhsSimplified.denominator
    }
}

// MARK: - Arithmetic Operations

extension Fraction {
    /// Adds two fractions together
    /// - Parameters:
    ///   - lhs: Left-hand side fraction
    ///   - rhs: Right-hand side fraction
    /// - Returns: The sum of the two fractions, simplified
    static func + (lhs: Fraction, rhs: Fraction) -> Fraction {
        // Find common denominator
        let commonDenom = lhs.denominator * rhs.denominator
        let newNumerator = (lhs.numerator * rhs.denominator) + (rhs.numerator * lhs.denominator)
        return Fraction(numerator: newNumerator, denominator: commonDenom).simplified()
    }

    /// Subtracts one fraction from another
    /// - Parameters:
    ///   - lhs: Left-hand side fraction
    ///   - rhs: Right-hand side fraction
    /// - Returns: The difference of the two fractions, simplified
    static func - (lhs: Fraction, rhs: Fraction) -> Fraction {
        // Find common denominator
        let commonDenom = lhs.denominator * rhs.denominator
        let newNumerator = (lhs.numerator * rhs.denominator) - (rhs.numerator * lhs.denominator)
        return Fraction(numerator: newNumerator, denominator: commonDenom).simplified()
    }

    /// Multiplies two fractions together
    /// - Parameters:
    ///   - lhs: Left-hand side fraction
    ///   - rhs: Right-hand side fraction
    /// - Returns: The product of the two fractions, simplified
    static func * (lhs: Fraction, rhs: Fraction) -> Fraction {
        let newNumerator = lhs.numerator * rhs.numerator
        let newDenominator = lhs.denominator * rhs.denominator
        return Fraction(numerator: newNumerator, denominator: newDenominator).simplified()
    }

    /// Divides one fraction by another
    /// - Parameters:
    ///   - lhs: Left-hand side fraction (dividend)
    ///   - rhs: Right-hand side fraction (divisor)
    /// - Returns: The quotient of the two fractions, simplified
    static func / (lhs: Fraction, rhs: Fraction) -> Fraction {
        // Division is multiplication by reciprocal
        let newNumerator = lhs.numerator * rhs.denominator
        let newDenominator = lhs.denominator * rhs.numerator
        return Fraction(numerator: newNumerator, denominator: newDenominator).simplified()
    }

    /// Adds an integer to a fraction
    /// - Parameters:
    ///   - lhs: Fraction
    ///   - rhs: Integer
    /// - Returns: The sum, simplified
    static func + (lhs: Fraction, rhs: Int) -> Fraction {
        let newNumerator = lhs.numerator + (rhs * lhs.denominator)
        return Fraction(numerator: newNumerator, denominator: lhs.denominator).simplified()
    }

    /// Adds a fraction to an integer
    /// - Parameters:
    ///   - lhs: Integer
    ///   - rhs: Fraction
    /// - Returns: The sum, simplified
    static func + (lhs: Int, rhs: Fraction) -> Fraction {
        return rhs + lhs
    }

    /// Subtracts a fraction from an integer
    /// - Parameters:
    ///   - lhs: Integer
    ///   - rhs: Fraction
    /// - Returns: The difference, simplified
    static func - (lhs: Int, rhs: Fraction) -> Fraction {
        let newNumerator = (lhs * rhs.denominator) - rhs.numerator
        return Fraction(numerator: newNumerator, denominator: rhs.denominator).simplified()
    }

    /// Subtracts an integer from a fraction
    /// - Parameters:
    ///   - lhs: Fraction
    ///   - rhs: Integer
    /// - Returns: The difference, simplified
    static func - (lhs: Fraction, rhs: Int) -> Fraction {
        let newNumerator = lhs.numerator - (rhs * lhs.denominator)
        return Fraction(numerator: newNumerator, denominator: lhs.denominator).simplified()
    }

    /// Multiplies a fraction by an integer
    /// - Parameters:
    ///   - lhs: Fraction
    ///   - rhs: Integer
    /// - Returns: The product, simplified
    static func * (lhs: Fraction, rhs: Int) -> Fraction {
        let newNumerator = lhs.numerator * rhs
        return Fraction(numerator: newNumerator, denominator: lhs.denominator).simplified()
    }

    /// Multiplies an integer by a fraction
    /// - Parameters:
    ///   - lhs: Integer
    ///   - rhs: Fraction
    /// - Returns: The product, simplified
    static func * (lhs: Int, rhs: Fraction) -> Fraction {
        return rhs * lhs
    }

    /// Divides a fraction by an integer
    /// - Parameters:
    ///   - lhs: Fraction
    ///   - rhs: Integer
    /// - Returns: The quotient, simplified
    static func / (lhs: Fraction, rhs: Int) -> Fraction {
        let newDenominator = lhs.denominator * rhs
        return Fraction(numerator: lhs.numerator, denominator: newDenominator).simplified()
    }

    /// Divides an integer by a fraction
    /// - Parameters:
    ///   - lhs: Integer
    ///   - rhs: Fraction
    /// - Returns: The quotient, simplified
    static func / (lhs: Int, rhs: Fraction) -> Fraction {
        // Division is multiplication by reciprocal
        let newNumerator = lhs * rhs.denominator
        let newDenominator = rhs.numerator
        return Fraction(numerator: newNumerator, denominator: newDenominator).simplified()
    }
}

// MARK: - Word Representation

extension Fraction {
    /// Converts the fraction to a word representation for text-to-speech
    /// - Parameter language: The target language (English or Chinese)
    /// - Returns: A string representing the fraction in words
    /// Examples:
    ///   - English: 1/2 → "one half", 1/3 → "one third", 2/3 → "two thirds"
    ///   - Chinese: 1/2 → "二分之一", 1/3 → "三分之一", 2/3 → "三分之二"
    func toWords(language: LocalizationManager.Language = LocalizationManager.shared.currentLanguage) -> String {
        // Handle whole numbers
        if numerator % denominator == 0 {
            let wholeNumber = numerator / denominator
            return numberToWords(wholeNumber, language: language)
        }

        // Handle mixed numbers (improper fractions)
        if let mixed = toMixedNumber() {
            let wholePart = numberToWords(mixed.whole, language: language)
            let fractionPart = mixed.fraction.toWordsProper(language: language)

            if language == .chinese {
                return "\(wholePart)又\(fractionPart)"
            } else {
                return "\(wholePart) and \(fractionPart)"
            }
        }

        // Proper fraction
        return toWordsProper(language: language)
    }

    /// Converts a proper fraction to words (assumes numerator < denominator)
    private func toWordsProper(language: LocalizationManager.Language) -> String {
        if language == .chinese {
            // Chinese format: "{denominator}分之{numerator}"
            let denomWords = numberToWords(denominator, language: .chinese)
            let numerWords = numberToWords(numerator, language: .chinese)
            return "\(denomWords)分之\(numerWords)"
        } else {
            // English format: "{numerator} {denominator-ordinal}"
            let numerWords = numberToWords(numerator, language: .english)
            let denomWords = denominatorToWords(denominator)

            // Handle plural for numerator > 1 (except special cases like "one half")
            if numerator > 1 && !denomWords.hasSuffix("half") && !denomWords.hasSuffix("quarter") {
                return "\(numerWords) \(denomWords)s"
            } else {
                return "\(numerWords) \(denomWords)"
            }
        }
    }

    /// Converts an integer to its word representation
    private func numberToWords(_ number: Int, language: LocalizationManager.Language) -> String {
        // Use localization keys for numbers
        if number >= 0 && number <= 100 {
            return "fraction.number.\(number)".localized
        }
        // For numbers > 100, fall back to numeric representation
        return "\(number)"
    }

    /// Converts a denominator to its ordinal word representation (English only)
    /// Examples: 2 → "half", 3 → "third", 4 → "fourth", etc.
    private func denominatorToWords(_ denom: Int) -> String {
        // Check for special cases
        if denom == 2 {
            return "fraction.denominator.2".localized // "half"
        } else if denom == 4 {
            return "fraction.denominator.4".localized // "quarter"
        }

        // Use localization key for denominators
        if denom >= 2 && denom <= 100 {
            return "fraction.denominator.\(denom)".localized
        }

        // Fallback to numeric representation
        return "\(denom)th"
    }
}

// MARK: - Common Fractions

extension Fraction {
    /// Common fraction constants
    static let oneHalf = Fraction(numerator: 1, denominator: 2)
    static let oneThird = Fraction(numerator: 1, denominator: 3)
    static let twoThirds = Fraction(numerator: 2, denominator: 3)
    static let oneQuarter = Fraction(numerator: 1, denominator: 4)
    static let threeQuarters = Fraction(numerator: 3, denominator: 4)
    static let oneFifth = Fraction(numerator: 1, denominator: 5)
    static let oneSixth = Fraction(numerator: 1, denominator: 6)
    static let oneEighth = Fraction(numerator: 1, denominator: 8)
    static let oneTenth = Fraction(numerator: 1, denominator: 10)
    static let oneTwelfth = Fraction(numerator: 1, denominator: 12)
}
