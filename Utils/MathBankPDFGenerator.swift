import Foundation
import UIKit
import PDFKit

class MathBankPDFGenerator {

    // A4纸张尺寸 (点) - 基于毫米换算，提升打印兼容性
    private static let pointsPerInch: CGFloat = 72.0
    private static let mmPerInch: CGFloat = 25.4
    private static let a4Width: CGFloat = 210.0 / mmPerInch * pointsPerInch
    private static let a4Height: CGFloat = 297.0 / mmPerInch * pointsPerInch

    // 页面边距配置（A4打印安全边距）
    private static let pageMargin: CGFloat = 36.0          // 0.5" ≈ 12.7mm

    // 页眉/页脚与正文间距配置
    private static let headerTopPadding: CGFloat = 4.0
    private static let headerSpacing: CGFloat = 4.0
    private static let headerRuleSpacing: CGFloat = 6.0
    private static let headerToContentSpacing: CGFloat = 10.0
    private static let footerTopSpacing: CGFloat = 8.0

    // 布局配置
    private static let questionColumnGap: CGFloat = 28.0
    private static let answerColumnGap: CGFloat = 18.0
    private static let questionLineSpacing: CGFloat = 5.0
    private static let answerLineSpacing: CGFloat = 4.0

    // 颜色主题（打印友好：低饱和度、足够对比度）
    private static let accentColor = UIColor.systemOrange
    private static let pageBackgroundColor = UIColor.white
    private static let primaryTextColor = UIColor(white: 0.12, alpha: 1.0)
    private static let secondaryTextColor = UIColor(white: 0.42, alpha: 1.0)
    private static let subtleTextColor = UIColor(white: 0.68, alpha: 1.0)
    private static let headerBackgroundColor = UIColor(red: 1.0, green: 0.97, blue: 0.93, alpha: 1.0)
    private static let answerHeaderBackgroundColor = UIColor(red: 0.94, green: 0.97, blue: 1.0, alpha: 1.0)
    private static let dividerColor = UIColor(white: 0.86, alpha: 1.0)

    // 页眉样式
    private static let headerCornerRadius: CGFloat = 12.0
    private static let headerInnerPaddingX: CGFloat = 14.0
    private static let headerAccentHeight: CGFloat = 3.0
    private static let titleMarkSize: CGFloat = 8.0
    private static let titleMarkSpacing: CGFloat = 8.0
    private static let badgeFont = roundedFont(UIFont.systemFont(ofSize: 10, weight: .semibold))
    private static let badgePaddingX: CGFloat = 10.0
    private static let badgePaddingY: CGFloat = 4.0

    // 题号/正文布局（让不同位数的题号对齐，视觉更松弛）
    private static let numberToBodySpacing: CGFloat = 6.0
    private static let questionNumberColumnWidth: CGFloat = 34.0
    private static let answerNumberColumnWidth: CGFloat = 28.0

    // Helper method to get localized string
    private static func localized(_ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String(format: format, arguments: args)
    }

    private static func roundedFont(_ base: UIFont) -> UIFont {
        guard let descriptor = base.fontDescriptor.withDesign(.rounded) else {
            return base
        }
        return UIFont(descriptor: descriptor, size: base.pointSize)
    }

    // 字体配置（与布局计算保持一致）
    private static let titleFont = roundedFont(UIFont.systemFont(ofSize: 16, weight: .bold))
    private static let headerFont = roundedFont(UIFont.systemFont(ofSize: 11, weight: .medium))
    private static let questionFont = roundedFont(UIFont.systemFont(ofSize: 13, weight: .regular))
    private static let questionNumberFont = roundedFont(UIFont.systemFont(ofSize: 12, weight: .semibold))
    private static let answerFont = roundedFont(UIFont.systemFont(ofSize: 11, weight: .regular))
    private static let answerNumberFont = roundedFont(UIFont.systemFont(ofSize: 10, weight: .semibold))
    private static let footerFont = roundedFont(UIFont.systemFont(ofSize: 9, weight: .regular))

    private static var contentStartY: CGFloat {
        pageMargin
            + headerTopPadding
            + titleFont.lineHeight
            + headerSpacing
            + headerFont.lineHeight
            + headerRuleSpacing
            + headerToContentSpacing
    }

    private static var footerY: CGFloat {
        a4Height - pageMargin - footerFont.lineHeight
    }

    private static var availableContentHeight: CGFloat {
        footerY - footerTopSpacing - contentStartY
    }

    private static func rowHeight(for font: UIFont, lineSpacing: CGFloat) -> CGFloat {
        ceil(font.lineHeight + lineSpacing)
    }

    private static func drawNumberedLine(
        number: Int,
        body: String,
        numberAttributes: [NSAttributedString.Key: Any],
        bodyAttributes: [NSAttributedString.Key: Any],
        numberColumnWidth: CGFloat,
        in rect: CGRect
    ) {
        let numberString = "(\(number))"

        let numberRect = CGRect(x: rect.minX, y: rect.minY, width: numberColumnWidth, height: rect.height)
        numberString.draw(with: numberRect, options: .usesLineFragmentOrigin, attributes: numberAttributes, context: nil)

        let bodyRect = CGRect(
            x: rect.minX + numberColumnWidth + numberToBodySpacing,
            y: rect.minY,
            width: max(0, rect.width - numberColumnWidth - numberToBodySpacing),
            height: rect.height
        )
        body.draw(with: bodyRect, options: .usesLineFragmentOrigin, attributes: bodyAttributes, context: nil)
    }

    @discardableResult
    private static func drawHeader(
        context: CGContext,
        safeBounds: CGRect,
        title: String,
        badgeText: String,
        infoText: String,
        backgroundColor: UIColor
    ) -> CGFloat {
        let titleY = safeBounds.minY + headerTopPadding
        let infoY = titleY + titleFont.lineHeight + headerSpacing
        let lineY = infoY + headerFont.lineHeight + headerRuleSpacing

        let headerRect = CGRect(x: safeBounds.minX, y: safeBounds.minY, width: safeBounds.width, height: lineY - safeBounds.minY)
        let headerPath = UIBezierPath(roundedRect: headerRect, cornerRadius: headerCornerRadius)

        context.saveGState()
        context.addPath(headerPath.cgPath)
        context.setFillColor(backgroundColor.cgColor)
        context.fillPath()
        context.restoreGState()

        // Subtle border to soften the block edge on white paper
        context.setStrokeColor(dividerColor.withAlphaComponent(0.65).cgColor)
        context.setLineWidth(0.8)
        context.addPath(headerPath.cgPath)
        context.strokePath()

        // Accent bar (clipped to rounded header)
        context.saveGState()
        context.addPath(headerPath.cgPath)
        context.clip()
        context.setFillColor(accentColor.cgColor)
        context.fill(CGRect(x: headerRect.minX, y: headerRect.minY, width: headerRect.width, height: headerAccentHeight))
        context.restoreGState()

        // Badge on the right (difficulty)
        let badgeAttributes: [NSAttributedString.Key: Any] = [
            .font: badgeFont,
            .foregroundColor: accentColor
        ]
        let badgeTextSize = badgeText.size(withAttributes: badgeAttributes)
        let badgeSize = CGSize(width: badgeTextSize.width + (badgePaddingX * 2), height: badgeTextSize.height + (badgePaddingY * 2))
        let badgeRect = CGRect(
            x: headerRect.maxX - headerInnerPaddingX - badgeSize.width,
            y: titleY + (titleFont.lineHeight - badgeSize.height) / 2,
            width: badgeSize.width,
            height: badgeSize.height
        )
        let badgePath = UIBezierPath(roundedRect: badgeRect, cornerRadius: badgeRect.height / 2)
        context.setFillColor(accentColor.withAlphaComponent(0.12).cgColor)
        context.addPath(badgePath.cgPath)
        context.fillPath()
        context.setStrokeColor(accentColor.withAlphaComponent(0.28).cgColor)
        context.setLineWidth(0.8)
        context.addPath(badgePath.cgPath)
        context.strokePath()

        let badgeTextRect = CGRect(
            x: badgeRect.minX + badgePaddingX,
            y: badgeRect.minY + badgePaddingY,
            width: badgeRect.width - (badgePaddingX * 2),
            height: badgeRect.height - (badgePaddingY * 2)
        )
        badgeText.draw(in: badgeTextRect, withAttributes: badgeAttributes)

        // Small accent mark to make the header feel less "table-like"
        let markX = headerRect.minX + headerInnerPaddingX
        let markY = titleY + (titleFont.lineHeight - titleMarkSize) / 2
        let markRect = CGRect(x: markX, y: markY, width: titleMarkSize, height: titleMarkSize)
        context.setFillColor(accentColor.withAlphaComponent(0.9).cgColor)
        context.fillEllipse(in: markRect)

        // Title on the left (avoid badge overlap)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: primaryTextColor
        ]
        let titleX = markRect.maxX + titleMarkSpacing
        let titleMaxX = badgeRect.minX - 10
        let titleRect = CGRect(
            x: titleX,
            y: titleY,
            width: max(0, titleMaxX - titleX),
            height: titleFont.lineHeight
        )
        title.draw(with: titleRect, options: .usesLineFragmentOrigin, attributes: titleAttributes, context: nil)

        // Info line
        let infoAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: secondaryTextColor
        ]
        let infoRect = CGRect(
            x: titleX,
            y: infoY,
            width: max(0, headerRect.maxX - headerInnerPaddingX - titleX),
            height: headerFont.lineHeight
        )
        infoText.draw(with: infoRect, options: .usesLineFragmentOrigin, attributes: infoAttributes, context: nil)

        return lineY
    }

    static func generatePDF(questions: [Question], difficulty: DifficultyLevel, count: Int) -> Data {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: a4Width, height: a4Height))

        let data = pdfRenderer.pdfData { context in
            // 计算每页可容纳的题目数量（基于优化后的布局）
            let rowHeight = rowHeight(for: questionFont, lineSpacing: questionLineSpacing)
            let questionsPerColumn = max(1, Int(availableContentHeight / rowHeight))
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
        let safeBounds = bounds.insetBy(dx: pageMargin, dy: pageMargin)

        // Ensure opaque background (better for some PDF viewers/printers)
        context.setFillColor(pageBackgroundColor.cgColor)
        context.fill(bounds)

        let title = localized("math_bank.pdf.title")
        let headerInfo = localized("math_bank.pdf.header_info", "\(totalCount)", "\(pageNumber)", "\(totalPages)")
        let lineY = drawHeader(
            context: context,
            safeBounds: safeBounds,
            title: title,
            badgeText: difficulty.localizedName,
            infoText: headerInfo,
            backgroundColor: headerBackgroundColor
        )

        // 计算布局参数（充分利用页面宽度）
        let contentWidth = safeBounds.width
        let columnWidth = (contentWidth - questionColumnGap) / 2
        let leftColumnX = safeBounds.minX
        let rightColumnX = safeBounds.minX + columnWidth + questionColumnGap
        let startY = lineY + headerToContentSpacing

        let rowHeight = rowHeight(for: questionFont, lineSpacing: questionLineSpacing)

        let numberParagraphStyle = NSMutableParagraphStyle()
        numberParagraphStyle.alignment = .right
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: questionNumberFont,
            .foregroundColor: accentColor,
            .paragraphStyle: numberParagraphStyle
        ]

        let bodyParagraphStyle = NSMutableParagraphStyle()
        bodyParagraphStyle.lineBreakMode = .byTruncatingTail
        bodyParagraphStyle.alignment = .left
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: questionFont,
            .foregroundColor: primaryTextColor,
            .paragraphStyle: bodyParagraphStyle
        ]

        // 绘制题目（两列紧凑布局）
        for (index, question) in questions.enumerated() {
            let questionNumber = startQuestionNumber + index
            let questionBody = question.questionText.replacingOccurrences(of: " = ?", with: " = ___")

            // 计算位置（两列布局）
            let column = index % 2
            let row = index / 2
            let x = column == 0 ? leftColumnX : rightColumnX
            let y = startY + CGFloat(row) * rowHeight

            let questionRect = CGRect(x: x, y: y, width: columnWidth, height: rowHeight)
            drawNumberedLine(
                number: questionNumber,
                body: questionBody,
                numberAttributes: numberAttributes,
                bodyAttributes: bodyAttributes,
                numberColumnWidth: questionNumberColumnWidth,
                in: questionRect
            )
        }

        // 绘制页脚（紧凑显示在底部）
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let footerText = localized("math_bank.pdf.generated_time", dateFormatter.string(from: Date()))
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: footerFont,
            .foregroundColor: subtleTextColor
        ]

        // 绘制底部页码（右侧）
        let pageNumText = "\(pageNumber)"
        let pageNumSize = pageNumText.size(withAttributes: footerAttributes)
        let pageNumRect = CGRect(
            x: safeBounds.maxX - pageNumSize.width,
            y: footerY,
            width: pageNumSize.width,
            height: pageNumSize.height
        )
        pageNumText.draw(in: pageNumRect, withAttributes: footerAttributes)

        let footerTextRect = CGRect(
            x: safeBounds.minX,
            y: footerY,
            width: max(0, pageNumRect.minX - safeBounds.minX - 8),
            height: pageNumSize.height
        )
        footerText.draw(with: footerTextRect, options: .usesLineFragmentOrigin, attributes: footerAttributes, context: nil)
    }

    private static func generateAnswerPages(context: UIGraphicsPDFRendererContext, questions: [Question], difficulty: DifficultyLevel) {
        // 计算每页可容纳的答案数量（三列紧凑布局）
        let rowHeight = rowHeight(for: answerFont, lineSpacing: answerLineSpacing)
        let answersPerColumn = max(1, Int(availableContentHeight / rowHeight))
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
        let safeBounds = bounds.insetBy(dx: pageMargin, dy: pageMargin)

        context.setFillColor(pageBackgroundColor.cgColor)
        context.fill(bounds)

        let title = localized("math_bank.pdf.answer_title")
        let headerInfo = localized("math_bank.pdf.answer_header_info", "\(pageNumber)", "\(totalPages)")
        let lineY = drawHeader(
            context: context,
            safeBounds: safeBounds,
            title: title,
            badgeText: difficulty.localizedName,
            infoText: headerInfo,
            backgroundColor: answerHeaderBackgroundColor
        )

        // 计算三列布局参数（充分利用页面宽度）
        let contentWidth = safeBounds.width
        let columnSpacing = answerColumnGap
        let totalColumnSpacing = columnSpacing * 2
        let columnWidth = (contentWidth - totalColumnSpacing) / 3
        let column1X = safeBounds.minX
        let column2X = safeBounds.minX + columnWidth + columnSpacing
        let column3X = safeBounds.minX + (columnWidth + columnSpacing) * 2
        let startY = lineY + headerToContentSpacing

        let rowHeight = rowHeight(for: answerFont, lineSpacing: answerLineSpacing)

        let numberParagraphStyle = NSMutableParagraphStyle()
        numberParagraphStyle.alignment = .right
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: answerNumberFont,
            .foregroundColor: accentColor,
            .paragraphStyle: numberParagraphStyle
        ]

        let bodyParagraphStyle = NSMutableParagraphStyle()
        bodyParagraphStyle.lineBreakMode = .byTruncatingTail
        bodyParagraphStyle.alignment = .left
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: answerFont,
            .foregroundColor: primaryTextColor,
            .paragraphStyle: bodyParagraphStyle
        ]

        // 绘制答案（三列紧凑布局）
        for (index, question) in questions.enumerated() {
            let questionNumber = startQuestionNumber + index
            let answerBody = "\(question.questionText.replacingOccurrences(of: " = ?", with: "")) = \(question.correctAnswer)"

            // 计算位置（三列布局）
            let column = index % 3
            let row = index / 3
            let x: CGFloat
            switch column {
            case 0: x = column1X
            case 1: x = column2X
            default: x = column3X
            }
            let y = startY + CGFloat(row) * rowHeight

            let answerRect = CGRect(x: x, y: y, width: columnWidth, height: rowHeight)
            drawNumberedLine(
                number: questionNumber,
                body: answerBody,
                numberAttributes: numberAttributes,
                bodyAttributes: bodyAttributes,
                numberColumnWidth: answerNumberColumnWidth,
                in: answerRect
            )
        }

        // 绘制页脚（紧凑显示在底部）
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let footerText = localized("math_bank.pdf.generated_time", dateFormatter.string(from: Date()))
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: footerFont,
            .foregroundColor: subtleTextColor
        ]

        // 绘制底部页码（右侧）
        let pageNumText = "\(pageNumber)"
        let pageNumSize = pageNumText.size(withAttributes: footerAttributes)
        let pageNumRect = CGRect(
            x: safeBounds.maxX - pageNumSize.width,
            y: footerY,
            width: pageNumSize.width,
            height: pageNumSize.height
        )
        pageNumText.draw(in: pageNumRect, withAttributes: footerAttributes)

        let footerTextRect = CGRect(
            x: safeBounds.minX,
            y: footerY,
            width: max(0, pageNumRect.minX - safeBounds.minX - 8),
            height: pageNumSize.height
        )
        footerText.draw(with: footerTextRect, options: .usesLineFragmentOrigin, attributes: footerAttributes, context: nil)
    }

    // MARK: - 新增：合页打印模式（题目和答案在同一张纸的正反面）
    static func generateDuplexPDF(questions: [Question], difficulty: DifficultyLevel, count: Int) -> Data {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: a4Width, height: a4Height))

        let data = pdfRenderer.pdfData { context in
            // 计算每页可容纳的题目数量
            let rowHeight = rowHeight(for: questionFont, lineSpacing: questionLineSpacing)
            let questionsPerColumn = max(1, Int(availableContentHeight / rowHeight))
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
