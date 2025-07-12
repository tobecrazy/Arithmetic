import SwiftUI

struct MultiplicationTableView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.presentationMode) var presentationMode
    
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
    
    var body: some View {
        NavigationView {
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
                            VStack(spacing: 4) {
                                Text(item.0)
                                    .font(.adaptiveBody())
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
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
                    }
                    .padding()
                }
                
                // Fixed bottom area with return button
                VStack {
                    Divider()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("button.back".localized)
                            .font(.adaptiveHeadline())
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(.adaptiveCornerRadius)
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MultiplicationTableView_Previews: PreviewProvider {
    static var previews: some View {
        MultiplicationTableView()
            .environmentObject(LocalizationManager())
    }
}
