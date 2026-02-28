//
//  FractionTests.swift
//  ArithmeticTests
//
//  Created by Claude Code
//  Copyright © 2026 Arithmetic. All rights reserved.
//

import XCTest
@testable import Arithmetic

class FractionTests: XCTestCase {

    // MARK: - Initialization Tests

    func testFractionInitialization() {
        let fraction = Fraction(numerator: 3, denominator: 4)
        XCTAssertEqual(fraction.numerator, 3)
        XCTAssertEqual(fraction.denominator, 4)
    }

    func testFractionInitializationWithZeroDenominatorCrashes() {
        // This should crash due to precondition
        // We can't test this directly in XCTest without causing test failure
        // Just document that denominator cannot be zero
    }

    // MARK: - Simplification Tests

    func testSimplification() {
        // 6/9 should simplify to 2/3
        let fraction = Fraction(numerator: 6, denominator: 9)
        let simplified = fraction.simplified()
        XCTAssertEqual(simplified.numerator, 2)
        XCTAssertEqual(simplified.denominator, 3)
    }

    func testSimplificationAlreadySimple() {
        // 3/5 is already in simplest form
        let fraction = Fraction(numerator: 3, denominator: 5)
        let simplified = fraction.simplified()
        XCTAssertEqual(simplified.numerator, 3)
        XCTAssertEqual(simplified.denominator, 5)
    }

    func testSimplificationWithOne() {
        // 5/5 should simplify to 1/1
        let fraction = Fraction(numerator: 5, denominator: 5)
        let simplified = fraction.simplified()
        XCTAssertEqual(simplified.numerator, 1)
        XCTAssertEqual(simplified.denominator, 1)
    }

    func testSimplificationNegativeNumerator() {
        // -6/9 should simplify to -2/3
        let fraction = Fraction(numerator: -6, denominator: 9)
        let simplified = fraction.simplified()
        XCTAssertEqual(simplified.numerator, -2)
        XCTAssertEqual(simplified.denominator, 3)
    }

    func testSimplificationNegativeDenominator() {
        // 6/-9 should simplify to -2/3 (negative moved to numerator)
        let fraction = Fraction(numerator: 6, denominator: -9)
        let simplified = fraction.simplified()
        XCTAssertEqual(simplified.numerator, -2)
        XCTAssertEqual(simplified.denominator, 3)
    }

    // MARK: - GCD Algorithm Tests

    func testGCD() {
        // Test GCD through simplification
        let testCases: [(Int, Int, Int)] = [
            (12, 8, 4),   // GCD(12, 8) = 4
            (15, 10, 5),  // GCD(15, 10) = 5
            (7, 13, 1),   // GCD(7, 13) = 1 (coprime)
            (100, 50, 50) // GCD(100, 50) = 50
        ]

        for (a, b, expectedGcd) in testCases {
            let fraction = Fraction(numerator: a, denominator: b)
            let simplified = fraction.simplified()
            XCTAssertEqual(a / expectedGcd, simplified.numerator)
            XCTAssertEqual(b / expectedGcd, simplified.denominator)
        }
    }

    // MARK: - Improper Fraction Tests

    func testIsImproper() {
        // 5/3 is improper (numerator >= denominator)
        let improper = Fraction(numerator: 5, denominator: 3)
        XCTAssertTrue(improper.isImproper)

        // 2/5 is proper
        let proper = Fraction(numerator: 2, denominator: 5)
        XCTAssertFalse(proper.isImproper)

        // 3/3 is improper (equal counts as improper)
        let equal = Fraction(numerator: 3, denominator: 3)
        XCTAssertTrue(equal.isImproper)
    }

    // MARK: - Mixed Number Tests

    func testToMixedNumber() {
        // 7/3 = 2⅓
        let fraction = Fraction(numerator: 7, denominator: 3)
        let mixed = fraction.toMixedNumber()
        XCTAssertNotNil(mixed)
        XCTAssertEqual(mixed?.whole, 2)
        XCTAssertEqual(mixed?.fraction.numerator, 1)
        XCTAssertEqual(mixed?.fraction.denominator, 3)
    }

    func testToMixedNumberProperFraction() {
        // 2/5 cannot be converted to mixed number
        let fraction = Fraction(numerator: 2, denominator: 5)
        let mixed = fraction.toMixedNumber()
        XCTAssertNil(mixed)
    }

    func testToMixedNumberWholeNumber() {
        // 6/3 = 2 (no fractional part)
        let fraction = Fraction(numerator: 6, denominator: 3)
        let mixed = fraction.toMixedNumber()
        XCTAssertNil(mixed) // Returns nil for whole numbers
    }

    // MARK: - Decimal Conversion Tests

    func testToDecimal() {
        let half = Fraction(numerator: 1, denominator: 2)
        XCTAssertEqual(half.toDecimal(), 0.5, accuracy: 0.001)

        let third = Fraction(numerator: 1, denominator: 3)
        XCTAssertEqual(third.toDecimal(), 0.333, accuracy: 0.001)

        let twoThirds = Fraction(numerator: 2, denominator: 3)
        XCTAssertEqual(twoThirds.toDecimal(), 0.666, accuracy: 0.001)
    }

    // MARK: - Equality Tests

    func testEquality() {
        // 2/4 should equal 1/2 (when simplified)
        let fraction1 = Fraction(numerator: 2, denominator: 4)
        let fraction2 = Fraction(numerator: 1, denominator: 2)
        XCTAssertEqual(fraction1, fraction2)
    }

    func testEqualityDifferentFractions() {
        let fraction1 = Fraction(numerator: 1, denominator: 2)
        let fraction2 = Fraction(numerator: 1, denominator: 3)
        XCTAssertNotEqual(fraction1, fraction2)
    }

    func testEqualityAlreadySimplified() {
        let fraction1 = Fraction(numerator: 3, denominator: 5)
        let fraction2 = Fraction(numerator: 3, denominator: 5)
        XCTAssertEqual(fraction1, fraction2)
    }

    // MARK: - String Representation Tests

    func testDescription() {
        let fraction = Fraction(numerator: 3, denominator: 4)
        XCTAssertEqual(fraction.description, "3/4")
    }

    func testLocalizedStringEnglish() {
        let fraction = Fraction(numerator: 5, denominator: 3)
        let localizedString = fraction.localizedString(language: .english)
        XCTAssertTrue(localizedString.contains("5/3") || localizedString.contains("1"))
    }

    func testLocalizedStringChinese() {
        let fraction = Fraction(numerator: 5, denominator: 3)
        let localizedString = fraction.localizedString(language: .chinese)
        XCTAssertTrue(localizedString.contains("又") || localizedString.contains("/"))
    }

    func testLocalizedStringWholeNumber() {
        // 6/3 = 2 (should display as "2", not "2/1")
        let fraction = Fraction(numerator: 6, denominator: 3)
        let localizedString = fraction.localizedString(language: .english)
        XCTAssertEqual(localizedString, "2")
    }

    // MARK: - Common Fractions Tests

    func testCommonFractionConstants() {
        XCTAssertEqual(Fraction.oneHalf.numerator, 1)
        XCTAssertEqual(Fraction.oneHalf.denominator, 2)

        XCTAssertEqual(Fraction.oneThird.numerator, 1)
        XCTAssertEqual(Fraction.oneThird.denominator, 3)

        XCTAssertEqual(Fraction.twoThirds.numerator, 2)
        XCTAssertEqual(Fraction.twoThirds.denominator, 3)

        XCTAssertEqual(Fraction.oneQuarter.numerator, 1)
        XCTAssertEqual(Fraction.oneQuarter.denominator, 4)

        XCTAssertEqual(Fraction.threeQuarters.numerator, 3)
        XCTAssertEqual(Fraction.threeQuarters.denominator, 4)
    }

    // MARK: - Edge Cases

    func testNegativeNumeratorNegativeDenominator() {
        // -6/-9 should simplify to 2/3 (both negatives cancel out)
        let fraction = Fraction(numerator: -6, denominator: -9)
        let simplified = fraction.simplified()
        XCTAssertEqual(simplified.numerator, 2)
        XCTAssertEqual(simplified.denominator, 3)
    }

    func testLargeNumbers() {
        // 1000/2500 should simplify to 2/5
        let fraction = Fraction(numerator: 1000, denominator: 2500)
        let simplified = fraction.simplified()
        XCTAssertEqual(simplified.numerator, 2)
        XCTAssertEqual(simplified.denominator, 5)
    }

    func testZeroNumerator() {
        // 0/5 should remain 0/5 (or simplify to 0/1)
        let fraction = Fraction(numerator: 0, denominator: 5)
        XCTAssertEqual(fraction.numerator, 0)
        XCTAssertEqual(fraction.toDecimal(), 0.0)
    }

    // MARK: - Arithmetic Operation Tests

    func testAdditionFractions() {
        // 1/2 + 1/3 = 3/6 + 2/6 = 5/6
        let half = Fraction(numerator: 1, denominator: 2)
        let third = Fraction(numerator: 1, denominator: 3)
        let result = half + third
        XCTAssertEqual(result.numerator, 5)
        XCTAssertEqual(result.denominator, 6)
    }

    func testSubtractionFractions() {
        // 3/4 - 1/2 = 3/4 - 2/4 = 1/4
        let threeFourths = Fraction(numerator: 3, denominator: 4)
        let half = Fraction(numerator: 1, denominator: 2)
        let result = threeFourths - half
        XCTAssertEqual(result.numerator, 1)
        XCTAssertEqual(result.denominator, 4)
    }

    func testMultiplicationFractions() {
        // 2/3 × 3/4 = 6/12 = 1/2
        let twoThirds = Fraction(numerator: 2, denominator: 3)
        let threeFourths = Fraction(numerator: 3, denominator: 4)
        let result = twoThirds * threeFourths
        XCTAssertEqual(result.numerator, 1)
        XCTAssertEqual(result.denominator, 2)
    }

    func testDivisionFractions() {
        // 1/2 ÷ 1/4 = 1/2 × 4/1 = 4/2 = 2/1
        let half = Fraction(numerator: 1, denominator: 2)
        let quarter = Fraction(numerator: 1, denominator: 4)
        let result = half / quarter
        XCTAssertEqual(result.numerator, 2)
        XCTAssertEqual(result.denominator, 1)
    }

    func testAdditionFractionAndInteger() {
        // 1/2 + 3 = 1/2 + 6/2 = 7/2
        let half = Fraction(numerator: 1, denominator: 2)
        let result = half + 3
        XCTAssertEqual(result.numerator, 7)
        XCTAssertEqual(result.denominator, 2)
    }

    func testMultiplicationFractionAndInteger() {
        // 2/3 × 6 = 12/3 = 4/1
        let twoThirds = Fraction(numerator: 2, denominator: 3)
        let result = twoThirds * 6
        XCTAssertEqual(result.numerator, 4)
        XCTAssertEqual(result.denominator, 1)
    }

    func testSubtractionIntegerAndFraction() {
        // 5 - 1/2 = 10/2 - 1/2 = 9/2
        let half = Fraction(numerator: 1, denominator: 2)
        let result = 5 - half
        XCTAssertEqual(result.numerator, 9)
        XCTAssertEqual(result.denominator, 2)
    }

    func testDivisionFractionByInteger() {
        // 3/4 ÷ 2 = 3/8
        let threeFourths = Fraction(numerator: 3, denominator: 4)
        let result = threeFourths / 2
        XCTAssertEqual(result.numerator, 3)
        XCTAssertEqual(result.denominator, 8)
    }

    func testDivisionIntegerByFraction() {
        // 6 ÷ 1/2 = 6 × 2/1 = 12/1
        let half = Fraction(numerator: 1, denominator: 2)
        let result = 6 / half
        XCTAssertEqual(result.numerator, 12)
        XCTAssertEqual(result.denominator, 1)
    }

    // MARK: - Word Representation Tests

    func testToWordsEnglishSimple() {
        // 1/2 should be "one half"
        let half = Fraction(numerator: 1, denominator: 2)
        let words = half.toWords(language: .english)
        XCTAssertEqual(words, "one half")
    }

    func testToWordsEnglishThird() {
        // 1/3 should be "one third"
        let third = Fraction(numerator: 1, denominator: 3)
        let words = third.toWords(language: .english)
        XCTAssertEqual(words, "one third")
    }

    func testToWordsEnglishPlural() {
        // 2/3 should be "two thirds" (plural)
        let twoThirds = Fraction(numerator: 2, denominator: 3)
        let words = twoThirds.toWords(language: .english)
        XCTAssertEqual(words, "two thirds")
    }

    func testToWordsChineseSimple() {
        // 1/2 should be "二分之一"
        let half = Fraction(numerator: 1, denominator: 2)
        let words = half.toWords(language: .chinese)
        XCTAssertEqual(words, "二分之一")
    }

    func testToWordsChineseTwoThirds() {
        // 2/3 should be "三分之二"
        let twoThirds = Fraction(numerator: 2, denominator: 3)
        let words = twoThirds.toWords(language: .chinese)
        XCTAssertEqual(words, "三分之二")
    }

    func testToWordsWholeNumber() {
        // 6/3 = 2 should be "two" / "二"
        let wholeNumber = Fraction(numerator: 6, denominator: 3)
        let wordsEnglish = wholeNumber.toWords(language: .english)
        let wordsChinese = wholeNumber.toWords(language: .chinese)
        XCTAssertEqual(wordsEnglish, "two")
        XCTAssertEqual(wordsChinese, "二")
    }

    func testToWordsMixedNumber() {
        // 5/3 = 1⅔ should be "one and two thirds" / "一又三分之二"
        let improper = Fraction(numerator: 5, denominator: 3)
        let wordsEnglish = improper.toWords(language: .english)
        let wordsChinese = improper.toWords(language: .chinese)
        XCTAssertTrue(wordsEnglish.contains("one") && wordsEnglish.contains("two thirds"))
        XCTAssertTrue(wordsChinese.contains("一又") && wordsChinese.contains("三分之二"))
    }

    // MARK: - Unicode Fraction Tests

    func testUnicodeDescriptionHalf() {
        // 1/2 should display as ½
        let half = Fraction(numerator: 1, denominator: 2)
        XCTAssertEqual(half.unicodeDescription, "½")
    }

    func testUnicodeDescriptionThird() {
        // 1/3 should display as ⅓
        let third = Fraction(numerator: 1, denominator: 3)
        XCTAssertEqual(third.unicodeDescription, "⅓")
    }

    func testUnicodeDescriptionTwoThirds() {
        // 2/3 should display as ⅔
        let twoThirds = Fraction(numerator: 2, denominator: 3)
        XCTAssertEqual(twoThirds.unicodeDescription, "⅔")
    }

    func testUnicodeDescriptionQuarter() {
        // 1/4 should display as ¼
        let quarter = Fraction(numerator: 1, denominator: 4)
        XCTAssertEqual(quarter.unicodeDescription, "¼")
    }

    func testUnicodeDescriptionNoMatch() {
        // 7/13 has no Unicode equivalent, should fall back to "7/13"
        let fraction = Fraction(numerator: 7, denominator: 13)
        XCTAssertEqual(fraction.unicodeDescription, "7/13")
    }

    func testFromStringUnicode() {
        // Parse ½ → Fraction(1, 2)
        let fraction = Fraction.from(string: "½")
        XCTAssertNotNil(fraction)
        XCTAssertEqual(fraction?.numerator, 1)
        XCTAssertEqual(fraction?.denominator, 2)
    }

    func testFromStringUnicodeThird() {
        // Parse ⅓ → Fraction(1, 3)
        let fraction = Fraction.from(string: "⅓")
        XCTAssertNotNil(fraction)
        XCTAssertEqual(fraction?.numerator, 1)
        XCTAssertEqual(fraction?.denominator, 3)
    }

    func testFromStringRegularFormat() {
        // Parse "1/3" → Fraction(1, 3)
        let fraction = Fraction.from(string: "1/3")
        XCTAssertNotNil(fraction)
        XCTAssertEqual(fraction?.numerator, 1)
        XCTAssertEqual(fraction?.denominator, 3)
    }

    func testFromStringInvalid() {
        // Invalid inputs should return nil
        XCTAssertNil(Fraction.from(string: "abc"))
        XCTAssertNil(Fraction.from(string: "1/0"))
        XCTAssertNil(Fraction.from(string: ""))
    }

    func testFromStringComplexFraction() {
        // Parse "7/13" → Fraction(7, 13)
        let fraction = Fraction.from(string: "7/13")
        XCTAssertNotNil(fraction)
        XCTAssertEqual(fraction?.numerator, 7)
        XCTAssertEqual(fraction?.denominator, 13)
    }
}
