import SwiftUI

extension View {
    func dismissToRoot() -> some View {
        self.modifier(DismissToRootViewModifier())
    }
}

struct DismissToRootViewModifier: ViewModifier {
    @Environment(\.presentationMode) var presentationMode
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DismissToRootView"))) { _ in
                self.presentationMode.wrappedValue.dismiss()
            }
    }
}

// This function can be used to trigger dismissal to root view
func triggerGlobalDismiss() {
    NotificationCenter.default.post(name: Notification.Name("DismissToRootView"), object: nil)
}
