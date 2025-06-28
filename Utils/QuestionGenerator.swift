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
            
            // 等级2及以上有概率生成三数运算题目
            if difficultyLevel != .level1 && Double.random(in: 0...1) < getThreeNumberProbability(difficultyLevel) {
                newQuestion = generateThreeNumberQuestion(difficultyLevel: difficultyLevel)
                combination = getCombinationKey(for: newQuestion)
            } else {
                newQuestion = generateTwoNumberQuestion(difficultyLevel: difficultyLevel)
                combination = getCombinationKey(for: newQuestion)
            }
            
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
        case .level4: return 0.4   // 等级4有80%概率生成三数运算
        case .level5: return 0.8   // 等级5有80%概率生成三数运算
        case .level6: return 0.9   // 等级6有90%概率生成三数运算
        }
    }
    
    // 安全随机数生成，避免 lowerBound > upperBound 导致崩溃
    private static func safeRandom(in range: ClosedRange<Int>) -> Int {
        guard range.lowerBound <= range.upperBound else {
            return range.lowerBound // 或者返回一个默认值
        }
        return Int.random(in: range)
    }
    // 支持半开区间
    private static func safeRandom(in range: Range<Int>) -> Int {
        guard range.lowerBound < range.upperBound else {
            return range.lowerBound
        }
        return Int.random(in: range)
    }
    
    // 生成两数运算题目
    private static func generateTwoNumberQuestion(difficultyLevel: DifficultyLevel) -> Question {
        let range = difficultyLevel.range
        let supportedOperations = difficultyLevel.supportedOperations
        
        // 随机选择一个支持的运算类型
        let operation = supportedOperations.randomElement()!
        
        var number1: Int
        var number2: Int
        
        // 根据难度等级设置最小数字
        let minNumber = difficultyLevel == .level1 ? 1 : 2
        
        // 尝试生成符合条件的题目
        let maxAttempts = 10
        var attempts = 0
        
        repeat {
            switch operation {
            case .addition:
                // 加法：确保结果不超过范围上限
                if difficultyLevel == .level1 {
                    number1 = safeRandom(in: minNumber...range.upperBound)
                    number2 = safeRandom(in: minNumber...range.upperBound)
                    if number1 + number2 > range.upperBound {
                        number2 = range.upperBound - number1
                    }
                } else {
                    // 等级2及以上，确保总和大于10
                    number1 = safeRandom(in: minNumber...range.upperBound)
                    let minSecondNumber = max(minNumber, 11 - number1)
                    let maxSecondNumber = range.upperBound - number1
                    if minSecondNumber <= maxSecondNumber {
                        number2 = safeRandom(in: minSecondNumber...maxSecondNumber)
                    } else {
                        number1 = max(minNumber, range.upperBound - 9)
                        number2 = safeRandom(in: max(minNumber, 11 - number1)...range.upperBound - number1)
                    }
                }
                
            case .subtraction:
                // 减法：确保结果为正数且有意义的差值
                if difficultyLevel == .level1 {
                    number1 = safeRandom(in: minNumber...range.upperBound)
                    number2 = safeRandom(in: minNumber...number1)
                    
                    // 避免相同数字相减，确保差值至少为1
                    if number1 == number2 && number1 > minNumber {
                        number2 = number1 - 1
                    }
                    // 进一步提高教学价值，避免差值过小
                    if number1 - number2 < 2 && number1 > minNumber + 1 {
                        number2 = max(minNumber, number1 - 2)
                    }
                } else {
                    // 等级2及以上，确保被减数至少为10，差值有意义
                    number1 = safeRandom(in: max(10, minNumber)...range.upperBound)
                    let maxSubtractor = number1 - 2 // 确保差值至少为2
                    number2 = safeRandom(in: minNumber...max(minNumber, maxSubtractor))
                    
                    // 避免相同数字相减
                    if number1 == number2 {
                        number2 = max(minNumber, number1 - 2)
                    }
                    
                    // 确保差值不会太小，提高计算挑战性
                    if number1 - number2 < 2 {
                        number2 = max(minNumber, number1 - safeRandom(in: 2...min(5, number1 - minNumber)))
                    }
                }
                
            case .multiplication:
                // 乘法：确保结果不超过范围上限，大幅减少×1题目
                let maxFactor = min(range.upperBound, Int(sqrt(Double(range.upperBound))))
                
                // 大幅减少×1的题目，提高教学价值
                if Double.random(in: 0...1) < 0.05 { // 降低到5%概率生成×1
                    number1 = safeRandom(in: 2...maxFactor)
                    number2 = 1
                } else {
                    // 优先生成2-9的乘法，避免过于简单的×1
                    number1 = safeRandom(in: 2...maxFactor)
                    let minSecondFactor = 2 // 确保第二个因数至少为2
                    let maxSecondFactor = min(range.upperBound / number1, maxFactor)
                    
                    if maxSecondFactor >= minSecondFactor {
                        number2 = safeRandom(in: minSecondFactor...maxSecondFactor)
                    } else {
                        // 如果无法生成合适的第二个因数，调整第一个因数
                        number1 = safeRandom(in: 2...min(maxFactor, range.upperBound / 2))
                        number2 = safeRandom(in: 2...min(range.upperBound / number1, maxFactor))
                    }
                }
                
                // 确保结果不超过范围
                if number1 * number2 > range.upperBound {
                    number2 = range.upperBound / number1
                    if number2 < 2 {
                        // 如果第二个因数小于2，重新生成更小的第一个因数
                        number1 = safeRandom(in: 2...min(maxFactor, range.upperBound / 2))
                        number2 = safeRandom(in: 2...range.upperBound / number1)
                    }
                }
                
            case .division:
                // 除法：先生成商，再计算被除数，确保整除且避免相同数字
                var quotient = safeRandom(in: 2...min(range.upperBound, 10)) // 商至少为2，提高教学价值
                number2 = safeRandom(in: 2...min(10, range.upperBound)) // 除数2-10，避免÷1
                
                // 避免商为1的简单除法，除非是特殊情况
                if quotient == 1 && Double.random(in: 0...1) > 0.1 { // 90%概率避免商为1
                    quotient = safeRandom(in: 2...min(range.upperBound, 10))
                }
                
                number1 = quotient * number2 // 被除数 = 商 × 除数，确保整除
                
                // 避免被除数等于除数的情况（如6÷6=1）
                if number1 == number2 {
                    if quotient < min(range.upperBound, 10) {
                        quotient += 1
                        number1 = quotient * number2
                    } else {
                        number2 = max(2, number2 - 1)
                        number1 = quotient * number2
                    }
                }
                
                // 如果被除数超过范围，重新调整
                if number1 > range.upperBound {
                    number2 = safeRandom(in: 2...min(range.upperBound, 10))
                    let maxQuotient = range.upperBound / number2
                    quotient = safeRandom(in: 2...max(2, maxQuotient)) // 确保商至少为2
                    number1 = quotient * number2
                    
                    // 再次检查避免相同数字
                    if number1 == number2 && quotient > 2 {
                        quotient = max(2, quotient - 1)
                        number1 = quotient * number2
                    }
                }
            }
            
            attempts += 1
        } while (number1 <= 0 || number2 <= 0 || 
                 (operation == .multiplication && number1 * number2 > range.upperBound) ||
                 (operation == .division && number1 > range.upperBound)) && attempts < maxAttempts
        
        // 最后的安全检查和调整
        if number1 <= 0 || number2 <= 0 {
            number1 = max(minNumber, number1)
            number2 = max(minNumber, number2)
        }
        
        return Question(number1: number1, number2: number2, operation: operation)
    }
    
    // 生成三数运算题目
    private static func generateThreeNumberQuestion(difficultyLevel: DifficultyLevel) -> Question {
        let range = difficultyLevel.range
        let supportedOperations = difficultyLevel.supportedOperations
        
        // 获取当前难度等级的上限
        let upperBound = range.upperBound
        
        // 确保不出现简单的算术题，最小数字至少为2
        let minNumber = 2
        
        // 生成三个数字，确保它们不会太大，以便运算过程中不超过上限
        // 对于加法，每个数字最大不超过上限的一半
        let maxNumberForAddition = upperBound / 3 // 改为三分之一，为三数运算留出空间
        
        var number1 = safeRandom(in: minNumber...min(maxNumberForAddition, range.upperBound))
        var number2 = safeRandom(in: minNumber...min(maxNumberForAddition, range.upperBound))
        var number3 = safeRandom(in: minNumber...min(maxNumberForAddition, range.upperBound))
        
        // 生成两个操作
        var operation1: Question.Operation
        var operation2: Question.Operation
        
        // 根据难度等级选择操作类型
        if difficultyLevel == .level6 {
            // 等级6：混合运算，随机选择任意支持的操作
            operation1 = supportedOperations.randomElement()!
            operation2 = supportedOperations.randomElement()!
        } else if difficultyLevel == .level4 || difficultyLevel == .level5 {
            // 等级4和5：只使用乘除法
            operation1 = supportedOperations.randomElement()! // 从[multiplication, division]中选择
            operation2 = supportedOperations.randomElement()! // 从[multiplication, division]中选择
        } else {
            // 等级2和3：只使用加减法
            operation1 = Double.random(in: 0...1) < 0.5 ? .addition : .subtraction
            operation2 = Double.random(in: 0...1) < 0.5 ? .addition : .subtraction
        }
        
        // 尝试生成符合条件的题目
        let maxAttempts = 10 // 增加尝试次数以满足更严格的条件
        var attempts = 0
        var intermediateResult: Int
        var finalResult: Int
        
        repeat {
            // 根据操作类型调整数字生成策略
            switch operation1 {
            case .addition:
                // 加法：保持原有逻辑
                break
            case .subtraction:
                // 减法：确保被减数大于等于10
                number1 = safeRandom(in: max(10, minNumber)...range.upperBound)
            case .multiplication:
                // 乘法：使用较小的数字避免结果过大，减少×1概率
                let maxFactor = min(10, Int(sqrt(Double(range.upperBound))))
                
                // 减少×1的概率，提高教学价值
                if Double.random(in: 0...1) < 0.05 { // 5%概率生成×1
                    number1 = safeRandom(in: 2...maxFactor)
                    number2 = 1
                } else {
                    number1 = safeRandom(in: 2...maxFactor)
                    number2 = safeRandom(in: 2...min(range.upperBound / max(1, number1), maxFactor))
                }
            case .division:
                // 除法：先生成商，再计算被除数，避免相同数字
                var quotient = safeRandom(in: 2...min(range.upperBound, 20)) // 商至少为2
                number2 = safeRandom(in: 2...min(10, range.upperBound))
                
                // 避免商为1的简单除法
                if quotient == 1 && Double.random(in: 0...1) > 0.1 {
                    quotient = safeRandom(in: 2...min(range.upperBound, 20))
                }
                
                number1 = quotient * number2
                
                // 避免被除数等于除数
                if number1 == number2 {
                    if quotient < min(range.upperBound, 20) {
                        quotient += 1
                        number1 = quotient * number2
                    } else {
                        number2 = max(2, number2 - 1)
                        number1 = quotient * number2
                    }
                }
            }
            
            // 确保没有操作数为0
            number1 = max(number1, minNumber)
            number2 = max(number2, minNumber)
            number3 = max(number3, minNumber)
            
            // 计算中间结果
            switch operation1 {
            case .addition:
                intermediateResult = number1 + number2
            case .subtraction:
                intermediateResult = number1 - number2
            case .multiplication:
                intermediateResult = number1 * number2
            case .division:
                intermediateResult = number2 != 0 ? number1 / number2 : number1
            }
            
            // 对于第二个操作，根据操作类型调整number3
            switch operation2 {
            case .addition, .subtraction:
                // 加减法：保持原有逻辑
                break
            case .multiplication:
                // 乘法：确保number3不会导致结果过大
                let maxMultiplier = min(10, range.upperBound / max(1, intermediateResult))
                if maxMultiplier >= 2 {
                    number3 = safeRandom(in: 2...maxMultiplier)
                } else {
                    number3 = 2
                    operation2 = .addition // 改为加法避免结果过大
                }
            case .division:
                // 除法：确保能整除
                if intermediateResult > 1 {
                    // 找到intermediateResult的因数作为除数
                    var divisors: [Int] = []
                    for i in 2...min(10, intermediateResult) {
                        if intermediateResult % i == 0 {
                            divisors.append(i)
                        }
                    }
                    if !divisors.isEmpty {
                        number3 = divisors.randomElement()!
                    } else {
                        number3 = 2
                        operation2 = .addition // 改为加法
                    }
                } else {
                    number3 = 2
                    operation2 = .addition // 改为加法
                }
            }
            
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
                    number1 = safeRandom(in: max(10, minNumber)...min(upperBound, range.upperBound))
                    number2 = safeRandom(in: minNumber...min(number1 - 1, range.upperBound))
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
                    if intermediateResult > minNumber {
                        number3 = safeRandom(in: minNumber..<intermediateResult)
                    } else {
                        // 如果intermediateResult <= minNumber，改为加法
                        operation2 = .addition
                    }
                }
            }
            
            // 计算最终结果
            switch operation2 {
            case .addition:
                finalResult = intermediateResult + number3
            case .subtraction:
                finalResult = intermediateResult - number3
            case .multiplication:
                finalResult = intermediateResult * number3
            case .division:
                finalResult = number3 != 0 ? intermediateResult / number3 : intermediateResult
            }
            
            // 确保最终结果不超过上限
            if finalResult > upperBound {
                if operation2 == .addition {
                    // 如果加法导致超过上限，改为减法
                    operation2 = .subtraction
                    // 确保中间结果 > number3，避免负数结果
                    if intermediateResult <= number3 {
                        if intermediateResult > minNumber {
                            number3 = safeRandom(in: minNumber..<intermediateResult)
                        } else {
                            // 如果intermediateResult <= minNumber，调整number1和number2
                            number1 += 2
                            intermediateResult = operation1 == .addition ? number1 + number2 : number1 - number2
                            // 确保中间结果大于minNumber
                            if intermediateResult > minNumber {
                                number3 = safeRandom(in: minNumber..<intermediateResult)
                            } else {
                                number3 = minNumber
                                operation2 = .addition
                            }
                        }
                    }
                    finalResult = intermediateResult - number3
                } else {
                    // 如果是减法但仍然超过上限（不太可能），减小number1和number2
                    number1 = safeRandom(in: max(10, minNumber)...min(upperBound / 2, range.upperBound))
                    number2 = safeRandom(in: minNumber...min(number1, range.upperBound))
                    intermediateResult = operation1 == .addition ? number1 + number2 : number1 - number2
                    
                    // 重新计算最终结果
                    if operation2 == .subtraction && intermediateResult <= number3 {
                        if intermediateResult > minNumber {
                            number3 = safeRandom(in: minNumber..<intermediateResult)
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
                        number3 = safeRandom(in: minNumber...min(maxNumberForAddition, range.upperBound))
                    } else {
                        number3 = safeRandom(in: minNumber...min(maxNumberForAddition, range.upperBound))
                    }
                } else {
                    // 如果是减法，确保intermediateResult != number3
                    if intermediateResult == number3 {
                        if intermediateResult > minNumber {
                            number3 = safeRandom(in: minNumber..<intermediateResult)
                        } else {
                            // 如果intermediateResult <= minNumber，无法创建有效范围
                            number3 = max(1, minNumber - 1)
                        }
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
        switch operation1 {
        case .addition:
            testResult += number2
        case .subtraction:
            testResult -= number2
        case .multiplication:
            testResult *= number2
        case .division:
            testResult = number2 != 0 ? testResult / number2 : testResult
        }
        
        switch operation2 {
        case .addition:
            testResult += number3
        case .subtraction:
            testResult -= number3
        case .multiplication:
            testResult *= number3
        case .division:
            testResult = number3 != 0 ? testResult / number3 : testResult
        }
        
        // 如果最终结果为负数，调整操作或数字
        if testResult < 0 {
            // 简单解决方案：将第二个操作改为加法
            operation2 = .addition
            // 重新计算结果确认
            testResult = number1
            switch operation1 {
            case .addition:
                testResult += number2
            case .subtraction:
                testResult -= number2
            case .multiplication:
                testResult *= number2
            case .division:
                testResult = number2 != 0 ? testResult / number2 : testResult
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
