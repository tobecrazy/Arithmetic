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
        let isLevel2OrAbove: Bool
        switch range.upperBound {
        case 10: 
            difficultyFactor = 0.0  // 等级1
            isLevel2OrAbove = false
        case 20: 
            difficultyFactor = 0.30 // 等级2
            isLevel2OrAbove = true
        case 50: 
            difficultyFactor = 0.60  // 等级3
            isLevel2OrAbove = true
        case 100: 
            difficultyFactor = 0.80 // 等级4
            isLevel2OrAbove = true
        default: 
            difficultyFactor = 0.0
            isLevel2OrAbove = false
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
        var result: Int
        
        // 根据难度因子调整数字范围
        // 难度越高，数字越倾向于使用范围上限
        let lowerBoundAdjusted = Int(Double(range.lowerBound) + Double(range.upperBound - range.lowerBound) * difficultyFactor * 0.5)
        
        // 确保从等级2开始，不出现简单的算术题
        let minNumber = isLevel2OrAbove ? max(2, lowerBoundAdjusted) : lowerBoundAdjusted
        
        // 尝试生成符合条件的题目
        let maxAttempts = 5 // 增加尝试次数以满足更严格的条件
        var attempts = 0
        
        repeat {
            switch operation {
            case .addition:
                // 对于加法，确保总和大于10
                if isLevel2OrAbove {
                    // 确保总和大于10
                    // 先生成第一个数
                    number1 = Int.random(in: minNumber...range.upperBound)
                    
                    // 确保第二个数不为0，且总和大于10
                    let minSecondNumber = max(1, 11 - number1)
                    let maxSecondNumber = range.upperBound - number1 > 0 ? range.upperBound - number1 : 1
                    
                    if minSecondNumber <= maxSecondNumber {
                        number2 = Int.random(in: minSecondNumber...maxSecondNumber)
                    } else {
                        // 如果范围无效，调整第一个数
                        number1 = max(1, range.upperBound - 9)
                        number2 = Int.random(in: max(1, 11 - number1)...range.upperBound)
                    }
                } else {
                    // 等级1的逻辑保持不变
                    number1 = Int.random(in: minNumber...range.upperBound)
                    number2 = Int.random(in: minNumber...range.upperBound)
                    
                    // 确保结果不超过范围上限
                    if number1 + number2 > range.upperBound {
                        number2 = range.upperBound - number1
                    }
                }
                
                result = number1 + number2
                
            case .subtraction:
                if isLevel2OrAbove {
                    // 确保大数大于等于10
                    number1 = Int.random(in: max(10, minNumber)...range.upperBound)
                    
                    // 确保number2不为0且不等于number1
                    let maxSubtractor = number1 - 1
                    number2 = Int.random(in: max(1, minNumber)...maxSubtractor)
                    
                    // 避免两个相同的数相减（虽然这种情况已经被上面的逻辑排除）
                    if number1 == number2 {
                        number2 = max(1, number2 - 1)
                    }
                } else {
                    // 等级1的逻辑
                    number1 = Int.random(in: minNumber...range.upperBound)
                    
                    // 难度越高，两个数字差值越小（越难计算）
                    let minSubtractor = max(1, Int(Double(number1) * (0.3 + difficultyFactor * 0.4)))
                    
                    // 确保number2 <= number1，避免负数结果
                    number2 = min(number1 - 1, Int.random(in: minSubtractor...number1))
                    
                    // 避免number1和number2相等（结果为0）
                    if number1 == number2 && number1 > minSubtractor {
                        number2 = number1 - 1
                    }
                }
                
                result = number1 - number2
            }
            
            attempts += 1
            // 确保没有0作为操作数，且结果不为0
        } while (number1 == 0 || number2 == 0 || result == 0) && attempts < maxAttempts
        
        // 如果尝试多次后仍不满足条件，进行最后的调整
        if number1 == 0 || number2 == 0 || result == 0 {
            if operation == .addition {
                number1 = max(5, number1)
                number2 = max(6, number2)
            } else {
                number1 = max(10, number1)
                number2 = max(1, min(number1 - 1, number2))
            }
            result = operation == .addition ? number1 + number2 : number1 - number2
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
        
        // 确保不出现简单的算术题，最小数字至少为2
        let minNumber = max(2, lowerBoundAdjusted)
        
        // 生成三个数字，确保它们不会太大，以便运算过程中不超过上限
        // 对于加法，每个数字最大不超过上限的一半
        let maxNumberForAddition = upperBound / 2
        
        var number1 = Int.random(in: minNumber...min(maxNumberForAddition, range.upperBound))
        var number2 = Int.random(in: minNumber...min(maxNumberForAddition, range.upperBound))
        var number3 = Int.random(in: minNumber...min(maxNumberForAddition, range.upperBound))
        
        // 生成两个操作
        var operation1: Question.Operation
        var operation2: Question.Operation
        
        // 随机决定操作类型
        operation1 = Double.random(in: 0...1) < 0.5 ? .addition : .subtraction
        operation2 = Double.random(in: 0...1) < 0.5 ? .addition : .subtraction
        
        // 尝试生成符合条件的题目
        let maxAttempts = 5 // 增加尝试次数以满足更严格的条件
        var attempts = 0
        var intermediateResult: Int
        var finalResult: Int
        
        repeat {
            // 对于减法操作，确保被减数大于等于10
            if operation1 == .subtraction {
                number1 = Int.random(in: max(10, minNumber)...range.upperBound)
            }
            
            // 确保没有操作数为0
            number1 = max(number1, minNumber)
            number2 = max(number2, minNumber)
            number3 = max(number3, minNumber)
            
            // 计算中间结果
            intermediateResult = operation1 == .addition ? number1 + number2 : number1 - number2
            
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
                    number1 = Int.random(in: max(10, minNumber)...min(upperBound, range.upperBound))
                    // 确保number1 > number2，避免负数结果
                    number2 = Int.random(in: minNumber...min(number1 - 1, range.upperBound))
                    intermediateResult = number1 - number2
                }
            }
            
            // 避免中间结果为0
            if intermediateResult == 0 {
                // 如果中间结果为0，调整number1或number2
                if operation1 == .addition {
                    // 如果是加法，增加数字使总和大于10
                    number1 = max(6, number1)
                    number2 = max(5, number2)
                } else {
                    // 如果是减法，确保number1 != number2
                    if number1 == number2 {
                        number1 = max(10, number1 + 1)
                    }
                }
                intermediateResult = operation1 == .addition ? number1 + number2 : number1 - number2
            }
            
            // 对于加法，确保总和大于10
            if operation1 == .addition && intermediateResult <= 10 {
                // 调整数字使总和大于10
                number1 = max(6, number1)
                number2 = max(5, number2)
                intermediateResult = number1 + number2
            }
            
            // 对于第二个操作是减法，确保被减数大于等于10
            if operation2 == .subtraction && intermediateResult < 10 {
                // 如果中间结果小于10，改为加法或调整数字
                if Double.random(in: 0...1) < 0.5 {
                    operation2 = .addition
                } else {
                    // 调整前面的数字使中间结果大于等于10
                    if operation1 == .addition {
                        number1 = max(number1, 5)
                        number2 = max(number2, 5)
                        intermediateResult = number1 + number2
                    } else {
                        number1 = max(number1, 10 + number2)
                        intermediateResult = number1 - number2
                    }
                }
            }
            
            // 避免两个相同的数相减
            if operation2 == .subtraction && intermediateResult == number3 {
                // 调整number3，避免两个相同的数相减
                number3 = max(minNumber, number3 - 1)
            }
            
            // 计算最终结果前，确保不会出现负数
            if operation2 == .subtraction && intermediateResult <= number3 {
                // 如果是减法且中间结果小于等于number3，会导致负数结果
                // 改为加法或确保中间结果大于number3
                if Double.random(in: 0...1) < 0.5 {
                    operation2 = .addition
                } else {
                    // 确保number3小于intermediateResult
                    if intermediateResult > 1 {
                        number3 = Int.random(in: minNumber..<intermediateResult)
                    } else {
                        // 如果intermediateResult <= 1，改为加法
                        operation2 = .addition
                    }
                }
            }
            
            // 计算最终结果
            finalResult = operation2 == .addition ? intermediateResult + number3 : intermediateResult - number3
            
            // 确保最终结果不超过上限
            if finalResult > upperBound {
                if operation2 == .addition {
                    // 如果加法导致超过上限，改为减法
                    operation2 = .subtraction
                    // 确保中间结果 > number3，避免负数结果
                    if intermediateResult <= number3 {
                        if intermediateResult > minNumber {
                            number3 = Int.random(in: minNumber..<intermediateResult)
                        } else {
                            // 如果intermediateResult <= minNumber，调整number1和number2
                            number1 += 2
                            intermediateResult = operation1 == .addition ? number1 + number2 : number1 - number2
                            number3 = minNumber
                        }
                    }
                    finalResult = intermediateResult - number3
                } else {
                    // 如果是减法但仍然超过上限（不太可能），减小number1和number2
                    number1 = Int.random(in: max(10, minNumber)...min(upperBound / 2, range.upperBound))
                    number2 = Int.random(in: minNumber...min(number1, range.upperBound))
                    intermediateResult = operation1 == .addition ? number1 + number2 : number1 - number2
                    
                    // 重新计算最终结果
                    if operation2 == .subtraction && intermediateResult <= number3 {
                        if intermediateResult > minNumber {
                            number3 = Int.random(in: minNumber..<intermediateResult)
                        } else {
                            operation2 = .addition
                        }
                    }
                    finalResult = operation2 == .addition ? intermediateResult + number3 : intermediateResult - number3
                }
            }
            
            // 再次检查最终结果是否为负数（以防万一）
            if finalResult < 0 {
                // 如果仍然为负数，强制改为加法
                operation2 = .addition
                finalResult = intermediateResult + number3
            }
            
            // 避免最终结果为0
            if finalResult == 0 {
                // 如果最终结果为0，调整number3
                if operation2 == .addition {
                    // 如果是加法，确保intermediateResult和number3不都为0
                    if intermediateResult == 0 {
                        number3 = Int.random(in: minNumber...min(maxNumberForAddition, range.upperBound))
                    } else {
                        number3 = Int.random(in: minNumber...min(maxNumberForAddition, range.upperBound))
                    }
                } else {
                    // 如果是减法，确保intermediateResult != number3
                    if intermediateResult == number3 {
                        number3 = Int.random(in: minNumber..<intermediateResult)
                    }
                }
                finalResult = operation2 == .addition ? intermediateResult + number3 : intermediateResult - number3
            }
            
            attempts += 1
        } while (number1 == 0 || number2 == 0 || number3 == 0 || finalResult == 0) && attempts < maxAttempts
        
        // 如果尝试多次后仍不满足条件，进行最后的调整
        if number1 == 0 || number2 == 0 || number3 == 0 || finalResult == 0 {
            // 确保所有数字不为0
            number1 = max(5, number1)
            number2 = max(6, number2)
            number3 = max(4, number3)
            
            // 确保减法操作的被减数大于等于10
            if operation1 == .subtraction {
                number1 = max(10, number1)
            }
            if operation2 == .subtraction {
                // 重新计算中间结果
                intermediateResult = operation1 == .addition ? number1 + number2 : number1 - number2
                // 确保中间结果大于等于10
                if intermediateResult < 10 {
                    if operation1 == .addition {
                        number1 = max(5, number1)
                        number2 = max(5, number2)
                    } else {
                        number1 = max(10 + number2, number1)
                    }
                    intermediateResult = operation1 == .addition ? number1 + number2 : number1 - number2
                }
                // 避免两个相同的数相减
                if intermediateResult == number3 {
                    number3 -= 1
                }
            }
        }
        
        // 最终验证：确保使用Question的correctAnswer计算逻辑不会产生负数
        var testResult = number1
        if operation1 == .addition {
            testResult += number2
        } else {
            testResult -= number2
        }
        
        if operation2 == .addition {
            testResult += number3
        } else {
            testResult -= number3
        }
        
        // 如果最终结果为负数，调整操作或数字
        if testResult < 0 {
            // 简单解决方案：将第二个操作改为加法
            operation2 = .addition
            // 重新计算结果确认
            testResult = number1
            if operation1 == .addition {
                testResult += number2
            } else {
                testResult -= number2
            }
            testResult += number3
            
            // 如果仍为负数（可能是第一个操作是减法且number2 > number1），将第一个操作也改为加法
            if testResult < 0 {
                operation1 = .addition
                testResult = number1 + number2 + number3
            }
        }
        
        return Question(number1: number1, number2: number2, number3: number3, operation1: operation1, operation2: operation2)
    }
}
