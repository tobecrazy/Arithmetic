import Foundation
import SwiftUI
import Combine

/// The central view model that manages game state, user interactions, and reactive updates.
///
/// `GameViewModel` serves as the single source of truth for all game logic, implementing
/// the MVVM pattern with Combine for reactive data flow. It handles timer management,
/// answer validation, game progress persistence, and TTS (Text-to-Speech) coordination.
///
/// ## Architecture
/// - Follows MVVM pattern with `@Published` properties for reactive SwiftUI updates
/// - Uses Combine to listen to `GameState` changes and language switching
/// - Manages game lifecycle: start, pause, resume, save, and end
/// - Coordinates with CoreData for progress persistence and wrong question tracking
///
/// ## Key Responsibilities
/// - Timer management (start, pause, resume, decrement)
/// - Answer submission and validation
/// - Solution display with localization
/// - Game progress saving and loading
/// - TTS coordination for question read-aloud
/// - Language change adaptation
///
/// ## Example Usage
/// ```swift
/// // Create new game
/// let viewModel = GameViewModel(difficultyLevel: .level2, timeInMinutes: 10)
/// viewModel.startGame()
///
/// // Resume saved game
/// if let savedGame = GameViewModel.loadSavedGame() {
///     savedGame.startGame()
/// }
///
/// // Submit answer
/// viewModel.submitAnswer(42)
/// ```
class GameViewModel: ObservableObject {
    // MARK: - Published Properties

    /// The current game state containing questions, score, time, and progress
    @Published var gameState: GameState

    /// Indicates whether the game timer is currently active and counting down
    @Published var timerActive: Bool = false

    /// Shows a success message when game progress is saved successfully
    @Published var showSaveProgressSuccess: Bool = false

    /// Shows an error message when game progress fails to save
    @Published var showSaveProgressError: Bool = false

    /// Controls visibility of the solution steps panel
    @Published var showSolutionSteps: Bool = false

    /// The localized solution content for the current question
    @Published var solutionContent: String = ""

    /// Set of Combine cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Constants
    private enum Constants {
        /// Duration in seconds before auto-dismissing alert messages
        static let alertDismissalDelay: TimeInterval = 3.0
    }

    // MARK: - Initialization

    /// Creates a new game with the specified difficulty and time limit.
    ///
    /// - Parameters:
    ///   - difficultyLevel: The difficulty level determining question ranges and operations
    ///   - timeInMinutes: The total time allowed for the game in minutes
    init(difficultyLevel: DifficultyLevel, timeInMinutes: Int) {
        self.gameState = GameState(difficultyLevel: difficultyLevel, timeInMinutes: timeInMinutes)
        setupSubscriptions()
    }

    /// Creates a view model from a previously saved game state.
    ///
    /// Used when resuming a paused or saved game from CoreData.
    ///
    /// - Parameter savedGameState: The game state loaded from persistent storage
    init(savedGameState: GameState) {
        self.gameState = savedGameState
        setupSubscriptions()
    }

    // MARK: - Private Setup Methods

    /// Sets up all Combine subscriptions for game state changes
    private func setupSubscriptions() {
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
    
    /// Starts or resumes the game, activating the timer and reading the current question.
    ///
    /// If the game is paused, it will be resumed. The timer becomes active and the
    /// current question is read aloud if TTS is enabled.
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
    
    /// Resets the game to its initial state with the same difficulty and time settings.
    ///
    /// Creates a new `GameState` with fresh questions, resets all subscriptions,
    /// and starts the game timer.
    ///
    /// - Note: This completely discards the current game progress
    func resetGame() {
        // 重置游戏状态
        let difficultyLevel = gameState.difficultyLevel
        let timeInMinutes = gameState.totalTime / 60

        // 创建新的游戏状态
        self.gameState = GameState(difficultyLevel: difficultyLevel, timeInMinutes: timeInMinutes)

        // 清除旧订阅并重新设置
        cancellables.removeAll()
        setupSubscriptions()

        // 激活计时器
        timerActive = true

        // 读出当前题目
        readCurrentQuestion()
    }
    
    /// Validates and processes a user's answer to the current question.
    ///
    /// If the answer is correct, automatically advances to the next question.
    /// If incorrect, displays the correct answer and waits for user to click "Next Question".
    /// Wrong answers are automatically saved to the wrong question collection.
    ///
    /// - Parameter answer: The user's submitted answer as an integer
    ///
    /// ## Behavior
    /// - **Correct**: Increments score, moves to next question, reads new question via TTS
    /// - **Incorrect**: Shows correct answer, enables solution panel, saves to wrong questions
    /// - **Last Question**: Marks game as completed instead of advancing
    func submitAnswer(_ answer: Int) {
        let isCorrect = gameState.checkAnswer(answer)
        handleAnswerResult(isCorrect: isCorrect)
    }

    /// Validates and processes a user's fraction answer to the current question.
    ///
    /// If the answer is correct, automatically advances to the next question.
    /// If incorrect, displays the correct answer and waits for user to click "Next Question".
    /// Wrong answers are automatically saved to the wrong question collection.
    ///
    /// - Parameter fraction: The user's submitted answer as a Fraction
    ///
    /// ## Behavior
    /// - **Correct**: Increments score, moves to next question, reads new question via TTS
    /// - **Incorrect**: Shows correct answer, enables solution panel, saves to wrong questions
    /// - **Last Question**: Marks game as completed instead of advancing
    func submitFractionAnswer(_ fraction: Fraction) {
        let isCorrect = gameState.checkAnswer(fraction)
        handleAnswerResult(isCorrect: isCorrect)
    }

    /// Validates and processes a user's decimal answer to the current question (for fraction questions).
    ///
    /// - Parameter decimal: The user's submitted answer as a decimal number
    /// - Parameter tolerance: The acceptable tolerance for decimal comparison (default 0.01)
    func submitDecimalAnswer(_ decimal: Double, tolerance: Double = 0.01) {
        let currentQuestion = gameState.questions[gameState.currentQuestionIndex]
        let isCorrect = currentQuestion.checkDecimalAnswer(decimal, tolerance: tolerance)

        // Update game state for decimal answers
        if isCorrect {
            gameState.score += 1
        } else {
            gameState.showingCorrectAnswer = true
            // Add to wrong questions
            WrongQuestionManager(context: CoreDataManager.shared.context)
                .addWrongQuestion(currentQuestion, for: gameState.difficultyLevel)
        }

        handleAnswerResult(isCorrect: isCorrect)
    }

    /// Common handler for answer results - moves to next question or shows correct answer
    private func handleAnswerResult(isCorrect: Bool) {
        if isCorrect {
            // If answer is correct, move to next question immediately
            if gameState.currentQuestionIndex < gameState.totalQuestions - 1 {
                gameState.currentQuestionIndex += 1
                gameState.showingCorrectAnswer = false

                // 读出新题目
                readCurrentQuestion()
            } else {
                gameState.gameCompleted = true
            }
        } else {
            // If answer is incorrect, we'll wait for the user to click the "Next Question" button
            // Note: The wrong question is already added to the collection in gameState.checkAnswer()
            #if DEBUG
            print("Question answered incorrectly: \(gameState.questions[gameState.currentQuestionIndex].questionText)")
            #endif
        }
    }
    
    /// Pauses the game, stopping the timer.
    ///
    /// The pause state is tracked and can only be used once per game session.
    /// Use ``resumeGame()`` to continue.
    func pauseGame() {
    gameState.pauseGame()
    timerActive = false
}

    /// Resumes a paused game, reactivating the timer.
    ///
    /// Only works if the game was previously paused via ``pauseGame()``.
    func resumeGame() {
    gameState.resumeGame()
    timerActive = true
}

    /// Saves the current game progress to CoreData for later resumption.
    ///
    /// Displays a success or error message for 3 seconds after the save attempt.
    /// The saved game can be restored using ``loadSavedGame()``.
    ///
    /// - Note: Only one game can be saved at a time; saving overwrites any previous save
    func saveProgress() {
    if gameState.saveProgress() {
        showSaveProgressSuccess = true

        // 自动隐藏成功提示
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.alertDismissalDelay) {
            self.showSaveProgressSuccess = false
        }
    } else {
        showSaveProgressError = true

        // 自动隐藏错误提示
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.alertDismissalDelay) {
            self.showSaveProgressError = false
        }
    }
}

    /// Loads a previously saved game from CoreData, if one exists.
    ///
    /// - Returns: A `GameViewModel` initialized with the saved game state, or `nil` if no save exists
    ///
    /// ## Example
    /// ```swift
    /// if let savedGame = GameViewModel.loadSavedGame() {
    ///     // Present savedGame to user
    ///     navigationPath.append(savedGame)
    /// }
    /// ```
    static func loadSavedGame() -> GameViewModel? {
    if let savedGameState = GameState.loadProgress() {
        return GameViewModel(savedGameState: savedGameState)
    }
    return nil
}

    /// Checks whether a saved game exists in CoreData.
    ///
    /// - Returns: `true` if a saved game can be resumed, `false` otherwise
    static func hasSavedProgress() -> Bool {
    return GameState.hasSavedProgress()
}

    /// Retrieves information about the saved game without loading it.
    ///
    /// - Returns: A tuple containing difficulty level, progress text, and save date, or `nil` if no save exists
    ///
    /// Useful for displaying save game information in the UI before loading.
    static func getSavedGameInfo() -> (difficultyLevel: DifficultyLevel, progress: String, savedAt: Date)? {
    return GameState.getSavedGameInfo()
}

    /// Advances to the next question after viewing the solution for a wrong answer.
    ///
    /// Resets the solution panel state and moves to the next question, or marks
    /// the game as completed if this was the last question.
    func moveToNextQuestion() {
    // 重置解析显示状态
    showSolutionSteps = false

    // Implement the logic directly in the view model instead of calling the game state
    if gameState.currentQuestionIndex < gameState.totalQuestions - 1 {
        gameState.currentQuestionIndex += 1
        gameState.showingCorrectAnswer = false

        // 读出新题目
        readCurrentQuestion()
    } else {
        gameState.gameCompleted = true
    }
}
    
    /// Immediately ends the game, stopping the timer and marking it as completed.
    ///
    /// Used when the user manually finishes the game or time runs out.
    func endGame() {
        timerActive = false
        gameState.gameCompleted = true
    }
    
    /// Decrements the remaining time by one second unless the game is paused.
    ///
    /// Called once per second by the game timer. When time reaches zero,
    /// automatically ends the game.
    ///
    /// - Note: This method does nothing if ``gameState.isPaused`` is `true`
    func decrementTimer() {
        // 如果游戏暂停，不减少时间
        if gameState.isPaused {
            return
        }

        if gameState.timeRemaining > 0 {
            gameState.timeRemaining -= 1
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

        #if DEBUG
        print("Updating solution content for language: \(LocalizationManager.shared.currentLanguage.rawValue)")
        print("Solution content: \(newSolutionContent)")
        #endif

        solutionContent = newSolutionContent
    }
    
    /// Displays the solution steps for the current question.
    ///
    /// Updates ``solutionContent`` with localized solution steps and sets
    /// ``showSolutionSteps`` to `true`.
    func showSolution() {
        updateSolutionContent()
        showSolutionSteps = true
    }
    
    /// Hides the solution panel and clears solution content.
    func hideSolution() {
        showSolutionSteps = false
        solutionContent = ""
    }
    
    /// Reads the current question aloud using TTS (Text-to-Speech) if enabled.
    ///
    /// Respects the user's TTS preference stored in `UserDefaults` and uses
    /// the current language for pronunciation.
    ///
    /// - Note: Does nothing if TTS is disabled or the question index is invalid
    func readCurrentQuestion() {
        guard UserDefaults.standard.bool(forKey: "isTtsEnabled") else {
            return
        }
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
        // Combine automatically cancels subscriptions when cancellables is deallocated
    }
}
