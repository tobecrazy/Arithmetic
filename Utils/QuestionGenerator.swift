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
        var intermediateResult: Int = 0
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
                // Ensured integer division: number1 = quotient * number2
                // Aim for quotient >= 2, number2 >= 2
                var quotient: Int
                // Try to keep number2 small to allow larger quotients within range
                number2 = safeRandom(in: 2...min(10, range.upperBound / 2)) // Max divisor 10, ensure number2 isn't too big
                if number2 == 0 { number2 = 2 } // Safety for range.upperBound / 2 being < 2

                let maxQuotient = range.upperBound / number2
                if maxQuotient < 2 {
                    // This case means range.upperBound is very small relative to number2 (e.g. range < 4 for number2=2)
                    if number2 > 2 { // Try smaller number2 if possible
                        number2 -= 1
                        let newMaxQuotient = range.upperBound / number2
                        if newMaxQuotient >= 2 {
                            quotient = safeRandom(in: 2...newMaxQuotient)
                        } else { // Still not enough room
                            quotient = 1 // Allow quotient of 1 if range is too restrictive
                        }
                    } else { // number2 is already 2 (or was 1 and became 0, then 2)
                         quotient = 1 // Allow quotient of 1
                    }
                } else {
                    quotient = safeRandom(in: 2...maxQuotient)
                }
                
                number1 = quotient * number2
                
                // If number1 > range.upperBound (should be prevented by maxQuotient logic)
                // For safety, cap number1 if it somehow exceeds.
                if number1 > range.upperBound {
                    // Recalculate to fit, ensuring it's a multiple of number2
                    let finalQuotient = range.upperBound / number2
                    number1 = finalQuotient * number2
                }
                // Ensure number1 is at least minNumber, if capping made it too small (e.g. if range.upperBound is tiny)
                if number1 < minNumber {
                    // This scenario suggests very restrictive ranges.
                    // Fallback to a simple valid division if possible, or change operation.
                    number2 = 2
                    number1 = minNumber * number2 // e.g. 2*2 = 4
                    if number1 > range.upperBound { // If even this is too big, ranges are problematic
                        // Consider changing operation or signalling an issue
                        // For now, stick to the values, even if small
                         number1 = safeRandom(in: minNumber...range.upperBound)
                         number2 = 1 // Simplest division
                         if number1 % number2 != 0 { // Should not happen with number2 = 1
                             operation1 = .addition // Fallback operation
                         }
                    }
                }
            }
            
            // 确保没有操作数为0
            number1 = max(number1, minNumber)
            number2 = max(number2, minNumber)
            number3 = max(number3, minNumber)
            
            // Adjustment for number3 if operation2 is division, considering operator precedence
            if operation2 == .division {
                let op1Prec = operation1.precedence
                let op2Prec = operation2.precedence

                var dividendForOp2: Int
                if op1Prec < op2Prec { // e.g., num1 + (num2 / num3) -> num2 is the dividend
                    dividendForOp2 = number2
                } else { // e.g., (num1 op1 num2) / num3 -> (num1 op1 num2) is the dividend
                    // Calculate num1 op1 num2
                    switch operation1 {
                    case .addition: dividendForOp2 = number1 + number2
                    case .subtraction: dividendForOp2 = number1 - number2
                    case .multiplication: dividendForOp2 = number1 * number2
                    case .division: // number1 / number2 has already been ensured to be integer by prior logic
                        dividendForOp2 = number2 != 0 ? number1 / number2 : 0
                    }
                }

                // Now, ensure number3 is a proper divisor for dividendForOp2
                if dividendForOp2 == 0 {
                    number3 = safeRandom(in: 2...10); if number3 == 0 { number3 = 2 }
                } else {
                    var divisors: [Int] = []
                    let absDividend = abs(dividendForOp2)
                    if absDividend >= 1 {
                        for i in 2...min(10, absDividend) { // Prefer divisors >= 2
                            if absDividend % i == 0 { divisors.append(i) }
                        }
                    }
                    if !divisors.isEmpty {
                        number3 = divisors.randomElement()!
                    } else {
                        if dividendForOp2 != 0 { number3 = 1 } // Fallback to 1 if no other divisors
                        else { number3 = 2; operation2 = .addition }
                    }
                    if number3 == 0 { number3 = 1 } // Final safety for number3 != 0
                }
            }

            // Calculate finalResult using correct order of operations
            let num1_calc = number1, num2_calc = number2, num3_calc = number3
            let op1_calc = operation1, op2_calc = operation2

            if op1_calc.precedence < op2_calc.precedence {
                var intermediateB_op2_C: Int
                switch op2_calc {
                case .multiplication: intermediateB_op2_C = num2_calc * num3_calc
                case .division: intermediateB_op2_C = num3_calc != 0 ? num2_calc / num3_calc : 0
                default: intermediateB_op2_C = 0
                }
                switch op1_calc {
                case .addition: finalResult = num1_calc + intermediateB_op2_C
                case .subtraction: finalResult = num1_calc - intermediateB_op2_C
                default: finalResult = 0
                }
            } else {
                var intermediateA_op1_B: Int
                switch op1_calc {
                case .addition: intermediateA_op1_B = num1_calc + num2_calc
                case .subtraction: intermediateA_op1_B = num1_calc - num2_calc
                case .multiplication: intermediateA_op1_B = num1_calc * num2_calc
                case .division: intermediateA_op1_B = num2_calc != 0 ? num1_calc / num2_calc : 0
                default: intermediateA_op1_B = 0 // Should not happen with defined operations
                }
                switch op2_calc {
                case .addition: finalResult = intermediateA_op1_B + num3_calc
                case .subtraction: finalResult = intermediateA_op1_B - num3_calc
                case .multiplication: finalResult = intermediateA_op1_B * num3_calc
                case .division: finalResult = num3_calc != 0 ? intermediateA_op1_B / num3_calc : 0
                default: finalResult = 0 // Should not happen
                }
            }
            
            // Simplified adjustment logic:
            // Focus on finalResult properties (range, sign, not zero).
            // The generator might need more attempts or smarter initial number choices
            // if the previous fine-grained intermediate adjustments are removed.

            // Ensure final result is not too large
            if finalResult > upperBound {
                // This is a simple catch-all. Ideally, numbers are chosen to prevent this.
                // If it happens, one strategy is to reduce one of the numbers, or change an operation
                // from multiply/add to divide/subtract if possible, or just retry the loop.
                // For now, the loop's `attempts < maxAttempts` will handle this by retrying.
                // Consider reducing the magnitude of numbers if this happens often.
                if operation1 == .multiplication || operation2 == .multiplication {
                     // If multiplication is involved, try making numbers smaller
                     number1 = max(minNumber, number1 / 2)
                     number2 = max(minNumber, number2 / 2)
                     number3 = max(minNumber, number3 / 2)
                } else if operation1 == .addition || operation2 == .addition {
                    // If addition, also try making numbers smaller
                     number1 = max(minNumber, number1 - 1)
                     number2 = max(minNumber, number2 - 1)
                     number3 = max(minNumber, number3 - 1)
                }
                // Recalculate finalResult after adjustment (or let loop retry)
                // For simplicity, let the main loop condition catch this and retry.
            }
            
            // Ensure final result is not negative (unless allowed by difficulty)
            // Assuming standard levels want positive results for now.
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
