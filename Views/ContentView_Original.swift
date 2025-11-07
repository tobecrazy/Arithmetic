import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedDifficulty: DifficultyLevel = .level1
    @State private var timeInMinutes: Int = 5
    @State private var navigationSelection: Int? = nil
    @State private var refreshTrigger = UUID()
    @State private var isAnimating = false

    // Use @AppStorage for better SwiftUI integration
    @AppStorage("HasLaunchedBefore") private var hasLaunchedBefore: Bool = false

    // Computed property to determine if welcome should be shown
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
                    print("🔍 Debug: Welcome dismissed, setting HasLaunchedBefore to true")
                    hasLaunchedBefore = true
                    print("🔍 Debug: HasLaunchedBefore is now \(hasLaunchedBefore)")
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
            withAnimation(.easeInOut(duration: 0.6)) {
                isAnimating = true
            }
        }
    }
    
    // Computed properties for navigation destinations
    private var gameDestination: some View {
        GameView(viewModel: GameViewModel(difficultyLevel: selectedDifficulty, timeInMinutes: timeInMinutes))
            .environmentObject(localizationManager)
    }
    
    private var wrongQuestionsDestination: some View {
        WrongQuestionsView()
            .environmentObject(localizationManager)
    }
    
    private var otherOptionsDestination: some View {
        OtherOptionsView()
            .environmentObject(localizationManager)
    }
    
    // Enhanced difficulty picker component
    @ViewBuilder
    private func enhancedDifficultyPicker() -> some View {
        ModernPickerCard(title: "difficulty.level".localized) {
            Picker("difficulty.level".localized, selection: $selectedDifficulty) {
                ForEach(DifficultyLevel.allCases) { level in
                    HStack {
                        Text(level.localizedName)
                        Spacer()
                        HStack(spacing: 2) {
                            ForEach(1...level.rawValue, id: \.self) { _ in
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

    // Enhanced time picker component
    @ViewBuilder
    private func enhancedTimePicker() -> some View {
        ModernPickerCard(title: "settings.time".localized) {
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

    // Enhanced iPad横屏专用布局
    var enhancedIPadLandscapeLayout: some View {
        HStack(spacing: 20) {
            // 左侧：标题和设置区域
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
                    // 难度选择器
                    enhancedDifficultyPicker()
                        .opacity(isAnimating ? 1 : 0)
                        .offset(x: isAnimating ? 0 : -50)
                        .animation(.easeInOut(duration: 0.6).delay(0.4), value: isAnimating)

                    // 时间设置
                    enhancedTimePicker()
                        .opacity(isAnimating ? 1 : 0)
                        .offset(x: isAnimating ? 0 : -50)
                        .animation(.easeInOut(duration: 0.6).delay(0.5), value: isAnimating)

                    // 语言选择器
                    ModernCard {
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

            // 右侧：行动按钮区域
            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 16) {
                    // 开始游戏按钮
                    IconButtonCard(
                        title: "button.start".localized,
                        subtitle: "\(selectedDifficulty.localizedName) • \(timeInMinutes) \("settings.minutes".localized)",
                        iconName: "play.fill",
                        gradient: .primaryGradient
                    ) {
                        navigationSelection = 1
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : 50)
                    .animation(.easeInOut(duration: 0.6).delay(0.7), value: isAnimating)

                    // 错题集按钮
                    IconButtonCard(
                        title: "button.wrong_questions".localized,
                        subtitle: "review.past.mistakes".localized,
                        iconName: "exclamationmark.triangle.fill",
                        gradient: .orangeGradient
                    ) {
                        navigationSelection = 2
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : 50)
                    .animation(.easeInOut(duration: 0.6).delay(0.8), value: isAnimating)

                    // 其他选项按钮
                    IconButtonCard(
                        title: "button.other_options".localized,
                        subtitle: "explore.more.features".localized,
                        iconName: "ellipsis.circle.fill",
                        gradient: .greenGradient
                    ) {
                        navigationSelection = 3
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : 50)
                    .animation(.easeInOut(duration: 0.6).delay(0.9), value: isAnimating)
                }

            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 30)

            // Hidden Navigation Links
            NavigationLink(
                destination: gameDestination,
                tag: 1,
                selection: $navigationSelection
            ) { EmptyView() }

            NavigationLink(
                destination: wrongQuestionsDestination,
                tag: 2,
                selection: $navigationSelection
            ) { EmptyView() }

            NavigationLink(
                destination: otherOptionsDestination,
                tag: 3,
                selection: $navigationSelection
            ) { EmptyView() }
        }
        .navigationBarHidden(true)
    }
    
    // Enhanced 默认布局（iPhone和iPad竖屏）
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
                    // 难度选择器
                    enhancedDifficultyPicker()
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.easeInOut(duration: 0.6).delay(0.4), value: isAnimating)

                    // 时间设置
                    enhancedTimePicker()
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.easeInOut(duration: 0.6).delay(0.5), value: isAnimating)

                    // 语言选择器
                    ModernCard {
                        LanguageSelectorView()
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeInOut(duration: 0.6).delay(0.6), value: isAnimating)
                }
                .padding(.horizontal, 20)

                // Action Buttons Section
                VStack(spacing: 16) {
                    // 开始游戏按钮
                    IconButtonCard(
                        title: "button.start".localized,
                        subtitle: "\(selectedDifficulty.localizedName) • \(timeInMinutes) \("settings.minutes".localized)",
                        iconName: "play.fill",
                        gradient: .primaryGradient
                    ) {
                        navigationSelection = 1
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeInOut(duration: 0.6).delay(0.7), value: isAnimating)

                    // 错题集按钮
                    IconButtonCard(
                        title: "button.wrong_questions".localized,
                        subtitle: "review.past.mistakes".localized,
                        iconName: "exclamationmark.triangle.fill",
                        gradient: .orangeGradient
                    ) {
                        navigationSelection = 2
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeInOut(duration: 0.6).delay(0.8), value: isAnimating)

                    // 其他选项按钮
                    IconButtonCard(
                        title: "button.other_options".localized,
                        subtitle: "explore.more.features".localized,
                        iconName: "ellipsis.circle.fill",
                        gradient: .greenGradient
                    ) {
                        navigationSelection = 3
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeInOut(duration: 0.6).delay(0.9), value: isAnimating)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                
                // Navigation Links with tag-based approach
                NavigationLink(
                    destination: gameDestination,
                    tag: 1,
                    selection: $navigationSelection
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: wrongQuestionsDestination,
                    tag: 2,
                    selection: $navigationSelection
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: otherOptionsDestination,
                    tag: 3,
                    selection: $navigationSelection
                ) {
                    EmptyView()
                }
            }
        }
        .navigationBarHidden(true)
        .id(refreshTrigger) // Force refresh when language changes
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))) { _ in
            refreshTrigger = UUID()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LocalizationManager())
    }
}
