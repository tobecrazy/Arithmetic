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
        // 根据范围确定当前难度等级
        let difficultyFactor: Double
        switch range.upperBound {
        case 10: difficultyFactor = 0.0  // 等级1
        case 20: difficultyFactor = 0.25 // 等级2
        case 50: difficultyFactor = 0.5  // 等级3
        case 100: difficultyFactor = 0.75 // 等级4
        default: difficultyFactor = 0.0
        }
        
        // 根据难度因子决定操作类型
        // 难度越高，减法的概率越大
        let operations = Question.Operation.allCases
        let operation: Question.Operation
        if Double.random(in: 0...1) < (0.4 + difficultyFactor * 0.2) {
            operation = .subtraction // 随着难度增加，减法概率从40%增加到55%
        } else {
            operation = .addition
        }
        
        var number1: Int
        var number2: Int
        
        // 根据难度因子调整数字范围
        // 难度越高，数字越倾向于使用范围上限
        let lowerBoundAdjusted = Int(Double(range.lowerBound) + Double(range.upperBound - range.lowerBound) * difficultyFactor * 0.5)
        
        switch operation {
        case .addition:
            // 难度越高，数字越大
            number1 = Int.random(in: lowerBoundAdjusted...range.upperBound)
            number2 = Int.random(in: lowerBoundAdjusted...range.upperBound)
            
            // 确保结果不超过范围上限
            if number1 + number2 > range.upperBound {
                number2 = range.upperBound - number1
            }
            
        case .subtraction:
            // 确保结果为正数
            number1 = Int.random(in: lowerBoundAdjusted...range.upperBound)
            
            // 难度越高，两个数字越接近（差值越小，越难计算）
            let minSubtractor = max(1, Int(Double(number1) * (0.3 + difficultyFactor * 0.4)))
            number2 = Int.random(in: minSubtractor...number1)
        }
        
        return Question(number1: number1, number2: number2, operation: operation)
    }
}
