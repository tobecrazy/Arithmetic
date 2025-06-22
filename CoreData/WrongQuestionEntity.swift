import Foundation
import CoreData

@objc(WrongQuestionEntity)
public class WrongQuestionEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var questionText: String
    @NSManaged public var correctAnswer: Int32
    @NSManaged public var level: String
    @NSManaged public var numbers: String
    @NSManaged public var operations: String
    @NSManaged public var combinationKey: String
    @NSManaged public var createdAt: Date
    @NSManaged public var lastShownAt: Date?
    @NSManaged public var timesShown: Int16
    @NSManaged public var timesWrong: Int16
    @NSManaged public var solutionMethod: String
    @NSManaged public var solutionSteps: String
}

extension WrongQuestionEntity {
    // Fetch request
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WrongQuestionEntity> {
        // Use the constant from ArithmeticModel.swift to ensure consistency
        return NSFetchRequest<WrongQuestionEntity>(entityName: ArithmeticModelEntities.wrongQuestion)
    }
    
    // Convert to Question model
    func toQuestion() -> Question? {
        let numbersArray = numbers.split(separator: ",").compactMap { Int(String($0)) }
        let operationsArray = operations.split(separator: ",").compactMap { Question.Operation(rawValue: String($0)) }
        
        if numbersArray.count == 2 && operationsArray.count == 1 {
            return Question(number1: numbersArray[0], number2: numbersArray[1], operation: operationsArray[0])
        } else if numbersArray.count == 3 && operationsArray.count == 2 {
            return Question(number1: numbersArray[0], number2: numbersArray[1], number3: numbersArray[2],
                           operation1: operationsArray[0], operation2: operationsArray[1])
        }
        
        return nil
    }
}
