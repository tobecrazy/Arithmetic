import Foundation
import CoreData

@objc(GameProgressEntity)
public class GameProgressEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var difficultyLevel: String
    @NSManaged public var currentQuestionIndex: Int16
    @NSManaged public var score: Int16
    @NSManaged public var timeRemaining: Int16
    @NSManaged public var questions: Data
    @NSManaged public var userAnswers: Data
    @NSManaged public var savedAt: Date
    @NSManaged public var isPaused: Bool
    @NSManaged public var pauseUsed: Bool
}

extension GameProgressEntity {
    // Fetch request
    @nonobjc public class func fetchRequest() -> NSFetchRequest<GameProgressEntity> {
        return NSFetchRequest<GameProgressEntity>(entityName: "GameProgress")
    }
    
    // Convert to GameState
    func toGameState() -> GameState? {
        guard let difficultyLevel = DifficultyLevel(rawValue: self.difficultyLevel) else {
            return nil
        }
        
        // Create a new GameState with the saved difficulty level and time
        let timeInMinutes = Int(timeRemaining) / 60
        let gameState = GameState(difficultyLevel: difficultyLevel, timeInMinutes: timeInMinutes)
        
        // Restore the saved state
        gameState.currentQuestionIndex = Int(currentQuestionIndex)
        gameState.score = Int(score)
        gameState.timeRemaining = Int(timeRemaining)
        
        // Decode questions and user answers
        do {
            if let questions = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: self.questions) as? [Question] {
                gameState.questions = questions
            }
            
            if let userAnswers = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: self.userAnswers) as? [Int?] {
                gameState.userAnswers = userAnswers
            }
        } catch {
            print("Error decoding game progress data: \(error)")
            return nil
        }
        
        return gameState
    }
}
