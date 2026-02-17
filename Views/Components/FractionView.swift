import SwiftUI

// Note: Fraction is defined in Models/Fraction.swift and will be available through the target

/// A reusable view that displays a single fraction with proper mathematical formatting
/// Shows the numerator on top, a horizontal line, and the denominator on the bottom
struct FractionView: View {
    let fraction: Fraction
    let baseFontSize: CGFloat

    var body: some View {
        VStack(spacing: 4) {
            // Numerator
            Text("\(fraction.numerator)")
                .font(.system(size: baseFontSize * 0.75, weight: .semibold))
                .frame(height: baseFontSize * 0.75)

            // Fraction line (using a divider-like line)
            Divider()
                .frame(height: 1.5)

            // Denominator
            Text("\(fraction.denominator)")
                .font(.system(size: baseFontSize * 0.75, weight: .semibold))
                .frame(height: baseFontSize * 0.75)
        }
        .frame(minWidth: max(
            baseFontSize * 0.75 * CGFloat(String(fraction.numerator).count) * 0.6,
            baseFontSize * 0.75 * CGFloat(String(fraction.denominator).count) * 0.6,
            50
        ))
    }
}

// MARK: - Preview

struct FractionView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Simple fractions
            HStack(spacing: 20) {
                FractionView(fraction: Fraction(numerator: 1, denominator: 2), baseFontSize: 40)
                FractionView(fraction: Fraction(numerator: 3, denominator: 4), baseFontSize: 40)
                FractionView(fraction: Fraction(numerator: 7, denominator: 10), baseFontSize: 40)
            }
            .padding()

            // Larger fractions
            HStack(spacing: 20) {
                FractionView(fraction: Fraction(numerator: 11, denominator: 100), baseFontSize: 40)
                FractionView(fraction: Fraction(numerator: 5, denominator: 6), baseFontSize: 40)
            }
            .padding()
        }
        .padding()
    }
}
