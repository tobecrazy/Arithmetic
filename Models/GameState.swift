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
    let totalQuestions: Int = 20
    let totalTime: Int
    
    init(difficultyLevel: DifficultyLevel, timeInMinutes: Int) {
        self.difficultyLevel = difficultyLevel
        self.timeRemaining = timeInMinutes * 60
        self.totalTime = timeInMinutes * 60
        self.userAnswers = Array(repeating: nil, count: totalQuestions)
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
            score += 5
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
        switch score {
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
