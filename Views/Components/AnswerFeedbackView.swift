import SwiftUI

/// Displays answer feedback (correct/wrong) with animations
struct AnswerFeedbackView: View {
    let question: Question
    let showingCorrectAnswer: Bool
    let isCorrect: Bool
    @Binding var isShaking: Bool
    @Binding var showSolutionSteps: Bool
    @Binding var buttonScale: CGFloat
    let difficultyLevel: DifficultyLevel
    let onNextQuestion: () -> Void
    let onToggleSolution: () -> Void

    var body: some View {
        VStack {
            if showingCorrectAnswer {
                wrongAnswerFeedback
            } else if isCorrect {
                correctAnswerFeedback
            }
        }
    }

    @ViewBuilder
    private var wrongAnswerFeedback: some View {
        VStack {
            // Wrong answer indicator
            HStack(spacing: 8) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
                    .scaleEffect(isShaking ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.4).repeatCount(3), value: isShaking)
                Text("game.wrong".localized)
                    .foregroundColor(.red)
                    .font(.adaptiveHeadline())
            }
            .offset(x: isShaking ? -5 : 5)
            .animation(.spring(response: 0.2, dampingFraction: 0.3).repeatCount(3), value: isShaking)

            // Correct answer display with proper formatting for fractions
            HStack(spacing: 8) {
                Text("game.correct_answer_label".localized)
                    .foregroundColor(.blue)
                    .font(.adaptiveBody())
                    .lineLimit(1)

                // Display fraction in vertical format if applicable
                if difficultyLevel == .level7,
                   let fractionAnswer = question.fractionAnswer {
                    FractionView(fraction: fractionAnswer, baseFontSize: 20)
                } else {
                    Text(String(question.correctAnswer))
                        .foregroundColor(.blue)
                        .font(.adaptiveBody())
                }
            }
            .padding(.vertical, 5)

            // Solution panel
            SolutionPanelView(
                question: question,
                difficultyLevel: difficultyLevel,
                isExpanded: $showSolutionSteps,
                onToggle: onToggleSolution
            )

            // Next question button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    onNextQuestion()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("button.next_question".localized)
                        .font(.adaptiveHeadline())
                }
                .padding()
                .frame(width: 220)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(.adaptiveCornerRadius)
                .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .id(UUID())
            .padding(.top, 12)
        }
        .padding()
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .opacity
        ))
    }

    @ViewBuilder
    private var correctAnswerFeedback: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .foregroundColor(.green)
                .scaleEffect(buttonScale)
            Text("game.correct".localized)
                .foregroundColor(.green)
                .font(.adaptiveHeadline())
        }
        .padding()
        .scaleEffect(buttonScale)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                buttonScale = 1.1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    buttonScale = 1.0
                }
            }
        }
    }
}

struct AnswerFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AnswerFeedbackView(
                question: Question(number1: 15, number2: 8, operation: .subtraction),
                showingCorrectAnswer: true,
                isCorrect: false,
                isShaking: .constant(false),
                showSolutionSteps: .constant(false),
                buttonScale: .constant(1.0),
                difficultyLevel: .level2,
                onNextQuestion: {},
                onToggleSolution: {}
            )
        }
    }
}
