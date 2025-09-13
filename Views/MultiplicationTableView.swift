import SwiftUI
import AVFoundation

struct MultiplicationTableView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var ttsHelper = TTSHelper()
    
    // Grid configuration for different device types
    private var gridColumns: [GridItem] {
        let deviceColumns: Int
        
        if DeviceUtils.isIPad {
            if DeviceUtils.isLandscape(with: (horizontalSizeClass, verticalSizeClass)) {
                deviceColumns = 9 // iPad landscape: show all 9 columns
            } else {
                deviceColumns = 6 // iPad portrait: 6 columns for better readability
            }
        } else {
            if DeviceUtils.isLandscape(with: (horizontalSizeClass, verticalSizeClass)) {
                deviceColumns = 6 // iPhone landscape: 6 columns
            } else {
                deviceColumns = 3 // iPhone portrait: 3 columns
            }
        }
        
        return Array(repeating: GridItem(.flexible(), spacing: 8), count: deviceColumns)
    }
    
    // Generate all multiplication results
    private var multiplicationResults: [(String, Color)] {
        var results: [(String, Color)] = []
        
        for i in 1...9 {
            for j in 1...9 {
                let result = i * j
                let formula = "multiplication_table.formula".localizedFormat(String(i), String(j), String(result))
                
                // Color coding for better visual distinction
                let color: Color
                if i == j {
                    color = .blue.opacity(0.2) // Same numbers (1×1, 2×2, etc.)
                } else if result <= 10 {
                    color = .green.opacity(0.15) // Easy results
                } else if result <= 50 {
                    color = .orange.opacity(0.15) // Medium results
                } else {
                    color = .red.opacity(0.15) // Challenging results
                }
                
                results.append((formula, color))
            }
        }
        
        return results
    }
    
    // Extract mathematical expression from index
    private func extractMathExpression(from formattedString: String, at index: Int) -> String {
        // Calculate i and j from index (0-based to 1-based)
        let i = (index / 9) + 1
        let j = (index % 9) + 1
        let result = i * j
        
        // Return the mathematical expression in standard format
        return "\(i) × \(j) = \(result)"
    }
    
    // Create multiplication button view
    private func multiplicationButton(for item: (String, Color), at index: Int) -> some View {
        Button(action: {
            let mathExpression = extractMathExpression(from: item.0, at: index)
            ttsHelper.speakMathExpression(mathExpression, language: localizationManager.currentLanguage)
        }) {
            VStack(spacing: 4) {
                Text(item.0)
                    .font(.adaptiveBody())
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .frame(minHeight: 60)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                    .fill(item.1)
                    .overlay(
                        RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Fixed header
            VStack {
                Text("multiplication_table.title".localized)
                    .font(.adaptiveTitle())
                    .padding()
                
                // Instructions
                Text("multiplication_table.instructions".localized)
                    .font(.adaptiveBody())
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            .background(Color(.systemBackground))
            
            // Scrollable multiplication table
            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                LazyVGrid(columns: gridColumns, spacing: 12) {
                    ForEach(Array(multiplicationResults.enumerated()), id: \.offset) { index, item in
                        multiplicationButton(for: item, at: index)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("multiplication_table.title".localized)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("button.back".localized)
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct MultiplicationTableView_Previews: PreviewProvider {
    static var previews: some View {
        MultiplicationTableView()
            .environmentObject(LocalizationManager())
    }
}
