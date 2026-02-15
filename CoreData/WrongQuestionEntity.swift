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
    // Fraction support (optional for backward compatibility)
    @NSManaged public var answerType: String?
    @NSManaged public var fractionNumerator: Int32
    @NSManaged public var fractionDenominator: Int32
    // Fraction operands support (stores operand fractions like "1/2,nil,3/4" for questions like "1/2 + 3 + 3/4")
    @NSManaged public var fractionOperands: String?
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
        let difficultyLevel = DifficultyLevel(rawValue: level)

        // Parse fraction operands if present
        let fractionOperandsArray: [Fraction?]? = parseFractionOperands()

        // Check if we have fraction operands
        if let fractionOps = fractionOperandsArray, fractionOps.contains(where: { $0 != nil }) {
            // Use fraction-aware initializers
            if numbersArray.count == 2 && operationsArray.count == 1 {
                let operand1: Any = fractionOps[0] ?? numbersArray[0]
                let operand2: Any = fractionOps[1] ?? numbersArray[1]
                return Question(operand1: operand1, operand2: operand2,
                              operation: operationsArray[0], difficultyLevel: difficultyLevel)
            } else if numbersArray.count == 3 && operationsArray.count == 2 {
                let operand1: Any = fractionOps[0] ?? numbersArray[0]
                let operand2: Any = fractionOps[1] ?? numbersArray[1]
                let operand3: Any = fractionOps[2] ?? numbersArray[2]
                return Question(operand1: operand1, operand2: operand2, operand3: operand3,
                              operation1: operationsArray[0], operation2: operationsArray[1],
                              difficultyLevel: difficultyLevel)
            }
        }

        // Standard integer-only questions
        if numbersArray.count == 2 && operationsArray.count == 1 {
            return Question(number1: numbersArray[0], number2: numbersArray[1],
                          operation: operationsArray[0], difficultyLevel: difficultyLevel)
        } else if numbersArray.count == 3 && operationsArray.count == 2 {
            return Question(number1: numbersArray[0], number2: numbersArray[1], number3: numbersArray[2],
                          operation1: operationsArray[0], operation2: operationsArray[1],
                          difficultyLevel: difficultyLevel)
        }

        return nil
    }

    // Parse fraction operands string into array of optional Fractions
    // Format: "1/2,nil,3/4" or "nil,nil" for all-integer questions
    private func parseFractionOperands() -> [Fraction?]? {
        guard let fractionOpsString = fractionOperands, !fractionOpsString.isEmpty else {
            return nil
        }

        let components = fractionOpsString.split(separator: ",", omittingEmptySubsequences: false).map { String($0) }
        var result: [Fraction?] = []

        for component in components {
            let trimmed = component.trimmingCharacters(in: .whitespaces)
            if trimmed == "nil" || trimmed.isEmpty {
                result.append(nil)
            } else if let fraction = Fraction.from(string: trimmed) {
                result.append(fraction)
            } else {
                result.append(nil)
            }
        }

        return result.isEmpty ? nil : result
    }
}
