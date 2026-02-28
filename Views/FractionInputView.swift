//
//  FractionInputView.swift
//  Arithmetic
//
//  Created by Claude Code
//  Copyright © 2026 Arithmetic. All rights reserved.
//

import SwiftUI
import Combine

struct FractionInputView: View {
    @Binding var numerator: String
    @Binding var denominator: String
    @State private var numeratorFocused: Bool = false
    @State private var unicodeInput: String = ""
    @State private var inputMode: InputMode = .split

    enum InputMode {
        case split      // Separate numerator/denominator fields
        case unicode    // Single field with Unicode support (½, ⅓, etc.)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Input mode toggle
            Picker("Fraction Input", selection: $inputMode) {
                Text("a/b").tag(InputMode.split)
                Text("½").tag(InputMode.unicode)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 150)

            if inputMode == .unicode {
                // Unicode fraction input
                VStack(spacing: 4) {
                    TextField("½", text: $unicodeInput)
                        .keyboardType(.default)
                        .font(.system(size: 32))
                        .multilineTextAlignment(.center)
                        .frame(width: 120)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(.adaptiveCornerRadius)
                        .onChange(of: unicodeInput) { newValue in
                            // Try to parse the input
                            parseUnicodeInput(newValue)
                        }

                    // Show common Unicode fractions as quick input buttons
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 8) {
                        ForEach(["½", "⅓", "⅔", "¼", "¾", "⅕", "⅖", "⅗", "⅘", "⅙"], id: \.self) { fraction in
                            Button(action: {
                                unicodeInput = fraction
                                parseUnicodeInput(fraction)
                            }) {
                                Text(fraction)
                                    .font(.system(size: 24))
                                    .frame(width: 40, height: 40)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .frame(maxWidth: 300)
                }
            } else {
                // Original split input
                VStack(spacing: 8) {
                    // Numerator input
                    TextField("", text: $numerator)
                        .keyboardType(.numberPad)
                        .font(.adaptiveHeadline())
                        .multilineTextAlignment(.center)
                        .frame(width: 100)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(.adaptiveCornerRadius)
                        .onReceive(Just(numerator)) { newValue in
                            let filtered = newValue.filter { "0123456789-".contains($0) }
                            if filtered != newValue {
                                self.numerator = filtered
                            }
                        }

                    // Division line
                    Divider()
                        .frame(width: 100, height: 2)
                        .background(Color.primary)

                    // Denominator input
                    TextField("", text: $denominator)
                        .keyboardType(.numberPad)
                        .font(.adaptiveHeadline())
                        .multilineTextAlignment(.center)
                        .frame(width: 100)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(.adaptiveCornerRadius)
                        .onReceive(Just(denominator)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.denominator = filtered
                            }
                        }
                }
            }
        }
        .padding()
    }

    // Parse Unicode fraction input and update numerator/denominator
    private func parseUnicodeInput(_ input: String) {
        if let fraction = Fraction.from(string: input) {
            numerator = "\(fraction.numerator)"
            denominator = "\(fraction.denominator)"
        }
    }

    // Helper to validate and create a fraction
    func getFraction() -> Fraction? {
        guard let num = Int(numerator),
              let denom = Int(denominator),
              denom != 0 else {
            return nil
        }
        return Fraction(numerator: num, denominator: denom)
    }
}

// Preview
struct FractionInputView_Previews: PreviewProvider {
    @State static var numerator = "1"
    @State static var denominator = "2"

    static var previews: some View {
        FractionInputView(numerator: $numerator, denominator: $denominator)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
