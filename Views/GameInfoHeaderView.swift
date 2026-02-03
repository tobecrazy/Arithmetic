import SwiftUI

/// Displays game information including time remaining, progress, and score
struct GameInfoHeaderView: View {
    let timeRemaining: String
    let currentTime: Int
    let progressText: String
    let currentQuestionIndex: Int
    let totalQuestions: Int
    let score: Int
    let streakCount: Int
    @Binding var buttonScale: CGFloat

    var body: some View {
        HStack {
            // Time remaining
            VStack(alignment: .leading) {
                Text("game.time".localized)
                    .font(.footnote)
                Text(timeRemaining)
                    .font(.adaptiveHeadline())
                    .foregroundColor(.blue)
                    .id(currentTime)
            }

            Spacer()

            // Progress bar
            VStack(spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 8)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentQuestionIndex)
                    }
                }
                .frame(height: 8)

                Text(progressText)
                    .font(.adaptiveCaption())
                    .foregroundColor(.secondary)
            }
            .frame(width: 100)

            Spacer()

            // Score with streak indicator
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    if streakCount >= 3 {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                            .scaleEffect(buttonScale)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5).repeatCount(3), value: buttonScale)
                    }
                    Text("game.score".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text("\(score)")
                    .font(.adaptiveTitle2())
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .contentTransition(.numericText())
                if streakCount >= 2 {
                    Text("🔥 ×\(streakCount)")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }

    private var progress: CGFloat {
        CGFloat(currentQuestionIndex + 1) / CGFloat(totalQuestions)
    }
}

struct GameInfoHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        GameInfoHeaderView(
            timeRemaining: "05:00",
            currentTime: 300,
            progressText: "5 / 20",
            currentQuestionIndex: 4,
            totalQuestions: 20,
            score: 80,
            streakCount: 3,
            buttonScale: .constant(1.0)
        )
    }
}
