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
            }
        } else if numbers.count == 3 && operations.count == 2 {
            // 三数运算，从左到右计算
            var result = numbers[0]
            for i in 0..<operations.count {
                switch operations[i] {
                case .addition: result += numbers[i + 1]
                case .subtraction: result -= numbers[i + 1]
                }
            }
            return result
        }
        return 0 // 默认返回0（不应该发生）
    }
    
    enum Operation: String, CaseIterable, Codable {
        case addition = "+"
        case subtraction = "-"
        
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
    
    // 获取解题方法 - 只在Level 2 (20以内) 中应用特殊方法
    func getSolutionMethod(for difficultyLevel: DifficultyLevel? = nil) -> SolutionMethod {
        // 只在Level 2中应用特殊的中国算术方法
        guard let level = difficultyLevel, level == .level2 else {
            return .standard
        }
        
        // 确保所有数字都在20以内
        guard numbers.allSatisfy({ $0 <= 20 }) else {
            return .standard
        }
        
        // 根据题目类型和数值特点选择合适的解题方法
        if operations.count == 1 {
            switch operations[0] {
            case .addition:
                // 凑十法：适用于个位数相加且和大于10的情况
                if numbers[0] < 10 && numbers[1] < 10 && numbers[0] + numbers[1] > 10 {
                    return .makingTen
                }
            case .subtraction:
                // 破十法：适用于从10几中减去个位数
                if numbers[0] > 10 && numbers[0] < 20 && numbers[1] < 10 {
                    return .breakingTen
                }
                // 借十法：适用于个位数不够减的情况
                else if numbers[0] % 10 < numbers[1] % 10 {
                    return .borrowingTen
                }
                // 平十法：适用于从特定数字中减去接近它的数
                else if numbers[0] - numbers[1] < 10 && numbers[1] > 8 {
                    return .levelingTen
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
            
            // 正确的破十法逻辑：
            // 1. 将被减数分解为10和余数（例如，13分解为10和3）
            // 2. 用10减去减数（例如，10-9=1）
            // 3. 将结果与余数相加（例如，1+3=4）
            let remainder = num1 - 10  // 余数部分（如13的3）
            let subtractResult = 10 - num2  // 10减去减数的结果（如10-9=1）
            
            return "solution.breaking_ten.steps".localizedFormat(
                num1, num2,
                num1, 10, remainder,
                10, num2, subtractResult,
                subtractResult, remainder, result,
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
            
            // 借十法逻辑：
            // 1. 将被减数分解为整十数和个位数（例如，35分解为30和5）
            // 2. 因为个位数不够减，从整十数借1个10，变成整十数减10和个位数加10
            // 3. 用个位数加10减去减数的个位数，再加上整十数减10
            let tens = num1 / 10 * 10  // 整十数部分（如35的30）
            let remainder = num1 % 10   // 个位数部分（如35的5）
            let remainderPlus10 = remainder + 10  // 个位数加10
            let tensMinusTen = tens - 10  // 整十数减10
            
            return "solution.borrowing_ten.steps".localizedFormat(
                num1, num2,
                tens, remainder,
                remainder, num2, remainderPlus10,
                remainderPlus10, num2, remainderPlus10 - num2,
                tensMinusTen, remainderPlus10 - num2, result,
                num1, num2, result
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
            
            // 凑十法逻辑：
            // 1. 选择较大的数（例如，6+8中的8）
            // 2. 计算这个数与10的差值（例如，10-8=2）
            // 3. 将较小的数分解为差值和余数（例如，6分解为2和4）
            // 4. 用较大的数和差值凑成10（例如，8+2=10）
            // 5. 再加上余数得到结果（例如，10+4=14）
            let larger = max(num1, num2)
            let smaller = min(num1, num2)
            let complement = 10 - larger  // 与10的差值
            let remainder = smaller - complement  // 余数
            
            return "solution.making_ten.steps".localizedFormat(
                num1, num2,
                larger, 10, complement,
                smaller, complement, remainder,
                larger, complement, 10,
                10, remainder, result,
                num1, num2, result
            )
        }
        return "solution.not_applicable".localizedFormat("solution.making_ten".localized)
    }
    
    // 生成平十法解析
    private func generateLevelingTenSolution() -> String {
        if operations.count == 1 && operations[0] == .subtraction {
            let num1 = numbers[0]
            let num2 = numbers[1]
            let result = num1 - num2
            
            // 平十法逻辑：
            // 1. 将减数分解为两部分，使得被减数减去第一部分等于10
            // 2. 用10减去减数的第二部分得到结果
            // 例如：19-16，将16分解为9和7，19-9=10，10-7=3
            let toTen = num1 - 10  // 被减数与10的差值
            let firstPart = num1 - 10  // 减数的第一部分
            let secondPart = num2 - firstPart  // 减数的第二部分
            
            return "solution.leveling_ten.steps".localizedFormat(
                num1, num2,
                num2, firstPart, secondPart,
                num1, firstPart, 10,
                10, secondPart, result,
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
            
            if operations[0] == .addition {
                return "solution.standard.addition".localizedFormat(
                    num1, num2, result,
                    num1, num2, result
                )
            } else {
                return "solution.standard.subtraction".localizedFormat(
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
            if op1 == .addition {
                intermediateResult = num1 + num2
            } else {
                intermediateResult = num1 - num2
            }
            
            var finalResult = 0
            if op2 == .addition {
                finalResult = intermediateResult + num3
            } else {
                finalResult = intermediateResult - num3
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
        case .standard:
            if op1 == .addition {
                firstStepSolution = "solution.standard.addition".localizedFormat(
                    num1, num2, intermediateResult,
                    num1, num2, intermediateResult
                )
            } else {
                firstStepSolution = "solution.standard.subtraction".localizedFormat(
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
        case .standard:
            if op2 == .addition {
                secondStepSolution = "solution.standard.addition".localizedFormat(
                    intermediateResult, num3, correctAnswer,
                    intermediateResult, num3, correctAnswer
                )
            } else {
                secondStepSolution = "solution.standard.subtraction".localizedFormat(
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
}
