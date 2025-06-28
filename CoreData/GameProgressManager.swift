import Foundation
import CoreData

class GameProgressManager {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    // Save game progress
    func saveGameProgress(_ gameState: GameState) -> Bool {
        // Delete any existing game progress
        deleteGameProgress()
        
        // Create a new game progress entity
        let gameProgress = GameProgressEntity(context: context)
        gameProgress.id = UUID()
        gameProgress.difficultyLevel = gameState.difficultyLevel.rawValue
        gameProgress.currentQuestionIndex = Int16(gameState.currentQuestionIndex)
        gameProgress.score = Int16(gameState.score)
        gameProgress.timeRemaining = Int16(gameState.timeRemaining)
        gameProgress.savedAt = Date()
        gameProgress.isPaused = gameState.isPaused ?? false
        gameProgress.pauseUsed = gameState.pauseUsed ?? false
        
        // Encode questions and user answers
        do {
            gameProgress.questions = try NSKeyedArchiver.archivedData(withRootObject: gameState.questions, requiringSecureCoding: false)
            gameProgress.userAnswers = try NSKeyedArchiver.archivedData(withRootObject: gameState.userAnswers, requiringSecureCoding: false)
        } catch {
            print("Error encoding game progress data: \(error)")
            return false
        }
        
        // Save context
        do {
            try context.save()
            return true
        } catch {
            print("Error saving game progress: \(error)")
            return false
        }
    }
    
    // Load game progress
    func loadGameProgress() -> GameState? {
        let fetchRequest: NSFetchRequest<GameProgressEntity> = GameProgressEntity.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            if let gameProgress = results.first {
                return gameProgress.toGameState()
            }
        } catch {
            print("Error loading game progress: \(error)")
        }
        
        return nil
    }
    
    // Check if game progress exists
    func hasGameProgress() -> Bool {
        let fetchRequest: NSFetchRequest<GameProgressEntity> = GameProgressEntity.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking game progress: \(error)")
            return false
        }
    }
    
    // Delete game progress
    func deleteGameProgress() {
        let fetchRequest: NSFetchRequest<GameProgressEntity> = GameProgressEntity.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            for gameProgress in results {
                context.delete(gameProgress)
            }
            try context.save()
        } catch {
            print("Error deleting game progress: \(error)")
        }
    }
    
    // Get saved game info
    func getSavedGameInfo() -> (difficultyLevel: DifficultyLevel, progress: String, savedAt: Date)? {
        let fetchRequest: NSFetchRequest<GameProgressEntity> = GameProgressEntity.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            if let gameProgress = results.first,
               let difficultyLevel = DifficultyLevel(rawValue: gameProgress.difficultyLevel) {
                
                let progress = "\(gameProgress.currentQuestionIndex + 1)/\(getTotalQuestions(for: difficultyLevel))"
                return (difficultyLevel, progress, gameProgress.savedAt)
            }
        } catch {
            print("Error getting saved game info: \(error)")
        }
        
        return nil
    }
    
    // Helper method: Get total questions for a difficulty level
    private func getTotalQuestions(for level: DifficultyLevel) -> Int {
        return level.questionCount
    }
}
