import Foundation

class QuestionGenerator {
    static func generateQuestions(difficultyLevel: DifficultyLevel, count: Int) -> [Question] {
        var questions: [Question] = []
        var generatedCombinations: Set<String> = []
        
        while questions.count < count {
            let newQuestion = generateRandomQuestion(in: difficultyLevel.range)
            let combination = "\(newQuestion.number1)\(newQuestion.operation.rawValue)\(newQuestion.number2)"
            
            if !generatedCombinations.contains(combination) {
                questions.append(newQuestion)
                generatedCombinations.insert(combination)
            }
        }
        
        return questions
    }
    
    private static func generateRandomQuestion(in range: ClosedRange<Int>) -> Question {
        let operations = Question.Operation.allCases
        let operation = operations.randomElement()!
        
        var number1: Int
        var number2: Int
        
        switch operation {
        case .addition:
            number1 = Int.random(in: range)
            number2 = Int.random(in: range)
            // 确保结果不超过范围上限
            if number1 + number2 > range.upperBound {
                number2 = range.upperBound - number1
            }
            
        case .subtraction:
            // 确保结果为正数
            number1 = Int.random(in: range)
            number2 = Int.random(in: 1...number1)
        }
        
        return Question(number1: number1, number2: number2, operation: operation)
    }
}
