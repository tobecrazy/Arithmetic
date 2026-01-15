import SwiftUI
import AVFoundation

struct MultiplicationTableView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var ttsHelper = TTSHelper()
    @State private var animateHeader = false
    @State private var selectedCell: String? = nil
    @State private var showLegend = true

    // MARK: - Difficulty Level Colors
    private struct DifficultyColors {
        static let perfect = LinearGradient(
            colors: [Color.purple.opacity(0.3), Color.purple.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let easy = LinearGradient(
            colors: [Color.green.opacity(0.2), Color.green.opacity(0.35)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let medium = LinearGradient(
            colors: [Color.orange.opacity(0.2), Color.orange.opacity(0.35)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let hard = LinearGradient(
            colors: [Color.red.opacity(0.2), Color.red.opacity(0.35)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static func solidColor(for i: Int, j: Int, result: Int) -> Color {
            if i == j { return .purple }
            else if result <= 10 { return .green }
            else if result <= 50 { return .orange }
            else { return .red }
        }

        static func gradient(for i: Int, j: Int, result: Int) -> LinearGradient {
            if i == j { return perfect }
            else if result <= 10 { return easy }
            else if result <= 50 { return medium }
            else { return hard }
        }
    }

    // Cell size based on device
    private var cellSize: CGSize {
        if DeviceUtils.isIPad {
            if DeviceUtils.isLandscape(with: (horizontalSizeClass, verticalSizeClass)) {
                return CGSize(width: 95, height: 75)
            } else {
                return CGSize(width: 85, height: 70)
            }
        } else {
            if DeviceUtils.isLandscape(with: (horizontalSizeClass, verticalSizeClass)) {
                return CGSize(width: 80, height: 65)
            } else {
                return CGSize(width: 105, height: 70)
            }
        }
    }

    // Create multiplication cell view for triangular layout
    private func multiplicationCell(i: Int, j: Int) -> some View {
        let result = i * j
        let cellId = "\(i)x\(j)"
        let isSelected = selectedCell == cellId
        let solidColor = DifficultyColors.solidColor(for: i, j: j, result: result)

        return Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()

            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                selectedCell = isSelected ? nil : cellId
            }

            guard UserDefaults.standard.bool(forKey: "isTtsEnabled") else {
                return
            }
            let mathExpression = "\(i) × \(j) = \(result)"
            ttsHelper.speakMathExpression(mathExpression, language: localizationManager.currentLanguage)
        }) {
            VStack(spacing: 2) {
                // Formula: i × j
                HStack(spacing: 2) {
                    Text("\(i)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(solidColor)
                    Text("×")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                    Text("\(j)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(solidColor)
                }

                // Result with equals
                HStack(spacing: 2) {
                    Text("=")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                    Text("\(result)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptiveText)
                }
            }
            .frame(width: cellSize.width, height: cellSize.height)
            .background(
                ZStack {
                    // Base gradient
                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                        .fill(DifficultyColors.gradient(for: i, j: j, result: result))

                    // Highlight overlay for perfect squares (diagonal)
                    if i == j {
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.7), Color.purple.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .stroke(Color.adaptiveBorder, lineWidth: 0.5)
            )
            .shadow(
                color: isSelected ? solidColor.opacity(0.5) : Color.adaptiveShadow.opacity(0.5),
                radius: isSelected ? 6 : 2,
                x: 0,
                y: isSelected ? 3 : 1
            )
            .scaleEffect(isSelected ? 1.08 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Triangular Table View
    private var triangularTableView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Row n contains: 1×n, 2×n, 3×n, ..., n×n
            ForEach(1...9, id: \.self) { row in
                HStack(spacing: 6) {
                    // Row label
                    Text("\(row)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(Color.accent.opacity(0.15))
                        )

                    // Cells for this row: 1×row, 2×row, ..., row×row
                    ForEach(1...row, id: \.self) { col in
                        multiplicationCell(i: col, j: row)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.leading, 8)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
    }

    // MARK: - Legend View
    private var legendView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("multiplication_table.legend".localized)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.adaptiveSecondaryText)

                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showLegend.toggle()
                    }
                }) {
                    Image(systemName: showLegend ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.accent)
                }
            }

            if showLegend {
                HStack(spacing: 12) {
                    legendItem(color: .purple, label: "multiplication_table.perfect_square".localized, icon: "star.fill")
                    legendItem(color: .green, label: "multiplication_table.easy".localized, icon: "leaf.fill")
                    legendItem(color: .orange, label: "multiplication_table.medium".localized, icon: "flame.fill")
                    legendItem(color: .red, label: "multiplication_table.hard".localized, icon: "bolt.fill")
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(Color.adaptiveBackground)
                .shadow(color: Color.adaptiveShadow, radius: AppTheme.lightShadowRadius, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
    }

    private func legendItem(color: Color, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
            }

            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.adaptiveSecondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Stats Header
    private var statsHeader: some View {
        HStack(spacing: 16) {
            statCard(
                value: "45",
                label: "multiplication_table.total_facts".localized,
                icon: "number.circle.fill",
                color: .accent
            )

            statCard(
                value: "9",
                label: "multiplication_table.perfect_squares".localized,
                icon: "star.circle.fill",
                color: .purple
            )

            statCard(
                value: "1-81",
                label: "multiplication_table.range".localized,
                icon: "arrow.left.arrow.right.circle.fill",
                color: .success
            )
        }
        .padding(.horizontal, 16)
        .opacity(animateHeader ? 1 : 0)
        .offset(y: animateHeader ? 0 : -20)
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)

                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptiveText)
            }

            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.adaptiveSecondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .fill(color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(.systemBackground), Color.adaptiveSecondaryBackground],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Stats header
                statsHeader
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                // Legend
                legendView
                    .padding(.bottom, 12)

                // Tip text
                HStack(spacing: 6) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.accent)
                    Text("multiplication_table.tap_hint".localized)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                }
                .padding(.bottom, 8)

                // Scrollable triangular multiplication table
                ScrollView([.vertical, .horizontal], showsIndicators: true) {
                    triangularTableView
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateHeader = true
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
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("button.back".localized)
                    }
                    .foregroundColor(.accent)
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
