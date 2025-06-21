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
        questions = QuestionGenerator.generateQuestions(difficultyLevel: difficultyLevel, count: totalQuestions)
    }
    
    // 检查答案
    func checkAnswer(_ answer: Int) -> Bool {
        let currentQuestion = questions[currentQuestionIndex]
        let isCorrect = answer == currentQuestion.correctAnswer
        
        userAnswers[currentQuestionIndex] = answer
        
        if isCorrect {
            score += pointsPerQuestion
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
}
