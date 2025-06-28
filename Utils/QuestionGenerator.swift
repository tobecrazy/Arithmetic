import Foundation

class QuestionGenerator {
    static func generateQuestions(difficultyLevel: DifficultyLevel, count: Int, wrongQuestions: [Question] = []) -> [Question] {
        var questions: [Question] = []
        var generatedCombinations: Set<String> = []
        
        // 首先添加错题集中的题目
        for wrongQuestion in wrongQuestions {
            let combination = getCombinationKey(for: wrongQuestion)
            if !generatedCombinations.contains(combination) {
                questions.append(wrongQuestion)
                generatedCombinations.insert(combination)
            }
        }
        
        // 如果错题不足，生成新题目补充
        while questions.count < count {
            let newQuestion: Question
            let combination: String
            
            // 根据难度等级生成相应的题目
            switch difficultyLevel {
            case .level1, .level2, .level3:
                // 加减法等级，可能包含三数运算
                if difficultyLevel != .level1 && Double.random(in: 0...1) < getThreeNumberProbability(difficultyLevel) {
                    newQuestion = generateThreeNumberAdditionSubtractionQuestion(in: difficultyLevel.range)
                } else {
                    newQuestion = generateTwoNumberAdditionSubtractionQuestion(in: difficultyLevel.range)
                }
            case .level4, .level5:
                // 乘除法等级，只生成两数运算
                newQuestion = generateTwoNumberMultiplicationDivisionQuestion(for: difficultyLevel)
            case .level6:
                // 混合运算等级
                if Double.random(in: 0...1) < 0.6 {
                    newQuestion = generateThreeNumberMixedQuestion(in: difficultyLevel.range)
                } else {
                    newQuestion = generateTwoNumberMixedQuestion(in: difficultyLevel.range)
                }
            }
            
            combination = getCombinationKey(for: newQuestion)
            
            if !generatedCombinations.contains(combination) {
                questions.append(newQuestion)
                generatedCombinations.insert(combination)
            }
        }
        
        // 如果错题数量超过需要的题目数量，随机选择一部分
        if questions.count > count {
            questions = Array(questions.shuffled().prefix(count))
        }
        
        // 打乱题目顺序
        return questions.shuffled()
    }
    
    // 生成题目的唯一标识键
    static func getCombinationKey(for question: Question) -> String {
        if question.numbers.count == 2 {
            return "\(question.numbers[0])\(question.operations[0].rawValue)\(question.numbers[1])"
        } else {
            return "\(question.numbers[0])\(question.operations[0].rawValue)\(question.numbers[1])\(question.operations[1].rawValue)\(question.numbers[2])"
        }
    }
    
    // 根据难度等级获取生成三数运算题目的概率
    private static func getThreeNumberProbability(_ difficultyLevel: DifficultyLevel) -> Double {
        switch difficultyLevel {
        case .level1: return 0.0   // 等级1不生成三数运算
        case .level2: return 0.4   // 等级2有40%概率生成三数运算
        case .level3: return 0.6   // 等级3有60%概率生成三数运算
        case .level6: return 0.6   // 等级6有60%概率生成三数运算
        default: return 0.0
        }
    }
    
    // MARK: - 加减法题目生成
    
    // 生成两数加减法题目
    private static func generateTwoNumberAdditionSubtractionQuestion(in range: ClosedRange<Int>) -> Question {
        let difficultyFactor: Double
        let isLevel2OrAbove: Bool
        
        switch range.upperBound {
        case 10: 
            difficultyFactor = 0.0
            isLevel2OrAbove = false
        case 20: 
            difficultyFactor = 0.30
            isLevel2OrAbove = true
        case 50: 
            difficultyFactor = 0.60
            isLevel2OrAbove = true
        default: 
            difficultyFactor = 0.0
            isLevel2OrAbove = false
        }
        
        let operation: Question.Operation = Double.random(in: 0...1) < (0.4 + difficultyFactor * 0.2) ? .subtraction : .addition
        
        var number1: Int
        var number2: Int
        
        let lowerBoundAdjusted = Int(Double(range.lowerBound) + Double(range.upperBound - range.lowerBound) * difficultyFactor * 0.5)
        let minNumber = isLevel2OrAbove ? max(2, lowerBoundAdjusted) : lowerBoundAdjusted
        
        let maxAttempts = 10
        var attempts = 0
        
        repeat {
            switch operation {
            case .addition:
                if isLevel2OrAbove {
                    number1 = Int.random(in: minNumber...range.upperBound)
                    let minSecondNumber = max(1, 11 - number1)
                    let maxSecondNumber = range.upperBound - number1 > 0 ? range.upperBound - number1 : 1
                    
                    if minSecondNumber <= maxSecondNumber {
                        number2 = Int.random(in: minSecondNumber...maxSecondNumber)
                    } else {
                        number1 = max(1, range.upperBound - 9)
                        number2 = Int.random(in: max(1, 11 - number1)...range.upperBound)
                    }
                } else {
                    number1 = Int.random(in: minNumber...range.upperBound)
                    number2 = Int.random(in: minNumber...range.upperBound)
                    
                    if number1 + number2 > range.upperBound {
                        number2 = range.upperBound - number1
                    }
                }
                
            case .subtraction:
                if isLevel2OrAbove {
                    number1 = Int.random(in: max(10, minNumber)...range.upperBound)
                    let maxSubtractor = number1 - 1
                    number2 = Int.random(in: max(1, minNumber)...maxSubtractor)
                    
                    if number1 == number2 {
                        number2 = max(1, number2 - 1)
                    }
                } else {
                    number1 = Int.random(in: minNumber...range.upperBound)
                    let minSubtractor = max(1, Int(Double(number1) * (0.3 + difficultyFactor * 0.4)))
                    number2 = min(number1 - 1, Int.random(in: minSubtractor...number1))
                    
                    if number1 == number2 && number1 > minSubtractor {
                        number2 = number1 - 1
                    }
                }
                
            default:
                number1 = Int.random(in: minNumber...range.upperBound)
                number2 = Int.random(in: minNumber...range.upperBound)
            }
            
            attempts += 1
        } while (number1 == 0 || number2 == 0 || (operation == .subtraction && number1 - number2 == 0)) && attempts < maxAttempts
        
        // 最后的安全检查
        if number1 == 0 || number2 == 0 || (operation == .subtraction && number1 - number2 == 0) {
            if operation == .addition {
                number1 = max(5, number1)
                number2 = max(6, number2)
            } else {
                number1 = max(10, number1)
                number2 = max(1, min(number1 - 1, number2))
            }
        }
        
        return Question(number1: number1, number2: number2, operation: operation)
    }
    
    // 生成三数加减法题目
    private static func generateThreeNumberAdditionSubtractionQuestion(in range: ClosedRange<Int>) -> Question {
        let difficultyFactor: Double
        switch range.upperBound {
        case 20: difficultyFactor = 0.25
        case 50: difficultyFactor = 0.5
        default: difficultyFactor = 0.25
        }
        
        let upperBound = range.upperBound
        let lowerBoundAdjusted = Int(Double(range.lowerBound) + Double(upperBound - range.lowerBound) * difficultyFactor * 0.3)
        let minNumber = max(2, lowerBoundAdjusted)
        let maxNumberForAddition = upperBound / 2
        
        var number1 = Int.random(in: minNumber...min(maxNumberForAddition, range.upperBound))
        var number2 = Int.random(in: minNumber...min(maxNumberForAddition, range.upperBound))
        var number3 = Int.random(in: minNumber...min(maxNumberForAddition, range.upperBound))
        
        var operation1: Question.Operation = Double.random(in: 0...1) < 0.5 ? .addition : .subtraction
        var operation2: Question.Operation = Double.random(in: 0...1) < 0.5 ? .addition : .subtraction
        
        let maxAttempts = 10
        var attempts = 0
        
        repeat {
            // 确保第一个操作不会产生负数或超出范围
            if operation1 == .subtraction && number1 <= number2 {
                if Double.random(in: 0...1) < 0.5 {
                    operation1 = .addition
                } else {
                    let temp = number1
                    number1 = number2
                    number2 = temp
                }
            }
            
            // 计算中间结果
            let intermediateResult = operation1 == .addition ? number1 + number2 : number1 - number2
            
            // 确保中间结果在合理范围内
            if intermediateResult <= 0 || intermediateResult > upperBound {
                if intermediateResult <= 0 {
                    operation1 = .addition
                } else {
                    number1 = Int.random(in: minNumber...min(upperBound / 2, range.upperBound))
                    number2 = Int.random(in: minNumber...min(number1, range.upperBound))
                }
                continue
            }
            
            // 确保第二个操作不会产生负数或超出范围
            if operation2 == .subtraction && intermediateResult <= number3 {
                if Double.random(in: 0...1) < 0.5 {
                    operation2 = .addition
                } else {
                    number3 = Int.random(in: minNumber...min(intermediateResult - 1, range.upperBound))
                }
            }
            
            // 计算最终结果
            let finalResult = operation2 == .addition ? intermediateResult + number3 : intermediateResult - number3
            
            // 检查最终结果是否在范围内且不为0
            if finalResult > 0 && finalResult <= upperBound {
                break
            }
            
            attempts += 1
        } while attempts < maxAttempts
        
        return Question(number1: number1, number2: number2, number3: number3, operation1: operation1, operation2: operation2)
    }
    
    // MARK: - 乘除法题目生成
    
    // 生成两数乘除法题目
    private static func generateTwoNumberMultiplicationDivisionQuestion(for level: DifficultyLevel) -> Question {
        let operation: Question.Operation = Double.random(in: 0...1) < 0.6 ? .multiplication : .division
        
        switch operation {
        case .multiplication:
            return generateMultiplicationQuestion(for: level)
        case .division:
            return generateDivisionQuestion(for: level)
        default:
            return generateMultiplicationQuestion(for: level)
        }
    }
    
    // 生成乘法题目
    private static func generateMultiplicationQuestion(for level: DifficultyLevel) -> Question {
        var number1: Int
        var number2: Int
        
        switch level {
        case .level4:
            // 10以内乘法，避免过多×1
            let multiplicationPairs = generateLevel4MultiplicationPairs()
            let selectedPair = multiplicationPairs.randomElement()!
            number1 = selectedPair.0
            number2 = selectedPair.1
            
        case .level5:
            // 20以内乘法，避免过多×1
            let multiplicationPairs = generateLevel5MultiplicationPairs()
            let selectedPair = multiplicationPairs.randomElement()!
            number1 = selectedPair.0
            number2 = selectedPair.1
            
        default:
            // 其他等级的乘法
            number1 = Int.random(in: 2...9)
            number2 = Int.random(in: 2...9)
        }
        
        return Question(number1: number1, number2: number2, operation: .multiplication)
    }
    
    // 生成除法题目
    private static func generateDivisionQuestion(for level: DifficultyLevel) -> Question {
        let validDivisions: [(Int, Int)]
        
        switch level {
        case .level4:
            validDivisions = generateLevel4DivisionPairs()
        case .level5:
            validDivisions = generateLevel5DivisionPairs()
        default:
            validDivisions = generateLevel4DivisionPairs()
        }
        
        let selectedPair = validDivisions.randomElement()!
        return Question(number1: selectedPair.0, number2: selectedPair.1, operation: .division)
    }
    
    // Level 4 (10以内) 乘法组合
    private static func generateLevel4MultiplicationPairs() -> [(Int, Int)] {
        var pairs: [(Int, Int)] = []
        
        // 核心乘法表，避免过多×1
        let weightedPairs: [(Int, Int, Int)] = [
            // (number1, number2, weight)
            (2, 2, 3), (2, 3, 3), (2, 4, 3), (2, 5, 3),
            (3, 2, 3), (3, 3, 3), (3, 4, 2), (3, 5, 2),
            (4, 2, 3), (4, 3, 2), (5, 2, 3), (5, 3, 2),
            (2, 6, 2), (2, 7, 2), (2, 8, 2), (2, 9, 2),
            (3, 6, 2), (4, 4, 2), (5, 4, 1),
            // 少量×1题目
            (1, 2, 1), (1, 3, 1), (2, 1, 1), (3, 1, 1)
        ]
        
        for (num1, num2, weight) in weightedPairs {
            for _ in 0..<weight {
                pairs.append((num1, num2))
            }
        }
        
        return pairs
    }
    
    // Level 5 (20以内) 乘法组合
    private static func generateLevel5MultiplicationPairs() -> [(Int, Int)] {
        var pairs: [(Int, Int)] = []
        
        let weightedPairs: [(Int, Int, Int)] = [
            // 基础乘法表
            (2, 6, 2), (2, 7, 2), (2, 8, 2), (2, 9, 2), (2, 10, 2),
            (3, 4, 2), (3, 5, 2), (3, 6, 2), (3, 7, 1),
            (4, 3, 2), (4, 4, 2), (4, 5, 1),
            (5, 3, 2), (5, 4, 1),
            // 进阶组合
            (6, 2, 2), (6, 3, 1), (7, 2, 2), (8, 2, 2), (9, 2, 2), (10, 2, 2),
            // 极少量×1
            (1, 11, 1), (1, 12, 1), (11, 1, 1), (12, 1, 1)
        ]
        
        for (num1, num2, weight) in weightedPairs {
            for _ in 0..<weight {
                pairs.append((num1, num2))
            }
        }
        
        return pairs
    }
    
    // Level 4 (10以内) 除法组合 - 确保整除
    private static func generateLevel4DivisionPairs() -> [(Int, Int)] {
        return [
            (4, 2), (6, 2), (8, 2), (10, 2),
            (6, 3), (9, 3), (12, 3), (15, 3), (18, 3),
            (8, 4), (12, 4), (16, 4), (20, 4),
            (10, 5), (15, 5), (20, 5),
            (12, 6), (18, 6),
            (14, 7), (21, 7),
            (16, 8), (24, 8),
            (18, 9), (27, 9)
        ].filter { $0.0 <= 20 && $0.1 <= 10 } // 确保在范围内
    }
    
    // Level 5 (20以内) 除法组合 - 确保整除
    private static func generateLevel5DivisionPairs() -> [(Int, Int)] {
        return [
            // 基础除法
            (4, 2), (6, 2), (8, 2), (10, 2), (12, 2), (14, 2), (16, 2), (18, 2), (20, 2),
            (6, 3), (9, 3), (12, 3), (15, 3), (18, 3),
            (8, 4), (12, 4), (16, 4), (20, 4),
            (10, 5), (15, 5), (20, 5),
            (12, 6), (18, 6),
            (14, 7),
            (16, 8),
            (18, 9),
            (20, 10)
        ]
    }
    
    // MARK: - 混合运算题目生成
    
    // 生成两数混合运算题目
    private static func generateTwoNumberMixedQuestion(in range: ClosedRange<Int>) -> Question {
        let operations = Question.Operation.allCases
        let operation = operations.randomElement()!
        
        switch operation {
        case .addition, .subtraction:
            return generateTwoNumberAdditionSubtractionQuestion(in: range)
        case .multiplication:
            return generateMultiplicationQuestion(for: .level6)
        case .division:
            return generateDivisionQuestion(for: .level6)
        }
    }
    
    // 生成三数混合运算题目
    private static func generateThreeNumberMixedQuestion(in range: ClosedRange<Int>) -> Question {
        // 为了简化，三数混合运算主要使用加减法
        return generateThreeNumberAdditionSubtractionQuestion(in: range)
    }
}
