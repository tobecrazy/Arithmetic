import SwiftUI

/// A reusable view that displays an arithmetic question with TTS support
struct QuestionDisplayView: View {
    let question: Question
    let isCorrect: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(question.questionText)
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(.primary)
                .scaleEffect(isCorrect ? 1.1 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isCorrect)
        }
        .buttonStyle(PlainButtonStyle())
        .padding()
    }

    private var fontSize: CGFloat {
        DeviceUtils.isIPad ? 60 : 40
    }
}

struct QuestionDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionDisplayView(
            question: Question(number1: 5, number2: 3, operation: .addition),
            isCorrect: false,
            onTap: {}
        )
    }
}
