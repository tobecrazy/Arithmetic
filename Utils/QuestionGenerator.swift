import Foundation

/// A factory class responsible for generating arithmetic questions with intelligent difficulty scaling.
///
/// `QuestionGenerator` creates mathematically valid questions that respect PEMDAS rules,
/// ensure all division operations result in integers, and incorporate wrong questions
/// from previous attempts for adaptive learning.
///
/// ## Features
/// - Generates both two-number and three-number arithmetic operations
/// - Ensures all division operations produce integer results
/// - Incorporates up to 30% wrong questions for review
/// - Avoids duplicate questions within a set
/// - Adaptive difficulty based on question range and supported operations
///
/// ## Example Usage
/// ```swift
/// // Generate 20 Level 2 questions
/// let questions = QuestionGenerator.generateQuestions(
///     difficultyLevel: .level2,
///     count: 20,
///     wrongQuestions: []
/// )
///
/// // Generate questions with wrong question integration
/// let wrongQuestions = WrongQuestionManager.shared.getWrongQuestions(for: .level2)
/// let mixedQuestions = QuestionGenerator.generateQuestions(
///     difficultyLevel: .level2,
///     count: 25,
///     wrongQuestions: wrongQuestions.map { $0.toQuestion() }.compactMap { $0 }
/// )
/// ```
class QuestionGenerator {
    // MARK: - Constants

    /// Configuration constants for question generation behavior
    enum Constants {
        /// Maximum number of attempts to generate a unique, valid question before giving up
        static let maxGenerationAttempts = 100

        /// Minimum value for question numbers to ensure meaningful arithmetic
        static let minNumberValue = 2

        /// Fallback range for simple addition when generation fails
        static let fallbackNumberRange = 2...10

        /// Target ratio of wrong questions to include in question sets (30%)
        static let wrongQuestionRatio = 0.3

        /// Correct answer rate threshold for considering a question mastered (70%)
        static let masteryCorrectRate = 0.7
    }

    // MARK: - Public Methods

    /// Generates a set of non-repetitive arithmetic questions for a given difficulty level.
    ///
    /// This method intelligently combines wrong questions from previous attempts with newly
    /// generated questions to create an adaptive learning experience. Up to 30% of the returned
    /// questions will be from the wrong questions collection, with the remainder being freshly
    /// generated based on the difficulty level.
    ///
    /// - Parameters:
    ///   - difficultyLevel: The difficulty level that determines number ranges and supported operations
    ///   - count: The desired number of questions to generate
    ///   - wrongQuestions: Optional array of previously answered incorrectly questions to incorporate
    ///
    /// - Returns: An array of valid, non-duplicate questions shuffled in random order
    ///
    /// - Note: If generation struggles to create enough unique questions, the method will fall back
    ///         to simple addition problems to ensure the requested count is met.
    ///
    /// ## Question Distribution by Level
    /// | Level | Range | Operations | Two-Number % | Three-Number % |
    /// |-------|-------|------------|--------------|----------------|
    /// | 1     | 1-10  | +, -       | 100%         | 0%             |
    /// | 2     | 1-20  | +, -       | 60%          | 40%            |
    /// | 3     | 1-50  | +, -       | 40%          | 60%            |
    /// | 4     | 1-10  | ×, ÷       | 60%          | 40%            |
    /// | 5     | 1-20  | ×, ÷       | 20%          | 80%            |
    /// | 6     | 1-100 | +, -, ×, ÷ | 10%          | 90%            |
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

        while questions.count < count && failedAttempts < Constants.maxGenerationAttempts {
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
            let maxFallback = min(10, difficultyLevel.range.upperBound)
            let num1 = Int.random(in: 2...maxFallback)
            let num2 = Int.random(in: 2...maxFallback)
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
    
    /// Generates a unique identifier key for a question to prevent duplicates.
    ///
    /// The key combines numbers and operations in a predictable format:
    /// - Two-number: `"{num1}{op}{num2}"` (e.g., "5+3")
    /// - Three-number: `"{num1}{op1}{num2}{op2}{num3}"` (e.g., "5+3-2")
    ///
    /// - Parameter question: The question to generate a key for
    /// - Returns: A string uniquely identifying this specific arithmetic expression
    ///
    /// - Note: This method is used internally to track generated questions and avoid duplicates
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
        case .level4: return 0.4   // 等级4有40%概率生成三数运算
        case .level5: return 0.8   // 等级5有80%概率生成三数运算
        case .level6: return 0.9   // 等级6有90%概率生成三数运算
        }
    }
    
    /// Generates a random integer within a closed range with safety checks.
    ///
    /// This method prevents crashes that would occur if `lowerBound > upperBound` by
    /// validating the range before generating a random number.
    ///
    /// - Parameter range: A closed range (e.g., `2...10`) to generate a random number from
    /// - Returns: A random integer within the range, or `lowerBound` if the range is invalid
    ///
    /// ## Example
    /// ```swift
    /// let num = QuestionGenerator.safeRandom(in: 1...10)  // Returns 1-10
    /// let safe = QuestionGenerator.safeRandom(in: 10...1)  // Returns 10 (invalid range)
    /// ```
    static func safeRandom(in range: ClosedRange<Int>) -> Int {
        guard range.lowerBound <= range.upperBound else {
            return range.lowerBound // 或者返回一个默认值
        }
        return Int.random(in: range)
    }
    /// Generates a random integer within a half-open range with safety checks.
    ///
    /// This overload handles half-open ranges (e.g., `2..<10`) and prevents crashes
    /// from invalid ranges.
    ///
    /// - Parameter range: A half-open range (e.g., `2..<10`) to generate a random number from
    /// - Returns: A random integer within the range, or `lowerBound` if the range is invalid
    static func safeRandom(in range: Range<Int>) -> Int {
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
                            let maxDiff = min(3, number1 - minNumber)
                            if maxDiff >= 2 {
                                number2 = number1 - safeRandom(in: 2...maxDiff)
                            } else {
                                number2 = number1 - 1
                            }
                        } else {
                            number1 = max(minNumber + 2, number1)
                            number2 = number1 - 2
                        }
                    }
                    // 进一步提高教学价值，避免差值过小（结果为1的情况）
                    if number1 - number2 <= 1 && number1 > minNumber + 1 {
                        let maxDiff = min(4, number1 - minNumber)
                        if maxDiff >= 2 {
                            number2 = max(minNumber, number1 - safeRandom(in: 2...maxDiff))
                        }
                    }
                } else {
                    // 等级2及以上，确保被减数至少为10，差值有意义
                    number1 = safeRandom(in: max(10, minNumber)...range.upperBound)
                    let maxSubtractor = number1 - 3 // 确保差值至少为3，减少结果为1或2的情况
                    number2 = safeRandom(in: minNumber...max(minNumber, maxSubtractor))

                    // 强化：避免相同数字相减
                    if number1 == number2 {
                        let maxDiff = min(6, number1 - minNumber)
                        if maxDiff >= 3 {
                            number2 = max(minNumber, number1 - safeRandom(in: 3...maxDiff))
                        } else if number1 > minNumber {
                            number2 = number1 - 1
                        }
                    }

                    // 确保差值不会太小，进一步减少结果为0、1的情况
                    if number1 - number2 <= 2 {
                        let maxDiff = min(7, number1 - minNumber)
                        if maxDiff >= 3 {
                            number2 = max(minNumber, number1 - safeRandom(in: 3...maxDiff))
                        }
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
                        let maxNum2 = max(2, range.upperBound / number1)
                        number2 = safeRandom(in: 2...min(maxNum2, maxFactor))
                    }
                }

                // 确保结果不超过范围
                if number1 * number2 > range.upperBound {
                    number2 = range.upperBound / number1
                    if number2 < 2 {
                        // 如果第二个因数小于2，重新生成更小的第一个因数
                        number1 = safeRandom(in: 2...min(maxFactor, range.upperBound / 2))
                        let maxNum2 = max(2, range.upperBound / number1)
                        number2 = safeRandom(in: 2...maxNum2)
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
                    let maxDivisor = max(2, range.upperBound / minQuotient)
                    if maxDivisor >= 2 {
                        number2 = safeRandom(in: 2...min(5, maxDivisor))
                    } else {
                        number2 = 2
                    }
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

    // MARK: - Three Number Question Generation
    // Note: Three-number question generation logic has been refactored into
    // QuestionGenerator+ThreeNumber.swift extension for better maintainability

    // MARK: - Pattern Detection
    // 检查是否存在重复数字模式，避免过于简单的题目，强化避免相同数字运算
    static func hasRepetitivePattern(num1: Int, num2: Int, num3: Int, op1: Question.Operation, op2: Question.Operation) -> Bool {
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
