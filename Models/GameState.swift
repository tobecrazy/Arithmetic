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
    @Published var streakCount: Int = 0
    @Published var longestStreak: Int = 0
    
    // 游戏设置
    let difficultyLevel: DifficultyLevel
    let totalTime: Int
    
    // 根据难度等级获取总题目数
    var totalQuestions: Int {
        return difficultyLevel.questionCount
    }
    
    // 根据难度等级获取每题分数
    var pointsPerQuestion: Int {
        return difficultyLevel.pointsPerQuestion
    }
    
    init(difficultyLevel: DifficultyLevel, timeInMinutes: Int) {
        print("🔧 Initializing GameState for \(difficultyLevel) with \(timeInMinutes) minutes")
        self.difficultyLevel = difficultyLevel
        self.timeRemaining = timeInMinutes * 60
        self.totalTime = timeInMinutes * 60

        // 使用难度等级的题目数量
        self.userAnswers = Array(repeating: nil, count: difficultyLevel.questionCount)

        // 同步生成题目，但添加错误处理和超时保护
        generateQuestions()

        // 验证题目生成是否成功
        if questions.isEmpty {
            print("⚠️ No questions generated, creating fallback questions")
            questions = generateFallbackQuestions()
        }

        print("✅ GameState initialized with \(questions.count) questions for \(difficultyLevel)")
    }
    
    // 生成题目 - 简化版本，减少潜在的阻塞
    private func generateQuestions() {
        print("🔄 Generating questions for difficulty \(difficultyLevel)...")

        var wrongQuestions: [Question] = []

        // 简化的错题获取
        let wrongQuestionManager = WrongQuestionManager()
        wrongQuestions = wrongQuestionManager.getWrongQuestionsForLevel(difficultyLevel, limit: Int(Double(totalQuestions) * 0.3))
        print("📚 Retrieved \(wrongQuestions.count) wrong questions from database")

        // 更新错题的显示次数
        for wrongQuestion in wrongQuestions {
            wrongQuestionManager.updateWrongQuestion(wrongQuestion, answeredCorrectly: nil)
        }

        // 生成题目，确保包含错题
        questions = QuestionGenerator.generateQuestions(difficultyLevel: difficultyLevel, count: totalQuestions, wrongQuestions: wrongQuestions)

        // 验证生成的题目数量
        if questions.count < totalQuestions {
            print("⚠️ Warning: Generated only \(questions.count) questions, expected \(totalQuestions)")
            // 补充简单题目
            let additionalQuestions = generateFallbackQuestions(count: totalQuestions - questions.count)
            questions.append(contentsOf: additionalQuestions)
        }

        print("✅ Question generation completed: \(questions.count) total questions")
    }

    // 生成备用题目
    private func generateFallbackQuestions(count: Int = 0) -> [Question] {
        let questionsToGenerate = count > 0 ? count : totalQuestions
        var fallbackQuestions: [Question] = []

        print("🆘 Generating \(questionsToGenerate) fallback questions...")

        for _ in 0..<questionsToGenerate {
            // Safety: Ensure we have a valid range
            let maxValue = max(10, difficultyLevel.range.upperBound) // Ensure at least 10
            let minValue = 1

            // Double-check the range is valid
            guard minValue <= maxValue else {
                print("⚠️ Warning: Invalid range in fallback questions, using default 1...10")
                let question = Question(number1: Int.random(in: 1...10), number2: Int.random(in: 1...10), operation: .addition)
                fallbackQuestions.append(question)
                continue
            }

            let num1 = Int.random(in: minValue...min(10, maxValue))
            let num2 = Int.random(in: minValue...min(10, maxValue))
            let question = Question(number1: num1, number2: num2, operation: .addition)
            fallbackQuestions.append(question)
        }

        return fallbackQuestions
    }
    
    // 检查答案
    func checkAnswer(_ answer: Int) -> Bool {
        let currentQuestion = questions[currentQuestionIndex]
        let isCorrect = answer == currentQuestion.correctAnswer

        userAnswers[currentQuestionIndex] = answer

        if isCorrect {
            score += pointsPerQuestion
            streakCount += 1
            if streakCount > longestStreak {
                longestStreak = streakCount
            }

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
            // Reset streak on wrong answer
            streakCount = 0
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
    func pauseGame() {
        // 如果已经使用过暂停，则不能再次暂停
        guard !pauseUsed else { return }
        
        // 标记暂停状态
        isPaused = true
        pauseUsed = true
        
        // 扣除分数
        if score >= 5 {
            score -= 5
        } else {
            score = 0
        }
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
