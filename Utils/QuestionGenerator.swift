import Foundation

class QuestionGenerator {
    static func generateQuestions(difficultyLevel: DifficultyLevel, count: Int) -> [Question] {
        var questions: [Question] = []
        var generatedCombinations: Set<String> = []
        
        while questions.count < count {
            let newQuestion: Question
            let combination: String
            
            // 等级2及以上有概率生成三数运算题目
            if difficultyLevel != .level1 && Double.random(in: 0...1) < getThreeNumberProbability(difficultyLevel) {
                newQuestion = generateThreeNumberQuestion(in: difficultyLevel.range)
                combination = "\(newQuestion.numbers[0])\(newQuestion.operations[0].rawValue)\(newQuestion.numbers[1])\(newQuestion.operations[1].rawValue)\(newQuestion.numbers[2])"
            } else {
                newQuestion = generateTwoNumberQuestion(in: difficultyLevel.range)
                combination = "\(newQuestion.numbers[0])\(newQuestion.operations[0].rawValue)\(newQuestion.numbers[1])"
            }
            
            if !generatedCombinations.contains(combination) {
                questions.append(newQuestion)
                generatedCombinations.insert(combination)
            }
        }
        
        return questions
    }
    
    // 根据难度等级获取生成三数运算题目的概率
    private static func getThreeNumberProbability(_ difficultyLevel: DifficultyLevel) -> Double {
        switch difficultyLevel {
        case .level1: return 0.0   // 等级1不生成三数运算
        case .level2: return 0.4   // 等级2有40%概率生成三数运算
        case .level3: return 0.6   // 等级3有60%概率生成三数运算
        case .level4: return 0.8   // 等级4有80%概率生成三数运算
        }
    }
    
    // 生成两数运算题目
    private static func generateTwoNumberQuestion(in range: ClosedRange<Int>) -> Question {
        // 根据范围确定当前难度等级
        let difficultyFactor: Double
        switch range.upperBound {
        case 10: difficultyFactor = 0.0  // 等级1
        case 20: difficultyFactor = 0.30 // 等级2
        case 50: difficultyFactor = 0.60  // 等级3
        case 100: difficultyFactor = 0.80 // 等级4
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
            
            // 难度越高，两个数字差值越小（越难计算）
            let minSubtractor = max(1, Int(Double(number1) * (0.3 + difficultyFactor * 0.4)))
            number2 = Int.random(in: minSubtractor...number1)
        }
        
        return Question(number1: number1, number2: number2, operation: operation)
    }
    
    // 生成三数运算题目
    private static func generateThreeNumberQuestion(in range: ClosedRange<Int>) -> Question {
        // 根据范围确定当前难度等级
        let difficultyFactor: Double
        switch range.upperBound {
        case 20: difficultyFactor = 0.25 // 等级2
        case 50: difficultyFactor = 0.5  // 等级3
        case 100: difficultyFactor = 0.75 // 等级4
        default: difficultyFactor = 0.25
        }
        
        // 获取当前难度等级的上限
        let upperBound = range.upperBound
        
        // 根据难度因子调整数字范围
        let lowerBoundAdjusted = Int(Double(range.lowerBound) + Double(upperBound - range.lowerBound) * difficultyFactor * 0.3)
        
        // 生成三个数字，确保它们不会太大，以便运算过程中不超过上限
        // 对于加法，每个数字最大不超过上限的一半
        let maxNumberForAddition = upperBound / 2
        
        var number1 = Int.random(in: lowerBoundAdjusted...min(maxNumberForAddition, range.upperBound))
        var number2 = Int.random(in: lowerBoundAdjusted...min(maxNumberForAddition, range.upperBound))
        var number3 = Int.random(in: lowerBoundAdjusted...min(maxNumberForAddition, range.upperBound))
        
        // 生成两个操作
        var operation1: Question.Operation
        var operation2: Question.Operation
        
        // 随机决定操作类型
        operation1 = Double.random(in: 0...1) < 0.5 ? .addition : .subtraction
        operation2 = Double.random(in: 0...1) < 0.5 ? .addition : .subtraction
        
        // 计算中间结果
        var intermediateResult = operation1 == .addition ? number1 + number2 : number1 - number2
        
        // 如果中间结果为负数，调整第一个操作或数字
        if intermediateResult < 0 {
            // 将第一个操作改为加法，或者交换number1和number2
            if operation1 == .subtraction {
                if Double.random(in: 0...1) < 0.5 {
                    operation1 = .addition
                    intermediateResult = number1 + number2
                } else {
                    // 交换number1和number2，确保number1 > number2
                    let temp = number1
                    number1 = number2
                    number2 = temp
                    intermediateResult = number1 - number2
                }
            }
        }
        
        // 确保中间结果不超过上限
        if intermediateResult > upperBound {
            // 如果是加法导致超过上限，改为减法
            if operation1 == .addition {
                operation1 = .subtraction
                // 确保number1 > number2，避免负数结果
                if number1 < number2 {
                    let temp = number1
                    number1 = number2
                    number2 = temp
                }
                intermediateResult = number1 - number2
            } else {
                // 如果是减法但仍然超过上限（不太可能），减小number1
                number1 = Int.random(in: lowerBoundAdjusted...min(upperBound, range.upperBound))
                // 确保number1 > number2，避免负数结果
                number2 = Int.random(in: lowerBoundAdjusted...min(number1 - 1, range.upperBound))
                intermediateResult = number1 - number2
            }
        }
        
        // 计算最终结果
        var finalResult = operation2 == .addition ? intermediateResult + number3 : intermediateResult - number3
        
        // 确保最终结果不为负数且不超过上限
        if finalResult < 0 || finalResult > upperBound {
            if operation2 == .addition && finalResult > upperBound {
                // 如果加法导致超过上限，改为减法
                operation2 = .subtraction
                // 确保中间结果 > number3，避免负数结果
                if intermediateResult < number3 {
                    number3 = Int.random(in: 1..<intermediateResult)
                }
                finalResult = intermediateResult - number3
            } else if operation2 == .subtraction && finalResult < 0 {
                // 如果减法导致负数结果，改为加法或减小number3
                if Double.random(in: 0...1) < 0.5 {
                    operation2 = .addition
                    // 确保加法结果不超过上限
                    if intermediateResult + number3 > upperBound {
                        number3 = Int.random(in: 1...(upperBound - intermediateResult))
                    }
                    finalResult = intermediateResult + number3
                } else {
                    number3 = Int.random(in: 1..<intermediateResult)
                    finalResult = intermediateResult - number3
                }
            }
        }
        
        return Question(number1: number1, number2: number2, number3: number3, operation1: operation1, operation2: operation2)
    }
}
