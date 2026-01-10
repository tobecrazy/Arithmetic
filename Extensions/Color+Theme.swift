import SwiftUI

/// Adaptive color scheme extensions for better dark mode support
extension Color {
    /// Creates a color that adapts to light and dark mode
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    // MARK: - App-specific adaptive colors

    /// Primary background color for cards and containers
    static var adaptiveBackground: Color {
        adaptive(light: Color.white, dark: Color(red: 0.15, green: 0.15, blue: 0.17))
    }

    /// Secondary background for nested containers
    static var adaptiveSecondaryBackground: Color {
        adaptive(light: Color.gray.opacity(0.1), dark: Color(red: 0.12, green: 0.12, blue: 0.14))
    }

    /// Primary text color
    static var adaptiveText: Color {
        adaptive(light: Color.primary, dark: Color.white)
    }

    /// Secondary text color
    static var adaptiveSecondaryText: Color {
        adaptive(light: Color.secondary, dark: Color(red: 0.6, green: 0.6, blue: 0.6))
    }

    /// Accent color for interactive elements
    static var accent: Color {
        adaptive(light: Color.blue, dark: Color(red: 0.2, green: 0.5, blue: 1.0))
    }

    /// Success color
    static var success: Color {
        adaptive(light: Color.green, dark: Color(red: 0.2, green: 0.8, blue: 0.4))
    }

    /// Error color
    static var error: Color {
        adaptive(light: Color.red, dark: Color(red: 0.9, green: 0.3, blue: 0.3))
    }

    /// Warning color
    static var warning: Color {
        adaptive(light: Color.orange, dark: Color(red: 1.0, green: 0.6, blue: 0.2))
    }

    /// Border color for cards and containers
    static var adaptiveBorder: Color {
        adaptive(light: Color.gray.opacity(0.2), dark: Color.gray.opacity(0.3))
    }

    /// Shadow color
    static var adaptiveShadow: Color {
        adaptive(light: Color.black.opacity(0.1), dark: Color.black.opacity(0.3))
    }

    /// Progress bar gradient colors
    static var progressGradientStart: Color {
        adaptive(light: Color.blue, dark: Color(red: 0.3, green: 0.6, blue: 1.0))
    }

    static var progressGradientEnd: Color {
        adaptive(light: Color.purple, dark: Color(red: 0.6, green: 0.4, blue: 1.0))
    }

    /// Button background color
    static var buttonBackground: Color {
        adaptive(light: Color.blue, dark: Color(red: 0.2, green: 0.5, blue: 1.0))
    }

    /// Button disabled color
    static var buttonDisabled: Color {
        adaptive(light: Color.gray, dark: Color(red: 0.4, green: 0.4, blue: 0.4))
    }
}

/// Theme configuration for the app
struct AppTheme {
    /// Standard corner radius for cards
    static var cornerRadius: CGFloat {
        12
    }

    /// Small corner radius for buttons
    static var smallCornerRadius: CGFloat {
        8
    }

    /// Large corner radius for modals
    static var largeCornerRadius: CGFloat {
        20
    }

    /// Standard shadow radius
    static var shadowRadius: CGFloat {
        8
    }

    /// Light shadow radius
    static var lightShadowRadius: CGFloat {
        4
    }

    /// Card padding
    static var cardPadding: CGFloat {
        16
    }

    /// Standard animation duration
    static var animationDuration: Double {
        0.3
    }

    /// Spring animation response
    static var springResponse: Double {
        0.4
    }

    /// Spring damping fraction
    static var springDampingFraction: Double {
        0.7
    }
}

/// View modifier for adaptive card styling
struct AdaptiveCardStyle: ViewModifier {
    var backgroundColor: Color = .adaptiveBackground
    var cornerRadius: CGFloat = AppTheme.cornerRadius
    var shadowRadius: CGFloat = AppTheme.shadowRadius

    func body(content: Content) -> some View {
        content
            .padding(AppTheme.cardPadding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.adaptiveBorder, lineWidth: 1)
            )
            .shadow(color: Color.adaptiveShadow, radius: shadowRadius, x: 0, y: 2)
    }
}

/// View modifier for adaptive button styling
struct AdaptiveButtonStyle: ViewModifier {
    var isEnabled: Bool = true
    var backgroundColor: Color = .buttonBackground
    var cornerRadius: CGFloat = AppTheme.smallCornerRadius

    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isEnabled ? backgroundColor : .buttonDisabled)
            .cornerRadius(cornerRadius)
            .shadow(color: isEnabled ? Color.adaptiveShadow : Color.clear, radius: AppTheme.lightShadowRadius, x: 0, y: 2)
    }
}

extension View {
    /// Applies adaptive card styling
    func adaptiveCard(backgroundColor: Color = .adaptiveBackground, cornerRadius: CGFloat = AppTheme.cornerRadius, shadowRadius: CGFloat = AppTheme.shadowRadius) -> some View {
        self.modifier(AdaptiveCardStyle(backgroundColor: backgroundColor, cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }

    /// Applies adaptive button styling
    func adaptiveButton(isEnabled: Bool = true, backgroundColor: Color = .buttonBackground, cornerRadius: CGFloat = AppTheme.smallCornerRadius) -> some View {
        self.modifier(AdaptiveButtonStyle(isEnabled: isEnabled, backgroundColor: backgroundColor, cornerRadius: cornerRadius))
    }
}
