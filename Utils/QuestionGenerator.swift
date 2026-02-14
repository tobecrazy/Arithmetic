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

        /// Minimum value for question numbers to ensure meaningful arithmetic (general)
        static let minNumberValue = 2

        /// Minimum value for Level 2+ addition/subtraction to avoid overly simple problems
        static let minNumberValueLevel2Plus = 3

        /// Minimum value for Level 3+ to ensure adequate challenge
        static let minNumberValueLevel3Plus = 5

        /// Minimum sum for addition operations in Level 2+ to ensure meaningful practice
        static let minSumLevel2Plus = 8

        /// Minimum difference for subtraction to ensure meaningful practice
        static let minDifferenceLevel2Plus = 3

        /// Fallback range for simple addition when generation fails
        static let fallbackNumberRange = 3...10

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
    /// | 5     | 1-50  | ×, ÷       | 70%          | 30%            |
    /// | 6     | 1-1000 | +, -, ×, ÷ | 10%          | 90%            |
    /// | 7     | Fractions | +, -, ×, ÷ | 50%         | 50% (fractions only, no simple +/- within 50) |
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

        // 如果仍然没有足够的题目，用简单的题目补充
        // Level 7 uses fraction questions as fallback, other levels use addition
        var fallbackAttempts = 0
        let maxFallbackAttempts = 1000 // Prevent infinite loops
        while questions.count < count && fallbackAttempts < maxFallbackAttempts {
            let fallbackQuestion: Question

            if difficultyLevel == .level7 {
                // Level 7 fallback: use fraction questions (no simple addition)
                fallbackQuestion = generatePureFractionQuestion()
            } else {
                // Other levels fallback: use simple addition
                let maxFallback = min(10, difficultyLevel.range.upperBound)
                let minFallback = difficultyLevel == .level1 ? 2 : Constants.minNumberValueLevel2Plus

                // Ensure minFallback <= maxFallback to avoid invalid range crashes
                guard minFallback <= maxFallback else {
                    print("⚠️ Warning: Invalid fallback range min=\(minFallback) max=\(maxFallback), using 1...10")
                    let num1 = Int.random(in: 1...10)
                    let num2 = Int.random(in: 1...10)
                    fallbackQuestion = Question(number1: num1, number2: num2, operation: .addition, difficultyLevel: difficultyLevel)
                    questions.append(fallbackQuestion)
                    continue
                }

                let num1 = Int.random(in: minFallback...maxFallback)
                let num2 = Int.random(in: minFallback...maxFallback)
                fallbackQuestion = Question(number1: num1, number2: num2, operation: .addition, difficultyLevel: difficultyLevel)
            }

            let combination = getCombinationKey(for: fallbackQuestion)

            if !generatedCombinations.contains(combination) {
                questions.append(fallbackQuestion)
                generatedCombinations.insert(combination)
                fallbackAttempts = 0 // Reset counter on success
            } else {
                fallbackAttempts += 1
                // If we've failed many times, relax the uniqueness requirement
                if fallbackAttempts > 100 {
                    // Just add the question even if it's a duplicate
                    questions.append(fallbackQuestion)
                    fallbackAttempts = 0
                }
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
    /// For commutative operations (addition and multiplication), the key normalizes
    /// the order to catch semantic duplicates (e.g., "3+5" and "5+3" are the same).
    ///
    /// - Parameter question: The question to generate a key for
    /// - Returns: A string uniquely identifying this specific arithmetic expression
    ///
    /// - Note: This method is used internally to track generated questions and avoid duplicates
    static func getCombinationKey(for question: Question) -> String {
        if question.numbers.count == 2 {
            let op = question.operations[0]
            let num1 = question.numbers[0]
            let num2 = question.numbers[1]

            // For commutative operations, normalize the order (smaller number first)
            if op == .addition || op == .multiplication {
                let minNum = min(num1, num2)
                let maxNum = max(num1, num2)
                return "\(minNum)\(op.rawValue)\(maxNum)"
            } else {
                return "\(num1)\(op.rawValue)\(num2)"
            }
        } else {
            // Three-number operations: keep original order due to precedence rules
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
        case .level5: return 0.3   // 等级5有30%概率生成三数运算
        case .level6: return 0.9   // 等级6有90%概率生成三数运算
        case .level7: return 0.5   // 等级7有50%概率生成三数运算
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
        // Special handling for Level 7 with fractions
        if difficultyLevel == .level7 {
            return generateLevel7TwoNumberQuestion()
        }

        let range = difficultyLevel.range
        let supportedOperations = difficultyLevel.supportedOperations

        // 随机选择一个支持的运算类型
        guard let operation = supportedOperations.randomElement() else {
            // 如果没有支持的运算，返回一个默认运算
            return Question(number1: 3, number2: 4, operation: .addition)
        }

        var number1: Int
        var number2: Int

        // 根据难度等级设置最小数字，确保足够的挑战性
        let minNumber: Int
        switch difficultyLevel {
        case .level1:
            minNumber = 2 // Level 1 保持基础
        case .level2:
            minNumber = Constants.minNumberValueLevel2Plus // Level 2 使用更高的最小值
        case .level3:
            minNumber = Constants.minNumberValueLevel3Plus // Level 3 使用更高的最小值
        case .level4:
            minNumber = 2 // 乘除法从2开始
        case .level5:
            minNumber = 2 // Level 5 乘除法从2开始（特殊处理两位数）
        case .level6:
            minNumber = Constants.minNumberValueLevel2Plus // 混合运算使用较高最小值
        case .level7:
            minNumber = Constants.minNumberValueLevel2Plus // Level 7 混合运算使用较高最小值
        }

        // 尝试生成符合条件的题目
        let maxAttempts = 10
        var attempts = 0

        repeat {
            switch operation {
            case .addition:
                // 加法：确保结果不超过范围上限，且避免过于简单的组合
                if difficultyLevel == .level1 {
                    number1 = safeRandom(in: minNumber...range.upperBound)
                    number2 = safeRandom(in: minNumber...range.upperBound)
                    if number1 + number2 > range.upperBound {
                        number2 = range.upperBound - number1
                    }
                    // Level 1: 避免相同数字和过小数字
                    if number1 == number2 || (number1 <= 2 && number2 <= 2) {
                        number1 = safeRandom(in: 2...range.upperBound)
                        let maxNum2 = range.upperBound - number1
                        if maxNum2 >= 2 {
                            number2 = safeRandom(in: 2...maxNum2)
                        } else {
                            // Fallback: use smaller number1 to have space for number2
                            number1 = safeRandom(in: 2...(range.upperBound - 2))
                            number2 = safeRandom(in: 2...(range.upperBound - number1))
                        }
                    }
                } else {
                    // 等级2及以上，确保总和达到最小值，避免过于简单
                    let minSum = Constants.minSumLevel2Plus
                    number1 = safeRandom(in: minNumber...range.upperBound)
                    let minSecondNumber = max(minNumber, minSum - number1)
                    let maxSecondNumber = range.upperBound - number1

                    if minSecondNumber <= maxSecondNumber {
                        number2 = safeRandom(in: minSecondNumber...maxSecondNumber)
                    } else {
                        // 重新选择第一个数字，确保能够满足最小和要求
                        let maxFirstNumber = range.upperBound - minSum + minNumber
                        // Safety check: ensure we have a valid range for number1
                        if minNumber <= maxFirstNumber {
                            number1 = safeRandom(in: minNumber...maxFirstNumber)
                            let newMinSecondNumber = max(minNumber, minSum - number1)
                            let newMaxSecondNumber = range.upperBound - number1
                            // Double-check the range is valid before calling safeRandom
                            if newMinSecondNumber <= newMaxSecondNumber {
                                number2 = safeRandom(in: newMinSecondNumber...newMaxSecondNumber)
                            } else {
                                // Fallback: use simpler values that we know will work
                                number1 = minNumber
                                number2 = minSum - minNumber
                            }
                        } else {
                            // Fallback: range too small, use minimum valid values
                            number1 = minNumber
                            number2 = min(minSum - minNumber, range.upperBound - number1)
                        }
                    }

                    // 严格避免相同数字
                    if number1 == number2 {
                        if number1 < range.upperBound - minNumber {
                            number2 = number1 + safeRandom(in: 1...3)
                        } else {
                            number1 = number2 - safeRandom(in: 1...3)
                        }
                    }
                }

            case .subtraction:
                // 减法：确保结果为正数且有意义的差值，严格避免相同数字相减
                let minDiff = difficultyLevel == .level1 ? 2 : Constants.minDifferenceLevel2Plus

                if difficultyLevel == .level1 {
                    number1 = safeRandom(in: (minNumber + minDiff)...range.upperBound)
                    let maxSubtractor = number1 - minDiff
                    number2 = safeRandom(in: minNumber...maxSubtractor)

                    // 严格避免相同数字相减
                    if number1 == number2 {
                        number2 = max(minNumber, number1 - minDiff)
                    }
                } else {
                    // 等级2及以上，确保被减数至少为一定值，差值有意义
                    let minMinuend = max(minDiff + minNumber, 10)
                    number1 = safeRandom(in: minMinuend...range.upperBound)
                    let maxSubtractor = number1 - minDiff
                    number2 = safeRandom(in: minNumber...max(minNumber, maxSubtractor))

                    // 严格避免相同数字相减
                    if number1 == number2 {
                        number2 = max(minNumber, number1 - minDiff)
                    }
                }

            case .multiplication:
                // 乘法：确保结果不超过范围上限，完全避免×1的情况

                // Level 5: Two-digit multiplication (at least one factor should be 10-50)
                if difficultyLevel == .level5 {
                    // One factor should be 10-50, the other 2-10
                    let useLargeFirst = Bool.random()
                    if useLargeFirst {
                        // First number is 10-50
                        number1 = safeRandom(in: 10...50)
                        let maxSecondFactor = min(10, range.upperBound / number1)
                        if maxSecondFactor >= 2 {
                            number2 = safeRandom(in: 2...maxSecondFactor)
                        } else {
                            // If range too small, adjust number1
                            number1 = safeRandom(in: 10...min(50, range.upperBound / 2))
                            number2 = 2
                        }
                    } else {
                        // Second number is 10-50
                        number2 = safeRandom(in: 10...50)
                        let maxFirstFactor = min(10, range.upperBound / number2)
                        if maxFirstFactor >= 2 {
                            number1 = safeRandom(in: 2...maxFirstFactor)
                        } else {
                            // If range too small, adjust number2
                            number2 = safeRandom(in: 10...min(50, range.upperBound / 2))
                            number1 = 2
                        }
                    }

                    // Ensure result is within range
                    if number1 * number2 > range.upperBound {
                        let largeFactor = max(number1, number2)
                        let smallFactor = min(number1, number2)
                        let newSmallFactor = max(2, range.upperBound / largeFactor)
                        if largeFactor == number1 {
                            number2 = newSmallFactor
                        } else {
                            number1 = newSmallFactor
                        }
                    }
                } else {
                    // Standard multiplication for other levels
                    let maxFactor = min(range.upperBound, Int(sqrt(Double(range.upperBound))))

                    // 完全禁止×1的题目，确保至少从2开始
                    let actualMinFactor = max(2, minNumber)
                    number1 = safeRandom(in: actualMinFactor...maxFactor)

                    let minSecondFactor = max(2, actualMinFactor) // 确保第二个因数至少为2
                    let maxSecondFactor = min(range.upperBound / number1, maxFactor)

                    if maxSecondFactor >= minSecondFactor {
                        number2 = safeRandom(in: minSecondFactor...maxSecondFactor)
                    } else {
                        // 重新生成更小的第一个因数
                        let maxFirstFactor = min(maxFactor, range.upperBound / minSecondFactor)
                        if actualMinFactor <= maxFirstFactor {
                            number1 = safeRandom(in: actualMinFactor...maxFirstFactor)
                            let newMaxSecondFactor = min(range.upperBound / number1, maxFactor)
                            if minSecondFactor <= newMaxSecondFactor {
                                number2 = safeRandom(in: minSecondFactor...newMaxSecondFactor)
                            } else {
                                // Fallback to safe values
                                number1 = actualMinFactor
                                number2 = minSecondFactor
                            }
                        } else {
                            // Range too constrained, use minimum values
                            number1 = actualMinFactor
                            number2 = minSecondFactor
                        }
                    }

                    // 确保结果不超过范围
                    if number1 * number2 > range.upperBound {
                        number2 = max(minSecondFactor, range.upperBound / number1)
                    }

                    // 双重保险：确保没有因数为1
                    if number1 == 1 { number1 = 2 }
                    if number2 == 1 { number2 = 2 }

                    // 再次验证范围
                    if number1 * number2 > range.upperBound {
                        let maxFirstFactor = min(maxFactor, range.upperBound / minSecondFactor)
                        if actualMinFactor <= maxFirstFactor {
                            number1 = safeRandom(in: actualMinFactor...maxFirstFactor)
                            number2 = max(minSecondFactor, min(range.upperBound / number1, maxFactor))
                        } else {
                            number1 = actualMinFactor
                            number2 = minSecondFactor
                        }
                    }
                }

            case .division:
                // 除法：确保整除（除非Level 7允许分数），严格避免相同数字和结果为1
                let allowFractions = difficultyLevel == .level7

                if allowFractions {
                    // Level 7: Allow fraction results (about 30% of division questions should have fractions)
                    let shouldBeFraction = Double.random(in: 0...1) < 0.3

                    if shouldBeFraction {
                        // Generate a division that results in a pedagogically meaningful fraction
                        // Use reverse generation: start with a target fraction structure
                        // This ensures results like 1/2, 2/3, 3/4 instead of 21/10

                        // Common denominators for educational fractions
                        let commonDenominators = [2, 3, 4, 5, 6, 8, 10, 12]
                        let divisor = commonDenominators.randomElement()!

                        // Generate a numerator that produces a meaningful fraction
                        let useImproper = Double.random(in: 0...1) < 0.3 // 30% improper fractions
                        var numerator: Int

                        if useImproper {
                            // Improper fraction with result between 1 and 3
                            let wholePartMultiplier = Int.random(in: 1...2)
                            let remainder = Int.random(in: 1...(divisor - 1))
                            numerator = wholePartMultiplier * divisor + remainder
                        } else {
                            // Proper fraction (result < 1)
                            numerator = Int.random(in: 1...(divisor - 1))
                        }

                        // Ensure numerator doesn't divide evenly by divisor
                        if numerator % divisor == 0 {
                            numerator = max(1, numerator - 1)
                        }

                        // Validate within range
                        if numerator <= range.upperBound {
                            number1 = numerator
                            number2 = divisor
                        } else {
                            // Fallback: use simpler fraction
                            number2 = [2, 3, 4, 5].randomElement()!
                            number1 = Int.random(in: 1...(number2 - 1))
                        }
                    } else {
                        // Generate an integer division for Level 7
                        let actualMinDivisor = max(2, minNumber)
                        let actualMinQuotient = 2

                        number2 = safeRandom(in: actualMinDivisor...min(10, range.upperBound))
                        let maxPossibleQuotient = range.upperBound / number2
                        let minQuotient = actualMinQuotient
                        let maxQuotient = max(minQuotient, maxPossibleQuotient)

                        let quotient = safeRandom(in: minQuotient...maxQuotient)
                        number1 = quotient * number2

                        if number1 > range.upperBound {
                            let maxDivisor = max(actualMinDivisor, range.upperBound / minQuotient)
                            let safeDivisorMax = min(10, maxDivisor)
                            if actualMinDivisor <= safeDivisorMax {
                                number2 = safeRandom(in: actualMinDivisor...safeDivisorMax)
                            } else {
                                number2 = actualMinDivisor
                            }
                            number1 = minQuotient * number2
                        }
                    }
                } else if difficultyLevel == .level5 {
                    // Level 5: Two-digit division (quotient 2-50, divisor 2-10)
                    let divisor = safeRandom(in: 2...10)
                    let quotient = safeRandom(in: 2...min(50, range.upperBound / divisor))
                    number1 = quotient * divisor
                    number2 = divisor

                    // Ensure range compliance
                    if number1 > range.upperBound {
                        let maxQuotient = range.upperBound / divisor
                        if maxQuotient >= 2 {
                            number1 = safeRandom(in: 2...maxQuotient) * divisor
                        } else {
                            number1 = 2 * divisor
                        }
                    }

                    // Avoid dividend equals divisor
                    if number1 == number2 {
                        number1 = (quotient + 1) * number2
                        if number1 > range.upperBound {
                            number1 = max(2, quotient - 1) * number2
                        }
                    }
                } else {
                    // Standard division for other levels (integer results only)
                    let actualMinDivisor = max(2, minNumber)
                    let actualMinQuotient: Int

                    switch difficultyLevel {
                    case .level1:
                        actualMinQuotient = 2
                    case .level4:
                        actualMinQuotient = 3 // Level 4 最小商为3
                    case .level5, .level6:
                        actualMinQuotient = 4 // Level 5/6 最小商为4
                    default:
                        actualMinQuotient = 3
                    }

                    // 选择除数（至少为2）
                    number2 = safeRandom(in: actualMinDivisor...min(10, range.upperBound))

                    // 计算可能的最大商
                    let maxPossibleQuotient = range.upperBound / number2
                    let minQuotient = actualMinQuotient
                    let maxQuotient = max(minQuotient, maxPossibleQuotient)

                    let quotient: Int
                    if maxQuotient >= minQuotient {
                        // 优先选择较大的商（70%概率选择上半区间）
                        if maxQuotient > minQuotient + 2 {
                            let isLargerRange = Double.random(in: 0...1) < 0.7
                            if isLargerRange {
                                let midPoint = (minQuotient + maxQuotient) / 2
                                quotient = safeRandom(in: midPoint...maxQuotient)
                            } else {
                                quotient = safeRandom(in: minQuotient...maxQuotient)
                            }
                        } else {
                            quotient = safeRandom(in: minQuotient...maxQuotient)
                        }
                    } else {
                        quotient = minQuotient
                    }

                    // 计算被除数
                    number1 = quotient * number2

                    // 验证范围
                    if number1 > range.upperBound {
                        let maxDivisor = max(actualMinDivisor, range.upperBound / minQuotient)
                        let safeDivisorMax = min(5, maxDivisor)
                        if actualMinDivisor <= safeDivisorMax {
                            number2 = safeRandom(in: actualMinDivisor...safeDivisorMax)
                        } else {
                            number2 = actualMinDivisor
                        }
                        number1 = minQuotient * number2
                    }

                    // 严格避免被除数等于除数
                    if number1 == number2 {
                        let newQuotient = max(actualMinQuotient, quotient + 1)
                        if newQuotient * number2 <= range.upperBound {
                            number1 = newQuotient * number2
                        } else {
                            // 减小除数
                            if number2 > actualMinDivisor {
                                number2 -= 1
                                number1 = max(actualMinQuotient, quotient) * number2
                            } else {
                                // 最后调整
                                number1 = actualMinQuotient * number2
                            }
                        }
                    }

                    // 最终验证：确保结果不为1
                    if number2 != 0 && number1 / number2 < actualMinQuotient {
                        number1 = actualMinQuotient * number2
                        if number1 > range.upperBound {
                            number2 = max(actualMinDivisor, range.upperBound / actualMinQuotient)
                            number1 = actualMinQuotient * number2
                        }
                    }
                }
            }

            attempts += 1
        } while (number1 <= 0 || number2 <= 0 ||
                 number1 == number2 && (operation == .subtraction || (operation == .division && difficultyLevel != .level7)) || // 避免减法和除法中的相同数字（除非Level 7允许分数）
                 (operation == .multiplication && (number1 == 1 || number2 == 1)) || // 避免乘法中的1
                 (operation == .multiplication && number1 * number2 > range.upperBound) ||
                 (operation == .division && number1 > range.upperBound) ||
                 (operation == .subtraction && number1 - number2 < (difficultyLevel == .level1 ? 2 : Constants.minDifferenceLevel2Plus)) ||
                 (operation == .addition && difficultyLevel != .level1 && number1 + number2 < Constants.minSumLevel2Plus) ||
                 (operation == .division && number2 != 0 && (number1 / number2 < 2 || (difficultyLevel != .level7 && number1 % number2 != 0)))) && attempts < maxAttempts

        // 最后的安全检查和调整
        if number1 <= 0 || number2 <= 0 {
            number1 = max(minNumber, number1)
            number2 = max(minNumber, number2)
        }

        return Question(number1: number1, number2: number2, operation: operation, difficultyLevel: difficultyLevel)
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

        // 强化：如果所有数字都小于等于3，且有重复，则拒绝（过于简单）
        if numbers.allSatisfy({ $0 <= 3 }) && uniqueNumbers.count < 3 {
            return true
        }

        // 如果有两个相同数字，更严格地检查是否会产生过于简单的运算
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
                    // 即使是加法或乘法，如果数字太小也拒绝
                    if num1 <= 3 {
                        return true
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
                        // 这种情况相对复杂，但如果数字太小仍然拒绝
                        if num1 <= 3 {
                            return true
                        }
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
                        // 如果是 B + B 或 B × B，但数字太小，也拒绝
                        if num2 <= 3 {
                            return true
                        }
                    } else {
                        // 左到右计算: (A op1 B) op2 B
                        // 如果第二个操作是减法或除法，检查是否会产生简单结果
                        if op2 == .subtraction || op2 == .division {
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

        // 额外检查：避免像 2+2+2 或 3+3+3 这样过于简单的重复模式
        if uniqueNumbers.count == 1 || (uniqueNumbers.count == 2 && numbers.filter({ $0 == numbers[0] }).count >= 2) {
            // 如果有重复数字且都是相同的简单操作
            if (op1 == .addition && op2 == .addition) || (op1 == .multiplication && op2 == .multiplication) {
                if num1 == num2 || num2 == num3 || num1 == num3 {
                    return true
                }
            }
        }

        return false // 没有发现重复模式，允许生成
    }

    // MARK: - Level 7 Fraction Question Generation

    /// Generates a Level 7 question with fractions only (no simple addition/subtraction within 50)
    /// Distribution: 50% pure fractions, 30% mixed (int+frac), 20% integer multiplication/division
    private static func generateLevel7TwoNumberQuestion() -> Question {
        let rand = Double.random(in: 0...1)

        if rand < 0.5 {
            // 50% pure fraction operations (both operands are fractions)
            return generatePureFractionQuestion()
        } else if rand < 0.8 {
            // 30% mixed operations (one integer, one fraction)
            return generateMixedFractionQuestion()
        } else {
            // 20% integer multiplication/division only (no addition/subtraction)
            return generateLevel7IntegerMultiplicationDivision()
        }
    }

    /// Generates an integer multiplication or division question for Level 7
    /// This avoids simple addition/subtraction within 50
    private static func generateLevel7IntegerMultiplicationDivision() -> Question {
        let operation: Question.Operation = Bool.random() ? .multiplication : .division

        if operation == .multiplication {
            // Generate multiplication: result should be reasonable (not too large)
            let num1 = Int.random(in: 2...12)
            let num2 = Int.random(in: 2...12)
            return Question(number1: num1, number2: num2, operation: .multiplication, difficultyLevel: .level7)
        } else {
            // Generate division that may or may not result in integer
            // Distribution: 40% integer division, 30% simple fraction, 30% reducible fraction (e.g., 25÷15=5/3)
            let rand = Double.random(in: 0...1)

            if rand < 0.4 {
                // 40% Integer division (e.g., 24 ÷ 6 = 4)
                let quotient = Int.random(in: 2...10)
                let divisor = Int.random(in: 2...10)
                let dividend = quotient * divisor
                return Question(number1: dividend, number2: divisor, operation: .division, difficultyLevel: .level7)
            } else if rand < 0.7 {
                // 30% Simple non-integer division with small numbers
                // Results in simple fractions like 1/2, 2/3, 3/4
                return generateSimpleFractionDivision()
            } else {
                // 30% Reducible fraction division (e.g., 25÷15=5/3, 14÷21=2/3)
                // Two larger integers that share a common factor
                return generateReducibleFractionDivision()
            }
        }
    }

    /// Generates a division question with small numbers resulting in a simple fraction
    /// Examples: 1÷2=1/2, 2÷3=2/3, 3÷4=3/4
    private static func generateSimpleFractionDivision() -> Question {
        // Common denominators for educational fractions
        let commonDenominators = [2, 3, 4, 5, 6, 8, 10, 12]
        let divisor = commonDenominators.randomElement()!

        // Generate a numerator that doesn't divide evenly by divisor
        var numerator: Int
        repeat {
            // 30% improper fractions (result > 1), 70% proper fractions (result < 1)
            let useImproper = Double.random(in: 0...1) < 0.3

            if useImproper {
                // Generate improper fraction with result between 1 and 3
                let wholePartMultiplier = Int.random(in: 1...2)
                let remainder = Int.random(in: 1...(divisor - 1))
                numerator = wholePartMultiplier * divisor + remainder
            } else {
                // Generate proper fraction (result < 1)
                numerator = Int.random(in: 1...(divisor - 1))
            }
        } while numerator % divisor == 0 // Ensure it doesn't divide evenly

        // Ensure dividend is within reasonable range (1-100)
        if numerator > 100 {
            // Fallback to simpler fraction
            let simpleDivisor = [2, 3, 4, 5].randomElement()!
            let simpleNumerator = Int.random(in: 1...(simpleDivisor - 1))
            return Question(number1: simpleNumerator, number2: simpleDivisor, operation: .division, difficultyLevel: .level7)
        }

        return Question(number1: numerator, number2: divisor, operation: .division, difficultyLevel: .level7)
    }

    /// Generates a division question where both numbers are larger and share a common factor
    /// The result simplifies to a nice fraction
    /// Examples: 25÷15=5/3, 14÷21=2/3, 10÷15=2/3, 12÷18=2/3, 35÷21=5/3
    private static func generateReducibleFractionDivision() -> Question {
        // Target simplified fractions that are pedagogically meaningful
        let targetFractions: [(numerator: Int, denominator: Int)] = [
            (1, 2), (1, 3), (2, 3), (1, 4), (3, 4),
            (1, 5), (2, 5), (3, 5), (4, 5),
            (1, 6), (5, 6),
            (2, 7), (3, 7), (4, 7), (5, 7),
            (3, 8), (5, 8), (7, 8),
            // Improper fractions (result > 1)
            (3, 2), (4, 3), (5, 3), (5, 4), (7, 4),
            (6, 5), (7, 5), (8, 5),
            (7, 6), (8, 3), (9, 4), (7, 3)
        ]

        let target = targetFractions.randomElement()!

        // Multiply both numerator and denominator by a common factor to get larger numbers
        // Factor range: 2-10 for variety
        let factor = Int.random(in: 2...10)

        let dividend = target.numerator * factor   // e.g., 5 * 5 = 25
        let divisor = target.denominator * factor  // e.g., 3 * 5 = 15

        // Validate: ensure both numbers are within range and divisor != 0
        guard divisor > 0 && dividend <= 100 && divisor <= 100 else {
            // Fallback: use smaller factor
            let smallFactor = Int.random(in: 2...5)
            let smallDividend = target.numerator * smallFactor
            let smallDivisor = target.denominator * smallFactor
            return Question(number1: smallDividend, number2: smallDivisor, operation: .division, difficultyLevel: .level7)
        }

        return Question(number1: dividend, number2: divisor, operation: .division, difficultyLevel: .level7)
    }

    /// Generates a question with both operands as fractions
    /// Examples: 1/2 + 1/3, 3/4 - 1/8, 2/3 × 1/2, 5/6 ÷ 1/3
    private static func generatePureFractionQuestion() -> Question {
        let operation = Question.Operation.allCases.randomElement()!

        // Generate two fractions
        let frac1 = generateRandomFraction()
        let frac2 = generateRandomFraction()

        // Create question with fraction operands
        let question = Question(operand1: frac1, operand2: frac2, operation: operation, difficultyLevel: .level7)

        // Validate the result is reasonable
        if let fractionAnswer = question.fractionAnswer {
            // Check if result is too large or negative
            if abs(fractionAnswer.numerator) > 100 || abs(fractionAnswer.denominator) > 100 {
                // Retry with simpler fractions
                return generatePureFractionQuestion()
            }
            if fractionAnswer.numerator < 0 {
                // Avoid negative results for subtraction
                return generatePureFractionQuestion()
            }
        }

        return question
    }

    /// Generates a question with one integer and one fraction
    /// Examples: 2 × 1/4, 3 + 1/2, 5 - 1/3, 6 ÷ 1/2
    private static func generateMixedFractionQuestion() -> Question {
        let operation = Question.Operation.allCases.randomElement()!

        // Generate integer (2-10)
        let integer = Int.random(in: 2...10)

        // Generate fraction
        let fraction = generateRandomFraction()

        // Randomly decide which operand is the fraction
        let fractionIsSecond = Bool.random()

        let question: Question
        if fractionIsSecond {
            question = Question(operand1: integer, operand2: fraction, operation: operation, difficultyLevel: .level7)
        } else {
            question = Question(operand1: fraction, operand2: integer, operation: operation, difficultyLevel: .level7)
        }

        // Validate the result
        if let fractionAnswer = question.fractionAnswer {
            if abs(fractionAnswer.numerator) > 100 || abs(fractionAnswer.denominator) > 100 {
                return generateMixedFractionQuestion()
            }
            if fractionAnswer.numerator < 0 {
                return generateMixedFractionQuestion()
            }
        }

        return question
    }

    /// Generates a random fraction for Level 7
    /// 70% use common denominators (2,3,4,5,6,8,10,12)
    /// 30% use random denominators (2-20)
    private static func generateRandomFraction() -> Fraction {
        let useCommonDenominator = Double.random(in: 0...1) < 0.7

        let denominator: Int
        if useCommonDenominator {
            let commonDenominators = [2, 3, 4, 5, 6, 8, 10, 12]
            denominator = commonDenominators.randomElement()!
        } else {
            denominator = Int.random(in: 2...20)
        }

        // Numerator should be less than denominator for proper fractions (mostly)
        // But allow some improper fractions (20% chance)
        let allowImproper = Double.random(in: 0...1) < 0.2
        let numerator: Int
        if allowImproper {
            numerator = Int.random(in: 1...(denominator * 2))
        } else {
            numerator = Int.random(in: 1...(denominator - 1))
        }

        return Fraction(numerator: numerator, denominator: denominator)
    }

    /// Generates a Level 7 three-number question with fractions only
    /// 60% include at least one fraction, 40% integer multiplication/division chains
    static func generateLevel7ThreeNumberQuestion() -> Question {
        let rand = Double.random(in: 0...1)

        if rand < 0.6 {
            // 60% include at least one fraction operand
            return generateThreeNumberWithFractions()
        } else {
            // 40% integer multiplication/division chains (no simple add/sub)
            return generateLevel7IntegerThreeNumberQuestion()
        }
    }

    /// Generates a Level 7 three-number question with only multiplication and division
    /// Avoids simple addition/subtraction within 50
    private static func generateLevel7IntegerThreeNumberQuestion() -> Question {
        // Only use multiplication and division for integer three-number questions
        let operations: [Question.Operation] = [.multiplication, .division]
        let op1 = operations.randomElement()!
        let op2 = operations.randomElement()!

        var num1, num2, num3: Int

        // Generate numbers that work well with multiplication/division
        if op1 == .multiplication && op2 == .multiplication {
            // A × B × C - keep numbers small
            num1 = Int.random(in: 2...5)
            num2 = Int.random(in: 2...5)
            num3 = Int.random(in: 2...5)
        } else if op1 == .division && op2 == .division {
            // A ÷ B ÷ C - need careful construction for integer results
            num2 = Int.random(in: 2...5)
            num3 = Int.random(in: 2...5)
            let quotient1 = Int.random(in: 2...5)
            let quotient2 = quotient1 * num3
            num1 = quotient2 * num2
        } else if op1 == .multiplication && op2 == .division {
            // A × B ÷ C
            num1 = Int.random(in: 2...6)
            num3 = Int.random(in: 2...6)
            // Ensure (A × B) is divisible by C
            let multiplier = Int.random(in: 1...3)
            num2 = num3 * multiplier
        } else {
            // A ÷ B × C
            num2 = Int.random(in: 2...5)
            num3 = Int.random(in: 2...5)
            let quotient = Int.random(in: 2...5)
            num1 = quotient * num2
        }

        let question = Question(number1: num1, number2: num2, number3: num3,
                               operation1: op1, operation2: op2, difficultyLevel: .level7)

        // Validate the question
        if question.isValid() && question.correctAnswer > 0 && question.correctAnswer <= 1000 {
            return question
        }

        // Fallback to fraction question if validation fails
        return generateThreeNumberWithFractions()
    }

    /// Generates a three-number question with at least one fraction
    /// Uses denominator families for simplicity (1/2, 1/4, 1/8 or 1/3, 1/6, 1/9)
    private static func generateThreeNumberWithFractions() -> Question {
        // Choose a denominator family
        let families: [[Int]] = [
            [2, 4, 8],     // Halves family
            [3, 6, 9],     // Thirds family
            [5, 10],       // Fifths family
        ]

        let family = families.randomElement()!
        let operations = [Question.Operation.addition, Question.Operation.subtraction]

        // Generate three operands from the same family or integers
        var operands: [Any] = []
        for _ in 0..<3 {
            if Bool.random() {
                // Use a fraction from the family
                let denom = family.randomElement()!
                let numer = Int.random(in: 1...(denom - 1))
                operands.append(Fraction(numerator: numer, denominator: denom))
            } else {
                // Use a small integer
                operands.append(Int.random(in: 1...5))
            }
        }

        // Ensure at least one is a fraction
        let hasFraction = operands.contains { $0 is Fraction }
        if !hasFraction {
            // Replace first operand with a fraction
            let denom = family.randomElement()!
            let numer = Int.random(in: 1...(denom - 1))
            operands[0] = Fraction(numerator: numer, denominator: denom)
        }

        let op1 = operations.randomElement()!
        let op2 = operations.randomElement()!

        let question = Question(
            operand1: operands[0],
            operand2: operands[1],
            operand3: operands[2],
            operation1: op1,
            operation2: op2,
            difficultyLevel: .level7
        )

        // Validate result
        if let fractionAnswer = question.fractionAnswer {
            if abs(fractionAnswer.numerator) > 100 || abs(fractionAnswer.denominator) > 100 {
                return generateThreeNumberWithFractions()
            }
            if fractionAnswer.numerator < 0 {
                return generateThreeNumberWithFractions()
            }
        }

        return question
    }
}
