import Foundation
import UIKit

class MathBankPDFGenerator {

    private struct PageTheme {
        let accentColor: UIColor
        let headerBackgroundColor: UIColor
        let panelBackgroundColor: UIColor
        let stripBackgroundColor: UIColor
        let rowTintColor: UIColor
    }

    // MARK: - Page Metrics

    private static let pointsPerInch: CGFloat = 72.0
    private static let mmPerInch: CGFloat = 25.4
    private static let a4Width: CGFloat = 210.0 / mmPerInch * pointsPerInch
    private static let a4Height: CGFloat = 297.0 / mmPerInch * pointsPerInch
    private static let pageMargin: CGFloat = 34.0

    // MARK: - General Layout

    private static let headerTopPadding: CGFloat = 6.0
    private static let headerSpacing: CGFloat = 5.0
    private static let headerRuleSpacing: CGFloat = 8.0
    private static let headerToContentSpacing: CGFloat = 12.0
    private static let footerTopSpacing: CGFloat = 10.0

    private static let worksheetStripHeight: CGFloat = 34.0
    private static let worksheetStripToPanelSpacing: CGFloat = 12.0
    private static let worksheetStripInnerPadding: CGFloat = 12.0
    private static let worksheetFieldSpacing: CGFloat = 16.0

    private static let contentPanelCornerRadius: CGFloat = 16.0
    private static let contentPanelPaddingX: CGFloat = 14.0
    private static let contentPanelPaddingTop: CGFloat = 14.0
    private static let contentPanelPaddingBottom: CGFloat = 14.0

    private static let questionColumnGap: CGFloat = 26.0
    private static let answerColumnGap: CGFloat = 18.0
    private static let questionLineSpacing: CGFloat = 9.0
    private static let answerLineSpacing: CGFloat = 7.0

    private static let questionRowCornerRadius: CGFloat = 10.0
    private static let answerRowCornerRadius: CGFloat = 8.0
    private static let rowHorizontalPadding: CGFloat = 8.0
    private static let rowTextSpacing: CGFloat = 10.0
    private static let minimumAnswerLineWidth: CGFloat = 58.0

    // MARK: - Colors

    private static let pageBackgroundColor = UIColor.white
    private static let primaryTextColor = UIColor(white: 0.12, alpha: 1.0)
    private static let secondaryTextColor = UIColor(white: 0.42, alpha: 1.0)
    private static let subtleTextColor = UIColor(white: 0.66, alpha: 1.0)
    private static let dividerColor = UIColor(white: 0.86, alpha: 1.0)

    private static let questionTheme = PageTheme(
        accentColor: UIColor(red: 0.83, green: 0.43, blue: 0.18, alpha: 1.0),
        headerBackgroundColor: UIColor(red: 1.0, green: 0.97, blue: 0.93, alpha: 1.0),
        panelBackgroundColor: UIColor(red: 0.999, green: 0.996, blue: 0.992, alpha: 1.0),
        stripBackgroundColor: UIColor(red: 0.996, green: 0.985, blue: 0.968, alpha: 1.0),
        rowTintColor: UIColor(red: 0.98, green: 0.94, blue: 0.90, alpha: 1.0)
    )

    private static let answerTheme = PageTheme(
        accentColor: UIColor(red: 0.22, green: 0.45, blue: 0.76, alpha: 1.0),
        headerBackgroundColor: UIColor(red: 0.94, green: 0.97, blue: 1.0, alpha: 1.0),
        panelBackgroundColor: UIColor(red: 0.985, green: 0.992, blue: 1.0, alpha: 1.0),
        stripBackgroundColor: UIColor(red: 0.955, green: 0.978, blue: 1.0, alpha: 1.0),
        rowTintColor: UIColor(red: 0.92, green: 0.96, blue: 1.0, alpha: 1.0)
    )

    // MARK: - Header Style

    private static let headerCornerRadius: CGFloat = 12.0
    private static let headerInnerPaddingX: CGFloat = 14.0
    private static let headerAccentHeight: CGFloat = 3.0
    private static let titleMarkSize: CGFloat = 8.0
    private static let titleMarkSpacing: CGFloat = 8.0
    private static let badgePaddingX: CGFloat = 10.0
    private static let badgePaddingY: CGFloat = 4.0

    // MARK: - Fonts

    private static let titleFont = roundedFont(UIFont.systemFont(ofSize: 18, weight: .bold))
    private static let headerFont = roundedFont(UIFont.systemFont(ofSize: 11, weight: .medium))
    private static let badgeFont = roundedFont(UIFont.systemFont(ofSize: 10, weight: .semibold))
    private static let worksheetLabelFont = roundedFont(UIFont.systemFont(ofSize: 9.5, weight: .semibold))
    private static let questionFont = roundedFont(UIFont.systemFont(ofSize: 13.5, weight: .medium))
    private static let questionNumberFont = UIFont.monospacedDigitSystemFont(ofSize: 10.5, weight: .semibold)
    private static let answerFont = roundedFont(UIFont.systemFont(ofSize: 11.0, weight: .regular))
    private static let answerEmphasisFont = roundedFont(UIFont.systemFont(ofSize: 11.0, weight: .bold))
    private static let answerNumberFont = UIFont.monospacedDigitSystemFont(ofSize: 9.5, weight: .semibold)
    private static let footerFont = roundedFont(UIFont.systemFont(ofSize: 9.0, weight: .regular))
    private static let footerBadgeFont = UIFont.monospacedDigitSystemFont(ofSize: 9.0, weight: .semibold)

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

    private static var footerRuleY: CGFloat {
        footerY - 6.0
    }

    private static var questionPanelTopY: CGFloat {
        contentStartY + worksheetStripHeight + worksheetStripToPanelSpacing
    }

    private static var questionRowHeight: CGFloat {
        max(24.0, ceil(questionFont.lineHeight + questionLineSpacing))
    }

    private static var answerRowHeight: CGFloat {
        max(18.0, ceil(answerFont.lineHeight + answerLineSpacing))
    }

    private static var questionRowsPerColumn: Int {
        let available = footerRuleY - footerTopSpacing - questionPanelTopY - contentPanelPaddingTop - contentPanelPaddingBottom
        return max(1, Int(available / questionRowHeight))
    }

    private static var answerRowsPerColumn: Int {
        let available = footerRuleY - footerTopSpacing - contentStartY - contentPanelPaddingTop - contentPanelPaddingBottom
        return max(1, Int(available / answerRowHeight))
    }

    // MARK: - Public API

    static func generatePDF(questions: [Question], difficulty: DifficultyLevel, count: Int) -> Data {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: a4Width, height: a4Height))

        let data = pdfRenderer.pdfData { context in
            let questionsPerPage = questionRowsPerColumn * 2
            let totalPages = Int(ceil(Double(questions.count) / Double(questionsPerPage)))

            for pageIndex in 0..<totalPages {
                context.beginPage()

                let startIndex = pageIndex * questionsPerPage
                let endIndex = min(startIndex + questionsPerPage, questions.count)
                let pageQuestions = Array(questions[startIndex..<endIndex])

                drawQuestionPage(
                    context: context.cgContext,
                    questions: pageQuestions,
                    pageNumber: pageIndex + 1,
                    totalPages: totalPages,
                    difficulty: difficulty,
                    totalCount: count,
                    startQuestionNumber: startIndex + 1
                )
            }

            generateAnswerPages(context: context, questions: questions, difficulty: difficulty)
        }

        return data
    }

    static func generateDuplexPDF(questions: [Question], difficulty: DifficultyLevel, count: Int) -> Data {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: a4Width, height: a4Height))

        let data = pdfRenderer.pdfData { context in
            let questionsPerPage = questionRowsPerColumn * 2
            let totalPages = Int(ceil(Double(questions.count) / Double(questionsPerPage)))

            for pageIndex in 0..<totalPages {
                context.beginPage()

                let startIndex = pageIndex * questionsPerPage
                let endIndex = min(startIndex + questionsPerPage, questions.count)
                let pageQuestions = Array(questions[startIndex..<endIndex])

                drawQuestionPage(
                    context: context.cgContext,
                    questions: pageQuestions,
                    pageNumber: pageIndex + 1,
                    totalPages: totalPages,
                    difficulty: difficulty,
                    totalCount: count,
                    startQuestionNumber: startIndex + 1
                )
            }

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

    // MARK: - Page Rendering

    private static func drawQuestionPage(
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
            theme: questionTheme
        )

        let stripBottomY = drawWorksheetStrip(
            context: context,
            safeBounds: safeBounds,
            topY: lineY + headerToContentSpacing,
            theme: questionTheme
        )

        let panelRect = CGRect(
            x: safeBounds.minX,
            y: stripBottomY + worksheetStripToPanelSpacing,
            width: safeBounds.width,
            height: max(0, footerRuleY - footerTopSpacing - (stripBottomY + worksheetStripToPanelSpacing))
        )
        let contentRect = drawContentPanel(context: context, rect: panelRect, theme: questionTheme)

        let columnWidth = (contentRect.width - questionColumnGap) / 2
        let leftColumnX = contentRect.minX
        let rightColumnX = contentRect.minX + columnWidth + questionColumnGap
        let separatorX = contentRect.minX + columnWidth + questionColumnGap / 2
        drawColumnSeparator(context: context, x: separatorX, rect: contentRect)

        for (index, question) in questions.enumerated() {
            let questionNumber = startQuestionNumber + index
            let column = index % 2
            let row = index / 2
            let x = column == 0 ? leftColumnX : rightColumnX
            let rowRect = CGRect(
                x: x,
                y: contentRect.minY + CGFloat(row) * questionRowHeight,
                width: columnWidth,
                height: questionRowHeight
            )

            drawQuestionRow(
                context: context,
                question: question,
                number: questionNumber,
                in: rowRect,
                theme: questionTheme,
                shaded: row % 2 == 0
            )
        }

        drawFooter(context: context, safeBounds: safeBounds, pageNumber: pageNumber, theme: questionTheme)
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
            theme: answerTheme
        )

        let panelRect = CGRect(
            x: safeBounds.minX,
            y: lineY + headerToContentSpacing,
            width: safeBounds.width,
            height: max(0, footerRuleY - footerTopSpacing - (lineY + headerToContentSpacing))
        )
        let contentRect = drawContentPanel(context: context, rect: panelRect, theme: answerTheme)

        let columnWidth = (contentRect.width - (answerColumnGap * 2)) / 3
        let column1X = contentRect.minX
        let column2X = contentRect.minX + columnWidth + answerColumnGap
        let column3X = contentRect.minX + (columnWidth + answerColumnGap) * 2
        drawColumnSeparator(context: context, x: contentRect.minX + columnWidth + answerColumnGap / 2, rect: contentRect)
        drawColumnSeparator(context: context, x: contentRect.minX + (columnWidth * 2) + answerColumnGap + (answerColumnGap / 2), rect: contentRect)

        for (index, question) in questions.enumerated() {
            let questionNumber = startQuestionNumber + index
            let column = index % 3
            let row = index / 3
            let x: CGFloat

            switch column {
            case 0:
                x = column1X
            case 1:
                x = column2X
            default:
                x = column3X
            }

            let rowRect = CGRect(
                x: x,
                y: contentRect.minY + CGFloat(row) * answerRowHeight,
                width: columnWidth,
                height: answerRowHeight
            )

            drawAnswerRow(
                context: context,
                question: question,
                number: questionNumber,
                in: rowRect,
                theme: answerTheme,
                shaded: row % 2 == 0
            )
        }

        drawFooter(context: context, safeBounds: safeBounds, pageNumber: pageNumber, theme: answerTheme)
    }

    private static func generateAnswerPages(
        context: UIGraphicsPDFRendererContext,
        questions: [Question],
        difficulty: DifficultyLevel
    ) {
        let answersPerPage = answerRowsPerColumn * 3
        let totalPages = Int(ceil(Double(questions.count) / Double(answersPerPage)))

        for pageIndex in 0..<totalPages {
            context.beginPage()

            let startIndex = pageIndex * answersPerPage
            let endIndex = min(startIndex + answersPerPage, questions.count)
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

    // MARK: - Drawing Helpers

    private static func drawHeader(
        context: CGContext,
        safeBounds: CGRect,
        title: String,
        badgeText: String,
        infoText: String,
        theme: PageTheme
    ) -> CGFloat {
        let titleY = safeBounds.minY + headerTopPadding
        let infoY = titleY + titleFont.lineHeight + headerSpacing
        let lineY = infoY + headerFont.lineHeight + headerRuleSpacing

        let headerRect = CGRect(x: safeBounds.minX, y: safeBounds.minY, width: safeBounds.width, height: lineY - safeBounds.minY)
        let headerPath = UIBezierPath(roundedRect: headerRect, cornerRadius: headerCornerRadius)

        context.saveGState()
        context.addPath(headerPath.cgPath)
        context.setFillColor(theme.headerBackgroundColor.cgColor)
        context.fillPath()
        context.restoreGState()

        context.setStrokeColor(dividerColor.withAlphaComponent(0.7).cgColor)
        context.setLineWidth(0.8)
        context.addPath(headerPath.cgPath)
        context.strokePath()

        context.saveGState()
        context.addPath(headerPath.cgPath)
        context.clip()
        context.setFillColor(theme.accentColor.cgColor)
        context.fill(CGRect(x: headerRect.minX, y: headerRect.minY, width: headerRect.width, height: headerAccentHeight))
        context.restoreGState()

        let badgeAttributes: [NSAttributedString.Key: Any] = [
            .font: badgeFont,
            .foregroundColor: theme.accentColor
        ]
        let badgeTextSize = badgeText.size(withAttributes: badgeAttributes)
        let badgeRect = CGRect(
            x: headerRect.maxX - headerInnerPaddingX - badgeTextSize.width - (badgePaddingX * 2),
            y: titleY + (titleFont.lineHeight - badgeTextSize.height - (badgePaddingY * 2)) / 2,
            width: badgeTextSize.width + (badgePaddingX * 2),
            height: badgeTextSize.height + (badgePaddingY * 2)
        )
        let badgePath = UIBezierPath(roundedRect: badgeRect, cornerRadius: badgeRect.height / 2)
        context.setFillColor(theme.accentColor.withAlphaComponent(0.12).cgColor)
        context.addPath(badgePath.cgPath)
        context.fillPath()
        context.setStrokeColor(theme.accentColor.withAlphaComponent(0.30).cgColor)
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

        let markRect = CGRect(
            x: headerRect.minX + headerInnerPaddingX,
            y: titleY + (titleFont.lineHeight - titleMarkSize) / 2,
            width: titleMarkSize,
            height: titleMarkSize
        )
        context.setFillColor(theme.accentColor.cgColor)
        context.fillEllipse(in: markRect)

        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: primaryTextColor
        ]
        let titleX = markRect.maxX + titleMarkSpacing
        let titleRect = CGRect(
            x: titleX,
            y: titleY,
            width: max(0, badgeRect.minX - titleX - 10),
            height: titleFont.lineHeight
        )
        title.draw(with: titleRect, options: .usesLineFragmentOrigin, attributes: titleAttributes, context: nil)

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

    private static func drawWorksheetStrip(
        context: CGContext,
        safeBounds: CGRect,
        topY: CGFloat,
        theme: PageTheme
    ) -> CGFloat {
        let stripRect = CGRect(x: safeBounds.minX, y: topY, width: safeBounds.width, height: worksheetStripHeight)
        let stripPath = UIBezierPath(roundedRect: stripRect, cornerRadius: 12.0)

        context.saveGState()
        context.addPath(stripPath.cgPath)
        context.setFillColor(theme.stripBackgroundColor.cgColor)
        context.fillPath()
        context.restoreGState()

        context.setStrokeColor(dividerColor.withAlphaComponent(0.75).cgColor)
        context.setLineWidth(0.8)
        context.addPath(stripPath.cgPath)
        context.strokePath()

        let fields = [
            localized("math_bank.pdf.field_name"),
            localized("math_bank.pdf.field_date"),
            localized("math_bank.pdf.field_score")
        ]

        let contentWidth = stripRect.width - (worksheetStripInnerPadding * 2) - (worksheetFieldSpacing * CGFloat(fields.count - 1))
        let fieldWidth = contentWidth / CGFloat(fields.count)
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: worksheetLabelFont,
            .foregroundColor: theme.accentColor
        ]

        for (index, field) in fields.enumerated() {
            let fieldX = stripRect.minX + worksheetStripInnerPadding + CGFloat(index) * (fieldWidth + worksheetFieldSpacing)
            let fieldRect = CGRect(x: fieldX, y: stripRect.minY, width: fieldWidth, height: stripRect.height)

            let labelSize = field.size(withAttributes: labelAttributes)
            let labelRect = CGRect(
                x: fieldRect.minX,
                y: stripRect.minY + (stripRect.height - labelSize.height) / 2 - 1,
                width: labelSize.width,
                height: labelSize.height
            )
            field.draw(in: labelRect, withAttributes: labelAttributes)

            let lineStartX = labelRect.maxX + 8
            let lineY = stripRect.midY + 4
            context.setStrokeColor(theme.accentColor.withAlphaComponent(0.32).cgColor)
            context.setLineWidth(0.9)
            context.move(to: CGPoint(x: lineStartX, y: lineY))
            context.addLine(to: CGPoint(x: fieldRect.maxX, y: lineY))
            context.strokePath()
        }

        return stripRect.maxY
    }

    private static func drawContentPanel(
        context: CGContext,
        rect: CGRect,
        theme: PageTheme
    ) -> CGRect {
        let panelPath = UIBezierPath(roundedRect: rect, cornerRadius: contentPanelCornerRadius)

        context.saveGState()
        context.addPath(panelPath.cgPath)
        context.setFillColor(theme.panelBackgroundColor.cgColor)
        context.fillPath()
        context.restoreGState()

        context.setStrokeColor(dividerColor.withAlphaComponent(0.8).cgColor)
        context.setLineWidth(0.8)
        context.addPath(panelPath.cgPath)
        context.strokePath()

        context.saveGState()
        context.addPath(panelPath.cgPath)
        context.clip()
        context.setFillColor(theme.accentColor.withAlphaComponent(0.08).cgColor)
        context.fill(CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: 4.0))
        context.restoreGState()

        return CGRect(
            x: rect.minX + contentPanelPaddingX,
            y: rect.minY + contentPanelPaddingTop,
            width: rect.width - (contentPanelPaddingX * 2),
            height: rect.height - contentPanelPaddingTop - contentPanelPaddingBottom
        )
    }

    private static func drawColumnSeparator(context: CGContext, x: CGFloat, rect: CGRect) {
        context.setStrokeColor(dividerColor.withAlphaComponent(0.65).cgColor)
        context.setLineWidth(0.8)
        context.move(to: CGPoint(x: x, y: rect.minY))
        context.addLine(to: CGPoint(x: x, y: rect.maxY))
        context.strokePath()
    }

    private static func drawQuestionRow(
        context: CGContext,
        question: Question,
        number: Int,
        in rect: CGRect,
        theme: PageTheme,
        shaded: Bool
    ) {
        let rowRect = rect.insetBy(dx: 0, dy: 1)
        if shaded {
            let fillPath = UIBezierPath(roundedRect: rowRect, cornerRadius: questionRowCornerRadius)
            context.setFillColor(theme.rowTintColor.withAlphaComponent(0.22).cgColor)
            context.addPath(fillPath.cgPath)
            context.fillPath()
        }

        let pillRect = CGRect(
            x: rowRect.minX + rowHorizontalPadding,
            y: rowRect.minY + (rowRect.height - 18.0) / 2,
            width: 30.0,
            height: 18.0
        )
        drawNumberPill(context: context, rect: pillRect, text: "\(number)", font: questionNumberFont, theme: theme)

        let bodyX = pillRect.maxX + rowTextSpacing
        let bodyMaxX = rowRect.maxX - rowHorizontalPadding
        let bodyWidth = max(0, bodyMaxX - bodyX)
        let bodyText = question.questionText.replacingOccurrences(of: " = ?", with: "") + " ="
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: questionFont,
            .foregroundColor: primaryTextColor
        ]

        let fittedTextWidth = max(0, min(bodyText.size(withAttributes: bodyAttributes).width, bodyWidth - minimumAnswerLineWidth - 10))
        let textRect = CGRect(
            x: bodyX,
            y: rowRect.minY + (rowRect.height - questionFont.lineHeight) / 2 - 1,
            width: max(0, bodyWidth - minimumAnswerLineWidth - 10),
            height: questionFont.lineHeight
        )
        bodyText.draw(with: textRect, options: .usesLineFragmentOrigin, attributes: bodyAttributes, context: nil)

        let lineStartX = max(bodyX + fittedTextWidth + 10, bodyMaxX - minimumAnswerLineWidth)
        let lineY = rowRect.midY + 4
        context.setStrokeColor(theme.accentColor.withAlphaComponent(0.42).cgColor)
        context.setLineWidth(1.0)
        context.move(to: CGPoint(x: lineStartX, y: lineY))
        context.addLine(to: CGPoint(x: bodyMaxX, y: lineY))
        context.strokePath()
    }

    private static func drawAnswerRow(
        context: CGContext,
        question: Question,
        number: Int,
        in rect: CGRect,
        theme: PageTheme,
        shaded: Bool
    ) {
        let rowRect = rect.insetBy(dx: 0, dy: 1)
        let fillPath = UIBezierPath(roundedRect: rowRect, cornerRadius: answerRowCornerRadius)
        context.setFillColor((shaded ? theme.rowTintColor.withAlphaComponent(0.38) : UIColor.white).cgColor)
        context.addPath(fillPath.cgPath)
        context.fillPath()

        context.setStrokeColor(dividerColor.withAlphaComponent(0.35).cgColor)
        context.setLineWidth(0.7)
        context.addPath(fillPath.cgPath)
        context.strokePath()

        let pillRect = CGRect(
            x: rowRect.minX + 6,
            y: rowRect.minY + (rowRect.height - 16.0) / 2,
            width: 24.0,
            height: 16.0
        )
        drawNumberPill(context: context, rect: pillRect, text: "\(number)", font: answerNumberFont, theme: theme)

        let expression = question.questionText.replacingOccurrences(of: " = ?", with: "")
        let answerText = question.correctAnswerText

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail

        let body = NSMutableAttributedString(
            string: "\(expression) = ",
            attributes: [
                .font: answerFont,
                .foregroundColor: primaryTextColor,
                .paragraphStyle: paragraphStyle
            ]
        )
        body.append(
            NSAttributedString(
                string: answerText,
                attributes: [
                    .font: answerEmphasisFont,
                    .foregroundColor: theme.accentColor,
                    .paragraphStyle: paragraphStyle
                ]
            )
        )

        let bodyRect = CGRect(
            x: pillRect.maxX + 8,
            y: rowRect.minY + (rowRect.height - answerFont.lineHeight) / 2 - 0.5,
            width: rowRect.maxX - pillRect.maxX - 16,
            height: answerFont.lineHeight + 1
        )
        body.draw(with: bodyRect, options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], context: nil)
    }

    private static func drawNumberPill(
        context: CGContext,
        rect: CGRect,
        text: String,
        font: UIFont,
        theme: PageTheme
    ) {
        let pillPath = UIBezierPath(roundedRect: rect, cornerRadius: rect.height / 2)
        context.setFillColor(theme.accentColor.withAlphaComponent(0.12).cgColor)
        context.addPath(pillPath.cgPath)
        context.fillPath()

        context.setStrokeColor(theme.accentColor.withAlphaComponent(0.25).cgColor)
        context.setLineWidth(0.8)
        context.addPath(pillPath.cgPath)
        context.strokePath()

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: theme.accentColor
        ]
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: rect.midX - textSize.width / 2,
            y: rect.midY - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )
        text.draw(in: textRect, withAttributes: attributes)
    }

    private static func drawFooter(
        context: CGContext,
        safeBounds: CGRect,
        pageNumber: Int,
        theme: PageTheme
    ) {
        context.setStrokeColor(theme.accentColor.withAlphaComponent(0.18).cgColor)
        context.setLineWidth(0.9)
        context.move(to: CGPoint(x: safeBounds.minX, y: footerRuleY))
        context.addLine(to: CGPoint(x: safeBounds.maxX, y: footerRuleY))
        context.strokePath()

        let footerText = localized("math_bank.pdf.generated_time", formattedTimestamp())
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: footerFont,
            .foregroundColor: subtleTextColor
        ]

        let badgeText = "\(pageNumber)"
        let badgeAttributes: [NSAttributedString.Key: Any] = [
            .font: footerBadgeFont,
            .foregroundColor: theme.accentColor
        ]
        let badgeTextSize = badgeText.size(withAttributes: badgeAttributes)
        let badgeRect = CGRect(
            x: safeBounds.maxX - max(24.0, badgeTextSize.width + 14.0),
            y: footerY - 4.0,
            width: max(24.0, badgeTextSize.width + 14.0),
            height: badgeTextSize.height + 6.0
        )

        let badgePath = UIBezierPath(roundedRect: badgeRect, cornerRadius: badgeRect.height / 2)
        context.setFillColor(theme.accentColor.withAlphaComponent(0.10).cgColor)
        context.addPath(badgePath.cgPath)
        context.fillPath()

        context.setStrokeColor(theme.accentColor.withAlphaComponent(0.24).cgColor)
        context.setLineWidth(0.8)
        context.addPath(badgePath.cgPath)
        context.strokePath()

        let badgeTextRect = CGRect(
            x: badgeRect.midX - badgeTextSize.width / 2,
            y: badgeRect.midY - badgeTextSize.height / 2,
            width: badgeTextSize.width,
            height: badgeTextSize.height
        )
        badgeText.draw(in: badgeTextRect, withAttributes: badgeAttributes)

        let footerTextRect = CGRect(
            x: safeBounds.minX,
            y: footerY - 1.0,
            width: max(0, badgeRect.minX - safeBounds.minX - 10),
            height: footerFont.lineHeight + 2
        )
        footerText.draw(with: footerTextRect, options: .usesLineFragmentOrigin, attributes: footerAttributes, context: nil)
    }

    // MARK: - Utilities

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

    private static func formattedTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: Date())
    }
}
