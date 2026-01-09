import Foundation
import UIKit
import PDFKit

class MathBankPDFGenerator {

    // A4纸张尺寸 (点)
    private static let a4Width: CGFloat = 595.0
    private static let a4Height: CGFloat = 842.0

    // 页面边距配置
    private static let pageMargin: CGFloat = 15.0          // 页面边距（减少以节省空间）
    private static let headerHeight: CGFloat = 60.0        // 页眉高度（优化后）
    private static let footerHeight: CGFloat = 30.0        // 页脚高度（优化后）

    // 布局配置
    private static let questionSpacing: CGFloat = 16.0     // 题目行间距
    private static let answerSpacing: CGFloat = 14.0       // 答案行间距

    // Helper method to get localized string
    private static func localized(_ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String(format: format, arguments: args)
    }

    static func generatePDF(questions: [Question], difficulty: DifficultyLevel, count: Int) -> Data {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: a4Width, height: a4Height))

        let data = pdfRenderer.pdfData { context in
            // 计算每页可容纳的题目数量（基于优化后的布局）
            let availableHeight = a4Height - headerHeight - footerHeight - (pageMargin * 2)
            let questionsPerColumn = Int(availableHeight / questionSpacing)
            let questionsPerPage = questionsPerColumn * 2  // 两列布局

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
        let bounds = CGRect(x: 0, y: 0, width: a4Width, height: a4Height)

        // 设置字体（优化字体大小以节省空间）
        let titleFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        let headerFont = UIFont.systemFont(ofSize: 11, weight: .medium)
        let questionFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        let pageNumberFont = UIFont.systemFont(ofSize: 9, weight: .regular)

        // 绘制标题（居中，紧凑布局）
        let title = "\(localized("math_bank.pdf.title")) - \(difficulty.localizedName)"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.black
        ]
        let titleSize = title.size(withAttributes: titleAttributes)
        let titleRect = CGRect(
            x: (bounds.width - titleSize.width) / 2,
            y: pageMargin + 5,
            width: titleSize.width,
            height: titleSize.height
        )
        title.draw(in: titleRect, withAttributes: titleAttributes)

        // 绘制页眉信息（紧凑单行显示）
        let headerInfo = "\(localized("math_bank.pdf.total")): \(totalCount) | \(localized("math_bank.pdf.page")): \(pageNumber)/\(totalPages)"
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.darkGray
        ]
        let headerSize = headerInfo.size(withAttributes: headerAttributes)
        let headerRect = CGRect(
            x: (bounds.width - headerSize.width) / 2,
            y: pageMargin + 24,
            width: headerSize.width,
            height: headerSize.height
        )
        headerInfo.draw(in: headerRect, withAttributes: headerAttributes)

        // 绘制细分割线
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(0.5)
        let lineY = pageMargin + 42
        context.move(to: CGPoint(x: pageMargin, y: lineY))
        context.addLine(to: CGPoint(x: bounds.width - pageMargin, y: lineY))
        context.strokePath()

        // 计算布局参数（充分利用页面宽度）
        let contentWidth = bounds.width - (pageMargin * 2)
        let columnWidth = (contentWidth - 20) / 2  // 两列之间留20pt间距
        let leftColumnX = pageMargin
        let rightColumnX = pageMargin + columnWidth + 20
        let startY = lineY + 15

        let questionAttributes: [NSAttributedString.Key: Any] = [
            .font: questionFont,
            .foregroundColor: UIColor.black
        ]

        // 绘制题目（两列紧凑布局）
        for (index, question) in questions.enumerated() {
            let questionNumber = startQuestionNumber + index
            let questionText = "(\(questionNumber)) \(question.questionText.replacingOccurrences(of: " = ?", with: " = ___"))"

            // 计算位置（两列布局）
            let column = index % 2
            let row = index / 2
            let x = column == 0 ? leftColumnX : rightColumnX
            let y = startY + CGFloat(row) * questionSpacing

            let questionRect = CGRect(x: x, y: y, width: columnWidth, height: questionSpacing)
            questionText.draw(in: questionRect, withAttributes: questionAttributes)
        }

        // 绘制页脚（紧凑显示在底部）
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let footerText = dateFormatter.string(from: Date())
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: pageNumberFont,
            .foregroundColor: UIColor.lightGray
        ]
        let footerSize = footerText.size(withAttributes: footerAttributes)
        let footerRect = CGRect(
            x: (bounds.width - footerSize.width) / 2,
            y: bounds.height - pageMargin - 12,
            width: footerSize.width,
            height: footerSize.height
        )
        footerText.draw(in: footerRect, withAttributes: footerAttributes)

        // 绘制底部页码（右侧）
        let pageNumText = "\(pageNumber)"
        let pageNumRect = CGRect(
            x: bounds.width - pageMargin - 30,
            y: bounds.height - pageMargin - 12,
            width: 30,
            height: 12
        )
        pageNumText.draw(in: pageNumRect, withAttributes: footerAttributes)
    }

    private static func generateAnswerPages(context: UIGraphicsPDFRendererContext, questions: [Question], difficulty: DifficultyLevel) {
        // 计算每页可容纳的答案数量（三列紧凑布局）
        let availableHeight = a4Height - headerHeight - footerHeight - (pageMargin * 2)
        let answersPerColumn = Int(availableHeight / answerSpacing)
        let answersPerPage = answersPerColumn * 3  // 三列布局

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
        let bounds = CGRect(x: 0, y: 0, width: a4Width, height: a4Height)

        // 设置字体（优化字体大小以节省空间）
        let titleFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        let headerFont = UIFont.systemFont(ofSize: 11, weight: .medium)
        let answerFont = UIFont.systemFont(ofSize: 11, weight: .regular)
        let pageNumberFont = UIFont.systemFont(ofSize: 9, weight: .regular)

        // 绘制标题（居中，紧凑布局）
        let title = "\(localized("math_bank.pdf.answer_title")) - \(difficulty.localizedName)"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.black
        ]
        let titleSize = title.size(withAttributes: titleAttributes)
        let titleRect = CGRect(
            x: (bounds.width - titleSize.width) / 2,
            y: pageMargin + 5,
            width: titleSize.width,
            height: titleSize.height
        )
        title.draw(in: titleRect, withAttributes: titleAttributes)

        // 绘制页眉信息（紧凑单行显示）
        let headerInfo = "\(localized("math_bank.pdf.page")): \(pageNumber)/\(totalPages)"
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.darkGray
        ]
        let headerSize = headerInfo.size(withAttributes: headerAttributes)
        let headerRect = CGRect(
            x: (bounds.width - headerSize.width) / 2,
            y: pageMargin + 24,
            width: headerSize.width,
            height: headerSize.height
        )
        headerInfo.draw(in: headerRect, withAttributes: headerAttributes)

        // 绘制细分割线
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(0.5)
        let lineY = pageMargin + 42
        context.move(to: CGPoint(x: pageMargin, y: lineY))
        context.addLine(to: CGPoint(x: bounds.width - pageMargin, y: lineY))
        context.strokePath()

        // 计算三列布局参数（充分利用页面宽度）
        let contentWidth = bounds.width - (pageMargin * 2)
        let columnSpacing: CGFloat = 15  // 列间距
        let totalColumnSpacing = columnSpacing * 2
        let columnWidth = (contentWidth - totalColumnSpacing) / 3
        let column1X = pageMargin
        let column2X = pageMargin + columnWidth + columnSpacing
        let column3X = pageMargin + (columnWidth + columnSpacing) * 2
        let startY = lineY + 12

        let answerAttributes: [NSAttributedString.Key: Any] = [
            .font: answerFont,
            .foregroundColor: UIColor.black
        ]

        // 绘制答案（三列紧凑布局）
        for (index, question) in questions.enumerated() {
            let questionNumber = startQuestionNumber + index
            let answerText = "(\(questionNumber)) \(question.questionText.replacingOccurrences(of: " = ?", with: "")) = \(question.correctAnswer)"

            // 计算位置（三列布局）
            let column = index % 3
            let row = index / 3
            let x: CGFloat
            switch column {
            case 0: x = column1X
            case 1: x = column2X
            default: x = column3X
            }
            let y = startY + CGFloat(row) * answerSpacing

            let answerRect = CGRect(x: x, y: y, width: columnWidth, height: answerSpacing)
            answerText.draw(in: answerRect, withAttributes: answerAttributes)
        }

        // 绘制页脚（紧凑显示在底部）
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let footerText = dateFormatter.string(from: Date())
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: pageNumberFont,
            .foregroundColor: UIColor.lightGray
        ]
        let footerSize = footerText.size(withAttributes: footerAttributes)
        let footerRect = CGRect(
            x: (bounds.width - footerSize.width) / 2,
            y: bounds.height - pageMargin - 12,
            width: footerSize.width,
            height: footerSize.height
        )
        footerText.draw(in: footerRect, withAttributes: footerAttributes)

        // 绘制底部页码（右侧）
        let pageNumText = "\(pageNumber)"
        let pageNumRect = CGRect(
            x: bounds.width - pageMargin - 30,
            y: bounds.height - pageMargin - 12,
            width: 30,
            height: 12
        )
        pageNumText.draw(in: pageNumRect, withAttributes: footerAttributes)
    }

    // MARK: - 新增：合页打印模式（题目和答案在同一张纸的正反面）
    static func generateDuplexPDF(questions: [Question], difficulty: DifficultyLevel, count: Int) -> Data {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: a4Width, height: a4Height))

        let data = pdfRenderer.pdfData { context in
            // 计算每页可容纳的题目数量
            let availableHeight = a4Height - headerHeight - footerHeight - (pageMargin * 2)
            let questionsPerColumn = Int(availableHeight / questionSpacing)
            let questionsPerPage = questionsPerColumn * 2

            let totalPages = Int(ceil(Double(questions.count) / Double(questionsPerPage)))

            // 生成题目页（正面）
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

            // 生成答案页（反面）- 使用相同的页数
            for pageIndex in 0..<totalPages {
                context.beginPage()

                let startIndex = pageIndex * questionsPerPage
                let endIndex = min(startIndex + questionsPerPage, questions.count)
                let pageQuestions = Array(questions[startIndex..<endIndex])

                drawAnswerPage(
                    context: context.cgContext,
                    questions: pageQuestions,
                    pageNumber: pageIndex + 1,
                    totalPages: totalPages,
                    difficulty: difficulty,
                    startQuestionNumber: startIndex + 1
                )
            }
        }

        return data
    }
}