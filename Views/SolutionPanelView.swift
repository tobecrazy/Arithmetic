import SwiftUI

/// Displays the solution steps for a wrong answer
struct SolutionPanelView: View {
    let question: Question
    let difficultyLevel: DifficultyLevel
    @Binding var isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack {
            // Toggle button
            Button(action: onToggle) {
                HStack(spacing: 8) {
                    Image(systemName: isExpanded ? "eye.slash.fill" : "eye.fill")
                    Text(isExpanded ? "button.hide_solution".localized : "button.show_solution".localized)
                        .font(.adaptiveBody())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(.adaptiveCornerRadius)
                .shadow(color: Color.green.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .padding(.top, 8)

            // Solution content
            if isExpanded {
                solutionContent
                    .transition(.opacity.combined(with: .scale))
            }
        }
    }

    @ViewBuilder
    private var solutionContent: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("solution.content".localized)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: "scroll")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)

            // Solution text
            ScrollView(.vertical, showsIndicators: true) {
                Text(question.getSolutionSteps(for: difficultyLevel))
                    .font(.footnote)
                    .lineSpacing(2)
                    .padding(12)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(8)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 6)
            }
            .frame(height: calculateHeight())
            .padding(.horizontal, 10)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private func calculateHeight() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let isLandscape = screenWidth > screenHeight

        let fixedUIHeight: CGFloat = 380
        let availableHeight = screenHeight - fixedUIHeight

        if DeviceUtils.isIPad {
            return isLandscape ? max(availableHeight * 0.4, 120) : max(availableHeight * 0.5, 180)
        } else {
            return isLandscape ? max(availableHeight * 0.3, 80) : max(availableHeight * 0.4, 150)
        }
    }
}

struct SolutionPanelView_Previews: PreviewProvider {
    static var previews: some View {
        SolutionPanelView(
            question: Question(number1: 15, number2: 8, operation: .subtraction),
            difficultyLevel: .level2,
            isExpanded: .constant(true),
            onToggle: {}
        )
    }
}
