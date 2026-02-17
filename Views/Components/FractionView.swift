import SwiftUI

// Note: Fraction is defined in Models/Fraction.swift and will be available through the target

/// A reusable view that displays a single fraction with proper mathematical formatting
/// Shows the numerator on top, a horizontal line, and the denominator on the bottom
struct FractionView: View {
    let fraction: Fraction
    let baseFontSize: CGFloat

    // Calculate text width for numerator and denominator
    private var numeratorWidth: CGFloat {
        let numeratorText = "\(fraction.numerator)"
        let font = UIFont.systemFont(ofSize: baseFontSize * 0.75, weight: .semibold)
        return numeratorText.size(withAttributes: [.font: font]).width
    }

    private var denominatorWidth: CGFloat {
        let denominatorText = "\(fraction.denominator)"
        let font = UIFont.systemFont(ofSize: baseFontSize * 0.75, weight: .semibold)
        return denominatorText.size(withAttributes: [.font: font]).width
    }

    // Calculate line width as the maximum of numerator and denominator widths
    private var lineWidth: CGFloat {
        max(numeratorWidth, denominatorWidth) + 4
    }

    var body: some View {
        VStack(spacing: 3) {
            // Numerator
            Text("\(fraction.numerator)")
                .font(.system(size: baseFontSize * 0.75, weight: .semibold))
                .frame(height: baseFontSize * 0.75)
                .lineLimit(1)

            // Fraction line - width matches numerator/denominator
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.primary)
                .frame(width: lineWidth, height: 2.5)

            // Denominator
            Text("\(fraction.denominator)")
                .font(.system(size: baseFontSize * 0.75, weight: .semibold))
                .frame(height: baseFontSize * 0.75)
                .lineLimit(1)
        }
        .frame(minWidth: lineWidth + 2)
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
