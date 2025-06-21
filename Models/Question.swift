import Foundation

class Question: NSObject, NSCoding, Identifiable {
    let id: UUID
    let numbers: [Int]
    let operations: [Operation]
    
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
}
