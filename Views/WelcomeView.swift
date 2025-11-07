import SwiftUI

struct WelcomeView: View {
    @State private var currentPage = 0
    @Binding var showWelcome: Bool
    
    var body: some View {
        NavigationView {
            TabView(selection: $currentPage) {
                // Page 1: App Introduction
                VStack(spacing: 25) {
                    Spacer()

                    Image(systemName: "figure.walk.arithmetic")
                        .font(.system(size: 90))
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                        .shadow(color: .blue.opacity(0.3), radius: 10)

                    Text("welcome.title".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.primary)

                    Text("welcome.intro".localized)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .tag(0)
                
                // Page 2: Difficulty Levels
                VStack(spacing: 25) {
                    Spacer()

                    Image(systemName: "number")
                        .font(.system(size: 90))
                        .foregroundColor(.green)
                        .padding(.bottom, 20)
                        .shadow(color: .green.opacity(0.3), radius: 10)

                    Text("welcome.levels.title".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.primary)

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(DifficultyLevel.allCases, id: \.self) { level in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(level.localizedName)
                                            .font(.headline)
                                            .foregroundColor(.primary)

                                        Spacer()

                                        // 添加难度指示器
                                        HStack(spacing: 4) {
                                            let difficultyIndex = DifficultyLevel.allCases.firstIndex(of: level) ?? 0
                                            ForEach(0..<difficultyIndex + 1, id: \.self) { _ in
                                                Image(systemName: "star.fill")
                                                    .font(.caption)
                                                    .foregroundColor(.orange)
                                            }
                                            ForEach(difficultyIndex + 1..<DifficultyLevel.allCases.count, id: \.self) { _ in
                                                Image(systemName: "star")
                                                    .font(.caption)
                                                    .foregroundColor(.gray.opacity(0.5))
                                            }
                                        }
                                    }

                                    Text(level.localizedDescription)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.05), radius: 5)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                .tag(1)
                
                // Page 3: Main Features
                VStack(spacing: 25) {
                    Spacer()

                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 90))
                        .foregroundColor(.orange)
                        .padding(.bottom, 20)
                        .shadow(color: .orange.opacity(0.3), radius: 10)

                    Text("welcome.features.title".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.primary)

                    ScrollView {
                        VStack(spacing: 16) {
                            EnhancedFeatureRow(
                                icon: "gamecontroller.fill",
                                iconColor: .blue,
                                title: "welcome.feature.game.title".localized,
                                description: "welcome.feature.game.desc".localized
                            )
                            EnhancedFeatureRow(
                                icon: "text.book.closed.fill",
                                iconColor: .green,
                                title: "welcome.feature.solutions.title".localized,
                                description: "welcome.feature.solutions.desc".localized
                            )
                            EnhancedFeatureRow(
                                icon: "doc.text.magnifyingglass.fill",
                                iconColor: .red,
                                title: "welcome.feature.wrongquestions.title".localized,
                                description: "welcome.feature.wrongquestions.desc".localized
                            )
                            EnhancedFeatureRow(
                                icon: "multiply.circle.fill",
                                iconColor: .purple,
                                title: "welcome.feature.multiplication.title".localized,
                                description: "welcome.feature.multiplication.desc".localized
                            )
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                .tag(2)
                
                // Page 4: How to Use
                VStack(spacing: 25) {
                    Spacer()

                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 90))
                        .foregroundColor(.purple)
                        .padding(.bottom, 20)
                        .shadow(color: .purple.opacity(0.3), radius: 10)

                    Text("welcome.howto.title".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.primary)

                    ScrollView {
                        VStack(spacing: 16) {
                            EnhancedHowToRow(
                                number: "1",
                                title: "welcome.howto.step1.title".localized,
                                description: "welcome.howto.step1.desc".localized,
                                accentColor: .blue
                            )
                            EnhancedHowToRow(
                                number: "2",
                                title: "welcome.howto.step2.title".localized,
                                description: "welcome.howto.step2.desc".localized,
                                accentColor: .green
                            )
                            EnhancedHowToRow(
                                number: "3",
                                title: "welcome.howto.step3.title".localized,
                                description: "welcome.howto.step3.desc".localized,
                                accentColor: .orange
                            )
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 100) // 为底部按钮留出空间
                }
                .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showWelcome = false
                    }) {
                        Text("welcome.skip".localized)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        // Enhanced "Start" button that appears on the last page
        .overlay(
            Group {
                if currentPage == 3 {  // Last page
                    VStack {
                        Spacer()
                        Button(action: {
                            showWelcome = false
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                    .font(.title3)
                                Text("welcome.start_button".localized)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 20)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                        .scaleEffect(currentPage == 3 ? 1.0 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
                    }
                }
            }
        )
    }
}

struct EnhancedFeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 50, height: 50)

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
                    .lineLimit(nil)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

struct EnhancedHowToRow: View {
    let number: String
    let title: String
    let description: String
    let accentColor: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(accentColor)
                    .frame(width: 40, height: 40)

                Text(number)
                    .font(.headline)
                    .fontWeight(.bold)
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
                    .lineLimit(nil)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(accentColor.opacity(0.3), lineWidth: 2)
        )
    }
}

// Keep the original components for compatibility
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct HowToRow: View {
    let number: String
    let title: String
    let description: String

    var body: some View {
        HStack {
            Text(number)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color.blue)
                .cornerRadius(15)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

extension DifficultyLevel {
    var localizedDescription: String {
        switch self {
        case .level1:
            return "welcome.level1.desc".localized
        case .level2:
            return "welcome.level2.desc".localized
        case .level3:
            return "welcome.level3.desc".localized
        case .level4:
            return "welcome.level4.desc".localized
        case .level5:
            return "welcome.level5.desc".localized
        case .level6:
            return "welcome.level6.desc".localized
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        @State var showWelcome = true
        return WelcomeView(showWelcome: $showWelcome)
            .environmentObject(LocalizationManager())
    }
}