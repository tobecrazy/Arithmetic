import Foundation

class Question: NSObject, NSSecureCoding, Identifiable {
    static var supportsSecureCoding: Bool { true }
    let id: UUID
    let numbers: [Int]
    let operations: [Operation]
    let difficultyLevel: DifficultyLevel?

    // Answer type enumeration
    enum AnswerType: String, Codable {
        case integer
        case fraction
    }

    // Store fraction answer when applicable
    let fractionAnswer: Fraction?

    // Store computed integer answer (for fraction operations that result in whole numbers)
    let computedAnswer: Int?

    // Store fraction operands when applicable (nil entry means use integer from numbers array)
    // Examples:
    // - 1/2 + 1/3: fractionOperands = [Fraction(1,2), Fraction(1,3)], numbers = [0,0]
    // - 2 × 1/4:   fractionOperands = [nil, Fraction(1,4)], numbers = [2,0]
    // - 3 + 5:     fractionOperands = nil, numbers = [3,5] (existing behavior)
    let fractionOperands: [Fraction?]?

    // Determine if answer should be a fraction
    var answerType: AnswerType {
        // Only Level 7 can have fraction answers
        guard let level = difficultyLevel, level == .level7 else {
            return .integer
        }

        // Check if we have fraction operands - this takes precedence
        if let fractionOps = fractionOperands, fractionOps.contains(where: { $0 != nil }) {
            // If we have a computed integer answer, it's still an integer
            if computedAnswer != nil {
                return .integer
            }
            // Otherwise, if we have a fraction answer, it's a fraction
            if fractionAnswer != nil {
                return .fraction
            }
        }

        // Check if any division operation results in a non-integer
        if numbers.count == 2 && operations.count == 1 && operations[0] == .division {
            let num1 = numbers[0]
            let num2 = numbers[1]
            if num2 != 0 && num1 % num2 != 0 {
                return .fraction
            }
        } else if numbers.count == 3 && operations.count == 2 {
            // For three-number operations, check if any intermediate division is non-integer
            let op1 = operations[0]
            let op2 = operations[1]

            if op1.precedence < op2.precedence {
                // Second operation has higher precedence
                if op2 == .division && numbers[1] % numbers[2] != 0 {
                    return .fraction
                }
            } else {
                // First operation has higher or same precedence
                if op1 == .division && numbers[0] % numbers[1] != 0 {
                    return .fraction
                } else if op2 == .division {
                    // Calculate intermediate result first
                    var intermediateResult = 0
                    switch op1 {
                    case .addition: intermediateResult = numbers[0] + numbers[1]
                    case .subtraction: intermediateResult = numbers[0] - numbers[1]
                    case .multiplication: intermediateResult = numbers[0] * numbers[1]
                    case .division: intermediateResult = numbers[0] / numbers[1]
                    }
                    if intermediateResult % numbers[2] != 0 {
                        return .fraction
                    }
                }
            }
        }

        return .integer
    }

    // 解题方法枚举
    enum SolutionMethod: String, Codable {
        case breakingTen = "breaking_ten"  // 破十法
        case borrowingTen = "borrowing_ten"  // 借十法
        case makingTen = "making_ten"  // 凑十法
        case levelingTen = "leveling_ten"  // 平十法
        case multiplicationTable = "multiplication_table"  // 乘法口诀法
        case decompositionMultiplication = "decomposition_multiplication"  // 分解乘法
        case divisionVerification = "division_verification"  // 除法验算法
        case groupingDivision = "grouping_division"  // 分组除法
        case standard = "standard"  // 标准计算
        
        var localizedName: String {
            return "solution.\(self.rawValue)".localized
        }
    }
    
    // 计算正确答案 (for integer answers)
    var correctAnswer: Int {
        if answerType == .fraction {
            // For fractions, return 0 as placeholder; use fractionAnswer instead
            return 0
        }

        // Check if we have a precomputed answer from fraction operations
        if let computed = computedAnswer {
            return computed
        }

        if numbers.count == 2 && operations.count == 1 {
            // 简单的两数运算
            switch operations[0] {
            case .addition: return numbers[0] + numbers[1]
            case .subtraction: return numbers[0] - numbers[1]
            case .multiplication: return numbers[0] * numbers[1]
            case .division: return numbers[1] != 0 ? numbers[0] / numbers[1] : 0
            }
        } else if numbers.count == 3 && operations.count == 2 {
            // Three-number operations with order of operations (PEMDAS/BODMAS)
            // Higher precedence for multiplication and division
            let num1 = numbers[0]
            let num2 = numbers[1]
            let num3 = numbers[2]
            let op1 = operations[0]
            let op2 = operations[1]

            let op1Precedence = op1.precedence
            let op2Precedence = op2.precedence

            if op1Precedence < op2Precedence {
                // Second operation has higher precedence (e.g., A + B * C or A - B / C)
                var intermediateResult2: Int
                switch op2 {
                case .multiplication:
                    intermediateResult2 = num2 * num3
                case .division:
                    intermediateResult2 = num3 != 0 ? num2 / num3 : 0 // Handle division by zero
                default:
                    // Should not happen as precedence rules mean op2 must be * or / here
                    intermediateResult2 = 0
                }

                switch op1 {
                case .addition:
                    return num1 + intermediateResult2
                case .subtraction:
                    return num1 - intermediateResult2
                default:
                    // Should not happen
                    return 0
                }
            } else {
                // Operations have same precedence or first operation has higher precedence
                // (e.g., A * B + C, A / B - C, A + B - C, A * B / C)
                // Calculate left-to-right
                var intermediateResult1: Int
                switch op1 {
                case .addition:
                    intermediateResult1 = num1 + num2
                case .subtraction:
                    intermediateResult1 = num1 - num2
                case .multiplication:
                    intermediateResult1 = num1 * num2
                case .division:
                    intermediateResult1 = num2 != 0 ? num1 / num2 : 0 // Handle division by zero
                }

                switch op2 {
                case .addition:
                    return intermediateResult1 + num3
                case .subtraction:
                    return intermediateResult1 - num3
                case .multiplication:
                    return intermediateResult1 * num3
                case .division:
                    return num3 != 0 ? intermediateResult1 / num3 : 0 // Handle division by zero
                }
            }
        }
        return 0 // Default return for invalid setup (should not happen)
    }
    
    enum Operation: String, CaseIterable, Codable {
        case addition = "+"
        case subtraction = "-"
        case multiplication = "×"
        case division = "÷"
        
        var symbol: String {
            return self.rawValue
        }

        // Precedence for order of operations
        // Higher number means higher precedence
        var precedence: Int {
            switch self {
            case .addition, .subtraction:
                return 1
            case .multiplication, .division:
                return 2
            }
        }
    }

    // Check integer answer
    func checkAnswer(_ intAnswer: Int) -> Bool {
        guard answerType == .integer else {
            return false
        }
        return intAnswer == correctAnswer
    }

    // Get the correct answer as a display string (handles both integer and fraction)
    var correctAnswerText: String {
        if answerType == .fraction {
            if let fraction = fractionAnswer {
                return fraction.unicodeDescription
            }
        }
        if let computed = computedAnswer {
            return String(computed)
        }
        return String(correctAnswer)
    }

    // Check fraction answer
    func checkAnswer(_ fractionAnswer: Fraction) -> Bool {
        guard answerType == .fraction, let correctFraction = self.fractionAnswer else {
            return false
        }
        return fractionAnswer == correctFraction
    }

    // Check decimal answer (with tolerance for repeating decimals like 0.333... ≈ 1/3)
    func checkDecimalAnswer(_ decimal: Double, tolerance: Double = 0.001) -> Bool {
        if answerType == .fraction {
            // Compare against fraction answer
            guard let fraction = fractionAnswer else {
                return false
            }
            return abs(fraction.toDecimal() - decimal) < tolerance
        } else {
            // Compare against integer answer
            return abs(Double(correctAnswer) - decimal) < tolerance
        }
    }

    // Compute correct fraction answer
    func computeFractionAnswer() -> Fraction? {
        guard answerType == .fraction else {
            return nil
        }

        if numbers.count == 2 && operations.count == 1 && operations[0] == .division {
            let num1 = numbers[0]
            let num2 = numbers[1]
            guard num2 != 0 else { return nil }
            return Fraction(numerator: num1, denominator: num2).simplified()
        } else if numbers.count == 3 && operations.count == 2 {
            // For three-number operations with fractions, this is more complex
            // For now, return nil (will be implemented if needed)
            return nil
        }

        return nil
    }

    // 用于检查题目是否重复
    static func == (lhs: Question, rhs: Question) -> Bool {
        return lhs.numbers == rhs.numbers && lhs.operations == rhs.operations
    }
    
    // 验证题目是否数学上合理（所有除法都能整除，且所有中间结果为正数）
    // For Level 7, allow non-integer division results (fractions)
    func isValid() -> Bool {
        // Level 7 allows fractions, so division doesn't need to be exact
        let allowFractions = difficultyLevel == .level7

        if numbers.count == 2 && operations.count == 1 {
            // 两数运算验证
            switch operations[0] {
            case .subtraction:
                // 对于减法，确保第一个数大于等于第二个数（避免负数结果）
                return numbers[0] >= numbers[1]
            case .division:
                if allowFractions {
                    // For Level 7, only check division by zero
                    return numbers[1] != 0
                } else {
                    // For other levels, division must be exact
                    return numbers[1] != 0 && numbers[0] % numbers[1] == 0
                }
            default:
                return true
            }
        } else if numbers.count == 3 && operations.count == 2 {
            // 三数运算验证 - 需要考虑运算顺序
            let num1 = numbers[0]
            let num2 = numbers[1]
            let num3 = numbers[2]
            let op1 = operations[0]
            let op2 = operations[1]

            // 检查所有可能的除法操作是否能整除，以及中间结果是否为正数
            // For Level 7, allow fractions
            let allowFractions = difficultyLevel == .level7

            if op1.precedence < op2.precedence {
                // 第二个操作优先级更高 (e.g., A + B ÷ C 或 A - B × C)
                // 先计算 B op2 C
                var intermediateResult2: Int
                if op2 == .division {
                    // 检查 B ÷ C 是否能整除 (unless Level 7 allows fractions)
                    if num3 == 0 {
                        return false
                    }
                    if !allowFractions && num2 % num3 != 0 {
                        return false
                    }
                    intermediateResult2 = num2 / num3
                } else if op2 == .multiplication {
                    intermediateResult2 = num2 * num3
                } else if op2 == .subtraction {
                    intermediateResult2 = num2 - num3
                    // 确保中间结果为正数
                    if intermediateResult2 <= 0 {
                        return false
                    }
                } else { // addition
                    intermediateResult2 = num2 + num3
                }

                // 然后计算 A op1 intermediateResult2
                if op1 == .subtraction {
                    // 对于 A - intermediateResult2，确保 A >= intermediateResult2
                    if num1 < intermediateResult2 {
                        return false
                    }
                }
            } else {
                // 第一个操作优先级更高或相等 (e.g., A ÷ B × C 或 A × B ÷ C 或 A + B - C)
                // 先计算 A op1 B
                var intermediateResult1: Int
                if op1 == .division {
                    // 检查 A ÷ B 是否能整除 (unless Level 7 allows fractions)
                    if num2 == 0 {
                        return false
                    }
                    if !allowFractions && num1 % num2 != 0 {
                        return false
                    }
                    intermediateResult1 = num1 / num2
                } else if op1 == .subtraction {
                    intermediateResult1 = num1 - num2
                    // 确保中间结果为正数
                    if intermediateResult1 <= 0 {
                        return false
                    }
                } else if op1 == .multiplication {
                    intermediateResult1 = num1 * num2
                } else { // addition
                    intermediateResult1 = num1 + num2
                }

                // 然后计算 intermediateResult1 op2 C
                if op2 == .division {
                    // 检查 intermediateResult1 ÷ C 是否能整除 (unless Level 7 allows fractions)
                    if num3 == 0 {
                        return false
                    }
                    if !allowFractions && intermediateResult1 % num3 != 0 {
                        return false
                    }
                } else if op2 == .subtraction {
                    // 对于 intermediateResult1 - C，确保 intermediateResult1 >= C
                    if intermediateResult1 < num3 {
                        return false
                    }
                }
            }

            // 额外检查：确保最终结果为正整数
            let finalResult = self.correctAnswer
            return finalResult > 0
        }
        return false
    }
    
    // 题目的字符串表示
    var questionText: String {
        // Handle fraction operands
        if let fractionOps = fractionOperands {
            var parts: [String] = []
            for (i, num) in numbers.enumerated() {
                if let frac = fractionOps[i] {
                    parts.append(frac.description) // Use regular format: "1/2" instead of "½"
                } else {
                    parts.append("\(num)") // "3"
                }
            }

            if parts.count == 2 && operations.count == 1 {
                // Two-number operation
                return "\(parts[0]) \(operations[0].symbol) \(parts[1]) = ?"
            } else if parts.count == 3 && operations.count == 2 {
                // Three-number operation
                return "\(parts[0]) \(operations[0].symbol) \(parts[1]) \(operations[1].symbol) \(parts[2]) = ?"
            }
        }

        // Standard integer operations
        if numbers.count == 2 && operations.count == 1 {
            // 简单的两数运算 - 题目不应显示答案，始终显示 "= ?"
            return "\(numbers[0]) \(operations[0].symbol) \(numbers[1]) = ?"
        } else if numbers.count == 3 && operations.count == 2 {
            // 三数运算
            return "\(numbers[0]) \(operations[0].symbol) \(numbers[1]) \(operations[1].symbol) \(numbers[2]) = ?"
        }
        return "Invalid Question"
    }

    // 获取用于语音朗读的题目文本
    var questionTextForSpeech: String {
        let questionExpression: String

        // Handle fraction operands - convert to words for TTS
        if let fractionOps = fractionOperands {
            var parts: [String] = []
            for (i, num) in numbers.enumerated() {
                if let frac = fractionOps[i] {
                    parts.append(frac.toWords()) // "one half", "三分之一"
                } else {
                    // TODO: Convert integer to words too for consistency
                    parts.append("\(num)")
                }
            }

            if parts.count == 2 && operations.count == 1 {
                // Two-number operation
                let opWord = operationToWords(operations[0])
                questionExpression = "\(parts[0]) \(opWord) \(parts[1])"
            } else if parts.count == 3 && operations.count == 2 {
                // Three-number operation
                let op1Word = operationToWords(operations[0])
                let op2Word = operationToWords(operations[1])
                questionExpression = "\(parts[0]) \(op1Word) \(parts[1]) \(op2Word) \(parts[2])"
            } else {
                questionExpression = "Invalid Question"
            }
        } else {
            // Standard integer operations
            if numbers.count == 2 && operations.count == 1 {
                // 简单的两数运算，去掉 "= ?" 部分
                questionExpression = "\(numbers[0]) \(operations[0].symbol) \(numbers[1])"
            } else if numbers.count == 3 && operations.count == 2 {
                // 三数运算，去掉 "= ?" 部分
                questionExpression = "\(numbers[0]) \(operations[0].symbol) \(numbers[1]) \(operations[1].symbol) \(numbers[2])"
            } else {
                questionExpression = "Invalid Question"
            }
        }

        // 使用本地化字符串格式化语音文本
        return "question.read_aloud".localizedFormat(questionExpression)
    }

    // Helper: Convert operation to words for TTS
    private func operationToWords(_ operation: Operation) -> String {
        switch operation {
        case .addition: return "plus"
        case .subtraction: return "minus"
        case .multiplication: return "times"
        case .division: return "divided by"
        }
    }
    
    // 便捷初始化方法 - 两数运算
    init(number1: Int, number2: Int, operation: Operation, difficultyLevel: DifficultyLevel? = nil) {
        self.id = UUID()
        self.numbers = [number1, number2]
        self.operations = [operation]
        self.difficultyLevel = difficultyLevel
        self.fractionOperands = nil // No fraction operands

        // Compute fraction answer if applicable
        if let level = difficultyLevel, level == .level7, operation == .division, number2 != 0, number1 % number2 != 0 {
            self.fractionAnswer = Fraction(numerator: number1, denominator: number2).simplified()
            self.computedAnswer = nil
        } else {
            self.fractionAnswer = nil
            self.computedAnswer = nil
        }

        super.init()
    }

    // 便捷初始化方法 - 两数运算（支持分数操作数）
    init(operand1: Any, operand2: Any, operation: Operation, difficultyLevel: DifficultyLevel? = nil) {
        self.id = UUID()
        self.operations = [operation]
        self.difficultyLevel = difficultyLevel

        // Parse operands: can be Int or Fraction
        var frac1: Fraction? = nil
        var frac2: Fraction? = nil
        var num1: Int = 0
        var num2: Int = 0

        if let f = operand1 as? Fraction {
            frac1 = f
            num1 = 0 // Placeholder
        } else if let n = operand1 as? Int {
            num1 = n
        }

        if let f = operand2 as? Fraction {
            frac2 = f
            num2 = 0 // Placeholder
        } else if let n = operand2 as? Int {
            num2 = n
        }

        self.numbers = [num1, num2]
        self.fractionOperands = [frac1, frac2]

        // Compute the answer
        if frac1 != nil || frac2 != nil {
            // At least one operand is a fraction
            let leftFrac = frac1 ?? Fraction(numerator: num1, denominator: 1)
            let rightFrac = frac2 ?? Fraction(numerator: num2, denominator: 1)

            let resultFraction: Fraction
            switch operation {
            case .addition:
                resultFraction = (leftFrac + rightFrac).simplified()
            case .subtraction:
                resultFraction = (leftFrac - rightFrac).simplified()
            case .multiplication:
                resultFraction = (leftFrac * rightFrac).simplified()
            case .division:
                resultFraction = (leftFrac / rightFrac).simplified()
            }

            // Check if result is a whole number
            if resultFraction.numerator % resultFraction.denominator == 0 {
                self.fractionAnswer = nil // It's an integer answer
                self.computedAnswer = resultFraction.numerator / resultFraction.denominator
            } else {
                self.fractionAnswer = resultFraction
                self.computedAnswer = nil
            }
        } else {
            // Both operands are integers (shouldn't happen with this init, but handle it)
            if difficultyLevel == .level7 && operation == .division && num2 != 0 && num1 % num2 != 0 {
                self.fractionAnswer = Fraction(numerator: num1, denominator: num2).simplified()
                self.computedAnswer = nil
            } else {
                self.fractionAnswer = nil
                self.computedAnswer = nil
            }
        }

        super.init()
    }

    // 便捷初始化方法 - 三数运算
    init(number1: Int, number2: Int, number3: Int, operation1: Operation, operation2: Operation, difficultyLevel: DifficultyLevel? = nil) {
        self.id = UUID()
        self.numbers = [number1, number2, number3]
        self.operations = [operation1, operation2]
        self.difficultyLevel = difficultyLevel
        self.fractionOperands = nil // No fraction operands
        // For now, three-number fractions are not supported
        self.fractionAnswer = nil
        self.computedAnswer = nil
        super.init()
    }

    // 便捷初始化方法 - 三数运算（支持分数操作数）
    init(operand1: Any, operand2: Any, operand3: Any, operation1: Operation, operation2: Operation, difficultyLevel: DifficultyLevel? = nil) {
        self.id = UUID()
        self.operations = [operation1, operation2]
        self.difficultyLevel = difficultyLevel

        // Parse operands: can be Int or Fraction
        var frac1: Fraction? = nil
        var frac2: Fraction? = nil
        var frac3: Fraction? = nil
        var num1: Int = 0
        var num2: Int = 0
        var num3: Int = 0

        if let f = operand1 as? Fraction {
            frac1 = f
            num1 = 0
        } else if let n = operand1 as? Int {
            num1 = n
        }

        if let f = operand2 as? Fraction {
            frac2 = f
            num2 = 0
        } else if let n = operand2 as? Int {
            num2 = n
        }

        if let f = operand3 as? Fraction {
            frac3 = f
            num3 = 0
        } else if let n = operand3 as? Int {
            num3 = n
        }

        self.numbers = [num1, num2, num3]
        self.fractionOperands = [frac1, frac2, frac3]

        // Compute the answer (following PEMDAS)
        if frac1 != nil || frac2 != nil || frac3 != nil {
            // At least one operand is a fraction
            let leftFrac = frac1 ?? Fraction(numerator: num1, denominator: 1)
            let midFrac = frac2 ?? Fraction(numerator: num2, denominator: 1)
            let rightFrac = frac3 ?? Fraction(numerator: num3, denominator: 1)

            let resultFraction: Fraction
            if operation1.precedence < operation2.precedence {
                // Second operation has higher precedence
                var intermediateResult: Fraction
                switch operation2 {
                case .multiplication:
                    intermediateResult = (midFrac * rightFrac).simplified()
                case .division:
                    intermediateResult = (midFrac / rightFrac).simplified()
                default:
                    intermediateResult = midFrac
                }

                switch operation1 {
                case .addition:
                    resultFraction = (leftFrac + intermediateResult).simplified()
                case .subtraction:
                    resultFraction = (leftFrac - intermediateResult).simplified()
                default:
                    resultFraction = leftFrac
                }
            } else {
                // First operation has higher or equal precedence
                var intermediateResult: Fraction
                switch operation1 {
                case .addition:
                    intermediateResult = (leftFrac + midFrac).simplified()
                case .subtraction:
                    intermediateResult = (leftFrac - midFrac).simplified()
                case .multiplication:
                    intermediateResult = (leftFrac * midFrac).simplified()
                case .division:
                    intermediateResult = (leftFrac / midFrac).simplified()
                }

                switch operation2 {
                case .addition:
                    resultFraction = (intermediateResult + rightFrac).simplified()
                case .subtraction:
                    resultFraction = (intermediateResult - rightFrac).simplified()
                case .multiplication:
                    resultFraction = (intermediateResult * rightFrac).simplified()
                case .division:
                    resultFraction = (intermediateResult / rightFrac).simplified()
                }
            }

            // Check if result is a whole number
            if resultFraction.numerator % resultFraction.denominator == 0 {
                self.fractionAnswer = nil
                self.computedAnswer = resultFraction.numerator / resultFraction.denominator
            } else {
                self.fractionAnswer = resultFraction
                self.computedAnswer = nil
            }
        } else {
            // All operands are integers (shouldn't happen with this init, but handle it)
            self.fractionAnswer = nil
            self.computedAnswer = nil
        }

        super.init()
    }

    // NSSecureCoding
    required init?(coder: NSCoder) {
        guard let id = coder.decodeObject(of: NSUUID.self, forKey: "id") as UUID?,
              let numbers = coder.decodeObject(of: [NSArray.self, NSNumber.self], forKey: "numbers") as? [Int],
              let operationStrings = coder.decodeObject(of: [NSArray.self, NSString.self], forKey: "operations") as? [String] else {
            return nil
        }

        self.id = id
        self.numbers = numbers
        self.operations = operationStrings.compactMap { Operation(rawValue: $0) }

        // Decode difficulty level if present
        if let levelString = coder.decodeObject(of: NSString.self, forKey: "difficultyLevel") as String? {
            self.difficultyLevel = DifficultyLevel(rawValue: levelString)
        } else {
            self.difficultyLevel = nil
        }

        // Decode fraction answer if present
        if let numerator = coder.decodeObject(of: NSNumber.self, forKey: "fractionNumerator") as? Int,
           let denominator = coder.decodeObject(of: NSNumber.self, forKey: "fractionDenominator") as? Int,
           denominator != 0 {
            self.fractionAnswer = Fraction(numerator: numerator, denominator: denominator)
        } else {
            self.fractionAnswer = nil
        }

        // Decode computed answer if present
        if let computed = coder.decodeObject(of: NSNumber.self, forKey: "computedAnswer") as? Int {
            self.computedAnswer = computed
        } else {
            self.computedAnswer = nil
        }

        // Decode fraction operands if present
        if let count = coder.decodeObject(of: NSNumber.self, forKey: "fractionOperandsCount") as? Int {
            var decodedFractions: [Fraction?] = []
            for i in 0..<count {
                if let numerator = coder.decodeObject(of: NSNumber.self, forKey: "fractionOperand\(i)Numerator") as? Int,
                   let denominator = coder.decodeObject(of: NSNumber.self, forKey: "fractionOperand\(i)Denominator") as? Int,
                   denominator != 0 {
                    decodedFractions.append(Fraction(numerator: numerator, denominator: denominator))
                } else {
                    decodedFractions.append(nil)
                }
            }
            self.fractionOperands = decodedFractions
        } else {
            self.fractionOperands = nil
        }

        super.init()
    }

    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(numbers, forKey: "numbers")
        coder.encode(operations.map { $0.rawValue }, forKey: "operations")

        // Encode difficulty level
        if let level = difficultyLevel {
            coder.encode(level.rawValue, forKey: "difficultyLevel")
        }

        // Encode fraction answer
        if let fraction = fractionAnswer {
            coder.encode(NSNumber(value: fraction.numerator), forKey: "fractionNumerator")
            coder.encode(NSNumber(value: fraction.denominator), forKey: "fractionDenominator")
        }

        // Encode computed answer
        if let computed = computedAnswer {
            coder.encode(NSNumber(value: computed), forKey: "computedAnswer")
        }

        // Encode fraction operands
        if let fractionOps = fractionOperands {
            coder.encode(NSNumber(value: fractionOps.count), forKey: "fractionOperandsCount")
            for (i, frac) in fractionOps.enumerated() {
                if let f = frac {
                    coder.encode(NSNumber(value: f.numerator), forKey: "fractionOperand\(i)Numerator")
                    coder.encode(NSNumber(value: f.denominator), forKey: "fractionOperand\(i)Denominator")
                }
            }
        }
    }
    
    // 获取解题方法 - 根据难度等级应用不同的特殊方法
    func getSolutionMethod(for difficultyLevel: DifficultyLevel? = nil) -> SolutionMethod {
        guard let level = difficultyLevel else {
            return .standard
        }
        
        // 根据题目类型和数值特点选择合适的解题方法
        if operations.count == 1 {
            switch operations[0] {
            case .addition:
                // 只在Level 2中应用凑十法
                if level == .level2 {
                    // 确保所有数字都在20以内
                    guard numbers.allSatisfy({ $0 <= 20 }) else {
                        return .standard
                    }
                    
                    let num1 = numbers[0]
                    let num2 = numbers[1]
                    let sum = num1 + num2
                    
                    if sum > 10 && sum <= 20 {
                        let larger = max(num1, num2)
                        let smaller = min(num1, num2)
                        let neededToMakeTen = 10 - larger
                        
                        // 检查是否可以应用凑十法：较大数小于10，且较小数足够分解
                        if larger < 10 && neededToMakeTen > 0 && neededToMakeTen <= smaller {
                            return .makingTen
                        }
                    }
                }
                
            case .subtraction:
                // 只在Level 2中应用特殊减法方法
                if level == .level2 {
                    // 确保所有数字都在20以内
                    guard numbers.allSatisfy({ $0 <= 20 }) else {
                        return .standard
                    }
                    
                    let num1 = numbers[0]
                    let num2 = numbers[1]
                    
                    // 破十法：适用于被减数的个位小于减数的情况
                    if num1 > 10 && num2 < 10 && (num1 % 10) < num2 {
                        return .breakingTen
                    }
                    // 借十法：适用于个位数不够减的情况
                    else if num1 > 10 && num2 <= 10 && (num1 % 10) < num2 {
                        return .borrowingTen
                    }
                    // 平十法：适用于从特定数字中减去接近它的数
                    else if num1 > 10 && num2 >= 10 && num1 - num2 < 10 {
                        return .levelingTen
                    }
                }
                
            case .multiplication:
                let num1 = numbers[0]
                let num2 = numbers[1]
                
                // Level 4 (10以内乘法) 使用乘法口诀法
                if level == .level4 && num1 <= 10 && num2 <= 10 {
                    return .multiplicationTable
                }
                // Level 5 (20以内乘法) 对于较大数使用分解乘法
                else if level == .level5 && (num1 > 10 || num2 > 10) && num1 <= 20 && num2 <= 20 {
                    return .decompositionMultiplication
                }
                // 其他情况使用乘法口诀法
                else if (level == .level4 || level == .level5) && num1 <= 20 && num2 <= 20 {
                    return .multiplicationTable
                }
                
            case .division:
                let num1 = numbers[0]
                let num2 = numbers[1]
                
                // Level 4 和 Level 5 的除法使用验算法
                if (level == .level4 || level == .level5) && num1 <= 20 && num2 <= 10 {
                    return .divisionVerification
                }
            }
        }
        return .standard
    }
    
    // 获取解题步骤（支持多语言）
    func getSolutionSteps(for difficultyLevel: DifficultyLevel? = nil) -> String {
        // 对于三数运算且是Level 2，使用特殊的分步解析
        if operations.count == 2 && difficultyLevel == .level2 {
            return generateThreeNumberSolutionForLevel2()
        }
        
        let method = getSolutionMethod(for: difficultyLevel)
        
        switch method {
        case .breakingTen:
            return generateBreakingTenSolution()
        case .borrowingTen:
            return generateBorrowingTenSolution()
        case .makingTen:
            return generateMakingTenSolution()
        case .levelingTen:
            return generateLevelingTenSolution()
        case .multiplicationTable:
            return generateMultiplicationTableSolution()
        case .decompositionMultiplication:
            return generateDecompositionMultiplicationSolution()
        case .divisionVerification:
            return generateDivisionVerificationSolution()
        case .groupingDivision:
            return generateGroupingDivisionSolution()
        case .standard:
            return generateStandardSolution()
        }
    }
    
    // 生成破十法解析
    private func generateBreakingTenSolution() -> String {
        if operations.count == 1 && operations[0] == .subtraction {
            let num1 = numbers[0]
            let num2 = numbers[1]
            let result = num1 - num2
            
            // 检查是否适合使用破十法（被减数的个位小于减数）
            if num1 > 10 && num2 < 10 && (num1 % 10) < num2 {
                let ones = num1 % 10  // 个位部分
                let tenMinusSubtrahend = 10 - num2  // 10减去减数的结果
                let finalResult = tenMinusSubtrahend + ones  // 最终结果
                
                // 确保计算正确
                if finalResult == result {
                    // 破十法解析：%d - %d = ? 步骤1：将%d分解为10和%d 步骤2：计算10 - %d = %d 步骤3：%d + %d = %d 所以，%d - %d = %d
                    return "solution.breaking_ten.steps".localizedFormat(
                        num1, num2,                    // %d - %d = ?
                        num1, ones,                    // 将%d分解为10和%d
                        num2, tenMinusSubtrahend,      // 计算10 - %d = %d
                        tenMinusSubtrahend, ones, finalResult,  // %d + %d = %d
                        num1, num2, result             // 所以，%d - %d = %d
                    )
                }
            }
            
            // 如果不适合使用破十法或计算有误，使用标准减法
            return "solution.standard.subtraction".localizedFormat(
                num1, num2, result,
                num1, num2, result
            )
        }
        return "solution.not_applicable".localizedFormat("solution.breaking_ten".localized)
    }
    
    // 生成借十法解析
    private func generateBorrowingTenSolution() -> String {
        if operations.count == 1 && operations[0] == .subtraction {
            let num1 = numbers[0]
            let num2 = numbers[1]
            let result = num1 - num2
            
            // 借十法逻辑：将被减数分解为整十数和个位数，从整十数借1个10
            let tens = num1 / 10 * 10  // 整十数部分
            let remainder = num1 % 10   // 个位数部分
            let remainderPlus10 = remainder + 10  // 个位数加10
            let tensMinusTen = tens - 10  // 整十数减10
            
            // 借十法解析：%d - %d = ? 步骤1：将%d分解为%d和%d 步骤2：因为%d小于%d，所以从十位借1得到%d 步骤3：%d - %d = %d 步骤4：%d + %d = %d 所以，%d - %d = %d
            return "solution.borrowing_ten.steps".localizedFormat(
                num1, num2,                           // %d - %d = ?
                num1, tens, remainder,                // 将%d分解为%d和%d
                remainder, num2, remainderPlus10,     // 因为%d小于%d，所以从十位借1得到%d
                remainderPlus10, num2, remainderPlus10 - num2,  // %d - %d = %d
                tensMinusTen, remainderPlus10 - num2, result,   // %d + %d = %d
                num1, num2, result                    // 所以，%d - %d = %d
            )
        }
        return "solution.not_applicable".localizedFormat("solution.borrowing_ten".localized)
    }
    
    // 生成凑十法解析
    private func generateMakingTenSolution() -> String {
        if operations.count == 1 && operations[0] == .addition {
            let num1 = numbers[0]
            let num2 = numbers[1]
            let result = num1 + num2
            
            // 凑十法逻辑：看大数拆小数，凑成十再加余
            let larger = max(num1, num2)
            let smaller = min(num1, num2)
            let neededToMakeTen = 10 - larger  // 较大数需要多少才能凑成10
            let remainderFromSmaller = smaller - neededToMakeTen  // 较小数拆出部分后的剩余
            
            // 验证凑十法是否适用（较小数必须大于等于所需的补充数）
            if neededToMakeTen > 0 && neededToMakeTen <= smaller && remainderFromSmaller >= 0 {
                return "solution.making_ten.steps".localizedFormat(
                    num1, num2,                           // %d + %d = ?
                    larger, neededToMakeTen,              // 看大数%d，需要%d凑成10
                    smaller, neededToMakeTen, remainderFromSmaller,  // 拆小数%d，分解为%d和%d
                    larger, neededToMakeTen,              // %d + %d = 10
                    remainderFromSmaller, result,         // 10 + %d = %d
                    num1, num2, result                    // 所以，%d + %d = %d
                )
            }
        }
        return "solution.not_applicable".localizedFormat("solution.making_ten".localized)
    }
    
    // 生成平十法解析
    private func generateLevelingTenSolution() -> String {
        if operations.count == 1 && operations[0] == .subtraction {
            let num1 = numbers[0]
            let num2 = numbers[1]
            let result = num1 - num2
            
            // 平十法逻辑：将减数分解为两部分，先减去一部分使被减数变成整十数，再减去剩余部分
            // 验证分解是否合理（减数应该能分解为10和另一个数）
            if num2 >= 10 {
                let firstPart = 10  // 先减去10
                let secondPart = num2 - 10  // 剩余部分
                let intermediateResult = num1 - firstPart  // 中间结果
                let finalResult = intermediateResult - secondPart  // 最终结果
                
                // 确保计算正确
                if finalResult == result {
                    // 平十法解析：%d - %d = ? 步骤1：将%d分解为%d和%d 步骤2：%d - %d = 10 步骤3：10 - %d = %d 所以，%d - %d = %d
                    return "solution.leveling_ten.steps".localizedFormat(
                        num1, num2,                       // %d - %d = ?
                        num2, firstPart, secondPart,      // 将%d分解为%d和%d
                        num1, firstPart, intermediateResult,  // %d - %d = 10 (这里应该是中间结果)
                        secondPart, finalResult,          // 10 - %d = %d
                        num1, num2, result                // 所以，%d - %d = %d
                    )
                }
            }
            
            // 如果不适合使用平十法或计算有误，使用标准减法
            return "solution.standard.subtraction".localizedFormat(
                num1, num2, result,
                num1, num2, result
            )
        }
        return "solution.not_applicable".localizedFormat("solution.leveling_ten".localized)
    }
    
    // 生成标准解法
    private func generateStandardSolution() -> String {
        // Check if we have fraction operands - use fraction-aware solution generation
        if let fractionOps = fractionOperands, fractionOps.contains(where: { $0 != nil }) {
            return generateFractionSolution()
        }

        if operations.count == 1 {
            let num1 = numbers[0]
            let num2 = numbers[1]

            // For fraction answers (Level 7 division), use the fraction result text
            // For integer answers, use the integer result
            let resultText: String
            if answerType == .fraction, let fraction = fractionAnswer {
                resultText = fraction.localizedString()
            } else {
                resultText = "\(correctAnswer)"
            }

            switch operations[0] {
            case .addition:
                return "solution.standard.addition".localizedFormat(
                    num1, num2, correctAnswer,
                    num1, num2, correctAnswer
                )
            case .subtraction:
                return "solution.standard.subtraction".localizedFormat(
                    num1, num2, correctAnswer,
                    num1, num2, correctAnswer
                )
            case .multiplication:
                return "solution.standard.multiplication".localizedFormat(
                    num1, num2, correctAnswer,
                    num1, num2, correctAnswer
                )
            case .division:
                // For division, use the correct result text (integer or fraction)
                return "solution.standard.division_with_result".localizedFormat(
                    num1, num2, resultText,
                    num1, num2, resultText
                )
            }
        } else if operations.count == 2 {
            let num1 = numbers[0]
            let num2 = numbers[1]
            let num3 = numbers[2]
            let op1 = operations[0]
            let op2 = operations[1]

            let actualFinalResult = self.correctAnswer // Get the already correctly calculated answer

            if op1.precedence < op2.precedence {
                // Higher precedence for op2 (e.g., A + B*C). Calculate num2 op2 num3 first.
                var firstPartResult: Int
                switch op2 {
                case .addition: firstPartResult = num2 + num3
                case .subtraction: firstPartResult = num2 - num3
                case .multiplication: firstPartResult = num2 * num3
                case .division: firstPartResult = num3 != 0 ? num2 / num3 : 0
                }

                // Step 2: num1 op1 (result of firstPart)
                // finalResult is actualFinalResult

                 return "solution.standard.three_numbers_op2_first".localizedFormat(
                    num1, op1.symbol, num2, op2.symbol, num3, // Question: %1$d %2$@ %3$d %4$@ %5$d = ?
                    num2, op2.symbol, num3, firstPartResult, // Step 1: %6$d %7$@ %8$d = %9$d  (B op2 C = res1)
                    num1, op1.symbol, firstPartResult, actualFinalResult, // Step 2: %10$d %11$@ %12$d = %13$d (A op1 res1 = final)
                    num1, op1.symbol, num2, op2.symbol, num3, actualFinalResult // Conclusion: %14$d ... = %19$d
                )

            } else {
                // Higher or same precedence for op1 (e.g., A*B+C or A+B-C). Calculate num1 op1 num2 first.
                var firstPartResult: Int
                switch op1 {
                case .addition: firstPartResult = num1 + num2
                case .subtraction: firstPartResult = num1 - num2
                case .multiplication: firstPartResult = num1 * num2
                case .division: firstPartResult = num2 != 0 ? num1 / num2 : 0
                }

                // Step 2: (result of firstPart) op2 num3
                // finalResult is actualFinalResult

                 return "solution.standard.three_numbers".localizedFormat(
                    num1, op1.symbol, num2, op2.symbol, num3,
                    num1, op1.symbol, num2, firstPartResult,
                    firstPartResult, op2.symbol, num3, actualFinalResult,
                    num1, op1.symbol, num2, op2.symbol, num3, actualFinalResult
                )
            }
        }

        return "solution.standard".localized
    }

    // 生成分数运算的解法
    private func generateFractionSolution() -> String {
        guard let fractionOps = fractionOperands else {
            return "solution.standard".localized
        }

        // Get operand display strings (fraction or integer)
        func operandString(_ index: Int) -> String {
            if let frac = fractionOps[index] {
                return frac.localizedString()
            } else {
                return "\(numbers[index])"
            }
        }

        // Get the result display string
        let resultString: String
        if let fracAnswer = fractionAnswer {
            resultString = fracAnswer.localizedString()
        } else if let computed = computedAnswer {
            resultString = "\(computed)"
        } else {
            resultString = "\(correctAnswer)"
        }

        if operations.count == 1 {
            let operand1 = operandString(0)
            let operand2 = operandString(1)
            let opSymbol = operations[0].symbol

            // Build solution text for fraction operations
            return "solution.fraction.two_operands".localizedFormat(
                operand1, opSymbol, operand2,
                operand1, opSymbol, operand2, resultString,
                operand1, opSymbol, operand2, resultString
            )
        } else if operations.count == 2 {
            let operand1 = operandString(0)
            let operand2 = operandString(1)
            let operand3 = operandString(2)
            let op1Symbol = operations[0].symbol
            let op2Symbol = operations[1].symbol

            // For three-operand fraction operations
            return "solution.fraction.three_operands".localizedFormat(
                operand1, op1Symbol, operand2, op2Symbol, operand3,
                operand1, op1Symbol, operand2, op2Symbol, operand3, resultString,
                operand1, op1Symbol, operand2, op2Symbol, operand3, resultString
            )
        }

        return "solution.standard".localized
    }
    
    // 生成Level 2三数运算的分步解析
    private func generateThreeNumberSolutionForLevel2() -> String {
        guard operations.count == 2 else {
            return generateStandardSolution()
        }
        
        let num1 = numbers[0]
        let num2 = numbers[1]
        let num3 = numbers[2]
        let op1 = operations[0]
        let op2 = operations[1]
        
        // 第一步：计算前两个数
        let intermediateResult = op1 == .addition ? num1 + num2 : num1 - num2
        
        // 创建临时的两数运算题目来获取第一步的解题方法
        let firstStepQuestion = Question(number1: num1, number2: num2, operation: op1)
        let firstStepMethod = firstStepQuestion.getSolutionMethod(for: .level2)
        
        // 创建临时的两数运算题目来获取第二步的解题方法
        let secondStepQuestion = Question(number1: intermediateResult, number2: num3, operation: op2)
        let secondStepMethod = secondStepQuestion.getSolutionMethod(for: .level2)
        
        // 生成第一步解析
        var firstStepSolution = ""
        switch firstStepMethod {
        case .makingTen:
            firstStepSolution = firstStepQuestion.generateMakingTenSolution()
        case .breakingTen:
            firstStepSolution = firstStepQuestion.generateBreakingTenSolution()
        case .borrowingTen:
            firstStepSolution = firstStepQuestion.generateBorrowingTenSolution()
        case .levelingTen:
            firstStepSolution = firstStepQuestion.generateLevelingTenSolution()
        case .multiplicationTable:
            firstStepSolution = firstStepQuestion.generateMultiplicationTableSolution()
        case .decompositionMultiplication:
            firstStepSolution = firstStepQuestion.generateDecompositionMultiplicationSolution()
        case .divisionVerification:
            firstStepSolution = firstStepQuestion.generateDivisionVerificationSolution()
        case .groupingDivision:
            firstStepSolution = firstStepQuestion.generateGroupingDivisionSolution()
        case .standard:
            switch op1 {
            case .addition:
                firstStepSolution = "solution.standard.addition".localizedFormat(
                    num1, num2, intermediateResult,
                    num1, num2, intermediateResult
                )
            case .subtraction:
                firstStepSolution = "solution.standard.subtraction".localizedFormat(
                    num1, num2, intermediateResult,
                    num1, num2, intermediateResult
                )
            case .multiplication:
                firstStepSolution = "solution.standard.multiplication".localizedFormat(
                    num1, num2, intermediateResult,
                    num1, num2, intermediateResult
                )
            case .division:
                firstStepSolution = "solution.standard.division".localizedFormat(
                    num1, num2, intermediateResult,
                    num1, num2, intermediateResult
                )
            }
        }
        
        // 生成第二步解析
        var secondStepSolution = ""
        switch secondStepMethod {
        case .makingTen:
            secondStepSolution = secondStepQuestion.generateMakingTenSolution()
        case .breakingTen:
            secondStepSolution = secondStepQuestion.generateBreakingTenSolution()
        case .borrowingTen:
            secondStepSolution = secondStepQuestion.generateBorrowingTenSolution()
        case .levelingTen:
            secondStepSolution = secondStepQuestion.generateLevelingTenSolution()
        case .multiplicationTable:
            secondStepSolution = secondStepQuestion.generateMultiplicationTableSolution()
        case .decompositionMultiplication:
            secondStepSolution = secondStepQuestion.generateDecompositionMultiplicationSolution()
        case .divisionVerification:
            secondStepSolution = secondStepQuestion.generateDivisionVerificationSolution()
        case .groupingDivision:
            secondStepSolution = secondStepQuestion.generateGroupingDivisionSolution()
        case .standard:
            switch op2 {
            case .addition:
                secondStepSolution = "solution.standard.addition".localizedFormat(
                    intermediateResult, num3, correctAnswer,
                    intermediateResult, num3, correctAnswer
                )
            case .subtraction:
                secondStepSolution = "solution.standard.subtraction".localizedFormat(
                    intermediateResult, num3, correctAnswer,
                    intermediateResult, num3, correctAnswer
                )
            case .multiplication:
                secondStepSolution = "solution.standard.multiplication".localizedFormat(
                    intermediateResult, num3, correctAnswer,
                    intermediateResult, num3, correctAnswer
                )
            case .division:
                secondStepSolution = "solution.standard.division".localizedFormat(
                    intermediateResult, num3, correctAnswer,
                    intermediateResult, num3, correctAnswer
                )
            }
        }
        
        // 合并两步解析
        return "solution.three_numbers_level2".localizedFormat(
            num1, op1.symbol, num2, op2.symbol, num3,
            firstStepSolution,
            secondStepSolution,
            num1, op1.symbol, num2, op2.symbol, num3, correctAnswer
        )
    }
    
    // 生成乘法口诀法解析
    private func generateMultiplicationTableSolution() -> String {
        if operations.count == 1 && operations[0] == .multiplication {
            let num1 = numbers[0]
            let num2 = numbers[1]
            let result = correctAnswer
            
            return "solution.multiplication_table.steps".localizedFormat(
                num1, num2, result,
                num1, num2, result
            )
        }
        return "solution.not_applicable".localizedFormat("solution.multiplication_table".localized)
    }
    
    // 生成分解乘法解析
    private func generateDecompositionMultiplicationSolution() -> String {
        if operations.count == 1 && operations[0] == .multiplication {
            let num1 = numbers[0]
            let num2 = numbers[1]
            let result = correctAnswer
            
            // 找出较大的数进行分解
            let larger = max(num1, num2)
            let smaller = min(num1, num2)
            
            // 如果较大数大于10，进行分解
            if larger > 10 {
                let tens = (larger / 10) * 10  // 十位部分
                let ones = larger % 10         // 个位部分
                
                let tensProduct = tens * smaller
                let onesProduct = ones * smaller
                let finalResult = tensProduct + onesProduct
                
                return "solution.decomposition_multiplication.steps".localizedFormat(
                    num1, num2, result,
                    larger, tens, ones,
                    smaller, tens, tensProduct,
                    smaller, ones, onesProduct,
                    tensProduct, onesProduct, finalResult,
                    num1, num2, result
                )
            }
        }
        return "solution.not_applicable".localizedFormat("solution.decomposition_multiplication".localized)
    }
    
    // 生成除法验算法解析
    private func generateDivisionVerificationSolution() -> String {
        if operations.count == 1 && operations[0] == .division {
            let num1 = numbers[0]
            let num2 = numbers[1]
            let result = correctAnswer
            
            // 验算：商 × 除数 = 被除数
            let verification = result * num2
            
            return "solution.division_verification.steps".localizedFormat(
                num1, num2, result,
                result, num2,
                result, num2, verification,
                num1, verification,
                num1, num2, result
            )
        }
        return "solution.not_applicable".localizedFormat("solution.division_verification".localized)
    }
    
    // 生成分组除法解析
    private func generateGroupingDivisionSolution() -> String {
        if operations.count == 1 && operations[0] == .division {
            let num1 = numbers[0]
            let num2 = numbers[1]
            let result = correctAnswer
            
            return "solution.grouping_division.steps".localizedFormat(
                num1, num2, result,
                num1, num2,
                result, num2, num1,
                num1, num2, result
            )
        }
        return "solution.not_applicable".localizedFormat("solution.grouping_division".localized)
    }
}
