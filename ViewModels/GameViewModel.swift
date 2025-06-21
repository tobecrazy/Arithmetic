import Foundation
import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var timerActive: Bool = false
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
    }
    
    func startGame() {
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
