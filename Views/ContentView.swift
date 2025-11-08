import SwiftUI
import CoreData

// MARK: - Enhanced Color Extensions
extension Color {
    static let primaryBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
    static let secondaryOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let accentGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let backgroundSecondary = Color(red: 0.95, green: 0.95, blue: 0.98)
    static let cardShadow = Color.black.opacity(0.05)
    static let textPrimary = Color(red: 0.2, green: 0.2, blue: 0.3)
    static let textSecondary = Color(red: 0.5, green: 0.5, blue: 0.6)
}

// MARK: - Enhanced Gradients
extension LinearGradient {
    static let primaryGradient = LinearGradient(
        colors: [Color.primaryBlue, Color.primaryBlue.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let orangeGradient = LinearGradient(
        colors: [Color.secondaryOrange, Color.secondaryOrange.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let greenGradient = LinearGradient(
        colors: [Color.accentGreen, Color.accentGreen.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [Color(red: 0.9, green: 0.95, blue: 1.0), Color(red: 0.95, green: 0.98, blue: 1.0)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Enhanced ContentView
struct ContentView: View {
    @State private var selectedDifficulty: DifficultyLevel = .level1
    @State private var timeInMinutes: Int = 5
    @State private var refreshTrigger = UUID()
    @State private var isAnimating = false
    @State private var isStartingGame = false
    @State private var gameViewModel: GameViewModel? = nil
    @State private var showGameView = false
    @State private var showWrongQuestionsView = false
    @State private var showOtherOptionsView = false

    @AppStorage("HasLaunchedBefore") private var hasLaunchedBefore: Bool = false

    private var showWelcome: Bool {
        return !hasLaunchedBefore
    }
    @EnvironmentObject var localizationManager: LocalizationManager

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        Group {
            if showWelcome {
                WelcomeView(onDismiss: {
                    hasLaunchedBefore = true
                    refreshTrigger = UUID()
                })
            } else {
                mainContentView
            }
        }
        .onAppear {
            print("🔍 Debug ContentView.onAppear:")
            print("  - HasLaunchedBefore: \(hasLaunchedBefore)")
            print("  - showWelcome: \(showWelcome)")
        }
    }

    var mainContentView: some View {
        NavigationView {
            Group {
                if DeviceUtils.isIPad && DeviceUtils.isLandscape(with: (horizontalSizeClass, verticalSizeClass)) {
                    enhancedIPadLandscapeLayout
                } else {
                    enhancedDefaultLayout
                }
            }
            .background(
                LinearGradient.backgroundGradient
                    .ignoresSafeArea()
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            print("🔄 MainContentView appeared - resetting state")
            // 每次回到主界面重置选择和状态，确保可以再次导航
            isStartingGame = false
            gameViewModel = nil
            showGameView = false
            showWrongQuestionsView = false
            showOtherOptionsView = false

            withAnimation(.easeInOut(duration: 0.6)) {
                isAnimating = true
            }
        }
    }

    // MARK: - Navigation now handled by sheets and fullScreenCover modifiers

    // MARK: - Helper Functions
    private func levelNumber(for level: DifficultyLevel) -> Int {
        switch level {
        case .level1: return 1
        case .level2: return 2
        case .level3: return 3
        case .level4: return 4
        case .level5: return 5
        case .level6: return 6
        }
    }

    // MARK: - Enhanced Components
    @ViewBuilder
    private func enhancedCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.adaptivePadding)
            .background(
                RoundedRectangle(cornerRadius: .adaptiveCornerRadius * 1.5)
                    .fill(Color.white)
                    .shadow(color: Color.cardShadow, radius: 8, x: 0, y: 4)
            )
    }

    @ViewBuilder
    private func enhancedDifficultyPicker() -> some View {
        enhancedCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.primaryBlue)
                        .font(.adaptiveBody())

                    Text("difficulty.level".localized)
                        .font(.adaptiveHeadline())
                        .foregroundColor(.textPrimary)
                        .fontWeight(.semibold)
                }

                Picker("difficulty.level".localized, selection: $selectedDifficulty) {
                    ForEach(DifficultyLevel.allCases, id: \.self) { level in
                        HStack {
                            Text(level.localizedName)
                            Spacer()
                            HStack(spacing: 2) {
                                ForEach(1...levelNumber(for: level), id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.primaryBlue)
                                        .font(.caption)
                                }
                            }
                        }
                        .tag(level)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                        .fill(Color.backgroundSecondary)
                )
            }
        }
    }

    @ViewBuilder
    private func enhancedTimePicker() -> some View {
        enhancedCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.primaryBlue)
                        .font(.adaptiveBody())

                    Text("settings.time".localized)
                        .font(.adaptiveHeadline())
                        .foregroundColor(.textPrimary)
                        .fontWeight(.semibold)
                }

                VStack(spacing: 12) {
                    HStack {
                        Text("3")
                            .font(.adaptiveCaption())
                            .foregroundColor(.textSecondary)

                        Slider(value: Binding(
                            get: { Double(timeInMinutes) },
                            set: { timeInMinutes = Int($0) }
                        ), in: 3...30, step: 1)
                        .accentColor(.primaryBlue)

                        Text("30")
                            .font(.adaptiveCaption())
                            .foregroundColor(.textSecondary)
                    }

                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.primaryBlue)
                            .font(.adaptiveCaption())

                        Text("\(timeInMinutes) \("settings.minutes".localized)")
                            .font(.adaptiveBody())
                            .fontWeight(.medium)
                            .foregroundColor(.textPrimary)

                        Spacer()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func enhancedActionButton(
        title: String,
        subtitle: String,
        iconName: String,
        gradient: LinearGradient,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.adaptiveHeadline())
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)

                    Text(subtitle)
                        .font(.adaptiveCaption())
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: .adaptiveCornerRadius * 1.5)
                    .fill(gradient)
                    .shadow(color: Color.cardShadow, radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Enhanced iPad Layout
    var enhancedIPadLandscapeLayout: some View {
        HStack(spacing: 20) {
            // Left side: Settings
            VStack(spacing: 30) {
                VStack(spacing: 8) {
                    Image(systemName: "textbook.fill")
                        .font(.largeTitle)
                        .foregroundColor(.primaryBlue)
                        .opacity(isAnimating ? 1 : 0)
                        .scaleEffect(isAnimating ? 1 : 0.5)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: isAnimating)

                    Text("app.title".localized)
                        .font(.adaptiveTitle())
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeInOut(duration: 0.6).delay(0.3), value: isAnimating)
                }
                .padding(.top, 20)

                VStack(spacing: 20) {
                    enhancedDifficultyPicker()
                        .opacity(isAnimating ? 1 : 0)
                        .offset(x: isAnimating ? 0 : -50)
                        .animation(.easeInOut(duration: 0.6).delay(0.4), value: isAnimating)

                    enhancedTimePicker()
                        .opacity(isAnimating ? 1 : 0)
                        .offset(x: isAnimating ? 0 : -50)
                        .animation(.easeInOut(duration: 0.6).delay(0.5), value: isAnimating)

                    enhancedCard {
                        LanguageSelectorView()
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -50)
                    .animation(.easeInOut(duration: 0.6).delay(0.6), value: isAnimating)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 30)

            // Right side: Action buttons
            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 16) {
                     enhancedActionButton(
                        title: isStartingGame ? "button.starting".localized : "button.start".localized,
                        subtitle: isStartingGame ? "game.loading".localized : "\(selectedDifficulty.localizedName) • \(timeInMinutes) \("settings.minutes".localized)",
                        iconName: isStartingGame ? "hourglass" : "play.fill",
                        gradient: .primaryGradient
                    ) {
                        startGame()
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : 50)
                    .animation(.easeInOut(duration: 0.6).delay(0.7), value: isAnimating)
                    .disabled(isStartingGame)
                    .accessibilityIdentifier("startGameButton")

                    enhancedActionButton(
                        title: "button.wrong_questions".localized,
                        subtitle: "review.past.mistakes".localized,
                        iconName: "exclamationmark.triangle.fill",
                        gradient: .orangeGradient
                    ) {
                        showWrongQuestionsView = true
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : 50)
                    .animation(.easeInOut(duration: 0.6).delay(0.8), value: isAnimating)

                    enhancedActionButton(
                        title: "button.other_options".localized,
                        subtitle: "explore.more.features".localized,
                        iconName: "ellipsis.circle.fill",
                        gradient: .greenGradient
                    ) {
                        showOtherOptionsView = true
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : 50)
                    .animation(.easeInOut(duration: 0.6).delay(0.9), value: isAnimating)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 30)

            // Use sheet presentations for more reliable navigation
            .fullScreenCover(isPresented: $showGameView, onDismiss: {
                // Reset states when game view is dismissed
                gameViewModel = nil
                isStartingGame = false
            }) {
                if let vm = gameViewModel {
                    GameView(viewModel: vm) {
                        // This closure will be called when user wants to exit to home
                        showGameView = false
                    }
                    .environmentObject(localizationManager)
                } else {
                    ProgressView("Loading...")
                }
            }
            .sheet(isPresented: $showWrongQuestionsView) {
                NavigationView {
                    WrongQuestionsView()
                        .environmentObject(localizationManager)
                }
            }
            .sheet(isPresented: $showOtherOptionsView) {
                NavigationView {
                    OtherOptionsView()
                        .environmentObject(localizationManager)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Enhanced Default Layout
    var enhancedDefaultLayout: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // App Title with Icon
                VStack(spacing: 16) {
                    Image(systemName: "textbook.fill")
                        .font(.largeTitle)
                        .foregroundColor(.primaryBlue)
                        .opacity(isAnimating ? 1 : 0)
                        .scaleEffect(isAnimating ? 1 : 0.5)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: isAnimating)

                    Text("app.title".localized)
                        .font(.adaptiveTitle())
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeInOut(duration: 0.6).delay(0.3), value: isAnimating)
                }
                .padding(.top, 20)

                // Settings Section
                VStack(spacing: 16) {
                    enhancedDifficultyPicker()
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.easeInOut(duration: 0.6).delay(0.4), value: isAnimating)

                    enhancedTimePicker()
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.easeInOut(duration: 0.6).delay(0.5), value: isAnimating)

                    enhancedCard {
                        LanguageSelectorView()
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeInOut(duration: 0.6).delay(0.6), value: isAnimating)
                }
                .padding(.horizontal, 20)

                // Action Buttons Section
                VStack(spacing: 16) {
                    enhancedActionButton(
                        title: isStartingGame ? "button.starting".localized : "button.start".localized,
                        subtitle: isStartingGame ? "game.loading".localized : "\(selectedDifficulty.localizedName) • \(timeInMinutes) \("settings.minutes".localized)",
                        iconName: isStartingGame ? "hourglass" : "play.fill",
                        gradient: .primaryGradient
                    ) {
                        startGame()
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeInOut(duration: 0.6).delay(0.7), value: isAnimating)
                    .disabled(isStartingGame)
                    .accessibilityIdentifier("startGameButton")

                    enhancedActionButton(
                        title: "button.wrong_questions".localized,
                        subtitle: "review.past.mistakes".localized,
                        iconName: "exclamationmark.triangle.fill",
                        gradient: .orangeGradient
                    ) {
                        showWrongQuestionsView = true
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeInOut(duration: 0.6).delay(0.8), value: isAnimating)

                    enhancedActionButton(
                        title: "button.other_options".localized,
                        subtitle: "explore.more.features".localized,
                        iconName: "ellipsis.circle.fill",
                        gradient: .greenGradient
                    ) {
                        showOtherOptionsView = true
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeInOut(duration: 0.6).delay(0.9), value: isAnimating)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)

                // No navigation links needed - using direct state management
            }
        }
        .navigationBarHidden(true)
        .id(refreshTrigger)
        .fullScreenCover(isPresented: $showGameView, onDismiss: {
            // Reset states when game view is dismissed
            gameViewModel = nil
            isStartingGame = false
        }) {
            if let vm = gameViewModel {
                GameView(viewModel: vm) {
                    // This closure will be called when user wants to exit to home
                    showGameView = false
                }
                .environmentObject(localizationManager)
            } else {
                ProgressView("Loading...")
            }
        }
        .sheet(isPresented: $showWrongQuestionsView) {
            NavigationView {
                WrongQuestionsView()
                    .environmentObject(localizationManager)
            }
        }
        .sheet(isPresented: $showOtherOptionsView) {
            NavigationView {
                OtherOptionsView()
                    .environmentObject(localizationManager)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))) { _ in
            refreshTrigger = UUID()
        }
    }
    private func startGame() {
        guard !isStartingGame else {
            print("🚫 Start game blocked - already starting")
            return
        }

        print("🎮 Starting game with difficulty: \(selectedDifficulty), time: \(timeInMinutes) minutes")
        isStartingGame = true

        // 简化的同步方法 - 直接创建 GameViewModel
        print("🔧 Creating GameViewModel...")
        let viewModel = GameViewModel(difficultyLevel: selectedDifficulty, timeInMinutes: timeInMinutes)

        // 验证 ViewModel 创建成功
        guard viewModel.gameState.questions.count > 0 else {
            print("❌ Failed to generate questions")
            isStartingGame = false
            return
        }

        print("✅ GameViewModel created successfully with \(viewModel.gameState.questions.count) questions")
        gameViewModel = viewModel

        // 直接触发导航
        showGameView = true

        // 重置加载状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isStartingGame = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LocalizationManager())
    }
}
