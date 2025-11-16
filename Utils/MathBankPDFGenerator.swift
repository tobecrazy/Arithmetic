import Foundation
import UIKit
import PDFKit

class MathBankPDFGenerator {

    // Helper method to get localized string
    private static func localized(_ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String(format: format, arguments: args)
    }
    static func generatePDF(questions: [Question], difficulty: DifficultyLevel, count: Int) -> Data {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842)) // A4 size

        let data = pdfRenderer.pdfData { context in
            let questionsPerPage = 35  // 增加每页题目数量
            let totalPages = Int(ceil(Double(questions.count) / Double(questionsPerPage)))

            for pageIndex in 0..<totalPages {
                context.beginPage()

                let startIndex = pageIndex * questionsPerPage
                let endIndex = min(startIndex + questionsPerPage, questions.count)
                let pageQuestions = Array(questions[startIndex..<endIndex])

                drawPage(
                    context: context.cgContext,
                    questions: pageQuestions,
                    pageNumber: pageIndex + 1,
                    totalPages: totalPages,
                    difficulty: difficulty,
                    totalCount: count,
                    startQuestionNumber: startIndex + 1
                )
            }

            // 生成答案页
            generateAnswerPages(context: context, questions: questions, difficulty: difficulty)
        }

        return data
    }

    private static func drawPage(
        context: CGContext,
        questions: [Question],
        pageNumber: Int,
        totalPages: Int,
        difficulty: DifficultyLevel,
        totalCount: Int,
        startQuestionNumber: Int
    ) {
        let bounds = CGRect(x: 0, y: 0, width: 595, height: 842)

        // 设置字体
        let titleFont = UIFont.systemFont(ofSize: 18, weight: .bold)
        let headerFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        let questionFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        let pageNumberFont = UIFont.systemFont(ofSize: 12, weight: .regular)

        // 绘制标题
        let title = "\(localized("math_bank.pdf.title")) - \(difficulty.localizedName)"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.black
        ]
        let titleSize = title.size(withAttributes: titleAttributes)
        let titleRect = CGRect(
            x: (bounds.width - titleSize.width) / 2,
            y: 50,
            width: titleSize.width,
            height: titleSize.height
        )
        title.draw(in: titleRect, withAttributes: titleAttributes)

        // 绘制页眉信息
        let headerInfo = localized("math_bank.pdf.header_info", "\(totalCount)", "\(pageNumber)", "\(totalPages)")
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.darkGray
        ]
        let headerSize = headerInfo.size(withAttributes: headerAttributes)
        let headerRect = CGRect(
            x: (bounds.width - headerSize.width) / 2,
            y: 80,
            width: headerSize.width,
            height: headerSize.height
        )
        headerInfo.draw(in: headerRect, withAttributes: headerAttributes)

        // 绘制分割线
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(1.0)
        context.move(to: CGPoint(x: 50, y: 110))
        context.addLine(to: CGPoint(x: bounds.width - 50, y: 110))
        context.strokePath()

        // 绘制题目 - 优化布局以容纳更多题目
        let startY: CGFloat = 140
        let leftColumnX: CGFloat = 60     // 减少左边距
        let rightColumnX: CGFloat = 310   // 调整右列位置
        let questionSpacing: CGFloat = 20 // 减少行间距
        let columnWidth: CGFloat = 220    // 增加列宽

        let questionAttributes: [NSAttributedString.Key: Any] = [
            .font: questionFont,
            .foregroundColor: UIColor.black
        ]

        for (index, question) in questions.enumerated() {
            let questionNumber = startQuestionNumber + index
            let questionText = "(\(questionNumber)) \(question.questionText.replacingOccurrences(of: " = ?", with: " = ___"))"

            // 计算位置 (两列布局)
            let column = index % 2
            let row = index / 2
            let x = column == 0 ? leftColumnX : rightColumnX
            let y = startY + CGFloat(row) * questionSpacing

            let questionRect = CGRect(x: x, y: y, width: columnWidth, height: 20)
            questionText.draw(in: questionRect, withAttributes: questionAttributes)
        }

        // 绘制页脚
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let footerText = localized("math_bank.pdf.generated_time", dateFormatter.string(from: Date()))
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: pageNumberFont,
            .foregroundColor: UIColor.lightGray
        ]
        let footerSize = footerText.size(withAttributes: footerAttributes)
        let footerRect = CGRect(
            x: (bounds.width - footerSize.width) / 2,
            y: bounds.height - 50,
            width: footerSize.width,
            height: footerSize.height
        )
        footerText.draw(in: footerRect, withAttributes: footerAttributes)
    }

    private static func generateAnswerPages(context: UIGraphicsPDFRendererContext, questions: [Question], difficulty: DifficultyLevel) {
        let answersPerPage = 45  // 增加答案页每页数量
        let totalAnswerPages = Int(ceil(Double(questions.count) / Double(answersPerPage)))

        for pageIndex in 0..<totalAnswerPages {
            context.beginPage()

            let startIndex = pageIndex * answersPerPage
            let endIndex = min(startIndex + answersPerPage, questions.count)
            let pageQuestions = Array(questions[startIndex..<endIndex])

            drawAnswerPage(
                context: context.cgContext,
                questions: pageQuestions,
                pageNumber: pageIndex + 1,
                totalPages: totalAnswerPages,
                difficulty: difficulty,
                startQuestionNumber: startIndex + 1
            )
        }
    }

    private static func drawAnswerPage(
        context: CGContext,
        questions: [Question],
        pageNumber: Int,
        totalPages: Int,
        difficulty: DifficultyLevel,
        startQuestionNumber: Int
    ) {
        let bounds = CGRect(x: 0, y: 0, width: 595, height: 842)

        // 设置字体
        let titleFont = UIFont.systemFont(ofSize: 18, weight: .bold)
        let headerFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        let answerFont = UIFont.systemFont(ofSize: 14, weight: .regular)

        // 绘制标题
        let title = "\(localized("math_bank.pdf.answer_title")) - \(difficulty.localizedName)"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.black
        ]
        let titleSize = title.size(withAttributes: titleAttributes)
        let titleRect = CGRect(
            x: (bounds.width - titleSize.width) / 2,
            y: 50,
            width: titleSize.width,
            height: titleSize.height
        )
        title.draw(in: titleRect, withAttributes: titleAttributes)

        // 绘制页眉信息
        let headerInfo = localized("math_bank.pdf.answer_header_info", "\(pageNumber)", "\(totalPages)")
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.darkGray
        ]
        let headerSize = headerInfo.size(withAttributes: headerAttributes)
        let headerRect = CGRect(
            x: (bounds.width - headerSize.width) / 2,
            y: 80,
            width: headerSize.width,
            height: headerSize.height
        )
        headerInfo.draw(in: headerRect, withAttributes: headerAttributes)

        // 绘制分割线
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(1.0)
        context.move(to: CGPoint(x: 50, y: 110))
        context.addLine(to: CGPoint(x: bounds.width - 50, y: 110))
        context.strokePath()

        // 绘制答案 - 优化三列布局以容纳更多内容
        let startY: CGFloat = 140
        let column1X: CGFloat = 50    // 减少左边距
        let column2X: CGFloat = 230   // 调整中列位置
        let column3X: CGFloat = 410   // 调整右列位置
        let answerSpacing: CGFloat = 16  // 减少行间距
        let columnWidth: CGFloat = 160   // 增加列宽

        let answerAttributes: [NSAttributedString.Key: Any] = [
            .font: answerFont,
            .foregroundColor: UIColor.black
        ]

        for (index, question) in questions.enumerated() {
            let questionNumber = startQuestionNumber + index
            let answerText = "(\(questionNumber)) \(question.questionText.replacingOccurrences(of: " = ?", with: "")) = \(question.correctAnswer)"

            // 计算位置 (三列布局)
            let column = index % 3
            let row = index / 3
            let x = column == 0 ? column1X : (column == 1 ? column2X : column3X)
            let y = startY + CGFloat(row) * answerSpacing

            let answerRect = CGRect(x: x, y: y, width: columnWidth, height: 18)
            answerText.draw(in: answerRect, withAttributes: answerAttributes)
        }
    }
}