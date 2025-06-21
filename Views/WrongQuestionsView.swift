import SwiftUI
import CoreData

struct WrongQuestionsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedLevel: DifficultyLevel? = nil
    @State private var wrongQuestions: [WrongQuestionViewModel] = []
    @State private var showingDeleteAlert = false
    @State private var showingDeleteMasteredAlert = false
    @EnvironmentObject var localizationManager: LocalizationManager
    
    private let wrongQuestionManager = WrongQuestionManager()
    
    var body: some View {
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
            
            // 错题列表
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
            
            // 底部按钮
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
        .onAppear {
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
                WrongQuestionViewModel(
                    id: entity.id,
                    questionText: entity.questionText,
                    correctAnswer: Int(entity.correctAnswer),
                    level: DifficultyLevel(rawValue: entity.level) ?? .level1,
                    timesShown: Int(entity.timesShown),
                    timesWrong: Int(entity.timesWrong)
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
}

// 错题视图模型
struct WrongQuestionViewModel: Identifiable {
    let id: UUID
    let questionText: String
    let correctAnswer: Int
    let level: DifficultyLevel
    let timesShown: Int
    let timesWrong: Int
}

struct WrongQuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        WrongQuestionsView()
            .environmentObject(LocalizationManager())
    }
}
