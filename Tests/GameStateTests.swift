import XCTest
@testable import Arithmetic

// MARK: - GameState Tests
class GameStateTests: XCTestCase {

    var gameState: GameState!

    override func setUp() {
        super.setUp()
        gameState = GameState(difficultyLevel: .level1, timeInMinutes: 5)
    }

    override func tearDown() {
        gameState = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitializationWithLevel1() {
        let state = GameState(difficultyLevel: .level1, timeInMinutes: 5)
        XCTAssertEqual(state.difficultyLevel, .level1)
        XCTAssertEqual(state.timeRemaining, 300) // 5 * 60
        XCTAssertEqual(state.totalTime, 300)
        XCTAssertEqual(state.currentQuestionIndex, 0)
        XCTAssertEqual(state.score, 0)
        XCTAssertFalse(state.gameCompleted)
        XCTAssertFalse(state.isPaused)
        XCTAssertFalse(state.pauseUsed)
        XCTAssertEqual(state.streakCount, 0)
        XCTAssertEqual(state.longestStreak, 0)
    }

    func testInitializationGeneratesQuestions() {
        XCTAssertFalse(gameState.questions.isEmpty)
        XCTAssertEqual(gameState.questions.count, gameState.totalQuestions)
    }

    func testInitializationCreatesUserAnswersArray() {
        XCTAssertEqual(gameState.userAnswers.count, gameState.totalQuestions)
        XCTAssertTrue(gameState.userAnswers.allSatisfy { $0 == nil })
    }

    func testTotalQuestionsMatchesDifficultyLevel() {
        XCTAssertEqual(gameState.totalQuestions, DifficultyLevel.level1.questionCount)

        let level4State = GameState(difficultyLevel: .level4, timeInMinutes: 5)
        XCTAssertEqual(level4State.totalQuestions, DifficultyLevel.level4.questionCount)
    }

    func testPointsPerQuestionMatchesDifficultyLevel() {
        XCTAssertEqual(gameState.pointsPerQuestion, DifficultyLevel.level1.pointsPerQuestion)

        let level3State = GameState(difficultyLevel: .level3, timeInMinutes: 5)
        XCTAssertEqual(level3State.pointsPerQuestion, DifficultyLevel.level3.pointsPerQuestion)
    }

    // MARK: - checkAnswer Tests

    func testCheckAnswerCorrect() {
        let correctAnswer = gameState.questions[0].correctAnswer
        let result = gameState.checkAnswer(correctAnswer)

        XCTAssertTrue(result)
        XCTAssertEqual(gameState.score, gameState.pointsPerQuestion)
        XCTAssertEqual(gameState.streakCount, 1)
        XCTAssertTrue(gameState.isCorrect)
        XCTAssertFalse(gameState.showingCorrectAnswer)
    }

    func testCheckAnswerIncorrect() {
        let incorrectAnswer = gameState.questions[0].correctAnswer + 1
        let result = gameState.checkAnswer(incorrectAnswer)

        XCTAssertFalse(result)
        XCTAssertEqual(gameState.score, 0)
        XCTAssertEqual(gameState.streakCount, 0)
        XCTAssertFalse(gameState.isCorrect)
        XCTAssertTrue(gameState.showingCorrectAnswer)
    }

    func testCheckAnswerUpdatesUserAnswers() {
        let answer = 42
        _ = gameState.checkAnswer(answer)

        XCTAssertEqual(gameState.userAnswers[0], answer)
    }

    func testCheckAnswerStreakIncrementsOnCorrect() {
        // Answer first 3 questions correctly
        for i in 0..<min(3, gameState.questions.count) {
            let correctAnswer = gameState.questions[i].correctAnswer
            _ = gameState.checkAnswer(correctAnswer)
            if i < gameState.questions.count - 1 {
                gameState.moveToNextQuestion()
            }
        }

        XCTAssertEqual(gameState.streakCount, 3)
        XCTAssertEqual(gameState.longestStreak, 3)
    }

    func testCheckAnswerStreakResetsOnIncorrect() {
        // Answer 2 correctly
        for i in 0..<min(2, gameState.questions.count) {
            let correctAnswer = gameState.questions[i].correctAnswer
            _ = gameState.checkAnswer(correctAnswer)
            if i < gameState.questions.count - 1 {
                gameState.moveToNextQuestion()
            }
        }

        XCTAssertEqual(gameState.streakCount, 2)

        // Answer incorrectly
        _ = gameState.checkAnswer(-999)

        XCTAssertEqual(gameState.streakCount, 0)
        XCTAssertEqual(gameState.longestStreak, 2) // Longest streak preserved
    }

    func testCheckAnswerLongestStreakPreserved() {
        // Build streak of 3
        for i in 0..<min(3, gameState.questions.count) {
            let correctAnswer = gameState.questions[i].correctAnswer
            _ = gameState.checkAnswer(correctAnswer)
            if i < gameState.questions.count - 1 {
                gameState.moveToNextQuestion()
            }
        }

        XCTAssertEqual(gameState.longestStreak, 3)

        // Break streak
        _ = gameState.checkAnswer(-999)
        gameState.moveToNextQuestion()

        // Build streak of 2
        for i in 0..<min(2, gameState.questions.count - 4) {
            if gameState.currentQuestionIndex < gameState.questions.count {
                let correctAnswer = gameState.questions[gameState.currentQuestionIndex].correctAnswer
                _ = gameState.checkAnswer(correctAnswer)
                if gameState.currentQuestionIndex < gameState.questions.count - 1 {
                    gameState.moveToNextQuestion()
                }
            }
        }

        // Longest streak should still be 3
        XCTAssertEqual(gameState.longestStreak, 3)
    }

    // MARK: - moveToNextQuestion Tests

    func testMoveToNextQuestionIncrementsIndex() {
        XCTAssertEqual(gameState.currentQuestionIndex, 0)
        gameState.moveToNextQuestion()
        XCTAssertEqual(gameState.currentQuestionIndex, 1)
    }

    func testMoveToNextQuestionClearsShowingCorrectAnswer() {
        gameState.showingCorrectAnswer = true
        gameState.moveToNextQuestion()
        XCTAssertFalse(gameState.showingCorrectAnswer)
    }

    func testMoveToNextQuestionCompletesGameAtLastQuestion() {
        // Move to last question
        for _ in 0..<(gameState.totalQuestions - 1) {
            gameState.moveToNextQuestion()
        }

        XCTAssertEqual(gameState.currentQuestionIndex, gameState.totalQuestions - 1)
        XCTAssertFalse(gameState.gameCompleted)

        // Move past last question
        gameState.moveToNextQuestion()

        XCTAssertTrue(gameState.gameCompleted)
    }

    // MARK: - Progress Text Tests

    func testProgressTextFormat() {
        let progressText = gameState.progressText
        XCTAssertTrue(progressText.contains("1"))
        XCTAssertTrue(progressText.contains(String(gameState.totalQuestions)))
    }

    func testProgressTextUpdatesWithIndex() {
        gameState.moveToNextQuestion()
        let progressText = gameState.progressText
        XCTAssertTrue(progressText.contains("2"))
    }

    // MARK: - Time Remaining Text Tests

    func testTimeRemainingTextFormat() {
        // 5 minutes = 05:00
        let timeText = gameState.timeRemainingText
        XCTAssertEqual(timeText, "05:00")
    }

    func testTimeRemainingTextWithDecrementedTime() {
        gameState.timeRemaining = 125 // 2:05
        XCTAssertEqual(gameState.timeRemainingText, "02:05")
    }

    func testTimeRemainingTextWithZero() {
        gameState.timeRemaining = 0
        XCTAssertEqual(gameState.timeRemainingText, "00:00")
    }

    // MARK: - Time Used Tests

    func testTimeUsedInitiallyZero() {
        XCTAssertEqual(gameState.timeUsed, 0)
    }

    func testTimeUsedAfterTimeDecrement() {
        gameState.timeRemaining = 250 // 50 seconds used
        XCTAssertEqual(gameState.timeUsed, 50)
    }

    func testTimeUsedTextFormat() {
        gameState.timeRemaining = 180 // 2 minutes used (120 seconds)
        XCTAssertEqual(gameState.timeUsedText, "02:00")
    }

    // MARK: - Correct Answers Count Tests

    func testCorrectAnswersCountInitiallyZero() {
        XCTAssertEqual(gameState.correctAnswersCount, 0)
    }

    func testCorrectAnswersCountAfterCorrectAnswers() {
        // Answer 3 questions correctly
        for i in 0..<min(3, gameState.questions.count) {
            let correctAnswer = gameState.questions[i].correctAnswer
            _ = gameState.checkAnswer(correctAnswer)
            if i < gameState.questions.count - 1 {
                gameState.moveToNextQuestion()
            }
        }

        XCTAssertEqual(gameState.correctAnswersCount, 3)
    }

    func testCorrectAnswersCountIgnoresIncorrect() {
        // Answer 2 correctly, 1 incorrectly
        let correctAnswer1 = gameState.questions[0].correctAnswer
        _ = gameState.checkAnswer(correctAnswer1)
        gameState.moveToNextQuestion()

        _ = gameState.checkAnswer(-999) // Incorrect
        gameState.moveToNextQuestion()

        let correctAnswer3 = gameState.questions[2].correctAnswer
        _ = gameState.checkAnswer(correctAnswer3)

        XCTAssertEqual(gameState.correctAnswersCount, 2)
    }

    // MARK: - Performance Rating Tests

    func testPerformanceRatingExcellent() {
        // Score 90%+ of max possible
        let maxScore = gameState.totalQuestions * gameState.pointsPerQuestion
        gameState.score = Int(Double(maxScore) * 0.95)

        let (rating, stars) = gameState.getPerformanceRating()
        XCTAssertTrue(stars.contains("⭐⭐⭐"))
        XCTAssertFalse(rating.isEmpty)
    }

    func testPerformanceRatingGood() {
        // Score 80-89%
        let maxScore = gameState.totalQuestions * gameState.pointsPerQuestion
        gameState.score = Int(Double(maxScore) * 0.85)

        let (_, stars) = gameState.getPerformanceRating()
        XCTAssertTrue(stars.contains("⭐⭐"))
    }

    func testPerformanceRatingPass() {
        // Score 70-79%
        let maxScore = gameState.totalQuestions * gameState.pointsPerQuestion
        gameState.score = Int(Double(maxScore) * 0.75)

        let (_, stars) = gameState.getPerformanceRating()
        XCTAssertEqual(stars, "⭐")
    }

    func testPerformanceRatingNeedImprovement() {
        // Score < 70%
        let maxScore = gameState.totalQuestions * gameState.pointsPerQuestion
        gameState.score = Int(Double(maxScore) * 0.50)

        let (_, stars) = gameState.getPerformanceRating()
        XCTAssertEqual(stars, "💪")
    }

    // MARK: - Pause/Resume Tests

    func testPauseGameSetsPausedState() {
        gameState.pauseGame()

        XCTAssertTrue(gameState.isPaused)
        XCTAssertTrue(gameState.pauseUsed)
    }

    func testPauseGameDeductsScore() {
        gameState.score = 20
        gameState.pauseGame()

        XCTAssertEqual(gameState.score, 15) // 20 - 5
    }

    func testPauseGameDeductsToZeroIfScoreLow() {
        gameState.score = 3
        gameState.pauseGame()

        XCTAssertEqual(gameState.score, 0)
    }

    func testPauseGameCanOnlyBeUsedOnce() {
        gameState.score = 50
        gameState.pauseGame()
        XCTAssertEqual(gameState.score, 45)

        // Try to pause again
        gameState.isPaused = false
        gameState.pauseGame()

        // Score should not change
        XCTAssertEqual(gameState.score, 45)
    }

    func testResumeGameClearsPausedState() {
        gameState.pauseGame()
        XCTAssertTrue(gameState.isPaused)

        gameState.resumeGame()
        XCTAssertFalse(gameState.isPaused)
    }

    func testResumeGameDoesNotResetPauseUsed() {
        gameState.pauseGame()
        gameState.resumeGame()

        XCTAssertTrue(gameState.pauseUsed)
    }

    // MARK: - All Difficulty Levels Tests

    func testGameStateInitializationAllLevels() {
        for level in DifficultyLevel.allCases {
            let state = GameState(difficultyLevel: level, timeInMinutes: 3)

            XCTAssertEqual(state.difficultyLevel, level)
            XCTAssertEqual(state.questions.count, level.questionCount)
            XCTAssertEqual(state.userAnswers.count, level.questionCount)
            XCTAssertEqual(state.totalQuestions, level.questionCount)
            XCTAssertEqual(state.pointsPerQuestion, level.pointsPerQuestion)
        }
    }

    // MARK: - Question Validation Tests

    func testGeneratedQuestionsAreValid() {
        for question in gameState.questions {
            XCTAssertTrue(question.isValid(), "Question '\(question.questionText)' should be valid")
        }
    }

    func testGeneratedQuestionsHaveCorrectOperationsForLevel() {
        let supportedOps = gameState.difficultyLevel.supportedOperations

        for question in gameState.questions {
            for op in question.operations {
                XCTAssertTrue(supportedOps.contains(op),
                             "Operation \(op.symbol) not supported for \(gameState.difficultyLevel)")
            }
        }
    }
}
