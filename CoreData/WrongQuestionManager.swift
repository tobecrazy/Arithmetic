import Foundation
import CoreData

class WrongQuestionManager {
    // MARK: - Constants
    private enum Constants {
        static let masteryCorrectRate = 0.7
        static let masteryMinAttempts = 3
        static let autoRemovalAttempts = 3
    }

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    // Add a wrong question to the collection
    func addWrongQuestion(_ question: Question, for level: DifficultyLevel) {
        // Generate unique combination key
        let combinationKey = getCombinationKey(for: question)
        
        // Check if the question already exists
        let fetchRequest: NSFetchRequest<WrongQuestionEntity> = WrongQuestionEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "combinationKey == %@", combinationKey)
        
        do {
            let existingQuestions = try context.fetch(fetchRequest)
            
            if existingQuestions.isEmpty {
                // Question doesn't exist, create a new one
                let newWrongQuestion = WrongQuestionEntity(context: context)
                newWrongQuestion.id = UUID()
                newWrongQuestion.questionText = question.questionText
                newWrongQuestion.correctAnswer = Int32(question.correctAnswer)
                newWrongQuestion.level = level.rawValue
                newWrongQuestion.numbers = question.numbers.map { String($0) }.joined(separator: ",")
                newWrongQuestion.operations = question.operations.map { $0.rawValue }.joined(separator: ",")
                newWrongQuestion.combinationKey = combinationKey
                newWrongQuestion.createdAt = Date()
                newWrongQuestion.timesShown = 1
                newWrongQuestion.timesWrong = 1
                newWrongQuestion.lastShownAt = Date()  // Set lastShownAt to current date

                // 保存解析方法和步骤
                newWrongQuestion.solutionMethod = question.getSolutionMethod(for: level).rawValue
                newWrongQuestion.solutionSteps = question.getSolutionSteps(for: level)

                // Save fraction answer if applicable
                newWrongQuestion.answerType = question.answerType.rawValue
                if let fractionAnswer = question.fractionAnswer {
                    newWrongQuestion.fractionNumerator = Int32(fractionAnswer.numerator)
                    newWrongQuestion.fractionDenominator = Int32(fractionAnswer.denominator)
                }

                // Save fraction operands if applicable
                if let fractionOps = question.fractionOperands {
                    newWrongQuestion.fractionOperands = serializeFractionOperands(fractionOps)
                }

                print("Adding new wrong question: \(question.questionText), key: \(combinationKey)")
                saveContext()
            } else {
                // Question exists, update statistics
                if let existingQuestion = existingQuestions.first {
                    // Only increment timesWrong, not timesShown
                    // timesShown will be incremented when the question is actually shown to the user
                    existingQuestion.timesWrong += 1
                    existingQuestion.lastShownAt = Date()
                    
                    print("Updating existing wrong question: \(question.questionText), key: \(combinationKey)")
                    saveContext()
                }
            }
        } catch {
            print("Error adding wrong question: \(error)")
        }
    }
    
    // Check if a question is in the wrong questions collection
    func isWrongQuestion(_ question: Question) -> Bool {
        let combinationKey = getCombinationKey(for: question)
        let fetchRequest: NSFetchRequest<WrongQuestionEntity> = WrongQuestionEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "combinationKey == %@", combinationKey)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking wrong question: \(error)")
            return false
        }
    }
    
    // Update statistics for a wrong question
    func updateWrongQuestion(_ question: Question, answeredCorrectly: Bool?) {
        let combinationKey = getCombinationKey(for: question)
        let fetchRequest: NSFetchRequest<WrongQuestionEntity> = WrongQuestionEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "combinationKey == %@", combinationKey)
        
        do {
            let questions = try context.fetch(fetchRequest)
            if let existingQuestion = questions.first {
                existingQuestion.timesShown += 1
                existingQuestion.lastShownAt = Date()
                
                // Only update timesWrong if answeredCorrectly is not nil
                if let answeredCorrectly = answeredCorrectly {
                    if !answeredCorrectly {
                        existingQuestion.timesWrong += 1
                    }

                    // If answered correctly multiple times, consider removing from wrong questions
                    if answeredCorrectly && existingQuestion.timesShown > Constants.autoRemovalAttempts {
                        let correctRate = Double(existingQuestion.timesShown - existingQuestion.timesWrong) / Double(existingQuestion.timesShown)
                        if correctRate >= Constants.masteryCorrectRate {
                            context.delete(existingQuestion)
                        }
                    }
                }
                
                saveContext()
            }
        } catch {
            print("Error updating wrong question: \(error)")
        }
    }
    
    // Get wrong questions for a specific difficulty level
    func getWrongQuestionsForLevel(_ level: DifficultyLevel, limit: Int) -> [Question] {
        let fetchRequest: NSFetchRequest<WrongQuestionEntity> = WrongQuestionEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "level == %@", level.rawValue)
        
        do {
            let wrongQuestions = try context.fetch(fetchRequest)
            
            // Sort by wrong count and last shown date
            let sortedQuestions = wrongQuestions.sorted { q1, q2 in
                // Prioritize questions with more wrong answers
                if q1.timesWrong != q2.timesWrong {
                    return q1.timesWrong > q2.timesWrong
                }
                
                // For questions with the same wrong count, prioritize those not shown recently
                if let lastShown1 = q1.lastShownAt, let lastShown2 = q2.lastShownAt {
                    return lastShown1 < lastShown2
                } else if q1.lastShownAt == nil {
                    return true
                } else {
                    return false
                }
            }
            
            // Convert to Question models and limit the count
            return sortedQuestions.prefix(limit).compactMap { $0.toQuestion() }
        } catch {
            print("Error fetching wrong questions: \(error)")
            return []
        }
    }
    
    // Delete a specific wrong question
    func deleteWrongQuestion(with id: UUID) {
        let fetchRequest: NSFetchRequest<WrongQuestionEntity> = WrongQuestionEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let questions = try context.fetch(fetchRequest)
            if let question = questions.first {
                context.delete(question)
                saveContext()
            }
        } catch {
            print("Error deleting wrong question: \(error)")
        }
    }
    
    // Delete all wrong questions for a specific level
    func deleteWrongQuestions(for level: DifficultyLevel? = nil) {
        let fetchRequest: NSFetchRequest<WrongQuestionEntity> = WrongQuestionEntity.fetchRequest()
        
        if let level = level {
            fetchRequest.predicate = NSPredicate(format: "level == %@", level.rawValue)
        }
        
        do {
            let questions = try context.fetch(fetchRequest)
            for question in questions {
                context.delete(question)
            }
            saveContext()
        } catch {
            print("Error batch deleting wrong questions: \(error)")
        }
    }
    
    // Delete mastered questions (those with high correct rate)
    func deleteMasteredQuestions(correctRateThreshold: Double = Constants.masteryCorrectRate, minAttempts: Int = Constants.masteryMinAttempts) {
        let fetchRequest: NSFetchRequest<WrongQuestionEntity> = WrongQuestionEntity.fetchRequest()

        do {
            let questions = try context.fetch(fetchRequest)
            for question in questions {
                // Calculate correct rate
                let totalAttempts = Int(question.timesShown)
                let wrongAttempts = Int(question.timesWrong)
                let correctAttempts = totalAttempts - wrongAttempts

                // If attempts are enough and correct rate is high, delete the question
                if totalAttempts >= minAttempts {
                    let correctRate = Double(correctAttempts) / Double(totalAttempts)
                    if correctRate >= correctRateThreshold {
                        context.delete(question)
                    }
                }
            }
            saveContext()
        } catch {
            print("Error deleting mastered questions: \(error)")
        }
    }
    
    // Get wrong question statistics
    func getWrongQuestionStats(for level: DifficultyLevel? = nil) -> (total: Int, byLevel: [DifficultyLevel: Int]) {
        var totalCount = 0
        var countByLevel: [DifficultyLevel: Int] = [:]
        
        for level in DifficultyLevel.allCases {
            let fetchRequest: NSFetchRequest<WrongQuestionEntity> = WrongQuestionEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "level == %@", level.rawValue)
            
            do {
                let count = try context.count(for: fetchRequest)
                countByLevel[level] = count
                totalCount += count
            } catch {
                print("Error counting wrong questions: \(error)")
            }
        }
        
        return (totalCount, countByLevel)
    }
    
    // Helper method: Generate a unique combination key for a question
    private func getCombinationKey(for question: Question) -> String {
        // Include fraction operands in the combination key to ensure uniqueness
        if let fractionOps = question.fractionOperands, fractionOps.contains(where: { $0 != nil }) {
            var parts: [String] = []
            for (i, num) in question.numbers.enumerated() {
                if let frac = fractionOps[i] {
                    parts.append("\(frac.numerator)/\(frac.denominator)")
                } else {
                    parts.append("\(num)")
                }
            }
            if parts.count == 2 {
                return "\(parts[0])\(question.operations[0].rawValue)\(parts[1])"
            } else {
                return "\(parts[0])\(question.operations[0].rawValue)\(parts[1])\(question.operations[1].rawValue)\(parts[2])"
            }
        }

        // Standard integer-only questions
        if question.numbers.count == 2 {
            return "\(question.numbers[0])\(question.operations[0].rawValue)\(question.numbers[1])"
        } else {
            return "\(question.numbers[0])\(question.operations[0].rawValue)\(question.numbers[1])\(question.operations[1].rawValue)\(question.numbers[2])"
        }
    }

    // Helper method: Serialize fraction operands to string
    // Format: "1/2,nil,3/4" where "nil" represents integer operands
    private func serializeFractionOperands(_ fractionOps: [Fraction?]) -> String {
        return fractionOps.map { frac in
            if let f = frac {
                return "\(f.numerator)/\(f.denominator)"
            } else {
                return "nil"
            }
        }.joined(separator: ",")
    }
    
    // Save context
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
