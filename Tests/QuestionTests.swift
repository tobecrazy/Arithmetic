import XCTest
@testable import Arithmetic

// MARK: - Question Model Tests
class QuestionTests: XCTestCase {

    // MARK: - Initialization Tests

    func testTwoNumberQuestionInitialization() {
        let question = Question(number1: 5, number2: 3, operation: .addition)

        XCTAssertEqual(question.numbers.count, 2)
        XCTAssertEqual(question.numbers[0], 5)
        XCTAssertEqual(question.numbers[1], 3)
        XCTAssertEqual(question.operations.count, 1)
        XCTAssertEqual(question.operations[0], .addition)
        XCTAssertNotNil(question.id)
    }

    func testThreeNumberQuestionInitialization() {
        let question = Question(number1: 5, number2: 3, number3: 2, operation1: .addition, operation2: .multiplication)

        XCTAssertEqual(question.numbers.count, 3)
        XCTAssertEqual(question.numbers[0], 5)
        XCTAssertEqual(question.numbers[1], 3)
        XCTAssertEqual(question.numbers[2], 2)
        XCTAssertEqual(question.operations.count, 2)
        XCTAssertEqual(question.operations[0], .addition)
        XCTAssertEqual(question.operations[1], .multiplication)
    }

    // MARK: - correctAnswer Tests for Two-Number Operations

    func testCorrectAnswerAddition() {
        let question = Question(number1: 7, number2: 5, operation: .addition)
        XCTAssertEqual(question.correctAnswer, 12)
    }

    func testCorrectAnswerSubtraction() {
        let question = Question(number1: 10, number2: 4, operation: .subtraction)
        XCTAssertEqual(question.correctAnswer, 6)
    }

    func testCorrectAnswerMultiplication() {
        let question = Question(number1: 6, number2: 7, operation: .multiplication)
        XCTAssertEqual(question.correctAnswer, 42)
    }

    func testCorrectAnswerDivision() {
        let question = Question(number1: 20, number2: 4, operation: .division)
        XCTAssertEqual(question.correctAnswer, 5)
    }

    func testCorrectAnswerDivisionByZero() {
        let question = Question(number1: 10, number2: 0, operation: .division)
        XCTAssertEqual(question.correctAnswer, 0)
    }

    // MARK: - correctAnswer Tests for Three-Number Operations (PEMDAS)

    func testCorrectAnswerThreeNumbersAdditionThenMultiplication() {
        // 5 + 3 * 2 = 5 + 6 = 11 (multiplication first due to PEMDAS)
        let question = Question(number1: 5, number2: 3, number3: 2, operation1: .addition, operation2: .multiplication)
        XCTAssertEqual(question.correctAnswer, 11)
    }

    func testCorrectAnswerThreeNumbersSubtractionThenMultiplication() {
        // 10 - 2 * 3 = 10 - 6 = 4 (multiplication first due to PEMDAS)
        let question = Question(number1: 10, number2: 2, number3: 3, operation1: .subtraction, operation2: .multiplication)
        XCTAssertEqual(question.correctAnswer, 4)
    }

    func testCorrectAnswerThreeNumbersAdditionThenDivision() {
        // 10 + 8 / 4 = 10 + 2 = 12 (division first due to PEMDAS)
        let question = Question(number1: 10, number2: 8, number3: 4, operation1: .addition, operation2: .division)
        XCTAssertEqual(question.correctAnswer, 12)
    }

    func testCorrectAnswerThreeNumbersMultiplicationThenAddition() {
        // 3 * 4 + 5 = 12 + 5 = 17 (left to right, same precedence level for * first)
        let question = Question(number1: 3, number2: 4, number3: 5, operation1: .multiplication, operation2: .addition)
        XCTAssertEqual(question.correctAnswer, 17)
    }

    func testCorrectAnswerThreeNumbersDivisionThenSubtraction() {
        // 20 / 4 - 3 = 5 - 3 = 2 (left to right, same precedence level for / first)
        let question = Question(number1: 20, number2: 4, number3: 3, operation1: .division, operation2: .subtraction)
        XCTAssertEqual(question.correctAnswer, 2)
    }

    func testCorrectAnswerThreeNumbersMultiplicationThenDivision() {
        // 6 * 4 / 2 = 24 / 2 = 12 (left to right, same precedence)
        let question = Question(number1: 6, number2: 4, number3: 2, operation1: .multiplication, operation2: .division)
        XCTAssertEqual(question.correctAnswer, 12)
    }

    func testCorrectAnswerThreeNumbersAdditionThenSubtraction() {
        // 10 + 5 - 3 = 15 - 3 = 12 (left to right, same precedence)
        let question = Question(number1: 10, number2: 5, number3: 3, operation1: .addition, operation2: .subtraction)
        XCTAssertEqual(question.correctAnswer, 12)
    }

    // MARK: - isValid Tests

    func testIsValidAddition() {
        let question = Question(number1: 5, number2: 3, operation: .addition)
        XCTAssertTrue(question.isValid())
    }

    func testIsValidSubtraction() {
        let question = Question(number1: 10, number2: 3, operation: .subtraction)
        XCTAssertTrue(question.isValid())
    }

    func testIsValidMultiplication() {
        let question = Question(number1: 5, number2: 6, operation: .multiplication)
        XCTAssertTrue(question.isValid())
    }

    func testIsValidDivisionWithIntegerResult() {
        let question = Question(number1: 12, number2: 3, operation: .division)
        XCTAssertTrue(question.isValid())
    }

    func testIsInvalidDivisionWithNonIntegerResult() {
        let question = Question(number1: 10, number2: 3, operation: .division)
        XCTAssertFalse(question.isValid())
    }

    func testIsInvalidDivisionByZero() {
        let question = Question(number1: 10, number2: 0, operation: .division)
        XCTAssertFalse(question.isValid())
    }

    func testIsValidThreeNumberWithDivision() {
        // 10 + 6 / 2 = 10 + 3 = 13 (valid, 6/2 is integer)
        let question = Question(number1: 10, number2: 6, number3: 2, operation1: .addition, operation2: .division)
        XCTAssertTrue(question.isValid())
    }

    func testIsInvalidThreeNumberWithNonIntegerDivision() {
        // 10 + 7 / 2 = 10 + 3.5 (invalid, 7/2 is not integer)
        let question = Question(number1: 10, number2: 7, number3: 2, operation1: .addition, operation2: .division)
        XCTAssertFalse(question.isValid())
    }

    func testIsValidThreeNumberDivisionFirst() {
        // 12 / 3 + 5 = 4 + 5 = 9 (valid)
        let question = Question(number1: 12, number2: 3, number3: 5, operation1: .division, operation2: .addition)
        XCTAssertTrue(question.isValid())
    }

    func testIsInvalidThreeNumberNegativeResult() {
        // 3 - 5 - 2 = -4 (invalid, negative result)
        let question = Question(number1: 3, number2: 5, number3: 2, operation1: .subtraction, operation2: .subtraction)
        XCTAssertFalse(question.isValid())
    }

    // MARK: - questionText Tests

    func testQuestionTextTwoNumbers() {
        let question = Question(number1: 5, number2: 3, operation: .addition)
        XCTAssertEqual(question.questionText, "5 + 3 = ?")
    }

    func testQuestionTextThreeNumbers() {
        let question = Question(number1: 5, number2: 3, number3: 2, operation1: .addition, operation2: .multiplication)
        XCTAssertEqual(question.questionText, "5 + 3 × 2 = ?")
    }

    func testQuestionTextSubtraction() {
        let question = Question(number1: 10, number2: 4, operation: .subtraction)
        XCTAssertEqual(question.questionText, "10 - 4 = ?")
    }

    func testQuestionTextDivision() {
        let question = Question(number1: 20, number2: 5, operation: .division)
        XCTAssertEqual(question.questionText, "20 ÷ 5 = ?")
    }

    // MARK: - questionTextForSpeech Tests

    func testQuestionTextForSpeechTwoNumbers() {
        let question = Question(number1: 5, number2: 3, operation: .addition)
        let speechText = question.questionTextForSpeech
        XCTAssertTrue(speechText.contains("5 + 3"))
    }

    func testQuestionTextForSpeechThreeNumbers() {
        let question = Question(number1: 5, number2: 3, number3: 2, operation1: .multiplication, operation2: .addition)
        let speechText = question.questionTextForSpeech
        XCTAssertTrue(speechText.contains("5 × 3 + 2"))
    }

    // MARK: - Equality Tests

    func testQuestionEqualityTrue() {
        let question1 = Question(number1: 5, number2: 3, operation: .addition)
        let question2 = Question(number1: 5, number2: 3, operation: .addition)
        XCTAssertTrue(question1 == question2)
    }

    func testQuestionEqualityFalseDifferentNumbers() {
        let question1 = Question(number1: 5, number2: 3, operation: .addition)
        let question2 = Question(number1: 5, number2: 4, operation: .addition)
        XCTAssertFalse(question1 == question2)
    }

    func testQuestionEqualityFalseDifferentOperation() {
        let question1 = Question(number1: 5, number2: 3, operation: .addition)
        let question2 = Question(number1: 5, number2: 3, operation: .subtraction)
        XCTAssertFalse(question1 == question2)
    }

    // MARK: - NSCoding Tests

    func testQuestionNSCodingTwoNumbers() {
        let original = Question(number1: 7, number2: 4, operation: .multiplication)

        // Archive
        let data = try! NSKeyedArchiver.archivedData(withRootObject: original, requiringSecureCoding: false)

        // Unarchive
        let decoded = try! NSKeyedUnarchiver.unarchivedObject(ofClass: Question.self, from: data)

        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.numbers, original.numbers)
        XCTAssertEqual(decoded?.operations, original.operations)
        XCTAssertEqual(decoded?.correctAnswer, original.correctAnswer)
    }

    func testQuestionNSCodingThreeNumbers() {
        let original = Question(number1: 10, number2: 5, number3: 2, operation1: .addition, operation2: .multiplication)

        // Archive
        let data = try! NSKeyedArchiver.archivedData(withRootObject: original, requiringSecureCoding: false)

        // Unarchive
        let decoded = try! NSKeyedUnarchiver.unarchivedObject(ofClass: Question.self, from: data)

        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.numbers, original.numbers)
        XCTAssertEqual(decoded?.operations, original.operations)
        XCTAssertEqual(decoded?.correctAnswer, original.correctAnswer)
    }
}

// MARK: - Operation Enum Tests
class OperationTests: XCTestCase {

    func testOperationSymbols() {
        XCTAssertEqual(Question.Operation.addition.symbol, "+")
        XCTAssertEqual(Question.Operation.subtraction.symbol, "-")
        XCTAssertEqual(Question.Operation.multiplication.symbol, "×")
        XCTAssertEqual(Question.Operation.division.symbol, "÷")
    }

    func testOperationPrecedence() {
        XCTAssertEqual(Question.Operation.addition.precedence, 1)
        XCTAssertEqual(Question.Operation.subtraction.precedence, 1)
        XCTAssertEqual(Question.Operation.multiplication.precedence, 2)
        XCTAssertEqual(Question.Operation.division.precedence, 2)
    }

    func testOperationPrecedenceOrdering() {
        XCTAssertLessThan(Question.Operation.addition.precedence, Question.Operation.multiplication.precedence)
        XCTAssertLessThan(Question.Operation.subtraction.precedence, Question.Operation.division.precedence)
    }

    func testOperationRawValues() {
        XCTAssertEqual(Question.Operation.addition.rawValue, "+")
        XCTAssertEqual(Question.Operation.subtraction.rawValue, "-")
        XCTAssertEqual(Question.Operation.multiplication.rawValue, "×")
        XCTAssertEqual(Question.Operation.division.rawValue, "÷")
    }

    func testOperationCaseIterable() {
        let allCases = Question.Operation.allCases
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.addition))
        XCTAssertTrue(allCases.contains(.subtraction))
        XCTAssertTrue(allCases.contains(.multiplication))
        XCTAssertTrue(allCases.contains(.division))
    }
}

// MARK: - SolutionMethod Enum Tests
class SolutionMethodTests: XCTestCase {

    func testSolutionMethodRawValues() {
        XCTAssertEqual(Question.SolutionMethod.breakingTen.rawValue, "breaking_ten")
        XCTAssertEqual(Question.SolutionMethod.borrowingTen.rawValue, "borrowing_ten")
        XCTAssertEqual(Question.SolutionMethod.makingTen.rawValue, "making_ten")
        XCTAssertEqual(Question.SolutionMethod.levelingTen.rawValue, "leveling_ten")
        XCTAssertEqual(Question.SolutionMethod.multiplicationTable.rawValue, "multiplication_table")
        XCTAssertEqual(Question.SolutionMethod.decompositionMultiplication.rawValue, "decomposition_multiplication")
        XCTAssertEqual(Question.SolutionMethod.divisionVerification.rawValue, "division_verification")
        XCTAssertEqual(Question.SolutionMethod.groupingDivision.rawValue, "grouping_division")
        XCTAssertEqual(Question.SolutionMethod.standard.rawValue, "standard")
    }

    func testSolutionMethodLocalizedNameNotEmpty() {
        for method in [Question.SolutionMethod.breakingTen, .borrowingTen, .makingTen, .levelingTen,
                       .multiplicationTable, .decompositionMultiplication, .divisionVerification,
                       .groupingDivision, .standard] {
            XCTAssertFalse(method.localizedName.isEmpty, "Localized name for \(method.rawValue) should not be empty")
        }
    }
}

// MARK: - Solution Method Selection Tests
class SolutionMethodSelectionTests: XCTestCase {

    func testGetSolutionMethodStandardWithoutDifficulty() {
        let question = Question(number1: 5, number2: 3, operation: .addition)
        let method = question.getSolutionMethod(for: nil)
        XCTAssertEqual(method, .standard)
    }

    func testGetSolutionMethodMakingTenForLevel2Addition() {
        // 8 + 5 = 13, should use making ten (8 needs 2 to make 10, split 5 into 2 and 3)
        let question = Question(number1: 8, number2: 5, operation: .addition)
        let method = question.getSolutionMethod(for: .level2)
        XCTAssertEqual(method, .makingTen)
    }

    func testGetSolutionMethodBreakingTenForLevel2Subtraction() {
        // 15 - 7 = 8, should use breaking ten (15 = 10 + 5, ones digit 5 < 7)
        let question = Question(number1: 15, number2: 7, operation: .subtraction)
        let method = question.getSolutionMethod(for: .level2)
        XCTAssertEqual(method, .breakingTen)
    }

    func testGetSolutionMethodMultiplicationTableForLevel4() {
        let question = Question(number1: 6, number2: 7, operation: .multiplication)
        let method = question.getSolutionMethod(for: .level4)
        XCTAssertEqual(method, .multiplicationTable)
    }

    func testGetSolutionMethodDecompositionForLevel5() {
        // 12 * 5 should use decomposition (12 > 10)
        let question = Question(number1: 12, number2: 5, operation: .multiplication)
        let method = question.getSolutionMethod(for: .level5)
        XCTAssertEqual(method, .decompositionMultiplication)
    }

    func testGetSolutionMethodDivisionVerificationForLevel4() {
        let question = Question(number1: 18, number2: 6, operation: .division)
        let method = question.getSolutionMethod(for: .level4)
        XCTAssertEqual(method, .divisionVerification)
    }

    func testGetSolutionMethodStandardForLevel6() {
        // Level 6 uses standard method for most operations
        let question = Question(number1: 50, number2: 25, operation: .addition)
        let method = question.getSolutionMethod(for: .level6)
        XCTAssertEqual(method, .standard)
    }
}

// MARK: - Solution Steps Tests
class SolutionStepsTests: XCTestCase {

    func testGetSolutionStepsNotEmpty() {
        let question = Question(number1: 5, number2: 3, operation: .addition)
        let steps = question.getSolutionSteps(for: .level1)
        XCTAssertFalse(steps.isEmpty)
    }

    func testGetSolutionStepsContainsNumbers() {
        let question = Question(number1: 7, number2: 4, operation: .addition)
        let steps = question.getSolutionSteps(for: .level1)
        XCTAssertTrue(steps.contains("7") || steps.contains("4") || steps.contains("11"))
    }

    func testGetSolutionStepsForMultiplication() {
        let question = Question(number1: 6, number2: 8, operation: .multiplication)
        let steps = question.getSolutionSteps(for: .level4)
        XCTAssertFalse(steps.isEmpty)
        XCTAssertTrue(steps.contains("48") || steps.contains("6") || steps.contains("8"))
    }

    func testGetSolutionStepsForDivision() {
        let question = Question(number1: 24, number2: 6, operation: .division)
        let steps = question.getSolutionSteps(for: .level4)
        XCTAssertFalse(steps.isEmpty)
    }

    func testGetSolutionStepsForThreeNumbersLevel2() {
        let question = Question(number1: 8, number2: 5, number3: 3, operation1: .addition, operation2: .subtraction)
        let steps = question.getSolutionSteps(for: .level2)
        XCTAssertFalse(steps.isEmpty)
    }
}
