import Foundation
import SwiftUI

class GameState: ObservableObject {
    @Published var currentQuestionIndex: Int = 0
    @Published var score: Int = 0
    @Published var timeRemaining: Int
    @Published var questions: [Question] = []
    @Published var userAnswers: [Int?]
    @Published var gameCompleted: Bool = false
    @Published var showingCorrectAnswer: Bool = false
    @Published var isCorrect: Bool = false
    @Published var isPaused: Bool = false
    @Published var pauseUsed: Bool = false
    
    // 游戏设置
    let difficultyLevel: DifficultyLevel
    let totalTime: Int
    
    // 根据难度等级获取总题目数
    var totalQuestions: Int {
        switch difficultyLevel {
        case .level1: return 20
        case .level2: return 25
        case .level3: return 50
        case .level4: return 100
        }
    }
    
    // 根据难度等级获取每题分数
    var pointsPerQuestion: Int {
        switch difficultyLevel {
        case .level1: return 5
        case .level2: return 4
        case .level3: return 2
        case .level4: return 1
        }
    }
    
    init(difficultyLevel: DifficultyLevel, timeInMinutes: Int) {
        self.difficultyLevel = difficultyLevel
        self.timeRemaining = timeInMinutes * 60
        self.totalTime = timeInMinutes * 60
        
        // 计算题目数量
        let questionCount: Int
        switch difficultyLevel {
        case .level1: questionCount = 20
        case .level2: questionCount = 25
        case .level3: questionCount = 50
        case .level4: questionCount = 100
        }
        
        self.userAnswers = Array(repeating: nil, count: questionCount)
        generateQuestions()
    }
    
    // 生成题目
    private func generateQuestions() {
        // 获取错题集中的题目
        let wrongQuestionManager = WrongQuestionManager()
        let wrongQuestions = wrongQuestionManager.getWrongQuestionsForLevel(difficultyLevel, limit: Int(Double(totalQuestions) * 0.3))
        
        // 生成题目，确保包含错题
        questions = QuestionGenerator.generateQuestions(difficultyLevel: difficultyLevel, count: totalQuestions, wrongQuestions: wrongQuestions)
    }
    
    // 检查答案
    func checkAnswer(_ answer: Int) -> Bool {
        let currentQuestion = questions[currentQuestionIndex]
        let isCorrect = answer == currentQuestion.correctAnswer
        
        userAnswers[currentQuestionIndex] = answer
        
        if isCorrect {
            score += pointsPerQuestion
            
            // 如果是错题集中的题目，更新统计信息
            let wrongQuestionManager = WrongQuestionManager()
            if wrongQuestionManager.isWrongQuestion(currentQuestion) {
                wrongQuestionManager.updateWrongQuestion(currentQuestion, answeredCorrectly: true)
                print("Updated wrong question statistics (correct answer): \(currentQuestion.questionText)")
            }
        } else {
            // 如果回答错误，添加到错题集
            let wrongQuestionManager = WrongQuestionManager()
            wrongQuestionManager.addWrongQuestion(currentQuestion, for: difficultyLevel)
            print("Added to wrong questions collection: \(currentQuestion.questionText)")
        }
        
        self.isCorrect = isCorrect
        self.showingCorrectAnswer = !isCorrect
        
        return isCorrect
    }
    
    // 进入下一题
    func moveToNextQuestion() {
        if currentQuestionIndex < totalQuestions - 1 {
            currentQuestionIndex += 1
            showingCorrectAnswer = false
        } else {
            gameCompleted = true
        }
    }
    
    // 获取当前进度
    var progressText: String {
        return "game.progress".localizedFormat(String(currentQuestionIndex + 1), String(totalQuestions))
    }
    
    // 获取剩余时间格式化字符串
    var timeRemainingText: String {
        // Access timeRemaining to ensure this property is recalculated when timeRemaining changes
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // 获取用时
    var timeUsed: Int {
        return totalTime - timeRemaining
    }
    
    // 获取用时格式化字符串
    var timeUsedText: String {
        let minutes = timeUsed / 60
        let seconds = timeUsed % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // 获取答对题目数量
    var correctAnswersCount: Int {
        var count = 0
        for (index, answer) in userAnswers.enumerated() {
            if let userAnswer = answer, userAnswer == questions[index].correctAnswer {
                count += 1
            }
        }
        return count
    }
    
    // 获取评价等级
    func getPerformanceRating() -> (String, String) {
        // 计算总分的百分比
        let maxPossibleScore = totalQuestions * pointsPerQuestion
        let scorePercentage = (score * 100) / maxPossibleScore
        
        switch scorePercentage {
        case 90...100:
            return ("result.excellent".localized, "⭐⭐⭐")
        case 80..<90:
            return ("result.good".localized, "⭐⭐")
        case 70..<80:
            return ("result.pass".localized, "⭐")
        default:
            return ("result.needimprove".localized, "💪")
        }
    }
    
    // 暂停游戏
    func pauseGame() -> Bool {
        // 如果已经使用过暂停，则不能再次暂停
        if pauseUsed {
            return false
        }
        
        // 标记暂停状态
        isPaused = true
        pauseUsed = true
        
        // 扣除分数
        if score >= 5 {
            score -= 5
        } else {
            score = 0
        }
        
        return true
    }
    
    // 恢复游戏
    func resumeGame() {
        isPaused = false
    }
    
    // 保存游戏进度
    func saveProgress() -> Bool {
        let gameProgressManager = GameProgressManager()
        return gameProgressManager.saveGameProgress(self)
    }
    
    // 加载游戏进度
    static func loadProgress() -> GameState? {
        let gameProgressManager = GameProgressManager()
        return gameProgressManager.loadGameProgress()
    }
    
    // 检查是否有保存的游戏进度
    static func hasSavedProgress() -> Bool {
        let gameProgressManager = GameProgressManager()
        return gameProgressManager.hasGameProgress()
    }
    
    // 获取保存的游戏信息
    static func getSavedGameInfo() -> (difficultyLevel: DifficultyLevel, progress: String, savedAt: Date)? {
        let gameProgressManager = GameProgressManager()
        return gameProgressManager.getSavedGameInfo()
    }
}
