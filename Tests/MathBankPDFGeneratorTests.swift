import XCTest
import PDFKit
@testable import Arithmetic

final class MathBankPDFGeneratorTests: XCTestCase {

    private func makeQuestions(count: Int) -> [Question] {
        guard count > 0 else { return [] }
        return (1...count).map { value in
            Question(number1: value, number2: value + 1, operation: .addition)
        }
    }

    func testGeneratePDFProducesA4PagesAndAnswerPage() {
        let questions = makeQuestions(count: 4)
        let data = MathBankPDFGenerator.generatePDF(
            questions: questions,
            difficulty: .level1,
            count: questions.count
        )

        XCTAssertFalse(data.isEmpty)

        let document = PDFDocument(data: data)
        XCTAssertNotNil(document)
        XCTAssertEqual(document?.pageCount, 2)

        let expectedWidth: CGFloat = 210.0 / 25.4 * 72.0
        let expectedHeight: CGFloat = 297.0 / 25.4 * 72.0
        let pageBounds = document?.page(at: 0)?.bounds(for: .mediaBox) ?? .zero

        XCTAssertEqual(pageBounds.size.width, expectedWidth, accuracy: 0.6)
        XCTAssertEqual(pageBounds.size.height, expectedHeight, accuracy: 0.6)
    }

    func testGenerateDuplexPDFCreatesQuestionAndAnswerPages() {
        let questions = makeQuestions(count: 4)
        let data = MathBankPDFGenerator.generateDuplexPDF(
            questions: questions,
            difficulty: .level1,
            count: questions.count
        )

        XCTAssertFalse(data.isEmpty)

        let document = PDFDocument(data: data)
        XCTAssertNotNil(document)
        XCTAssertEqual(document?.pageCount, 2)
    }

    // MARK: - Fraction Answer Tests

    func testFractionQuestionCorrectAnswerText() {
        // Test: 1/6 + 7 = 43/6
        let fraction = Fraction(numerator: 1, denominator: 6)
        let question = Question(operand1: fraction, operand2: 7, operation: .addition, difficultyLevel: .level7)

        // Verify the answer is correctly computed as a fraction
        XCTAssertEqual(question.answerType, .fraction, "1/6 + 7 should result in a fraction answer")
        XCTAssertNotNil(question.fractionAnswer, "Fraction answer should not be nil")
        XCTAssertEqual(question.fractionAnswer?.numerator, 43, "Numerator should be 43")
        XCTAssertEqual(question.fractionAnswer?.denominator, 6, "Denominator should be 6")

        // Verify correctAnswerText returns the fraction string, not "0"
        let answerText = question.correctAnswerText
        XCTAssertNotEqual(answerText, "0", "Fraction answer should not be 0")
        XCTAssertEqual(answerText, "43/6", "correctAnswerText should return '43/6'")
    }

    func testFractionQuestionWithWholeNumberResult() {
        // Test: 1/2 + 1/2 = 1 (whole number)
        let frac1 = Fraction(numerator: 1, denominator: 2)
        let frac2 = Fraction(numerator: 1, denominator: 2)
        let question = Question(operand1: frac1, operand2: frac2, operation: .addition, difficultyLevel: .level7)

        // Verify the answer is an integer (whole number result)
        XCTAssertEqual(question.answerType, .integer, "1/2 + 1/2 should result in an integer answer")
        XCTAssertEqual(question.computedAnswer, 1, "Computed answer should be 1")
        XCTAssertEqual(question.correctAnswerText, "1", "correctAnswerText should return '1'")
    }

    func testFractionQuestionWithUnicodeFraction() {
        // Test: 3/4 - 1/4 = 1/2 (has Unicode representation)
        let frac1 = Fraction(numerator: 3, denominator: 4)
        let frac2 = Fraction(numerator: 1, denominator: 4)
        let question = Question(operand1: frac1, operand2: frac2, operation: .subtraction, difficultyLevel: .level7)

        // Verify the answer is a fraction
        XCTAssertEqual(question.answerType, .fraction, "3/4 - 1/4 should result in a fraction answer")
        XCTAssertNotNil(question.fractionAnswer)
        XCTAssertEqual(question.fractionAnswer?.numerator, 1)
        XCTAssertEqual(question.fractionAnswer?.denominator, 2)

        // Verify correctAnswerText returns Unicode fraction
        let answerText = question.correctAnswerText
        XCTAssertEqual(answerText, "½", "correctAnswerText should return Unicode '½'")
    }

    func testGeneratePDFWithFractionQuestionsDoesNotShowZero() {
        // Create fraction questions for Level 7
        let fraction = Fraction(numerator: 1, denominator: 6)
        let question1 = Question(operand1: fraction, operand2: 7, operation: .addition, difficultyLevel: .level7)

        let questions = [question1]
        let data = MathBankPDFGenerator.generatePDF(
            questions: questions,
            difficulty: .level7,
            count: questions.count
        )

        // Verify PDF is generated
        XCTAssertFalse(data.isEmpty)

        let document = PDFDocument(data: data)
        XCTAssertNotNil(document)

        // Extract text from the answer page (page 1, 0-indexed)
        if let page = document?.page(at: 1) {
            let pageText = page.string ?? ""
            // The answer page should contain the fraction answer "43/6", not "0"
            XCTAssertTrue(pageText.contains("43/6"), "Answer page should contain '43/6' for fraction answer")
            // Should NOT show "= 0" as the answer
            XCTAssertFalse(pageText.contains("= 0"), "Answer page should not show '= 0' for fraction questions")
        }
    }
}
