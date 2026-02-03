import SwiftUI
import Combine

/// A reusable view for answer input and submission
struct AnswerInputView: View {
    @Binding var userInput: String
    @Binding var buttonScale: CGFloat
    let isDisabled: Bool
    let onSubmit: () -> Void

    var body: some View {
        VStack {
            // Input field
            HStack {
                TextField("", text: $userInput)
                    .keyboardType(.numberPad)
                    .font(.adaptiveHeadline())
                    .multilineTextAlignment(.center)
                    .frame(width: inputWidth)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(.adaptiveCornerRadius)
                    .disabled(isDisabled)
                    .onReceive(Just(userInput)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.userInput = filtered
                        }
                    }
            }
            .padding()

            // Submit button
            Button(action: onSubmit) {
                Text("game.submit".localized)
                    .font(.adaptiveHeadline())
                    .padding()
                    .frame(width: buttonWidth)
                    .background(userInput.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(.adaptiveCornerRadius)
                    .scaleEffect(buttonScale)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: buttonScale)
            }
            .disabled(userInput.isEmpty || isDisabled)
            .padding()
        }
    }

    private var inputWidth: CGFloat {
        DeviceUtils.isIPad ? 150 : 100
    }

    private var buttonWidth: CGFloat {
        200
    }
}

struct AnswerInputView_Previews: PreviewProvider {
    static var previews: some View {
        AnswerInputView(
            userInput: .constant("42"),
            buttonScale: .constant(1.0),
            isDisabled: false,
            onSubmit: {}
        )
    }
}
