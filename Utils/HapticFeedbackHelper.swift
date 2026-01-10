import UIKit

/// A helper class for providing haptic feedback throughout the app
/// Provides different types of haptic feedback for various user interactions
class HapticFeedbackHelper {
    static let shared = HapticFeedbackHelper()

    private init() {}

    /// Light haptic for subtle feedback (e.g., button taps, selection changes)
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium haptic for standard interactions (e.g., confirming actions)
    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Heavy haptic for significant events (e.g., completing a game)
    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    /// Success feedback (e.g., correct answer, achievement unlocked)
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Warning feedback (e.g., almost out of time)
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Error feedback (e.g., wrong answer, invalid input)
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    /// Selection changed feedback (e.g., scrolling through options)
    func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    /// Custom haptic with specific intensity and duration
    /// - Parameters:
    ///   - intensity: Value between 0.0 and 1.0
    ///   - duration: Duration in seconds
    func custom(intensity: CGFloat, duration: TimeInterval) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }

    /// Sequential haptic pattern for celebrations
    /// - Parameters:
    ///   - count: Number of haptic bursts
    ///   - interval: Time between bursts
    func celebrate(count: Int = 3, interval: TimeInterval = 0.15) {
        for index in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + (interval * Double(index))) {
                self.medium()
            }
        }
    }

    /// Gentle shake pattern for wrong answers
    func wrongAnswer() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred(intensity: 0.7)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.impactOccurred(intensity: 0.5)
        }
    }

    /// Reward pattern for correct answers (two light taps)
    func correctAnswer() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            generator.impactOccurred()
        }
    }

    /// Progress feedback (e.g., level up, milestone reached)
    func progress() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()

        // Ascending pattern
        generator.impactOccurred(intensity: 0.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.impactOccurred(intensity: 0.7)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            generator.impactOccurred(intensity: 1.0)
        }
    }
}
