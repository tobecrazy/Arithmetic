import Foundation

struct Question: Identifiable, Equatable {
    let id = UUID()
    let number1: Int
    let number2: Int
    let operation: Operation
    
    var correctAnswer: Int {
        switch operation {
        case .addition: return number1 + number2
        case .subtraction: return number1 - number2
        }
    }
    
    enum Operation: String, CaseIterable {
        case addition = "+"
        case subtraction = "-"
        
        var symbol: String {
            return self.rawValue
        }
    }
    
    // 用于检查题目是否重复
    static func == (lhs: Question, rhs: Question) -> Bool {
        return lhs.number1 == rhs.number1 && 
               lhs.number2 == rhs.number2 && 
               lhs.operation == rhs.operation
    }
    
    // 题目的字符串表示
    var questionText: String {
        return "\(number1) \(operation.symbol) \(number2) = ?"
    }
}
