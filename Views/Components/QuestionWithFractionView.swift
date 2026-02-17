import SwiftUI

/// A reusable view that displays a question with fraction operands
/// Handles mixed expressions like "1/2 + 3/4 = ?" with proper mathematical formatting
struct QuestionWithFractionView: View {
    let question: Question
    let isCorrect: Bool
    let onTap: () -> Void

    private var baseFontSize: CGFloat {
        DeviceUtils.isIPad ? 60 : 40
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                // Build the expression with fractions
                if question.operations.count == 1 {
                    // Two-operand expression
                    buildTwoOperandExpression()
                } else if question.operations.count == 2 {
                    // Three-operand expression
                    buildThreeOperandExpression()
                } else {
                    // Fallback to text
                    Text(question.questionText)
                        .font(.system(size: baseFontSize, weight: .bold))
                }
            }
            .foregroundColor(.primary)
            .scaleEffect(isCorrect ? 1.1 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isCorrect)
        }
        .buttonStyle(PlainButtonStyle())
        .padding()
    }

    // MARK: - Helper Methods

    /// Builds a two-operand expression (e.g., "1/2 + 3/4 = ?")
    private func buildTwoOperandExpression() -> some View {
        HStack(spacing: 8) {
            // First operand
            if let fractionOps = question.fractionOperands,
               let firstFraction = fractionOps[0] {
                FractionView(fraction: firstFraction, baseFontSize: baseFontSize)
            } else if question.fractionOperands != nil {
                // Integer operand
                Text("\(question.numbers[0])")
                    .font(.system(size: baseFontSize, weight: .bold))
            } else {
                Text(String(question.numbers[0]))
                    .font(.system(size: baseFontSize, weight: .bold))
            }

            // Operation
            Text(question.operations[0].symbol)
                .font(.system(size: baseFontSize, weight: .bold))
                .padding(.horizontal, 4)

            // Second operand
            if let fractionOps = question.fractionOperands,
               let secondFraction = fractionOps[1] {
                FractionView(fraction: secondFraction, baseFontSize: baseFontSize)
            } else if question.fractionOperands != nil {
                // Integer operand
                Text("\(question.numbers[1])")
                    .font(.system(size: baseFontSize, weight: .bold))
            } else {
                Text(String(question.numbers[1]))
                    .font(.system(size: baseFontSize, weight: .bold))
            }

            // Result placeholder
            Text("=")
                .font(.system(size: baseFontSize, weight: .bold))
                .padding(.horizontal, 4)
            Text("?")
                .font(.system(size: baseFontSize, weight: .bold))
        }
    }

    /// Builds a three-operand expression (e.g., "1/2 + 3/4 × 1/3 = ?")
    private func buildThreeOperandExpression() -> some View {
        HStack(spacing: 8) {
            // First operand
            if let fractionOps = question.fractionOperands,
               let firstFraction = fractionOps[0] {
                FractionView(fraction: firstFraction, baseFontSize: baseFontSize)
            } else if question.fractionOperands != nil {
                Text("\(question.numbers[0])")
                    .font(.system(size: baseFontSize, weight: .bold))
            } else {
                Text(String(question.numbers[0]))
                    .font(.system(size: baseFontSize, weight: .bold))
            }

            // First operation
            Text(question.operations[0].symbol)
                .font(.system(size: baseFontSize, weight: .bold))
                .padding(.horizontal, 4)

            // Second operand
            if let fractionOps = question.fractionOperands,
               let secondFraction = fractionOps[1] {
                FractionView(fraction: secondFraction, baseFontSize: baseFontSize)
            } else if question.fractionOperands != nil {
                Text("\(question.numbers[1])")
                    .font(.system(size: baseFontSize, weight: .bold))
            } else {
                Text(String(question.numbers[1]))
                    .font(.system(size: baseFontSize, weight: .bold))
            }

            // Second operation
            Text(question.operations[1].symbol)
                .font(.system(size: baseFontSize, weight: .bold))
                .padding(.horizontal, 4)

            // Third operand
            if let fractionOps = question.fractionOperands,
               let thirdFraction = fractionOps[2] {
                FractionView(fraction: thirdFraction, baseFontSize: baseFontSize)
            } else if question.fractionOperands != nil {
                Text("\(question.numbers[2])")
                    .font(.system(size: baseFontSize, weight: .bold))
            } else {
                Text(String(question.numbers[2]))
                    .font(.system(size: baseFontSize, weight: .bold))
            }

            // Result placeholder
            Text("=")
                .font(.system(size: baseFontSize, weight: .bold))
                .padding(.horizontal, 4)
            Text("?")
                .font(.system(size: baseFontSize, weight: .bold))
        }
    }
}

// MARK: - Preview

struct QuestionWithFractionView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Two-operand fraction expression
            QuestionWithFractionView(
                question: Question(operand1: Fraction(numerator: 1, denominator: 2),
                                   operand2: Fraction(numerator: 1, denominator: 3),
                                   operation: .addition,
                                   difficultyLevel: .level7),
                isCorrect: false,
                onTap: {}
            )

            // Mixed operand expression
            QuestionWithFractionView(
                question: Question(operand1: Fraction(numerator: 3, denominator: 4),
                                   operand2: 2,
                                   operation: .multiplication,
                                   difficultyLevel: .level7),
                isCorrect: false,
                onTap: {}
            )
        }
        .padding()
    }
}
