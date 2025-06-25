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
                // 破十法：适用于被减数的个位小于减数的个位
                if numbers[0] > 10 && numbers[1] < 10 && (numbers[0] % 10) < numbers[1] {
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
            
            // 破十法逻辑：当被减数的个位小于减数时，需要"破十"
            // 例如：13 - 9 = ?
            // 1. 将13分解为10和3
            // 2. 用10减去9：10 - 9 = 1
            // 3. 将得到的差(1)与被减数剩下的个位数字(3)相加：1 + 3 = 4
            
            // 检查是否适合使用破十法（被减数的个位小于减数）
            if num1 > 10 && num2 < 10 && (num1 % 10) < num2 {
                let tens = (num1 / 10) * 10  // 十位部分（如13的10）
                let ones = num1 % 10  // 个位部分（如13的3）
                let tenMinusSubtrahend = 10 - num2  // 10减去减数的结果（如10-9=1）
                let finalResult = tenMinusSubtrahend + ones  // 最终结果（如1+3=4）
                
                // 确保计算正确
                if finalResult == result {
                    // 根据当前语言选择正确的格式
                    let currentLanguage = LocalizationManager.shared.currentLanguage
                    
                    if currentLanguage == .chinese {
                        // 中文解析
                        return String(format: "破十法解析：\n%d - %d = ?\n\n步骤1：将%d分解为10和%d\n步骤2：用10减去%d：10 - %d = %d\n步骤3：将得到的差(%d)与个位数字(%d)相加：%d + %d = %d\n\n所以，%d - %d = %d",
                            num1, num2,
                            num1, ones,
                            num2, num2, tenMinusSubtrahend,
                            tenMinusSubtrahend, ones, tenMinusSubtrahend, ones, finalResult,
                            num1, num2, result
                        )
                    } else {
                        // 英文解析
                        return String(format: "Breaking Ten Method:\n%d - %d = ?\n\nStep 1: Split %d into 10 and %d\nStep 2: Subtract %d from 10: 10 - %d = %d\nStep 3: Add the difference (%d) to the ones digit (%d): %d + %d = %d\n\nTherefore, %d - %d = %d",
                            num1, num2,
                            num1, ones,
                            num2, num2, tenMinusSubtrahend,
                            tenMinusSubtrahend, ones, tenMinusSubtrahend, ones, finalResult,
                            num1, num2, result
                        )
                    }
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
            
            // 凑十法逻辑：拆小数，补大数，凑成10，加剩数
            // 1. 确定较大数和较小数
            // 2. 计算较大数需要多少才能凑成10
            // 3. 从较小数中拆出这个数量来补大数
            // 4. 较大数+拆出的部分=10
            // 5. 10+较小数的剩余部分=最终结果
            let larger = max(num1, num2)
            let smaller = min(num1, num2)
            let neededToMakeTen = 10 - larger  // 较大数需要多少才能凑成10
            let remainderFromSmaller = smaller - neededToMakeTen  // 较小数拆出部分后的剩余
            
            // 验证凑十法是否适用（较小数必须大于等于所需的补充数）
            if neededToMakeTen > 0 && neededToMakeTen <= smaller {
                return "solution.making_ten.steps".localizedFormat(
                    num1, num2,                           // %d + %d = ?
                    larger, larger, neededToMakeTen,      // 找出%d与10的差值：10 - %d = %d
                    smaller, neededToMakeTen, remainderFromSmaller,  // 将%d分解为%d和%d
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
            // 例如：19 - 16 = ?
            // 1. 将减数16分解为10和6
            // 2. 先减10：19 - 10 = 9
            // 3. 再减6：9 - 6 = 3
            // 验证分解是否合理（减数应该能分解为10和另一个数）
            if num2 >= 10 {
                let firstPart = 10  // 先减去10
                let secondPart = num2 - 10  // 剩余部分
                let intermediateResult = num1 - firstPart  // 中间结果
                let finalResult = intermediateResult - secondPart  // 最终结果
                
                // 确保计算正确
                if finalResult == result {
                    // 根据当前语言选择正确的格式
                    let currentLanguage = LocalizationManager.shared.currentLanguage
                    
                    if currentLanguage == .chinese {
                        // 中文解析
                        return String(format: "平十法解析：\n%d - %d = ?\n\n步骤1：将减数%d分解为%d和%d\n步骤2：先减%d：%d - %d = %d\n步骤3：再减%d：%d - %d = %d\n\n所以，%d - %d = %d",
                            num1, num2,
                            num2, firstPart, secondPart,
                            firstPart, num1, firstPart, intermediateResult,
                            secondPart, intermediateResult, secondPart, finalResult,
                            num1, num2, result
                        )
                    } else {
                        // 英文解析
                        return String(format: "Leveling Ten Method:\n%d - %d = ?\n\nStep 1: Split subtrahend %d into %d and %d\nStep 2: First subtract %d: %d - %d = %d\nStep 3: Then subtract %d: %d - %d = %d\n\nTherefore, %d - %d = %d",
                            num1, num2,
                            num2, firstPart, secondPart,
                            firstPart, num1, firstPart, intermediateResult,
                            secondPart, intermediateResult, secondPart, finalResult,
                            num1, num2, result
                        )
                    }
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
