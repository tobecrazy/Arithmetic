import SwiftUI
import CoreData

// MARK: - Enhanced Color Extensions
extension Color {
    static let primaryBlue = Color.accentColor
    static let secondaryOrange = Color.orange
    static let accentGreen = Color.green
    static let backgroundSecondary = Color(UIColor.systemGray5)
    static let cardShadow = Color.black.opacity(0.05)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
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
        colors: [Color(UIColor.systemGroupedBackground), Color(UIColor.systemGroupedBackground).opacity(0.8)],
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
    @State private var showSettingsView = false

    // Resume Game Banner
    @State private var hasResumableGame: Bool = false
    @State private var savedGameInfo: (difficultyLevel: DifficultyLevel, progress: String, savedAt: Date)? = nil
    @State private var showResumeBanner: Bool = true

    // Quick Stats
    @State private var wrongQuestionStats: (total: Int, byLevel: [DifficultyLevel: Int]) = (0, [:])

    // Custom Time
    @State private var isCustomTime: Bool = false

    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("followSystem") private var followSystem = true
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
        .preferredColorScheme(followSystem ? nil : (isDarkMode ? .dark : .light))
    }

    var mainContentView: some View {
        NavigationStack {
            Group {
                if DeviceUtils.isIPad && DeviceUtils.isLandscape(with: (horizontalSizeClass, verticalSizeClass)) {
                    enhancedIPadLandscapeLayout
                } else {
                    enhancedDefaultLayout
                }
            }
            .background(
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
            )
        }
        .onAppear {
            isStartingGame = false
            gameViewModel = nil
            showGameView = false
            showWrongQuestionsView = false
            showOtherOptionsView = false
            showSettingsView = false

            loadDashboardData()

            withAnimation(.easeInOut(duration: 0.6)) {
                isAnimating = true
            }
        }
    }

    // MARK: - Data Loading

    private func loadDashboardData() {
        hasResumableGame = GameViewModel.hasSavedProgress()
        if hasResumableGame {
            savedGameInfo = GameViewModel.getSavedGameInfo()
            showResumeBanner = true
        } else {
            showResumeBanner = false
        }
        wrongQuestionStats = WrongQuestionManager().getWrongQuestionStats(for: nil)
    }

    // MARK: - Helper Functions
    private func levelNumber(for level: DifficultyLevel) -> Int {
        switch level {
        case .level1: return 1
        case .level2: return 2
        case .level3: return 3
        case .level4: return 4
        case .level5: return 5
        case .level6: return 6
        case .level7: return 7
        }
    }

    private func operationSymbols(for level: DifficultyLevel) -> String {
        level.supportedOperations.map { $0.symbol }.joined(separator: " ")
    }

    private func progressRatio(from progressString: String) -> Double {
        let parts = progressString.split(separator: "/")
        guard parts.count == 2,
              let current = Double(parts[0]),
              let total = Double(parts[1]),
              total > 0 else { return 0 }
        return current / total
    }

    // MARK: - Enhanced Components
    @ViewBuilder
    private func enhancedCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.adaptivePadding)
            .background(
                RoundedRectangle(cornerRadius: .adaptiveCornerRadius * 1.5)
                    .fill(.regularMaterial)
                    .shadow(color: Color.cardShadow, radius: 8, x: 0, y: 4)
            )
    }

    // MARK: - Resume Game Banner
    @ViewBuilder
    private func resumeGameBanner() -> some View {
        if hasResumableGame && showResumeBanner, let info = savedGameInfo {
            VStack(spacing: 12) {
                HStack(alignment: .top) {
                    Image(systemName: "pause.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.accentGreen)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("resume.title".localized)
                            .font(.adaptiveHeadline())
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.textPrimary)

                        Text("\(info.difficultyLevel.localizedName) • \(info.progress) \("resume.questions".localized)")
                            .font(.adaptiveCaption())
                            .foregroundStyle(Color.textSecondary)
                    }

                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showResumeBanner = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.textSecondary.opacity(0.6))
                    }
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.backgroundSecondary)
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.accentGreen)
                            .frame(width: geo.size.width * progressRatio(from: info.progress), height: 6)
                    }
                }
                .frame(height: 6)

                Button {
                    resumeSavedGame()
                } label: {
                    Text("resume.continue".localized)
                        .font(.adaptiveBody())
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                                .fill(Color.accentGreen)
                        )
                }
            }
            .padding(.adaptivePadding)
            .background(
                RoundedRectangle(cornerRadius: .adaptiveCornerRadius * 1.5)
                    .fill(.regularMaterial)
                    .shadow(color: Color.cardShadow, radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: .adaptiveCornerRadius * 1.5)
                    .stroke(Color.accentGreen.opacity(0.3), lineWidth: 1)
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private func resumeSavedGame() {
        if let vm = GameViewModel.loadSavedGame() {
            gameViewModel = vm
            showGameView = true
        }
    }

    // MARK: - Quick Stats Card
    @ViewBuilder
    private func quickStatsCard() -> some View {
        enhancedCard {
            HStack(spacing: 0) {
                statItem(
                    icon: "exclamationmark.triangle.fill",
                    iconColor: .secondaryOrange,
                    value: "\(wrongQuestionStats.total)",
                    label: "stats.total_wrong".localized
                )

                Divider().frame(height: 40)

                statItem(
                    icon: "star.fill",
                    iconColor: .primaryBlue,
                    value: "\(wrongQuestionStats.byLevel[selectedDifficulty] ?? 0)",
                    label: "stats.this_level".localized
                )

                Divider().frame(height: 40)

                statItem(
                    icon: "number.circle.fill",
                    iconColor: .accentGreen,
                    value: "\(selectedDifficulty.questionCount)",
                    label: "stats.questions_count".localized
                )
            }
        }
    }

    @ViewBuilder
    private func statItem(icon: String, iconColor: Color, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .font(.adaptiveCaption())
            Text(value)
                .font(.adaptiveHeadline())
                .fontWeight(.bold)
                .foregroundStyle(Color.textPrimary)
            Text(label)
                .font(.adaptiveCaption())
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Improved Difficulty Picker
    @ViewBuilder
    private func enhancedDifficultyPicker() -> some View {
        enhancedCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.primaryBlue)
                        .font(.adaptiveBody())

                    Text("difficulty.level".localized)
                        .font(.adaptiveHeadline())
                        .foregroundStyle(Color.textPrimary)
                        .fontWeight(.semibold)
                }

                VStack(spacing: 6) {
                    ForEach(DifficultyLevel.allCases, id: \.self) { level in
                        difficultyLevelRow(level)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func difficultyLevelRow(_ level: DifficultyLevel) -> some View {
        let isSelected = selectedDifficulty == level

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDifficulty = level
            }
        } label: {
            HStack(spacing: 12) {
                Text("\(levelNumber(for: level))")
                    .font(.adaptiveCaption())
                    .fontWeight(.bold)
                    .foregroundStyle(isSelected ? Color.white : Color.primaryBlue)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle().fill(isSelected ? Color.primaryBlue : Color(UIColor.tertiarySystemFill))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(level.localizedName)
                        .font(.adaptiveCaption())
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(operationSymbols(for: level))
                            .font(.adaptiveCaption())
                            .foregroundStyle(Color.secondaryOrange)
                            .fontWeight(.medium)

                        Text("\(level.range.lowerBound)-\(level.range.upperBound)")
                            .font(.adaptiveCaption())
                            .foregroundStyle(Color.textSecondary)

                        Text("\(level.questionCount)\("stats.questions_short".localized)")
                            .font(.adaptiveCaption())
                            .foregroundStyle(Color.textSecondary)
                    }
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.primaryBlue : Color.secondary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                    .fill(isSelected ? Color.primaryBlue.opacity(0.08) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                    .stroke(isSelected ? Color.primaryBlue.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Time Chips Picker
    @ViewBuilder
    private func enhancedTimePicker() -> some View {
        enhancedCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(Color.primaryBlue)
                        .font(.adaptiveBody())

                    Text("settings.time".localized)
                        .font(.adaptiveHeadline())
                        .foregroundStyle(Color.textPrimary)
                        .fontWeight(.semibold)

                    Spacer()

                    Text("\(timeInMinutes) \("settings.minutes".localized)")
                        .font(.adaptiveBody())
                        .fontWeight(.medium)
                        .foregroundStyle(Color.primaryBlue)
                }

                let presets = [3, 5, 10, 15, 20, 30]
                let isPresetSelected = presets.contains(timeInMinutes) && !isCustomTime
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: DeviceUtils.isIPad ? 7 : 4), spacing: 8) {
                    ForEach(presets, id: \.self) { minutes in
                        timeChip(minutes: minutes, isPresetSelected: isPresetSelected)
                    }

                    // Custom chip
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isCustomTime = true
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.adaptiveCaption())
                            .foregroundStyle(isCustomTime ? Color.white : Color.textPrimary)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                                    .fill(isCustomTime ? Color.primaryBlue : Color(UIColor.tertiarySystemFill))
                            )
                    }
                    .buttonStyle(.plain)
                }

                if isCustomTime {
                    HStack(spacing: 16) {
                        Stepper(value: $timeInMinutes, in: 1...60, step: 1) {
                            Text("\(timeInMinutes) \("settings.minutes_short".localized)")
                                .font(.adaptiveBody())
                                .fontWeight(.medium)
                                .foregroundStyle(Color.textPrimary)
                        }
                    }
                    .padding(.top, 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }

    @ViewBuilder
    private func timeChip(minutes: Int, isPresetSelected: Bool) -> some View {
        let isSelected = timeInMinutes == minutes && isPresetSelected

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                timeInMinutes = minutes
                isCustomTime = false
            }
        } label: {
            Text("\(minutes)")
                .font(.adaptiveCaption())
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? Color.white : Color.textPrimary)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                        .fill(isSelected ? Color.primaryBlue : Color(UIColor.tertiarySystemFill))
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Action Buttons
    @ViewBuilder
    private func enhancedActionButton(
        title: String,
        subtitle: String,
        iconName: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(tint.opacity(0.12)))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.adaptiveHeadline())
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)

                    Text(subtitle)
                        .font(.adaptiveCaption())
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: .adaptiveCornerRadius * 1.5)
                    .fill(.regularMaterial)
                    .shadow(color: Color.cardShadow, radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }

    private var wrongQuestionsSubtitle: String {
        wrongQuestionStats.total > 0
            ? "\(wrongQuestionStats.total) \("stats.questions_to_review".localized)"
            : "review.past.mistakes".localized
    }

    // MARK: - Enhanced iPad Layout
    var enhancedIPadLandscapeLayout: some View {
        HStack(spacing: 20) {
            // Left side: Settings
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "textbook.fill")
                            .font(.largeTitle)
                            .foregroundStyle(Color.primaryBlue)
                            .opacity(isAnimating ? 1 : 0)
                            .scaleEffect(isAnimating ? 1 : 0.5)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: isAnimating)

                        Text("app.title".localized)
                            .font(.adaptiveTitle())
                            .fontWeight(.bold)
                            .foregroundStyle(Color.textPrimary)
                            .opacity(isAnimating ? 1 : 0)
                            .animation(.easeInOut(duration: 0.6).delay(0.3), value: isAnimating)
                    }
                    .padding(.top, 20)

                    resumeGameBanner()
                        .opacity(isAnimating ? 1 : 0)
                        .offset(x: isAnimating ? 0 : -50)
                        .animation(.easeInOut(duration: 0.6).delay(0.3), value: isAnimating)

                    quickStatsCard()
                        .opacity(isAnimating ? 1 : 0)
                        .offset(x: isAnimating ? 0 : -50)
                        .animation(.easeInOut(duration: 0.6).delay(0.4), value: isAnimating)

                    enhancedDifficultyPicker()
                        .opacity(isAnimating ? 1 : 0)
                        .offset(x: isAnimating ? 0 : -50)
                        .animation(.easeInOut(duration: 0.6).delay(0.5), value: isAnimating)

                    enhancedTimePicker()
                        .opacity(isAnimating ? 1 : 0)
                        .offset(x: isAnimating ? 0 : -50)
                        .animation(.easeInOut(duration: 0.6).delay(0.6), value: isAnimating)

                    enhancedCard {
                        LanguageSelectorView()
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -50)
                    .animation(.easeInOut(duration: 0.6).delay(0.7), value: isAnimating)
                }
                .padding(.horizontal, 30)
            }
            .frame(maxWidth: .infinity)

            // Right side: Action buttons
            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 16) {
                     enhancedActionButton(
                        title: isStartingGame ? "button.starting".localized : "button.start".localized,
                        subtitle: isStartingGame ? "game.loading".localized : "\(selectedDifficulty.localizedName) • \(timeInMinutes) \("settings.minutes".localized)",
                        iconName: isStartingGame ? "hourglass" : "play.fill",
                        tint: .blue
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
                        subtitle: wrongQuestionsSubtitle,
                        iconName: "exclamationmark.triangle.fill",
                        tint: .orange
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
                        tint: .mint
                    ) {
                        showOtherOptionsView = true
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : 50)
                    .animation(.easeInOut(duration: 0.6).delay(0.9), value: isAnimating)

                    enhancedActionButton(
                        title: "button.settings".localized,
                        subtitle: "settings.title".localized,
                        iconName: "gear",
                        tint: .indigo
                    ) {
                        showSettingsView = true
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : 50)
                    .animation(.easeInOut(duration: 0.6).delay(1.0), value: isAnimating)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 30)

            .fullScreenCover(isPresented: $showGameView, onDismiss: {
                gameViewModel = nil
                isStartingGame = false
                loadDashboardData()
            }) {
                if let vm = gameViewModel {
                    GameView(viewModel: vm) {
                        showGameView = false
                    }
                    .environmentObject(localizationManager)
                } else {
                    ProgressView("Loading...")
                }
            }
            .sheet(isPresented: $showWrongQuestionsView, onDismiss: {
                loadDashboardData()
            }) {
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
            .sheet(isPresented: $showSettingsView) {
                SettingsView()
                    .environmentObject(localizationManager)
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
                        .foregroundStyle(Color.primaryBlue)
                        .opacity(isAnimating ? 1 : 0)
                        .scaleEffect(isAnimating ? 1 : 0.5)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: isAnimating)

                    Text("app.title".localized)
                        .font(.adaptiveTitle())
                        .fontWeight(.bold)
                        .foregroundStyle(Color.textPrimary)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeInOut(duration: 0.6).delay(0.3), value: isAnimating)
                }
                .padding(.top, 20)

                // Resume Game Banner
                resumeGameBanner()
                    .padding(.horizontal, 20)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                    .animation(.easeInOut(duration: 0.6).delay(0.35), value: isAnimating)

                // Quick Stats
                quickStatsCard()
                    .padding(.horizontal, 20)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeInOut(duration: 0.6).delay(0.4), value: isAnimating)

                // Settings Section
                VStack(spacing: 16) {
                    enhancedDifficultyPicker()
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.easeInOut(duration: 0.6).delay(0.5), value: isAnimating)

                    enhancedTimePicker()
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.easeInOut(duration: 0.6).delay(0.6), value: isAnimating)

                    enhancedCard {
                        LanguageSelectorView()
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeInOut(duration: 0.6).delay(0.7), value: isAnimating)
                }
                .padding(.horizontal, 20)

                // Action Buttons Section
                VStack(spacing: 16) {
                    enhancedActionButton(
                        title: isStartingGame ? "button.starting".localized : "button.start".localized,
                        subtitle: isStartingGame ? "game.loading".localized : "\(selectedDifficulty.localizedName) • \(timeInMinutes) \("settings.minutes".localized)",
                        iconName: isStartingGame ? "hourglass" : "play.fill",
                        tint: .blue
                    ) {
                        startGame()
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeInOut(duration: 0.6).delay(0.8), value: isAnimating)
                    .disabled(isStartingGame)
                    .accessibilityIdentifier("startGameButton")

                    enhancedActionButton(
                        title: "button.wrong_questions".localized,
                        subtitle: wrongQuestionsSubtitle,
                        iconName: "exclamationmark.triangle.fill",
                        tint: .orange
                    ) {
                        showWrongQuestionsView = true
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeInOut(duration: 0.6).delay(0.9), value: isAnimating)

                    enhancedActionButton(
                        title: "button.other_options".localized,
                        subtitle: "explore.more.features".localized,
                        iconName: "ellipsis.circle.fill",
                        tint: .mint
                    ) {
                        showOtherOptionsView = true
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeInOut(duration: 0.6).delay(1.0), value: isAnimating)

                    enhancedActionButton(
                        title: "button.settings".localized,
                        subtitle: "settings.title".localized,
                        iconName: "gear",
                        tint: .indigo
                    ) {
                        showSettingsView = true
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeInOut(duration: 0.6).delay(1.1), value: isAnimating)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
        .id(refreshTrigger)
        .fullScreenCover(isPresented: $showGameView, onDismiss: {
            gameViewModel = nil
            isStartingGame = false
            loadDashboardData()
        }) {
            if let vm = gameViewModel {
                GameView(viewModel: vm) {
                    showGameView = false
                }
                .environmentObject(localizationManager)
            } else {
                ProgressView("Loading...")
            }
        }
        .sheet(isPresented: $showWrongQuestionsView, onDismiss: {
            loadDashboardData()
        }) {
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
        .sheet(isPresented: $showSettingsView) {
            SettingsView()
                .environmentObject(localizationManager)
        }
        .onChange(of: selectedDifficulty) { _ in
            wrongQuestionStats = WrongQuestionManager().getWrongQuestionStats(for: nil)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))) { _ in
            refreshTrigger = UUID()
        }
    }

    private func startGame() {
        guard !isStartingGame else { return }

        isStartingGame = true

        let viewModel = GameViewModel(difficultyLevel: selectedDifficulty, timeInMinutes: timeInMinutes)

        guard viewModel.gameState.questions.count > 0 else {
            isStartingGame = false
            return
        }

        gameViewModel = viewModel
        showGameView = true

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
