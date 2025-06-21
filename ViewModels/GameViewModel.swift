import Foundation
import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var timerActive: Bool = false
    @Published var showSaveProgressSuccess: Bool = false
    @Published var showSaveProgressError: Bool = false
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
    }
    
    func startGame() {
        // 如果游戏处于暂停状态，先恢复
        if gameState.isPaused {
            gameState.resumeGame()
        }
        
        // 激活计时器
        timerActive = true
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
        
        // 激活计时器
        timerActive = true
    }
    
func submitAnswer(_ answer: Int) {
    let isCorrect = gameState.checkAnswer(answer)
    
    if isCorrect {
        // If answer is correct, move to next question immediately
        gameState.moveToNextQuestion()
    }
    // If answer is incorrect, we'll wait for the user to click the "Next Question" button
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
    // Implement the logic directly in the view model instead of calling the game state
    if gameState.currentQuestionIndex < gameState.totalQuestions - 1 {
        gameState.currentQuestionIndex += 1
        gameState.showingCorrectAnswer = false
        
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
    
    deinit {
        timerActive = false
        cancellables.forEach { $0.cancel() }
    }
}
