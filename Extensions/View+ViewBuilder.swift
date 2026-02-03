import SwiftUI

/// Extension providing ViewBuilder utilities for cleaner view composition
extension View {
    /// Conditionally applies a transformation to the view.
    ///
    /// This ViewBuilder utility allows for cleaner conditional view modifications
    /// without breaking the SwiftUI view builder chain.
    ///
    /// - Parameters:
    ///   - condition: Whether to apply the transformation
    ///   - transform: The transformation closure to apply if condition is true
    /// - Returns: Either the transformed view or the original view
    ///
    /// ## Example
    /// ```swift
    /// Text("Hello")
    ///     .if(isPremium) { view in
    ///         view.foregroundColor(.gold)
    ///     }
    /// ```
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Conditionally applies one of two transformations to the view.
    ///
    /// Provides a clean if-else pattern for view transformations.
    ///
    /// - Parameters:
    ///   - condition: The condition to evaluate
    ///   - trueTransform: Transformation to apply if condition is true
    ///   - falseTransform: Transformation to apply if condition is false
    /// - Returns: The transformed view based on the condition
    ///
    /// ## Example
    /// ```swift
    /// Text("Status")
    ///     .ifElse(isActive,
    ///         trueTransform: { $0.foregroundColor(.green) },
    ///         falseTransform: { $0.foregroundColor(.gray) }
    ///     )
    /// ```
    @ViewBuilder
    func ifElse<TrueTransform: View, FalseTransform: View>(
        _ condition: Bool,
        trueTransform: (Self) -> TrueTransform,
        falseTransform: (Self) -> FalseTransform
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }

    /// Applies a transformation based on an optional value.
    ///
    /// Only applies the transformation if the optional value is non-nil.
    ///
    /// - Parameters:
    ///   - value: The optional value to unwrap
    ///   - transform: The transformation closure that receives the unwrapped value
    /// - Returns: Either the transformed view or the original view
    ///
    /// ## Example
    /// ```swift
    /// Text("Title")
    ///     .ifLet(errorMessage) { view, message in
    ///         view.overlay(
    ///             Text(message).foregroundColor(.red),
    ///             alignment: .bottom
    ///         )
    ///     }
    /// ```
    @ViewBuilder
    func ifLet<Value, Transform: View>(_ value: Value?, transform: (Self, Value) -> Transform) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
}

/// A namespace for common ViewBuilder patterns used throughout the app
enum ViewBuilders {
    /// Creates a status badge view with adaptive styling.
    ///
    /// - Parameters:
    ///   - text: The badge text to display
    ///   - color: The badge background color
    /// - Returns: A styled badge view
    @ViewBuilder
    static func badge(text: String, color: Color) -> some View {
        Text(text)
            .font(.adaptiveCaption())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }

    /// Creates an icon with text label in a horizontal stack.
    ///
    /// - Parameters:
    ///   - systemName: SF Symbol name for the icon
    ///   - text: The text label
    ///   - color: The tint color (defaults to primary)
    /// - Returns: An icon-text combination view
    @ViewBuilder
    static func iconLabel(systemName: String, text: String, color: Color = .primary) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemName)
                .font(.caption)
            Text(text)
                .font(.adaptiveBody())
        }
        .foregroundColor(color)
    }

    /// Creates a card-style container with rounded corners and shadow.
    ///
    /// - Parameter content: The content view to wrap in a card
    /// - Returns: A card-styled container view
    @ViewBuilder
    static func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(.adaptiveCornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    /// Creates an overlay loading indicator.
    ///
    /// - Parameter isLoading: Whether to show the loading indicator
    /// - Returns: A loading overlay view
    @ViewBuilder
    static func loadingOverlay(isLoading: Bool) -> some View {
        if isLoading {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }

    /// Creates an empty state view with icon and message.
    ///
    /// - Parameters:
    ///   - systemName: SF Symbol name for the empty state icon
    ///   - message: The empty state message
    /// - Returns: An empty state view
    @ViewBuilder
    static func emptyState(systemName: String, message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: systemName)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text(message)
                .font(.adaptiveBody())
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
