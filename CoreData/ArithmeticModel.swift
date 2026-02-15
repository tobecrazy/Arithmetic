import Foundation
import CoreData

// This file serves as a reference for the CoreData model used in the application.
// The actual model is created programmatically in CoreDataManager.swift.

// Model name used for the NSPersistentContainer
let arithmeticModelName = "ArithmeticModel"

// Entity names
struct ArithmeticModelEntities {
    static let wrongQuestion = "WrongQuestion"
    static let gameProgress = "GameProgress"
}

// WrongQuestion entity attributes
struct WrongQuestionAttributes {
    static let id = "id"
    static let questionText = "questionText"
    static let correctAnswer = "correctAnswer"
    static let level = "level"
    static let numbers = "numbers"
    static let operations = "operations"
    static let combinationKey = "combinationKey"
    static let createdAt = "createdAt"
    static let lastShownAt = "lastShownAt"
    static let timesShown = "timesShown"
    static let timesWrong = "timesWrong"
    static let solutionMethod = "solutionMethod"
    static let solutionSteps = "solutionSteps"
    // Fraction support (optional fields for backward compatibility)
    static let answerType = "answerType"
    static let fractionNumerator = "fractionNumerator"
    static let fractionDenominator = "fractionDenominator"
}

// GameProgress entity attributes
struct GameProgressAttributes {
    static let id = "id"
    static let difficultyLevel = "difficultyLevel"
    static let currentQuestionIndex = "currentQuestionIndex"
    static let score = "score"
    static let timeRemaining = "timeRemaining"
    static let questions = "questions"
    static let userAnswers = "userAnswers"
    static let savedAt = "savedAt"
    static let isPaused = "isPaused"
    static let pauseUsed = "pauseUsed"
}
