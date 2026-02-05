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
}
