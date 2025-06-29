import SwiftUI
import CoreData

struct WrongQuestionsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedLevel: DifficultyLevel? = nil
    @State private var wrongQuestions: [WrongQuestionViewModel] = []
    @State private var showingDeleteAlert = false
    @State private var showingDeleteMasteredAlert = false
    @State private var expandedQuestionIds: [UUID] = []
    @EnvironmentObject var localizationManager: LocalizationManager
    
    private let wrongQuestionManager = WrongQuestionManager()
    
    var body: some View {
        VStack(spacing: 0) {
            // 固定顶部区域：标题和难度选择器
            VStack {
                // 标题
                Text("wrong_questions.title".localized)
                    .font(.adaptiveTitle())
                    .padding()
                
                // 难度选择器
                Picker("wrong_questions.filter_by_level".localized, selection: $selectedLevel) {
                    Text("wrong_questions.all_levels".localized).tag(nil as DifficultyLevel?)
                    ForEach(DifficultyLevel.allCases) { level in
                        Text(level.localizedName).tag(level as DifficultyLevel?)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onChange(of: selectedLevel) { _ in
                    loadWrongQuestions()
                }
            }
            .background(Color(.systemBackground))
            
            // 可滚动的主要内容区域
            if wrongQuestions.isEmpty {
                VStack {
                    Spacer()
                    Text("wrong_questions.empty".localized)
                        .font(.adaptiveBody())
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                List {
                    ForEach(wrongQuestions) { question in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(question.questionText)
                                .font(.adaptiveHeadline())
                            
                            Text("wrong_questions.answer".localizedFormat(String(question.correctAnswer)))
                                .font(.adaptiveBody())
                                .foregroundColor(.blue)
                            
                            // 添加解析按钮
                            Button(action: {
                                if let index = self.expandedQuestionIds.firstIndex(of: question.id) {
                                    self.expandedQuestionIds.remove(at: index)
                                } else {
                                    self.expandedQuestionIds.append(question.id)
                                }
                            }) {
                                Text(self.expandedQuestionIds.contains(question.id) ? "button.hide_solution".localized : "button.show_solution".localized)
                                    .font(.footnote)
                                    .foregroundColor(.green)
                            }
                            
                            // 显示解析内容
                            if self.expandedQuestionIds.contains(question.id) {
                                ScrollView {
                                    Text(question.currentLanguageSolutionSteps)
                                        .font(.footnote)
                                        .padding(8)
                                        .background(Color.yellow.opacity(0.1))
                                        .cornerRadius(8)
                                        .multilineTextAlignment(.leading)
                                }
                                .frame(maxHeight: 150) // 限制解析内容的最大高度
                            }
                            
                            HStack {
                                Text("wrong_questions.level".localizedFormat(question.level.localizedName))
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text("wrong_questions.stats".localizedFormat(
                                    String(question.timesShown),
                                    String(question.timesWrong)
                                ))
                                .font(.footnote)
                                .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete(perform: deleteWrongQuestions)
                }
            }
            
            // 固定底部按钮区域
            VStack {
                Divider()
                HStack {
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Text("wrong_questions.delete_all".localized)
                            .foregroundColor(.red)
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
                    
                    Spacer()
                    
                    Button(action: {
                        showingDeleteMasteredAlert = true
                    }) {
                        Text("wrong_questions.delete_mastered".localized)
                            .foregroundColor(.blue)
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
                .padding()
            }
            .background(Color(.systemBackground))
        }
        .onAppear {
            loadWrongQuestions()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))) { _ in
            // 当语言变化时，重新生成解析内容
            refreshSolutionContent()
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
         originalEntity: WrongQuestionEntity? = nil) {
        self.id = id
        self.questionText = questionText
        self.correctAnswer = correctAnswer
        self.level = level
        self.timesShown = timesShown
        self.timesWrong = timesWrong
        self.solutionMethod = solutionMethod
        self.solutionSteps = solutionSteps
        self.originalEntity = originalEntity
    }
}

struct WrongQuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        WrongQuestionsView()
            .environmentObject(LocalizationManager())
    }
}
