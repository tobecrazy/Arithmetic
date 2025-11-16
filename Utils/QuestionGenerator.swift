import Foundation

class QuestionGenerator {
    static func generateQuestions(difficultyLevel: DifficultyLevel, count: Int, wrongQuestions: [Question] = []) -> [Question] {
        var questions: [Question] = []
        var generatedCombinations: Set<String> = []
        
        // 首先添加错题集中的题目，但需要验证其有效性
        for wrongQuestion in wrongQuestions {
            let combination = getCombinationKey(for: wrongQuestion)
            if !generatedCombinations.contains(combination) && wrongQuestion.isValid() {
                questions.append(wrongQuestion)
                generatedCombinations.insert(combination)
            }
        }
        
        // 如果错题不足，生成新题目补充
        var failedAttempts = 0
        let maxFailedAttempts = 100 // 防止无限循环
        
        while questions.count < count && failedAttempts < maxFailedAttempts {
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
            
            if !generatedCombinations.contains(combination) && newQuestion.isValid() {
                questions.append(newQuestion)
                generatedCombinations.insert(combination)
                failedAttempts = 0 // 重置失败计数
            } else {
                failedAttempts += 1
            }
        }
        
        // 如果仍然没有足够的题目，用简单的加法题目补充
        while questions.count < count {
            let num1 = Int.random(in: 2...min(10, difficultyLevel.range.upperBound))
            let num2 = Int.random(in: 2...min(10, difficultyLevel.range.upperBound))
            let fallbackQuestion = Question(number1: num1, number2: num2, operation: .addition)
            let combination = getCombinationKey(for: fallbackQuestion)
            
            if !generatedCombinations.contains(combination) {
                questions.append(fallbackQuestion)
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
        guard let operation = supportedOperations.randomElement() else {
            // 如果没有支持的运算，返回一个默认运算
            return Question(number1: 2, number2: 2, operation: .addition)
        }
        
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
                // 减法：确保结果为正数且有意义的差值，强化避免相同数字相减
                if difficultyLevel == .level1 {
                    number1 = safeRandom(in: minNumber...range.upperBound)
                    number2 = safeRandom(in: minNumber...number1)

                    // 强化：避免相同数字相减，确保差值至少为2（减少结果为1的情况）
                    if number1 == number2 {
                        if number1 > minNumber + 1 {
                            number2 = number1 - safeRandom(in: 2...min(3, number1 - minNumber))
                        } else {
                            number1 = max(minNumber + 2, number1)
                            number2 = number1 - 2
                        }
                    }
                    // 进一步提高教学价值，避免差值过小（结果为1的情况）
                    if number1 - number2 <= 1 && number1 > minNumber + 1 {
                        number2 = max(minNumber, number1 - safeRandom(in: 2...min(4, number1 - minNumber)))
                    }
                } else {
                    // 等级2及以上，确保被减数至少为10，差值有意义
                    number1 = safeRandom(in: max(10, minNumber)...range.upperBound)
                    let maxSubtractor = number1 - 3 // 确保差值至少为3，减少结果为1或2的情况
                    number2 = safeRandom(in: minNumber...max(minNumber, maxSubtractor))

                    // 强化：避免相同数字相减
                    if number1 == number2 {
                        number2 = max(minNumber, number1 - safeRandom(in: 3...min(6, number1 - minNumber)))
                    }

                    // 确保差值不会太小，进一步减少结果为0、1的情况
                    if number1 - number2 <= 2 {
                        number2 = max(minNumber, number1 - safeRandom(in: 3...min(7, number1 - minNumber)))
                    }
                }
                
            case .multiplication:
                // 乘法：确保结果不超过范围上限，进一步减少×1题目和结果为1的情况
                let maxFactor = min(range.upperBound, Int(sqrt(Double(range.upperBound))))

                // 进一步减少×1的题目，仅在level1且随机概率很低时允许
                if difficultyLevel == .level1 && Double.random(in: 0...1) < 0.02 { // 进一步降低到2%概率生成×1
                    number1 = safeRandom(in: 2...maxFactor)
                    number2 = 1
                } else {
                    // 优先生成2-9的乘法，完全避免×1（除了上述极低概率情况）
                    number1 = safeRandom(in: 2...maxFactor)
                    let minSecondFactor = 2 // 确保第二个因数至少为2，避免结果为原数
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

                // 额外检查：避免任何因数为1的情况（双重保险）
                if number1 == 1 {
                    number1 = 2
                }
                if number2 == 1 && difficultyLevel != .level1 {
                    number2 = 2
                    // 重新检查范围
                    if number1 * number2 > range.upperBound {
                        number1 = range.upperBound / number2
                    }
                }
                
            case .division:
                // 除法：确保整除，先选择除数和商，再计算被除数，强化避免相同数字和结果为1
                // 选择除数（2-10之间，避免÷1）
                number2 = safeRandom(in: 2...min(10, range.upperBound))

                // 计算可能的最大商，确保被除数不超过范围
                let maxPossibleQuotient = range.upperBound / number2

                // 选择商（至少为3，大幅减少结果为1或2的情况）
                let minQuotient = max(difficultyLevel == .level1 ? 2 : 3, minNumber)
                let maxQuotient = max(minQuotient, maxPossibleQuotient)
                let quotient: Int

                if maxQuotient >= minQuotient {
                    // 进一步减少生成结果为1的概率：优先选择较大的商
                    if maxQuotient > minQuotient + 2 {
                        // 70%概率选择较大的商范围
                        let isLargerRange = Double.random(in: 0...1) < 0.7
                        if isLargerRange {
                            let midPoint = (minQuotient + maxQuotient) / 2
                            quotient = safeRandom(in: midPoint...maxQuotient)
                        } else {
                            quotient = safeRandom(in: minQuotient...maxQuotient)
                        }
                    } else {
                        quotient = minQuotient
                    }
                } else {
                    // 如果无法生成合适的商，调整除数
                    number2 = max(2, range.upperBound / minQuotient)
                    quotient = minQuotient
                }

                // 计算被除数，确保整除
                number1 = quotient * number2

                // 最终验证：确保被除数在范围内
                if number1 > range.upperBound {
                    // 重新选择更小的除数，但保持商至少为minQuotient
                    number2 = safeRandom(in: 2...min(5, range.upperBound / minQuotient))
                    number1 = minQuotient * number2
                }

                // 强化：严格避免被除数等于除数的情况（如6÷6=1）
                if number1 == number2 {
                    // 优先增加商，而不是减少除数
                    let newQuotient = max(quotient + 1, 3) // 至少为3
                    if newQuotient * number2 <= range.upperBound {
                        number1 = newQuotient * number2
                    } else {
                        // 如果增加商会超出范围，则减少除数
                        if number2 > 2 {
                            number2 -= 1
                            number1 = max(quotient, 3) * number2
                        } else {
                            // 最后的调整：确保不相等且商不为1
                            number1 = max(3 * number2, minNumber * number2)
                            if number1 > range.upperBound {
                                // 如果仍然超出范围，重新生成更小的数字
                                number2 = 2
                                number1 = 3 * number2 // 确保结果不为1
                            }
                        }
                    }
                }

                // 额外检查：再次确保结果不为1
                if number2 != 0 && number1 / number2 == 1 {
                    // 如果结果为1，强制调整为至少为2
                    number1 = max(2, minQuotient) * number2
                    if number1 > range.upperBound {
                        number2 = max(2, range.upperBound / max(2, minQuotient))
                        number1 = max(2, minQuotient) * number2
                    }
                }

                // 最终安全检查：确保整除
                if number2 != 0 && number1 % number2 != 0 {
                    // 强制调整为整除
                    let actualQuotient = max(2, number1 / number2) // 确保商至少为2
                    number1 = actualQuotient * number2
                }
            }
            
            attempts += 1
        } while (number1 <= 0 || number2 <= 0 ||
                 (operation == .multiplication && number1 * number2 > range.upperBound) ||
                 (operation == .division && number1 > range.upperBound) ||
                 (operation == .subtraction && number1 - number2 <= 1) ||
                 (operation == .division && number2 != 0 && number1 / number2 <= 1)) && attempts < maxAttempts
        
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
            operation1 = supportedOperations.randomElement() ?? .addition
            operation2 = supportedOperations.randomElement() ?? .addition
        } else if difficultyLevel == .level4 || difficultyLevel == .level5 {
            // 等级4和5：只使用乘除法
            operation1 = supportedOperations.randomElement() ?? .multiplication // 从[multiplication, division]中选择
            operation2 = supportedOperations.randomElement() ?? .multiplication // 从[multiplication, division]中选择
        } else {
            // 等级2和3：只使用加减法
            operation1 = Double.random(in: 0...1) < 0.5 ? .addition : .subtraction
            operation2 = Double.random(in: 0...1) < 0.5 ? .addition : .subtraction
        }
        
        // 尝试生成符合条件的题目
        let maxAttempts = 20 // 增加尝试次数以满足更严格的条件，包括避免重复数字
        var attempts = 0
        var intermediateResult: Int = 0
        var finalResult: Int = 0
        
        repeat {
            // 重新生成数字以避免重复
            number1 = safeRandom(in: minNumber...min(maxNumberForAddition, range.upperBound))
            number2 = safeRandom(in: minNumber...min(maxNumberForAddition, range.upperBound))
            number3 = safeRandom(in: minNumber...min(maxNumberForAddition, range.upperBound))
            
            // 检查并避免重复数字模式，减少过于简单的题目
            if hasRepetitivePattern(num1: number1, num2: number2, num3: number3, op1: operation1, op2: operation2) {
                attempts += 1
                continue // 跳过这次循环，重新生成
            }
            
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
                // 除法：确保整除，先选择除数和商，再计算被除数，强化避免相同数字和结果为1
                // 选择除数（2-10之间，避免÷1）
                number2 = safeRandom(in: 2...min(10, range.upperBound / 2))
                if number2 == 0 { number2 = 2 } // 安全检查

                // 计算可能的最大商，确保被除数不超过范围
                let maxQuotient = range.upperBound / number2
                let minQuotient = max(3, minNumber) // 提高最小商，减少结果为1或2的情况

                let quotient: Int
                if maxQuotient >= minQuotient {
                    // 优先选择较大的商，减少结果为1的概率
                    if maxQuotient > minQuotient + 1 {
                        let midPoint = (minQuotient + maxQuotient) / 2
                        quotient = safeRandom(in: midPoint...maxQuotient)
                    } else {
                        quotient = minQuotient
                    }
                } else {
                    // 如果无法生成合适的商，调整除数
                    number2 = max(2, range.upperBound / minQuotient)
                    quotient = minQuotient
                }

                // 计算被除数，确保整除
                number1 = quotient * number2

                // 强化：避免被除数等于除数的情况（如6÷6=1）
                if number1 == number2 {
                    let newQuotient = max(quotient + 1, 3)
                    if newQuotient * number2 <= range.upperBound {
                        number1 = newQuotient * number2
                    } else {
                        number2 = max(2, number2 - 1)
                        number1 = max(quotient, 3) * number2
                    }
                }

                // 最终验证：确保被除数在范围内
                if number1 > range.upperBound {
                    let finalQuotient = max(3, range.upperBound / number2)
                    number1 = finalQuotient * number2
                }

                // 确保被除数至少为最小值
                if number1 < minNumber {
                    number2 = 2
                    number1 = max(minNumber, 3) * number2
                    if number1 > range.upperBound {
                        // 如果仍然超出范围，改为加法操作
                        operation1 = .addition
                        number1 = safeRandom(in: minNumber...min(maxNumberForAddition, range.upperBound))
                        number2 = safeRandom(in: minNumber...min(maxNumberForAddition, range.upperBound))
                    }
                }

                // 最终安全检查：确保整除且结果不为1
                if number2 != 0 && number1 % number2 != 0 {
                    let actualQuotient = max(3, number1 / number2) // 确保商至少为3
                    number1 = actualQuotient * number2
                }

                // 再次检查结果不为1
                if number2 != 0 && number1 / number2 == 1 {
                    number1 = max(3, minQuotient) * number2
                    if number1 > range.upperBound {
                        number2 = max(2, range.upperBound / max(3, minQuotient))
                        number1 = max(3, minQuotient) * number2
                    }
                }
            }
            
            // 确保没有操作数为0
            number1 = max(number1, minNumber)
            number2 = max(number2, minNumber)
            number3 = max(number3, minNumber)
            
            // Special handling for division operations to ensure integer results
            if operation1 == .division || operation2 == .division {
                // Handle first operation division
                if operation1 == .division {
                    // Ensure number1 is divisible by number2
                    if number2 != 0 && number1 % number2 != 0 {
                        // Regenerate to ensure divisibility
                        let quotient = max(2, number1 / number2)
                        number1 = quotient * number2
                    }
                }
                
                // Handle second operation division with precedence consideration
                if operation2 == .division {
                    let op1Prec = operation1.precedence
                    let op2Prec = operation2.precedence

                    var dividendForOp2: Int
                    if op1Prec < op2Prec { // e.g., num1 + (num2 / num3) -> num2 is the dividend
                        dividendForOp2 = number2
                        // Ensure number2 is divisible by number3
                        if number3 != 0 && number2 % number3 != 0 {
                            let quotient = max(2, number2 / number3)
                            number2 = quotient * number3
                        }
                    } else { // e.g., (num1 op1 num2) / num3 -> (num1 op1 num2) is the dividend
                        // Calculate num1 op1 num2
                        switch operation1 {
                        case .addition: dividendForOp2 = number1 + number2
                        case .subtraction: dividendForOp2 = number1 - number2
                        case .multiplication: dividendForOp2 = number1 * number2
                        case .division: 
                            // Ensure integer division first
                            if number2 != 0 && number1 % number2 != 0 {
                                let quotient = max(2, number1 / number2)
                                number1 = quotient * number2
                            }
                            dividendForOp2 = number2 != 0 ? number1 / number2 : 0
                        }

                        // Now, ensure number3 is a proper divisor for dividendForOp2
                        if dividendForOp2 <= 0 {
                            number3 = 2
                            operation2 = .addition // Fallback to addition
                        } else {
                            var divisors: [Int] = []
                            let absDividend = abs(dividendForOp2)
                            for i in 2...min(10, absDividend) { // Prefer divisors >= 2
                                if absDividend % i == 0 { divisors.append(i) }
                            }
                            if !divisors.isEmpty {
                                number3 = divisors.randomElement() ?? divisors.first ?? 2
                            } else {
                                // If no suitable divisors found, change operation
                                if dividendForOp2 > 1 { 
                                    number3 = 1 // Last resort
                                } else { 
                                    number3 = 2
                                    operation2 = .addition // Change to addition
                                }
                            }
                        }
                    }
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
                }
                switch op2_calc {
                case .addition: finalResult = intermediateA_op1_B + num3_calc
                case .subtraction: finalResult = intermediateA_op1_B - num3_calc
                case .multiplication: finalResult = intermediateA_op1_B * num3_calc
                case .division: finalResult = num3_calc != 0 ? intermediateA_op1_B / num3_calc : 0
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
        } while (number1 == 0 || number2 == 0 || number3 == 0 || finalResult <= 1 ||
                 hasRepetitivePattern(num1: number1, num2: number2, num3: number3, op1: operation1, op2: operation2)) && attempts < maxAttempts
        
        // 如果尝试多次后仍不满足条件，进行最后的调整
        if number1 == 0 || number2 == 0 || number3 == 0 || finalResult <= 1 {
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
    
    // 检查是否存在重复数字模式，避免过于简单的题目，强化避免相同数字运算
    private static func hasRepetitivePattern(num1: Int, num2: Int, num3: Int, op1: Question.Operation, op2: Question.Operation) -> Bool {
        // 检查是否有两个或三个相同的数字
        let numbers = [num1, num2, num3]
        let uniqueNumbers = Set(numbers)

        // 如果三个数字都相同，直接拒绝
        if uniqueNumbers.count == 1 {
            return true
        }

        // 强化：如果有两个相同数字，更严格地检查是否会产生过于简单的运算
        if uniqueNumbers.count == 2 {
            // 找出重复数字的位置
            var duplicatePositions: [Int] = []
            
            for (index, number) in numbers.enumerated() {
                if numbers.filter({ $0 == number }).count == 2 {
                    duplicatePositions.append(index)
                }
            }
            
            // 检查特定的重复模式
            if duplicatePositions.count == 2 {
                // 情况1: 第一个和第二个数字相同 (A op1 A op2 C)
                if duplicatePositions == [0, 1] {
                    // 检查是否会产生简单的运算，如 A - A = 0 或 A ÷ A = 1
                    if op1 == .subtraction || op1 == .division {
                        return true // 拒绝 A - A op2 C 或 A ÷ A op2 C 这类题目
                    }
                }
                
                // 情况2: 第一个和第三个数字相同 (A op1 B op2 A)
                if duplicatePositions == [0, 2] {
                    // 根据运算优先级检查
                    if op1.precedence >= op2.precedence {
                        // 左到右计算: (A op1 B) op2 A
                        // 如果第二个操作是减法或除法，可能产生简单结果
                        if op2 == .subtraction || op2 == .division {
                            return true // 拒绝可能产生 X - A = 0 或 X ÷ A = 1 的情况
                        }
                    } else {
                        // 先计算 B op2 A，然后 A op1 result
                        // 这种情况相对复杂，暂时允许
                    }
                }
                
                // 情况3: 第二个和第三个数字相同 (A op1 B op2 B)
                if duplicatePositions == [1, 2] {
                    // 根据运算优先级检查
                    if op1.precedence < op2.precedence {
                        // 先计算 B op2 B，然后 A op1 result
                        if op2 == .subtraction || op2 == .division {
                            return true // 拒绝 A op1 (B - B) 或 A op1 (B ÷ B) 这类题目
                        }
                    } else {
                        // 左到右计算: (A op1 B) op2 B
                        // 如果第二个操作是减法或除法，检查是否会产生简单结果
                        if op2 == .subtraction || op2 == .division {
                            // 进一步检查：如果 A op1 B 的结果等于 B，则会产生简单运算
                            // 这里简化处理，直接拒绝这类模式
                            return true
                        }
                    }
                }
            }
        }
        
        // 额外检查：避免连续相同操作导致的简化
        // 例如：A + B - B 或 A × B ÷ B
        if op1 == .addition && op2 == .subtraction && num2 == num3 {
            return true // 拒绝 A + B - B 模式
        }
        if op1 == .subtraction && op2 == .addition && num2 == num3 {
            return true // 拒绝 A - B + B 模式
        }
        if op1 == .multiplication && op2 == .division && num2 == num3 {
            return true // 拒绝 A × B ÷ B 模式
        }
        if op1 == .division && op2 == .multiplication && num2 == num3 {
            return true // 拒绝 A ÷ B × B 模式
        }
        
        // 检查是否所有数字都太小（都小于等于3），这可能导致过于简单的题目
        if numbers.allSatisfy({ $0 <= 3 }) {
            return true
        }
        
        return false // 没有发现重复模式，允许生成
    }
}
