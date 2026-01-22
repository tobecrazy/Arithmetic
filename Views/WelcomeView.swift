import SwiftUI

// MARK: - Welcome / Onboarding
struct WelcomeView: View {
    @State private var currentPage = 0
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                IntroPage()
                    .tag(0)
                DifficultyLevelsPage()
                    .tag(1)
                FeaturesPage()
                    .tag(2)
                FeaturesPage2()
                    .tag(3)
                HowToPage()
                    .tag(4)
                HowToPage2()
                    .tag(5)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .automatic))

            // Persistent Start button (top-right)
            VStack {
                HStack {
                    Spacer()
                    Button(action: { onDismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                                .font(.subheadline.weight(.bold))
                            Text("welcome.start_button".localized)
                                .font(.subheadline.weight(.bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.progressGradientStart, Color.progressGradientEnd]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: .blue.opacity(0.25), radius: 6, x: 0, y: 3)
                        .accessibilityIdentifier("welcomeTopStartButton")
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 16)
                Spacer()
            }

            // Bottom navigation bar
            VStack {
                Spacer()
                HStack {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation(.easeInOut) { currentPage -= 1 }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("welcome.prev".localized)
                            }
                            .font(.body.weight(.medium))
                        }
                        .accessibilityIdentifier("welcomePrevButton")
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.accentColor.opacity(0.1))
                        .clipShape(Capsule())
                    }

                    Spacer()

                    if currentPage < 5 {
                        Button(action: {
                            withAnimation(.easeInOut) { currentPage += 1 }
                        }) {
                            HStack {
                                Text("welcome.next".localized)
                                Image(systemName: "chevron.right")
                            }
                            .font(.body.weight(.medium))
                        }
                        .accessibilityIdentifier("welcomeNextButton")
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.accentColor.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
            }
            .transition(.opacity)
            .animation(.easeInOut, value: currentPage)
        }
    }
}

// MARK: - Shared Page Container
private struct PageContainer<Content: View>: View {
    let icon: String
    let iconColor: Color
    let gradient: [Color]
    let titleKey: String
    @ViewBuilder let content: Content

    init(icon: String, iconColor: Color, gradient: [Color], titleKey: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.iconColor = iconColor
        self.gradient = gradient
        self.titleKey = titleKey
        self.content = content()
    }

    var body: some View {
        ScrollView { // Unified scroll container for consistency
            VStack(spacing: 24) {
                // Icon + ring
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: gradient.map { $0.opacity(0.65) }),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: iconColor.opacity(0.2), radius: 10)

                    Image(systemName: icon)
                        .font(.system(size: 72))
                        .foregroundColor(iconColor)
                        .accessibilityHidden(true)
                }
                .padding(.top, 20)

                // Title
                Text(titleKey.localized)
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .foregroundColor(.primary)
                    .accessibilityIdentifier(titleKey)

                content
                    .padding(.horizontal, 20)

                Spacer(minLength: 40)
            }
            .frame(maxWidth: 900) // Constrain width for large screens (iPad/Mac)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Individual Pages
private struct IntroPage: View {
    @State private var animate = false
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Enhanced icon area
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.progressGradientStart.opacity(0.65), Color.progressGradientEnd.opacity(0.65)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: Color.blue.opacity(0.2), radius: 10)

                    Image(systemName: "figure.walk.arithmetic")
                        .font(.system(size: 72))
                        .foregroundColor(.blue)
                        .accessibilityHidden(true)

                    // Decorative math symbols
                    Group {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.success) // Adaptive green
                            .offset(x: -50, y: -10)
                        Image(systemName: "minus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.accent) // Adaptive blue
                            .offset(x: 48, y: 12)
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.error) // Adaptive red
                            .offset(x: -20, y: 50)
                        Image(systemName: "divide")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.warning) // Adaptive orange
                            .offset(x: 20, y: -50)
                    }
                    .opacity(animate ? 1 : 0.4)
                    .scaleEffect(animate ? 1 : 0.85)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
                }
                .padding(.top, 20)
                .onAppear { animate = true }

                // Tagline
                Text("welcome.icon.tagline".localized)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .accessibilityIdentifier("welcomeIntroTagline")

                // Title
                Text("welcome.title".localized)
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .foregroundColor(.primary)
                    .accessibilityIdentifier("welcome.title")

                // Intro description card
                Text("welcome.intro".localized)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                    )
                    .accessibilityIdentifier("welcomeIntroText")

                Spacer(minLength: 40)
            }
            .frame(maxWidth: 900)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct DifficultyLevelsPage: View {
    var body: some View {
        PageContainer(icon: "number", iconColor: .green, gradient: [.success, .accent], titleKey: "welcome.levels.title") {
            LazyVStack(spacing: 14) {
                ForEach(DifficultyLevel.allCases, id: \.self) { level in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .center) {
                            Text(level.localizedName)
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()

                            DifficultyStarRow(level: level)
                        }
                        Text(level.localizedDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [.green.opacity(0.35), .blue.opacity(0.35)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .accessibilityIdentifier("difficultyRow_\(level)")
                }
            }
        }
    }
}

private struct FeaturesPage: View {
    var body: some View {
        PageContainer(icon: "lightbulb.fill", iconColor: .orange, gradient: [.warning, .error], titleKey: "welcome.features.title") {
            VStack(spacing: 18) {
                FeatureCard(icon: "gamecontroller.fill", iconColor: .blue, title: "welcome.feature.game.title".localized, description: "welcome.feature.game.desc".localized)
                FeatureCard(icon: "text.book.closed.fill", iconColor: .green, title: "welcome.feature.solutions.title".localized, description: "welcome.feature.solutions.desc".localized)
                FeatureCard(icon: "doc.text.magnifyingglass.fill", iconColor: .red, title: "welcome.feature.wrongquestions.title".localized, description: "welcome.feature.wrongquestions.desc".localized)
                FeatureCard(icon: "multiply.circle.fill", iconColor: .purple, title: "welcome.feature.multiplication.title".localized, description: "welcome.feature.multiplication.desc".localized)
            }
        }
    }
}

private struct FeaturesPage2: View {
    var body: some View {
        PageContainer(icon: "sparkles", iconColor: .yellow, gradient: [.warning, .accent], titleKey: "welcome.features.title2") {
            VStack(spacing: 18) {
                FeatureCard(icon: "qrcode", iconColor: .gray, title: "welcome.feature.qrcode.title".localized, description: "welcome.feature.qrcode.desc".localized)
                FeatureCard(icon: "doc.text", iconColor: .brown, title: "welcome.feature.pdf.title".localized, description: "welcome.feature.pdf.desc".localized)
            }
        }
    }
}

private struct HowToPage: View {
    var body: some View {
        PageContainer(icon: "hand.tap.fill", iconColor: .purple, gradient: [.accent, .primary], titleKey: "welcome.howto.title") {
            VStack(spacing: 18) {
                HowToStep(number: 1, title: "welcome.howto.step1.title".localized, description: "welcome.howto.step1.desc".localized, color: .blue)
                HowToStep(number: 2, title: "welcome.howto.step2.title".localized, description: "welcome.howto.step2.desc".localized, color: .green)
                HowToStep(number: 3, title: "welcome.howto.step3.title".localized, description: "welcome.howto.step3.desc".localized, color: .orange)
                HowToStep(number: 4, title: "welcome.howto.step4.title".localized, description: "welcome.howto.step4.desc".localized, color: .red)
            }
        }
    }
}

private struct HowToPage2: View {
    var body: some View {
        PageContainer(icon: "hand.draw.fill", iconColor: .pink, gradient: [.error, .warning], titleKey: "welcome.howto.title") {
            VStack(spacing: 18) {
                HowToStep(number: 5, title: "welcome.howto.step5.title".localized, description: "welcome.howto.step5.desc".localized, color: .purple)
                HowToStep(number: 6, title: "welcome.howto.step6.title".localized, description: "welcome.howto.step6.desc".localized, color: .pink)
                HowToStep(number: 7, title: "welcome.howto.step7.title".localized, description: "welcome.howto.step7.desc".localized, color: .gray)
                HowToStep(number: 8, title: "welcome.howto.step8.title".localized, description: "welcome.howto.step8.desc".localized, color: .brown)
            }
        }
    }
}

// MARK: - Components
private struct FeatureCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(iconColor.opacity(0.12))
                    .frame(width: 54, height: 54)
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .primary.opacity(0.05), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

private struct HowToStep: View {
    let number: Int
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(color)
                    .frame(width: 44, height: 44)
                Text("\(number)")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .primary.opacity(0.05), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.35), lineWidth: 2)
        )
        .accessibilityIdentifier("howToStep_\(number)")
    }
}

private struct DifficultyStarRow: View {
    let level: DifficultyLevel
    var body: some View {
        let difficultyIndex = DifficultyLevel.allCases.firstIndex(of: level) ?? 0
        HStack(spacing: 4) {
            ForEach(0..<DifficultyLevel.allCases.count, id: \.self) { i in
                Image(systemName: i <= difficultyIndex ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundColor(i <= difficultyIndex ? .accentColor : .secondary.opacity(0.45))
            }
        }
        .accessibilityLabel("difficultyStars_\(difficultyIndex + 1)")
    }
}

// MARK: - Difficulty Description Extension
extension DifficultyLevel {
    var localizedDescription: String {
        switch self {
        case .level1: return "welcome.level1.desc".localized
        case .level2: return "welcome.level2.desc".localized
        case .level3: return "welcome.level3.desc".localized
        case .level4: return "welcome.level4.desc".localized
        case .level5: return "welcome.level5.desc".localized
        case .level6: return "welcome.level6.desc".localized
        }
    }
}

// MARK: - Preview
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WelcomeView(onDismiss: {})
                .environmentObject(LocalizationManager())
                .previewDisplayName("iPhone")
            WelcomeView(onDismiss: {})
                .environmentObject(LocalizationManager())
                .previewDevice("iPad (10th generation)")
                .previewDisplayName("iPad")
        }
    }
}
