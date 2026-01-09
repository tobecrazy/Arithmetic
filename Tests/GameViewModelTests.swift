import XCTest
@testable import Arithmetic

class GameViewModelTests: XCTestCase {
    
    var gameViewModel: GameViewModel!
    
    override func setUp() {
        super.setUp()
        // Initialize with a simple difficulty level and time
        gameViewModel = GameViewModel(difficultyLevel: .level1, timeInMinutes: 5)
    }
    
    override func tearDown() {
        gameViewModel = nil
        super.tearDown()
    }
    
    func testInitialization() {
        XCTAssertNotNil(gameViewModel)
        XCTAssertEqual(gameViewModel.gameState.difficultyLevel, .level1)
        XCTAssertEqual(gameViewModel.gameState.totalTime, 300) // 5 minutes in seconds
    }
    
    func testStartGame() {
        gameViewModel.startGame()
        
        XCTAssertTrue(gameViewModel.timerActive)
        XCTAssertFalse(gameViewModel.gameState.isPaused)
    }
    
    func testResetGame() {
        gameViewModel.startGame()
        gameViewModel.gameState.currentQuestionIndex = 5 // Set to some value
        
        let initialDifficulty = gameViewModel.gameState.difficultyLevel
        let initialTime = gameViewModel.gameState.totalTime
        
        gameViewModel.resetGame()
        
        XCTAssertEqual(gameViewModel.gameState.difficultyLevel, initialDifficulty)
        XCTAssertEqual(gameViewModel.gameState.totalTime, initialTime)
        XCTAssertEqual(gameViewModel.gameState.currentQuestionIndex, 0)
        XCTAssertTrue(gameViewModel.timerActive)
    }
    
    func testSubmitCorrectAnswer() {
        // Ensure there are questions
        XCTAssertFalse(gameViewModel.gameState.questions.isEmpty)
        
        let initialIndex = gameViewModel.gameState.currentQuestionIndex
        let correctAnswer = gameViewModel.gameState.questions[initialIndex].answer
        
        gameViewModel.submitAnswer(correctAnswer)
        
        // For a correct answer, if not at the last question, index should increment
        if initialIndex < gameViewModel.gameState.totalQuestions - 1 {
            XCTAssertEqual(gameViewModel.gameState.currentQuestionIndex, initialIndex + 1)
        } else {
            XCTAssertTrue(gameViewModel.gameState.gameCompleted)
        }
    }
    
    func testSubmitIncorrectAnswer() {
        // Ensure there are questions
        XCTAssertFalse(gameViewModel.gameState.questions.isEmpty)
        
        let initialIndex = gameViewModel.gameState.currentQuestionIndex
        
        // Submit an incorrect answer (not the actual answer)
        gameViewModel.submitAnswer(-1) // Assuming -1 is never the correct answer
        
        // For an incorrect answer, the index should remain the same
        XCTAssertEqual(gameViewModel.gameState.currentQuestionIndex, initialIndex)
    }
    
    func testPauseGame() {
        gameViewModel.startGame()
        XCTAssertTrue(gameViewModel.timerActive)
        
        gameViewModel.pauseGame()
        
        XCTAssertFalse(gameViewModel.timerActive)
        XCTAssertTrue(gameViewModel.gameState.isPaused)
    }
    
    func testResumeGame() {
        gameViewModel.pauseGame()
        XCTAssertFalse(gameViewModel.timerActive)
        XCTAssertTrue(gameViewModel.gameState.isPaused)
        
        gameViewModel.resumeGame()
        
        XCTAssertTrue(gameViewModel.timerActive)
        XCTAssertFalse(gameViewModel.gameState.isPaused)
    }
    
    func testEndGame() {
        gameViewModel.startGame()
        XCTAssertTrue(gameViewModel.timerActive)
        
        gameViewModel.endGame()
        
        XCTAssertFalse(gameViewModel.timerActive)
        XCTAssertTrue(gameViewModel.gameState.gameCompleted)
    }
    
    func testDecrementTimer() {
        gameViewModel.startGame()
        let initialTime = gameViewModel.gameState.timeRemaining
        
        gameViewModel.decrementTimer()
        
        XCTAssertEqual(gameViewModel.gameState.timeRemaining, initialTime - 1)
    }
    
    func testDecrementTimerWhenPaused() {
        gameViewModel.pauseGame()
        let initialTime = gameViewModel.gameState.timeRemaining
        
        gameViewModel.decrementTimer()
        
        // Time should not change when paused
        XCTAssertEqual(gameViewModel.gameState.timeRemaining, initialTime)
    }
    
    func testDecrementTimerEndsGameWhenTimeExpires() {
        gameViewModel.startGame()
        gameViewModel.gameState.timeRemaining = 0
        
        gameViewModel.decrementTimer()
        
        XCTAssertFalse(gameViewModel.timerActive)
        XCTAssertTrue(gameViewModel.gameState.gameCompleted)
    }
    
    func testMoveToNextQuestion() {
        // Ensure we're not at the last question
        if gameViewModel.gameState.currentQuestionIndex < gameViewModel.gameState.totalQuestions - 1 {
            let initialIndex = gameViewModel.gameState.currentQuestionIndex
            
            gameViewModel.moveToNextQuestion()
            
            XCTAssertEqual(gameViewModel.gameState.currentQuestionIndex, initialIndex + 1)
            XCTAssertFalse(gameViewModel.gameState.showingCorrectAnswer)
        }
    }
    
    func testMoveToNextQuestionAtEnd() {
        gameViewModel.gameState.currentQuestionIndex = gameViewModel.gameState.totalQuestions - 1
        
        gameViewModel.moveToNextQuestion()
        
        XCTAssertTrue(gameViewModel.gameState.gameCompleted)
    }
    
    func testShowSolution() {
        XCTAssertFalse(gameViewModel.showSolutionSteps)
        
        gameViewModel.showSolution()
        
        XCTAssertTrue(gameViewModel.showSolutionSteps)
        XCTAssertFalse(gameViewModel.solutionContent.isEmpty)
    }
    
    func testHideSolution() {
        gameViewModel.showSolution()
        XCTAssertTrue(gameViewModel.showSolutionSteps)
        
        gameViewModel.hideSolution()
        
        XCTAssertFalse(gameViewModel.showSolutionSteps)
        XCTAssertTrue(gameViewModel.solutionContent.isEmpty)
    }
    
    func testUpdateSolutionContent() {
        gameViewModel.updateSolutionContent()
        
        XCTAssertFalse(gameViewModel.solutionContent.isEmpty)
    }
    
    func testSaveProgress() {
        let initialSuccessState = gameViewModel.showSaveProgressSuccess
        let initialErrorState = gameViewModel.showSaveProgressError
        
        gameViewModel.saveProgress()
        
        // The saveProgress method updates the UI state, so we check that the state has been updated
        XCTAssertNotEqual(gameViewModel.showSaveProgressSuccess, initialSuccessState || gameViewModel.showSaveProgressError != initialErrorState)
    }
    
    func testHasSavedProgress() {
        let hasProgress = GameViewModel.hasSavedProgress()
        XCTAssertFalse(hasProgress) // Initially should be false
    }
    
    func testGetSavedGameInfo() {
        let savedInfo = GameViewModel.getSavedGameInfo()
        XCTAssertNil(savedInfo) // Initially should be nil
    }
}