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
    
    // 获取解题方法
    func getSolutionMethod() -> SolutionMethod {
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
    func getSolutionSteps() -> String {
        let method = getSolutionMethod()
        
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
            // 1. 将第一个数分解为10和余数（例如，12分解为10和2）
            // 2. 用10减去第二个数（例如，10-9=1）
            // 3. 将结果与余数相加（例如，1+2=3）
            let remainder = num1 - 10
            let subtractResult = 10 - num2
            
            return "solution.breaking_ten.steps".localizedFormat(
                num1, num2,
                remainder, 10,
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
            
            return "solution.borrowing_ten.steps".localizedFormat(
                num1, num2,
                tens, remainder,
                remainder, num2, 10 - num2,
                tens - 10, 10 - num2 + remainder, result,
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
            // 例如：17-9，将9分解为7和2，17-7=10，10-2=8
            let toTen = num1 - 10  // 被减数与10的差值
            let firstPart = toTen  // 减数的第一部分
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
}
