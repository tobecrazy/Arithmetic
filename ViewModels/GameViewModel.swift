import Foundation
import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var timerActive: Bool = false
    @Published var showSaveProgressSuccess: Bool = false
    @Published var showSaveProgressError: Bool = false
    @Published var showSolutionSteps: Bool = false
    @Published var solutionContent: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    init(difficultyLevel: DifficultyLevel, timeInMinutes: Int) {
        self.gameState = GameState(difficultyLevel: difficultyLevel, timeInMinutes: timeInMinutes)
        
        // 监听游戏完成状态
        gameState.$gameCompleted
            .sink { [weak self] completed in
                if completed {
                    self?.timerActive = false
                }
            }
            .store(in: &cancellables)
            
        // 监听游戏暂停状态
        gameState.$isPaused
            .sink { [weak self] isPaused in
                if isPaused {
                    self?.timerActive = false
                }
            }
            .store(in: &cancellables)
        
        // 监听语言变化
        setupLanguageChangeListener()
    }
    
    // 从保存的进度初始化
    init(savedGameState: GameState) {
        self.gameState = savedGameState
        
        // 监听游戏完成状态
        gameState.$gameCompleted
            .sink { [weak self] completed in
                if completed {
                    self?.timerActive = false
                }
            }
            .store(in: &cancellables)
            
        // 监听游戏暂停状态
        gameState.$isPaused
            .sink { [weak self] isPaused in
                if isPaused {
                    self?.timerActive = false
                }
            }
            .store(in: &cancellables)
        
        // 监听语言变化
        setupLanguageChangeListener()
    }
    
    func startGame() {
        // 如果游戏处于暂停状态，先恢复
        if gameState.isPaused {
            gameState.resumeGame()
        }
        
        // 激活计时器
        timerActive = true
        
        // 读出当前题目
        readCurrentQuestion()
    }
    
    func resetGame() {
        // 重置游戏状态
        let difficultyLevel = gameState.difficultyLevel
        let timeInMinutes = gameState.totalTime / 60
        
        // 创建新的游戏状态
        self.gameState = GameState(difficultyLevel: difficultyLevel, timeInMinutes: timeInMinutes)
        
        // 重新监听游戏完成状态
        cancellables.removeAll()
        gameState.$gameCompleted
            .sink { [weak self] completed in
                if completed {
                    self?.timerActive = false
                }
            }
            .store(in: &cancellables)
        
        // 重新设置语言变化监听器
        setupLanguageChangeListener()
        
        // 激活计时器
        timerActive = true
        
        // 读出当前题目
        readCurrentQuestion()
    }
    
func submitAnswer(_ answer: Int) {
    let isCorrect = gameState.checkAnswer(answer)
    
    if isCorrect {
        // If answer is correct, move to next question immediately
        if gameState.currentQuestionIndex < gameState.totalQuestions - 1 {
            gameState.currentQuestionIndex += 1
            gameState.showingCorrectAnswer = false
            
            // 读出新题目
            readCurrentQuestion()
            
            // Force UI update by triggering objectWillChange
            self.objectWillChange.send()
        } else {
            gameState.gameCompleted = true
        }
    } else {
        // If answer is incorrect, we'll wait for the user to click the "Next Question" button
        // Note: The wrong question is already added to the collection in gameState.checkAnswer()
        // No need to add it again here
        print("Question answered incorrectly: \(gameState.questions[gameState.currentQuestionIndex].questionText)")
    }
}
    
// 暂停游戏
func pauseGame() -> Bool {
    if gameState.pauseGame() {
        timerActive = false
        return true
    }
    return false
}

// 恢复游戏
func resumeGame() {
    gameState.resumeGame()
    timerActive = true
}

// 保存游戏进度
func saveProgress() {
    if gameState.saveProgress() {
        showSaveProgressSuccess = true
        
        // 3秒后自动隐藏成功提示
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showSaveProgressSuccess = false
        }
    } else {
        showSaveProgressError = true
        
        // 3秒后自动隐藏错误提示
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showSaveProgressError = false
        }
    }
}

// 加载保存的游戏进度
static func loadSavedGame() -> GameViewModel? {
    if let savedGameState = GameState.loadProgress() {
        return GameViewModel(savedGameState: savedGameState)
    }
    return nil
}

// 检查是否有保存的游戏进度
static func hasSavedProgress() -> Bool {
    return GameState.hasSavedProgress()
}

// 获取保存的游戏信息
static func getSavedGameInfo() -> (difficultyLevel: DifficultyLevel, progress: String, savedAt: Date)? {
    return GameState.getSavedGameInfo()
}

func moveToNextQuestion() {
    // 重置解析显示状态
    showSolutionSteps = false
    
    // Implement the logic directly in the view model instead of calling the game state
    if gameState.currentQuestionIndex < gameState.totalQuestions - 1 {
        gameState.currentQuestionIndex += 1
        gameState.showingCorrectAnswer = false
        
        // 读出新题目
        readCurrentQuestion()
        
        // Force UI update by triggering objectWillChange
        self.objectWillChange.send()
    } else {
        gameState.gameCompleted = true
    }
}
    
    func endGame() {
        timerActive = false
        gameState.gameCompleted = true
    }
    
    func decrementTimer() {
        // 如果游戏暂停，不减少时间
        if gameState.isPaused {
            return
        }
        
        if gameState.timeRemaining > 0 {
            // Explicitly notify observers before changing the value
            self.objectWillChange.send()
            gameState.timeRemaining -= 1
            // Also notify gameState observers to ensure UI updates
            gameState.objectWillChange.send()
        } else {
            endGame()
        }
    }
    
    // 设置语言变化监听器
    private func setupLanguageChangeListener() {
        NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))
            .sink { [weak self] _ in
                self?.refreshSolutionContent()
            }
            .store(in: &cancellables)
    }
    
    // 刷新解析内容
    private func refreshSolutionContent() {
        DispatchQueue.main.async { [weak self] in
            if self?.showSolutionSteps == true {
                self?.updateSolutionContent()
            }
        }
    }
    
    // 更新解析内容
    func updateSolutionContent() {
        let currentQuestion = gameState.questions[gameState.currentQuestionIndex]
        let newSolutionContent = currentQuestion.getSolutionSteps(for: gameState.difficultyLevel)
        
        // Debug: Print solution content for verification
        #if DEBUG
        print("Updating solution content for language: \(LocalizationManager.shared.currentLanguage.rawValue)")
        print("Solution content: \(newSolutionContent)")
        #endif
        
        solutionContent = newSolutionContent
        
        // Force UI update
        objectWillChange.send()
    }
    
    // 显示解析
    func showSolution() {
        updateSolutionContent()
        showSolutionSteps = true
    }
    
    // 隐藏解析
    func hideSolution() {
        showSolutionSteps = false
        solutionContent = ""
    }
    
    // 读出当前题目
    func readCurrentQuestion() {
        guard gameState.currentQuestionIndex < gameState.questions.count else { return }
        
        let currentQuestion = gameState.questions[gameState.currentQuestionIndex]
        let currentLanguage = LocalizationManager.shared.currentLanguage
        let speechText = currentQuestion.questionTextForSpeech
        
        // 使用TTSHelper读出题目
        TTSHelper.shared.speakMathExpression(speechText, language: currentLanguage)
        
        #if DEBUG
        print("Reading question: \(speechText)")
        #endif
    }
    
    deinit {
        timerActive = false
        cancellables.forEach { $0.cancel() }
    }
}
