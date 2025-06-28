import Foundation

class Question: NSObject, NSCoding, Identifiable {
    let id: UUID
    let numbers: [Int]
    let operations: [Operation]
    
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
    
    // 计算正确答案
    var correctAnswer: Int {
        if numbers.count == 2 && operations.count == 1 {
            // 简单的两数运算
            switch operations[0] {
            case .addition: return numbers[0] + numbers[1]
            case .subtraction: return numbers[0] - numbers[1]
            case .multiplication: return numbers[0] * numbers[1]
            case .division: return numbers[1] != 0 ? numbers[0] / numbers[1] : 0
            }
        } else if numbers.count == 3 && operations.count == 2 {
            // 三数运算，从左到右计算
            var result = numbers[0]
            for i in 0..<operations.count {
                switch operations[i] {
                case .addition: result += numbers[i + 1]
                case .subtraction: result -= numbers[i + 1]
                case .multiplication: result *= numbers[i + 1]
                case .division: result = numbers[i + 1] != 0 ? result / numbers[i + 1] : 0
                }
            }
            return result
        }
        return 0 // 默认返回0（不应该发生）
    }
    
    enum Operation: String, CaseIterable, Codable {
        case addition = "+"
        case subtraction = "-"
        case multiplication = "×"
        case division = "÷"
        
        var symbol: String {
            return self.rawValue
        }
    }
    
    // 用于检查题目是否重复
    static func == (lhs: Question, rhs: Question) -> Bool {
        return lhs.numbers == rhs.numbers && lhs.operations == rhs.operations
    }
    
    // 题目的字符串表示
    var questionText: String {
        if numbers.count == 2 && operations.count == 1 {
            // 简单的两数运算
            return "\(numbers[0]) \(operations[0].symbol) \(numbers[1]) = ?"
        } else if numbers.count == 3 && operations.count == 2 {
            // 三数运算
            return "\(numbers[0]) \(operations[0].symbol) \(numbers[1]) \(operations[1].symbol) \(numbers[2]) = ?"
        }
        return "Invalid Question"
    }
    
    // 便捷初始化方法 - 两数运算
    init(number1: Int, number2: Int, operation: Operation) {
        self.id = UUID()
        self.numbers = [number1, number2]
        self.operations = [operation]
        super.init()
    }
    
    // 便捷初始化方法 - 三数运算
    init(number1: Int, number2: Int, number3: Int, operation1: Operation, operation2: Operation) {
        self.id = UUID()
        self.numbers = [number1, number2, number3]
        self.operations = [operation1, operation2]
        super.init()
    }
    
    // NSCoding
    required init?(coder: NSCoder) {
        guard let id = coder.decodeObject(forKey: "id") as? UUID,
              let numbers = coder.decodeObject(forKey: "numbers") as? [Int],
              let operationStrings = coder.decodeObject(forKey: "operations") as? [String] else {
            return nil
        }
        
        self.id = id
        self.numbers = numbers
        self.operations = operationStrings.compactMap { Operation(rawValue: $0) }
        super.init()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(numbers, forKey: "numbers")
        coder.encode(operations.map { $0.rawValue }, forKey: "operations")
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
        if operations.count == 1 {
            let num1 = numbers[0]
            let num2 = numbers[1]
            let result = correctAnswer
            
            switch operations[0] {
            case .addition:
                return "solution.standard.addition".localizedFormat(
                    num1, num2, result,
                    num1, num2, result
                )
            case .subtraction:
                return "solution.standard.subtraction".localizedFormat(
                    num1, num2, result,
                    num1, num2, result
                )
            case .multiplication:
                return "solution.standard.multiplication".localizedFormat(
                    num1, num2, result,
                    num1, num2, result
                )
            case .division:
                return "solution.standard.division".localizedFormat(
                    num1, num2, result,
                    num1, num2, result
                )
            }
        } else if operations.count == 2 {
            let num1 = numbers[0]
            let num2 = numbers[1]
            let num3 = numbers[2]
            let op1 = operations[0]
            let op2 = operations[1]
            
            var intermediateResult = 0
            switch op1 {
            case .addition:
                intermediateResult = num1 + num2
            case .subtraction:
                intermediateResult = num1 - num2
            case .multiplication:
                intermediateResult = num1 * num2
            case .division:
                intermediateResult = num2 != 0 ? num1 / num2 : 0
            }
            
            var finalResult = 0
            switch op2 {
            case .addition:
                finalResult = intermediateResult + num3
            case .subtraction:
                finalResult = intermediateResult - num3
            case .multiplication:
                finalResult = intermediateResult * num3
            case .division:
                finalResult = num3 != 0 ? intermediateResult / num3 : 0
            }
            
            return "solution.standard.three_numbers".localizedFormat(
                num1, op1.symbol, num2, op2.symbol, num3,
                num1, op1.symbol, num2, intermediateResult,
                intermediateResult, op2.symbol, num3, finalResult,
                num1, op1.symbol, num2, op2.symbol, num3, finalResult
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
            if op1 == .addition {
                firstStepSolution = "solution.standard.addition".localizedFormat(
                    num1, num2, intermediateResult,
                    num1, num2, intermediateResult
                )
            } else if op1 == .subtraction {
                firstStepSolution = "solution.standard.subtraction".localizedFormat(
                    num1, num2, intermediateResult,
                    num1, num2, intermediateResult
                )
            } else if op1 == .multiplication {
                firstStepSolution = "solution.standard.multiplication".localizedFormat(
                    num1, num2, intermediateResult,
                    num1, num2, intermediateResult
                )
            } else if op1 == .division {
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
            if op2 == .addition {
                secondStepSolution = "solution.standard.addition".localizedFormat(
                    intermediateResult, num3, correctAnswer,
                    intermediateResult, num3, correctAnswer
                )
            } else if op2 == .subtraction {
                secondStepSolution = "solution.standard.subtraction".localizedFormat(
                    intermediateResult, num3, correctAnswer,
                    intermediateResult, num3, correctAnswer
                )
            } else if op2 == .multiplication {
                secondStepSolution = "solution.standard.multiplication".localizedFormat(
                    intermediateResult, num3, correctAnswer,
                    intermediateResult, num3, correctAnswer
                )
            } else if op2 == .division {
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
