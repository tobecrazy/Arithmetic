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

    private func colorForLevel(_ level: DifficultyLevel?) -> Color {
        switch level {
        case .level1: return .green
        case .level2: return .blue
        case .level3: return .orange
        case .level4: return .purple
        case .level5: return .red
        case .level6: return .pink
        case .level7: return .cyan
        case .none: return .accentColor
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
        ZStack(alignment: .bottom) {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                levelSelectorSection

                if wrongQuestions.isEmpty {
                    emptyStateView
                } else {
                    questionsListSection
                }
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
        .safeAreaInset(edge: .bottom) {
            bottomActionsSection
        }
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
                    .foregroundStyle(Color.accent)
                }
            }
        }
    }

    private var headerSection: some View {
        HStack(spacing: 16) {
            statCard(
                value: "\(wrongQuestions.count)",
                title: "wrong_questions.total".localized,
                tint: .red,
                symbol: "exclamationmark.circle.fill"
            )

            let masteredCount = wrongQuestions.filter { $0.timesShown >= 3 && $0.timesWrong == 0 }.count
            statCard(
                value: "\(masteredCount)",
                title: "wrong_questions.mastered".localized,
                tint: .green,
                symbol: "checkmark.circle.fill"
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .opacity(animateHeader ? 1 : 0)
        .offset(y: animateHeader ? 0 : -20)
    }

    private func statCard(value: String, title: String, tint: Color, symbol: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.caption.weight(.semibold))
                .foregroundStyle(tint)
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(tint.opacity(0.25), lineWidth: 1)
        )
    }

    private var levelSelectorSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                levelButton(level: nil, isSelected: selectedLevel == nil)

                ForEach(DifficultyLevel.allCases) { level in
                    levelButton(level: level, isSelected: selectedLevel == level)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(.thinMaterial)
    }

    private func levelButton(level: DifficultyLevel?, isSelected: Bool) -> some View {
        let tint = colorForLevel(level)

        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedLevel = level
            }
            loadWrongQuestions()
        }) {
            HStack(spacing: 6) {
                if let lvl = level {
                    Image(systemName: iconForLevel(lvl))
                        .font(.caption.weight(.semibold))
                } else {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .font(.caption.weight(.semibold))
                }
                Text(level?.localizedName ?? "wrong_questions.all_levels".localized)
                    .font(.subheadline.weight(.semibold))
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption.weight(.bold))
                }
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? tint : Color(UIColor.tertiarySystemFill))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(isSelected ? tint.opacity(0.2) : Color.clear, lineWidth: 1)
            )
            .scaleEffect(isSelected ? 1.03 : 1.0)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 90, height: 90)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.green)
            }

            Text("wrong_questions.empty".localized)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)

            Text("wrong_questions.empty_subtitle".localized)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

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
            .padding(.top, 12)
            .padding(.bottom, 88)
        }
    }

    private func questionCard(_ question: WrongQuestionViewModel) -> some View {
        let levelTint = colorForLevel(question.level)

        return VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: iconForLevel(question.level))
                            .font(.caption2.weight(.semibold))
                        Text(question.level.localizedName)
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(levelTint)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(levelTint.opacity(0.12))
                    .clipShape(Capsule())

                    Spacer()

                    HStack(spacing: 8) {
                        statBadge(icon: "eye.fill", value: question.timesShown, color: .blue)
                        statBadge(icon: "xmark.circle.fill", value: question.timesWrong, color: .red)
                    }
                }

                Text(question.questionText)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)

                HStack {
                    Text("wrong_questions.answer_label".localized)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.green)

                    if let answerType = question.answerType,
                       answerType == "fraction",
                       let fractionAnswer = question.fractionAnswer {
                        FractionView(fraction: fractionAnswer, baseFontSize: 18)
                    } else {
                        Text(question.answerDisplayString)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.green)
                    }

                    Spacer()

                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if let index = expandedQuestionIds.firstIndex(of: question.id) {
                                expandedQuestionIds.remove(at: index)
                            } else {
                                expandedQuestionIds.append(question.id)
                            }
                        }
                    }) {
                        Label(
                            expandedQuestionIds.contains(question.id) ? "button.hide_solution".localized : "button.show_solution".localized,
                            systemImage: expandedQuestionIds.contains(question.id) ? "lightbulb.fill" : "lightbulb"
                        )
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.12))
                        .clipShape(Capsule(style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)

            if expandedQuestionIds.contains(question.id) {
                solutionSection(question)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(Color(UIColor.separator).opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: AppTheme.lightShadowRadius, x: 0, y: 2)
        .contextMenu {
            Button(role: .destructive, action: {
                deleteQuestion(question)
            }) {
                Label("alert.delete_confirm".localized, systemImage: "trash")
            }
        }
    }

    private func statBadge(icon: String, value: Int, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2.weight(.semibold))
            Text("\(value)")
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .clipShape(Capsule(style: .continuous))
    }

    private func solutionSection(_ question: WrongQuestionViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
                .padding(.horizontal, 16)

            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.orange)
                Text("solution.content".localized)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            ScrollView(.vertical, showsIndicators: true) {
                Text(question.currentLanguageSolutionSteps)
                    .font(.subheadline)
                    .lineSpacing(4)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            }
            .frame(height: calculateSolutionHeight(screenHeight: UIScreen.main.bounds.height))
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.orange.opacity(0.08))
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    private var bottomActionsSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Button(role: .destructive, action: {
                    showingDeleteAlert = true
                }) {
                    Label("wrong_questions.delete_all".localized, systemImage: "trash")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
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

                Button(action: {
                    showingDeleteMasteredAlert = true
                }) {
                    Label("wrong_questions.delete_mastered".localized, systemImage: "checkmark.circle")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.accentColor)
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
            .padding(.top, 10)
            .padding(.bottom, 6)
        }
        .background(.bar)
    }

    private func deleteQuestion(_ question: WrongQuestionViewModel) {
        withAnimation {
            wrongQuestionManager.deleteWrongQuestion(with: question.id)
            loadWrongQuestions()
        }
    }

    private func loadWrongQuestions() {
        let fetchRequest: NSFetchRequest<WrongQuestionEntity> = WrongQuestionEntity.fetchRequest()

        if let level = selectedLevel {
            fetchRequest.predicate = NSPredicate(format: "level == %@", level.rawValue)
        }

        do {
            let entities = try viewContext.fetch(fetchRequest)
            wrongQuestions = entities.map { entity in
                var determinedCorrectAnswer: Int = Int(entity.correctAnswer)
                var determinedSolutionMethod: String = entity.solutionMethod
                var determinedSolutionSteps: String = entity.solutionSteps

                if let question = entity.toQuestion() {
                    let qLevel = DifficultyLevel(rawValue: entity.level) ?? .level1
                    determinedCorrectAnswer = question.correctAnswer
                    determinedSolutionMethod = question.getSolutionMethod(for: qLevel).rawValue
                    determinedSolutionSteps = question.getSolutionSteps(for: qLevel)
                }

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
                    correctAnswer: determinedCorrectAnswer,
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

            print("Loaded \(wrongQuestions.count) wrong questions")
            if wrongQuestions.isEmpty {
                let checkRequest: NSFetchRequest<WrongQuestionEntity> = WrongQuestionEntity.fetchRequest()
                let totalCount = try viewContext.count(for: checkRequest)
                print("Total wrong questions in database: \(totalCount)")
            }
        } catch {
            print("Error loading wrong questions: \(error)")
        }
    }

    private func deleteWrongQuestions(at offsets: IndexSet) {
        for index in offsets {
            let questionToDelete = wrongQuestions[index]
            wrongQuestionManager.deleteWrongQuestion(with: questionToDelete.id)
        }

        loadWrongQuestions()
    }

    private func deleteAllWrongQuestions() {
        wrongQuestionManager.deleteWrongQuestions(for: selectedLevel)
        loadWrongQuestions()
    }

    private func deleteMasteredQuestions() {
        wrongQuestionManager.deleteMasteredQuestions()
        loadWrongQuestions()
    }

    private func calculateSolutionHeight(screenHeight: CGFloat) -> CGFloat {
        let screenBounds = UIScreen.main.bounds
        let currentScreenHeight = screenBounds.height
        let currentScreenWidth = screenBounds.width

        let isLandscape = currentScreenWidth > currentScreenHeight

        let titleHeight: CGFloat = 60
        let pickerHeight: CGFloat = 50
        let buttonHeight: CGFloat = 80
        let questionInfoHeight: CGFloat = 120
        let safeAreaHeight: CGFloat = DeviceUtils.isIPad ? 120 : 100

        let availableHeight = currentScreenHeight - titleHeight - pickerHeight - buttonHeight - questionInfoHeight - safeAreaHeight

        let maxHeight: CGFloat
        let minHeight: CGFloat = 120

        if DeviceUtils.isIPad {
            if isLandscape {
                maxHeight = max(availableHeight * 0.7, 250)
            } else {
                maxHeight = max(availableHeight * 0.6, 200)
            }
        } else {
            if isLandscape {
                maxHeight = max(availableHeight * 0.4, 120)
            } else {
                maxHeight = max(availableHeight * 0.5, 150)
            }
        }

        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            return max(min(maxHeight * 1.2, availableHeight * 0.8), minHeight)
        } else if horizontalSizeClass == .compact && verticalSizeClass == .compact {
            return max(min(maxHeight * 0.8, availableHeight * 0.4), minHeight)
        } else {
            return max(min(maxHeight, availableHeight * 0.6), minHeight)
        }
    }

    private func refreshSolutionContent() {
        let fetchRequest: NSFetchRequest<WrongQuestionEntity> = WrongQuestionEntity.fetchRequest()

        if let level = selectedLevel {
            fetchRequest.predicate = NSPredicate(format: "level == %@", level.rawValue)
        }

        do {
            let entities = try viewContext.fetch(fetchRequest)
            wrongQuestions = entities.map { entity in
                var determinedCorrectAnswer: Int = Int(entity.correctAnswer)
                var determinedSolutionMethod: String = entity.solutionMethod
                var determinedSolutionSteps: String = entity.solutionSteps

                if let question = entity.toQuestion() {
                    let qLevel = DifficultyLevel(rawValue: entity.level) ?? .level1
                    determinedCorrectAnswer = question.correctAnswer
                    determinedSolutionMethod = question.getSolutionMethod(for: qLevel).rawValue
                    determinedSolutionSteps = question.getSolutionSteps(for: qLevel)

                    #if DEBUG
                    print("Refreshed solution and answer for question \(entity.questionText): steps: \(determinedSolutionSteps), answer: \(determinedCorrectAnswer)")
                    #endif
                }

                return WrongQuestionViewModel(
                    id: entity.id,
                    questionText: entity.questionText,
                    correctAnswer: determinedCorrectAnswer,
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
    let answerType: String?
    let fractionAnswer: Fraction?

    var answerDisplayString: String {
        if let type = answerType, type == "fraction", let fraction = fractionAnswer {
            return fraction.localizedString()
        } else {
            return String(correctAnswer)
        }
    }

    var currentLanguageSolutionSteps: String {
        if let entity = originalEntity, let question = entity.toQuestion() {
            return question.getSolutionSteps(for: level)
        }
        return solutionSteps
    }

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
