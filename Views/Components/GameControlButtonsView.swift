import SwiftUI

/// Displays game control buttons (pause, save, exit, finish)
struct GameControlButtonsView: View {
    let isPauseDisabled: Bool
    @Binding var showingPauseAlert: Bool
    @Binding var showingExitAlert: Bool
    let onPause: () -> Void
    let onSave: () -> Void
    let onExit: () -> Void
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Top row: Pause and Save
            HStack {
                pauseButton
                Spacer()
                saveButton
            }
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.05))

            // Bottom row: Exit and Finish
            HStack {
                exitButton
                Spacer()
                finishButton
            }
            .background(Color.gray.opacity(0.1))
        }
    }

    @ViewBuilder
    private var pauseButton: some View {
        Button(action: {
            if !isPauseDisabled {
                showingPauseAlert = true
            }
        }) {
            HStack {
                Image(systemName: "pause.circle")
                Text("button.pause".localized)
            }
            .foregroundColor(isPauseDisabled ? .gray : .orange)
        }
        .disabled(isPauseDisabled)
        .padding(.horizontal)
        .alert(isPresented: $showingPauseAlert) {
            Alert(
                title: Text("alert.pause_title".localized),
                message: Text("alert.pause_message".localized),
                primaryButton: .destructive(Text("alert.pause_confirm".localized)) {
                    onPause()
                },
                secondaryButton: .cancel(Text("alert.cancel".localized))
            )
        }
    }

    @ViewBuilder
    private var saveButton: some View {
        Button(action: onSave) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                Text("button.save".localized)
            }
            .foregroundColor(.blue)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var exitButton: some View {
        Button(action: {
            showingExitAlert = true
        }) {
            Text("button.exit".localized)
                .foregroundColor(.red)
        }
        .padding()
        .alert(isPresented: $showingExitAlert) {
            Alert(
                title: Text("alert.exit_title".localized),
                message: Text("alert.exit_message".localized),
                primaryButton: .destructive(Text("alert.exit_confirm".localized)) {
                    onExit()
                },
                secondaryButton: .cancel(Text("alert.cancel".localized))
            )
        }
    }

    @ViewBuilder
    private var finishButton: some View {
        Button(action: onFinish) {
            Text("button.finish".localized)
                .foregroundColor(.blue)
        }
        .padding()
    }
}

struct GameControlButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        GameControlButtonsView(
            isPauseDisabled: false,
            showingPauseAlert: .constant(false),
            showingExitAlert: .constant(false),
            onPause: {},
            onSave: {},
            onExit: {},
            onFinish: {}
        )
    }
}
