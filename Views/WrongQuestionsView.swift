import SwiftUI
import CoreData

struct WrongQuestionsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var selectedLevel: DifficultyLevel? = nil
    @State private var wrongQuestions: [WrongQuestionViewModel] = []
    @State private var showingDeleteAlert = false
    @State private var showingDeleteMasteredAlert = false
    @State private var expandedQuestionIds: [UUID] = []
    @State private var refreshTrigger = UUID()
    @State private var animateHeader = false
    @EnvironmentObject var localizationManager: LocalizationManager

    private let wrongQuestionManager = WrongQuestionManager()

    // MARK: - Gradient Colors for Level Badges
    private func gradientForLevel(_ level: DifficultyLevel?) -> LinearGradient {
        switch level {
        case .level1:
            return LinearGradient(colors: [Color.green.opacity(0.8), Color.green], startPoint: .leading, endPoint: .trailing)
        case .level2:
            return LinearGradient(colors: [Color.blue.opacity(0.8), Color.blue], startPoint: .leading, endPoint: .trailing)
        case .level3:
            return LinearGradient(colors: [Color.orange.opacity(0.8), Color.orange], startPoint: .leading, endPoint: .trailing)
        case .level4:
            return LinearGradient(colors: [Color.purple.opacity(0.8), Color.purple], startPoint: .leading, endPoint: .trailing)
        case .level5:
            return LinearGradient(colors: [Color.red.opacity(0.8), Color.red], startPoint: .leading, endPoint: .trailing)
        case .level6:
            return LinearGradient(colors: [Color.pink.opacity(0.8), Color.pink], startPoint: .leading, endPoint: .trailing)
        case .level7:
            return LinearGradient(colors: [Color.cyan.opacity(0.8), Color.cyan], startPoint: .leading, endPoint: .trailing)
        case .none:
            return LinearGradient(colors: [Color.progressGradientStart, Color.progressGradientEnd], startPoint: .leading, endPoint: .trailing)
        }
    }

    private func iconForLevel(_ level: DifficultyLevel) -> String {
        switch level {
        case .level1: return "leaf.fill"
        case .level2: return "flame.fill"
        case .level3: return "bolt.fill"
        case .level4: return "star.fill"
        case .level5: return "crown.fill"
        case .level6: return "medal.fill"
        case .level7: return "sparkles"
        }
    }

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
                // Header with stats
                headerSection

                // Difficulty level selector
                levelSelectorSection

                // Main content area
                if wrongQuestions.isEmpty {
                    emptyStateView
                } else {
                    questionsListSection
                }

                // Bottom action buttons
                bottomActionsSection
            }
        }
        .onAppear {
            loadWrongQuestions()
            withAnimation(.easeOut(duration: 0.5)) {
                animateHeader = true
            }
        }
        .id(refreshTrigger)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))) { _ in
            refreshTrigger = UUID()
            refreshSolutionContent()
        }
        .navigationTitle("wrong_questions.title".localized)
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

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: 16) {
            // Total count badge
            VStack(spacing: 4) {
                Text("\(wrongQuestions.count)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.error)
                Text("wrong_questions.total".localized)
                    .font(.caption)
                    .foregroundColor(.adaptiveSecondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(Color.error.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(Color.error.opacity(0.3), lineWidth: 1)
            )

            // Mastered indicator
            VStack(spacing: 4) {
                let masteredCount = wrongQuestions.filter { $0.timesShown >= 3 && $0.timesWrong == 0 }.count
                Text("\(masteredCount)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.success)
                Text("wrong_questions.mastered".localized)
                    .font(.caption)
                    .foregroundColor(.adaptiveSecondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(Color.success.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(Color.success.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .opacity(animateHeader ? 1 : 0)
        .offset(y: animateHeader ? 0 : -20)
    }

    // MARK: - Level Selector Section
    private var levelSelectorSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // All levels option
                levelButton(level: nil, isSelected: selectedLevel == nil)

                // Individual level options
                ForEach(DifficultyLevel.allCases) { level in
                    levelButton(level: level, isSelected: selectedLevel == level)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color.adaptiveBackground.opacity(0.8))
    }

    private func levelButton(level: DifficultyLevel?, isSelected: Bool) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedLevel = level
            }
            loadWrongQuestions()
        }) {
            HStack(spacing: 6) {
                if let lvl = level {
                    Image(systemName: iconForLevel(lvl))
                        .font(.system(size: 12))
                } else {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 12))
                }
                Text(level?.localizedName ?? "wrong_questions.all_levels".localized)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : .adaptiveText)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        gradientForLevel(level)
                    } else {
                        LinearGradient(colors: [Color.adaptiveSecondaryBackground], startPoint: .leading, endPoint: .trailing)
                    }
                }
            )
            .clipShape(Capsule())
            .shadow(color: isSelected ? Color.adaptiveShadow : Color.clear, radius: 4, x: 0, y: 2)
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            // Animated checkmark icon
            ZStack {
                Circle()
                    .fill(Color.success.opacity(0.1))
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(Color.success.opacity(0.2))
                    .frame(width: 90, height: 90)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.success)
            }

            Text("wrong_questions.empty".localized)
                .font(.adaptiveTitle2())
                .fontWeight(.semibold)
                .foregroundColor(.adaptiveText)

            Text("wrong_questions.empty_subtitle".localized)
                .font(.adaptiveBody())
                .foregroundColor(.adaptiveSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

    // MARK: - Questions List Section
    private var questionsListSection: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(wrongQuestions) { question in
                    questionCard(question)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .slide),
                            removal: .opacity.combined(with: .scale)
                        ))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private func questionCard(_ question: WrongQuestionViewModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main question content
            VStack(alignment: .leading, spacing: 12) {
                // Question header with level badge
                HStack {
                    // Level badge
                    HStack(spacing: 4) {
                        Image(systemName: iconForLevel(question.level))
                            .font(.system(size: 10))
                        Text(question.level.localizedName)
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(gradientForLevel(question.level))
                    .clipShape(Capsule())

                    Spacer()

                    // Stats badges
                    HStack(spacing: 8) {
                        statBadge(icon: "eye.fill", value: question.timesShown, color: .blue)
                        statBadge(icon: "xmark.circle.fill", value: question.timesWrong, color: .red)
                    }
                }

                // Question text
                Text(question.questionText)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptiveText)

                // Answer row
                HStack {
                    Text("wrong_questions.answer".localizedFormat(question.answerDisplayString))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.success)

                    Spacer()

                    // Solution toggle button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if let index = expandedQuestionIds.firstIndex(of: question.id) {
                                expandedQuestionIds.remove(at: index)
                            } else {
                                expandedQuestionIds.append(question.id)
                            }
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: expandedQuestionIds.contains(question.id) ? "lightbulb.fill" : "lightbulb")
                                .font(.system(size: 14))
                            Text(expandedQuestionIds.contains(question.id) ? "button.hide_solution".localized : "button.show_solution".localized)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.warning)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.warning.opacity(0.15))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(16)

            // Expandable solution section
            if expandedQuestionIds.contains(question.id) {
                solutionSection(question)
            }
        }
        .background(Color.adaptiveBackground)
        .cornerRadius(AppTheme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(Color.adaptiveBorder, lineWidth: 1)
        )
        .shadow(color: Color.adaptiveShadow, radius: AppTheme.lightShadowRadius, x: 0, y: 2)
        .contextMenu {
            Button(role: .destructive, action: {
                deleteQuestion(question)
            }) {
                Label("alert.delete_confirm".localized, systemImage: "trash")
            }
        }
    }

    private func statBadge(icon: String, value: Int, color: Color) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text("\(value)")
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }

    private func solutionSection(_ question: WrongQuestionViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
                .padding(.horizontal, 16)

            // Solution header
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.warning)
                Text("solution.content".localized)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.adaptiveSecondaryText)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // Solution content
            ScrollView(.vertical, showsIndicators: true) {
                Text(question.currentLanguageSolutionSteps)
                    .font(.system(size: 14))
                    .lineSpacing(4)
                    .foregroundColor(.adaptiveText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            }
            .frame(height: calculateSolutionHeight(screenHeight: UIScreen.main.bounds.height))
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.warning.opacity(0.08))
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Bottom Actions Section
    private var bottomActionsSection: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 16) {
                // Delete All Button
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 14))
                        Text("wrong_questions.delete_all".localized)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(wrongQuestions.isEmpty ? .gray : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                            .fill(wrongQuestions.isEmpty ? Color.gray.opacity(0.3) : Color.error)
                    )
                }
                .disabled(wrongQuestions.isEmpty)
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text("alert.delete_all_title".localized),
                        message: Text("alert.delete_all_message".localized),
                        primaryButton: .destructive(Text("alert.delete_confirm".localized)) {
                            deleteAllWrongQuestions()
                        },
                        secondaryButton: .cancel(Text("alert.cancel".localized))
                    )
                }

                // Delete Mastered Button
                Button(action: {
                    showingDeleteMasteredAlert = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                        Text("wrong_questions.delete_mastered".localized)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(wrongQuestions.isEmpty ? .gray : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                            .fill(wrongQuestions.isEmpty ? Color.gray.opacity(0.3) : Color.accent)
                    )
                }
                .disabled(wrongQuestions.isEmpty)
                .alert(isPresented: $showingDeleteMasteredAlert) {
                    Alert(
                        title: Text("alert.delete_mastered_title".localized),
                        message: Text("alert.delete_mastered_message".localized),
                        primaryButton: .destructive(Text("alert.delete_confirm".localized)) {
                            deleteMasteredQuestions()
                        },
                        secondaryButton: .cancel(Text("alert.cancel".localized))
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.adaptiveBackground)
    }

    // MARK: - Helper function to delete a single question
    private func deleteQuestion(_ question: WrongQuestionViewModel) {
        withAnimation {
            wrongQuestionManager.deleteWrongQuestion(with: question.id)
            loadWrongQuestions()
        }
    }
    
    // 加载错题
    private func loadWrongQuestions() {
        let fetchRequest: NSFetchRequest<WrongQuestionEntity> = WrongQuestionEntity.fetchRequest()
        
        if let level = selectedLevel {
            fetchRequest.predicate = NSPredicate(format: "level == %@", level.rawValue)
        }
        
        do {
            // Use the viewContext directly to ensure we're using the correct context
            let entities = try viewContext.fetch(fetchRequest)
            wrongQuestions = entities.map { entity in
                var determinedCorrectAnswer: Int = Int(entity.correctAnswer) // Default to stored
                var determinedSolutionMethod: String = entity.solutionMethod // Default to stored
                var determinedSolutionSteps: String = entity.solutionSteps   // Default to stored

                if let question = entity.toQuestion() { // Attempt to reconstruct the Question object
                    let qLevel = DifficultyLevel(rawValue: entity.level) ?? .level1
                    determinedCorrectAnswer = question.correctAnswer // Use freshly computed answer
                    determinedSolutionMethod = question.getSolutionMethod(for: qLevel).rawValue // Use freshly computed method
                    determinedSolutionSteps = question.getSolutionSteps(for: qLevel) // Use freshly computed steps
                }

                // Check for fraction answer
                var fractionAnswer: Fraction? = nil
                if let answerType = entity.answerType, answerType == "fraction",
                   entity.fractionDenominator != 0 {
                    fractionAnswer = Fraction(
                        numerator: Int(entity.fractionNumerator),
                        denominator: Int(entity.fractionDenominator)
                    )
                }

                return WrongQuestionViewModel(
                    id: entity.id,
                    questionText: entity.questionText,
                    correctAnswer: determinedCorrectAnswer, // Use the up-to-date correct answer
                    level: DifficultyLevel(rawValue: entity.level) ?? .level1,
                    timesShown: Int(entity.timesShown),
                    timesWrong: Int(entity.timesWrong),
                    solutionMethod: determinedSolutionMethod,
                    solutionSteps: determinedSolutionSteps,
                    originalEntity: entity,
                    answerType: entity.answerType,
                    fractionAnswer: fractionAnswer
                )
            }
            
            // Print debug information
            print("Loaded \(wrongQuestions.count) wrong questions")
            if wrongQuestions.isEmpty {
                // Check if there are any wrong questions in the database at all
                let checkRequest: NSFetchRequest<WrongQuestionEntity> = WrongQuestionEntity.fetchRequest()
                let totalCount = try viewContext.count(for: checkRequest)
                print("Total wrong questions in database: \(totalCount)")
            }
        } catch {
            print("Error loading wrong questions: \(error)")
        }
    }
    
    // 删除选中的错题
    private func deleteWrongQuestions(at offsets: IndexSet) {
        for index in offsets {
            let questionToDelete = wrongQuestions[index]
            wrongQuestionManager.deleteWrongQuestion(with: questionToDelete.id)
        }
        
        // 重新加载错题列表
        loadWrongQuestions()
    }
    
    // 删除所有错题
    private func deleteAllWrongQuestions() {
        wrongQuestionManager.deleteWrongQuestions(for: selectedLevel)
        loadWrongQuestions()
    }
    
    // 删除已掌握的错题
    private func deleteMasteredQuestions() {
        wrongQuestionManager.deleteMasteredQuestions()
        loadWrongQuestions()
    }
    
    // 计算解析内容的动态高度
    private func calculateSolutionHeight(screenHeight: CGFloat) -> CGFloat {
        // 获取当前屏幕尺寸
        let screenBounds = UIScreen.main.bounds
        let currentScreenHeight = screenBounds.height
        let currentScreenWidth = screenBounds.width
        
        // 判断是否为横屏模式
        let isLandscape = currentScreenWidth > currentScreenHeight
        
        // 计算固定UI元素占用的高度
        let titleHeight: CGFloat = 60 // 标题区域
        let pickerHeight: CGFloat = 50 // 难度选择器
        let buttonHeight: CGFloat = 80 // 底部按钮区域
        let questionInfoHeight: CGFloat = 120 // 题目信息和统计信息
        let safeAreaHeight: CGFloat = DeviceUtils.isIPad ? 120 : 100 // 安全区域和其他边距
        
        // 计算可用高度
        let availableHeight = currentScreenHeight - titleHeight - pickerHeight - buttonHeight - questionInfoHeight - safeAreaHeight
        
        // 根据设备类型和方向调整最大高度
        let maxHeight: CGFloat
        let minHeight: CGFloat = 120
        
        if DeviceUtils.isIPad {
            if isLandscape {
                // iPad横屏：可以使用更多垂直空间
                maxHeight = max(availableHeight * 0.7, 250)
            } else {
                // iPad竖屏：适中的空间分配
                maxHeight = max(availableHeight * 0.6, 200)
            }
        } else {
            if isLandscape {
                // iPhone横屏：垂直空间有限，使用较小比例
                maxHeight = max(availableHeight * 0.4, 120)
            } else {
                // iPhone竖屏：标准比例
                maxHeight = max(availableHeight * 0.5, 150)
            }
        }
        
        // 根据size class进一步调整
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            // 大屏设备（如iPad）
            return max(min(maxHeight * 1.2, availableHeight * 0.8), minHeight)
        } else if horizontalSizeClass == .compact && verticalSizeClass == .compact {
            // 紧凑模式（如iPhone横屏）
            return max(min(maxHeight * 0.8, availableHeight * 0.4), minHeight)
        } else {
            // 标准模式
            return max(min(maxHeight, availableHeight * 0.6), minHeight)
        }
    }
    
    // 刷新解析内容
    private func refreshSolutionContent() {
        let fetchRequest: NSFetchRequest<WrongQuestionEntity> = WrongQuestionEntity.fetchRequest()
        
        if let level = selectedLevel {
            fetchRequest.predicate = NSPredicate(format: "level == %@", level.rawValue)
        }
        
        do {
            let entities = try viewContext.fetch(fetchRequest)
            wrongQuestions = entities.map { entity in
                var determinedCorrectAnswer: Int = Int(entity.correctAnswer) // Default to stored
                var determinedSolutionMethod: String = entity.solutionMethod // Default to stored
                var determinedSolutionSteps: String = entity.solutionSteps   // Default to stored

                // 尝试从数据库实体重新创建Question对象并生成解析, 同时更新答案
                if let question = entity.toQuestion() {
                    let qLevel = DifficultyLevel(rawValue: entity.level) ?? .level1
                    determinedCorrectAnswer = question.correctAnswer // Use freshly computed answer
                    determinedSolutionMethod = question.getSolutionMethod(for: qLevel).rawValue // Use freshly computed method
                    determinedSolutionSteps = question.getSolutionSteps(for: qLevel) // Use freshly computed steps
                    
                    #if DEBUG
                    print("Refreshed solution and answer for question \(entity.questionText): steps: \(determinedSolutionSteps), answer: \(determinedCorrectAnswer)")
                    #endif
                }
                // No explicit 'else' needed here for fallback, as defaults are already set from entity.
                // If entity.toQuestion() fails, we use the stored values.
                
                return WrongQuestionViewModel(
                    id: entity.id,
                    questionText: entity.questionText,
                    correctAnswer: determinedCorrectAnswer, // Use the up-to-date correct answer
                    level: DifficultyLevel(rawValue: entity.level) ?? .level1,
                    timesShown: Int(entity.timesShown),
                    timesWrong: Int(entity.timesWrong),
                    solutionMethod: determinedSolutionMethod,
                    solutionSteps: determinedSolutionSteps,
                    originalEntity: entity
                )
            }
        } catch {
            print("Error refreshing solution content: \(error)")
        }
    }
}

// 错题视图模型
struct WrongQuestionViewModel: Identifiable {
    let id: UUID
    let questionText: String
    let correctAnswer: Int
    let level: DifficultyLevel
    let timesShown: Int
    let timesWrong: Int
    let solutionMethod: String
    let solutionSteps: String
    let originalEntity: WrongQuestionEntity?
    // Fraction support
    let answerType: String?
    let fractionAnswer: Fraction?

    // Get display string for answer
    var answerDisplayString: String {
        if let type = answerType, type == "fraction", let fraction = fractionAnswer {
            return fraction.localizedString()
        } else {
            return String(correctAnswer)
        }
    }

    // 获取当前语言的解析内容
    var currentLanguageSolutionSteps: String {
        if let entity = originalEntity, let question = entity.toQuestion() {
            return question.getSolutionSteps(for: level)
        }
        return solutionSteps
    }
    
    // 便捷初始化方法（保持向后兼容）
    init(id: UUID, questionText: String, correctAnswer: Int, level: DifficultyLevel,
         timesShown: Int, timesWrong: Int, solutionMethod: String, solutionSteps: String,
         originalEntity: WrongQuestionEntity? = nil,
         answerType: String? = nil, fractionAnswer: Fraction? = nil) {
        self.id = id
        self.questionText = questionText
        self.correctAnswer = correctAnswer
        self.level = level
        self.timesShown = timesShown
        self.timesWrong = timesWrong
        self.solutionMethod = solutionMethod
        self.solutionSteps = solutionSteps
        self.originalEntity = originalEntity
        self.answerType = answerType
        self.fractionAnswer = fractionAnswer
    }
}

struct WrongQuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        WrongQuestionsView()
            .environmentObject(LocalizationManager())
    }
}
