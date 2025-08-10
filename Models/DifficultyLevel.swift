import Foundation
import Combine

enum DifficultyLevel: String, CaseIterable, Identifiable {
    case level1 = "level1"
    case level2 = "level2"
    case level3 = "level3"
    case level4 = "level4"
    case level5 = "level5"
    case level6 = "level6"
    
    var id: String { self.rawValue }
    
    var localizedName: String {
        switch self {
        case .level1: return "difficulty.level1".localized
        case .level2: return "difficulty.level2".localized
        case .level3: return "difficulty.level3".localized
        case .level4: return "difficulty.level4".localized
        case .level5: return "difficulty.level5".localized
        case .level6: return "difficulty.level6".localized
        }
    }
    
    var range: ClosedRange<Int> {
        switch self {
        case .level1: return 1...10    // 10以内加减法
        case .level2: return 1...20    // 20以内加减法
        case .level3: return 1...50    // 50以内加减法
        case .level4: return 1...10    // 10以内乘除法
        case .level5: return 1...20    // 20以内乘除法
        case .level6: return 1...100   // 100以内混合运算
        }
    }
    
    // 获取当前等级支持的运算类型
    var supportedOperations: [Question.Operation] {
        switch self {
        case .level1, .level2, .level3:
            return [.addition, .subtraction]
        case .level4, .level5:
            return [.multiplication, .division]
        case .level6:
            return [.addition, .subtraction, .multiplication, .division]
        }
    }
    
    // 获取当前等级的题目数量
    var questionCount: Int {
        switch self {
        case .level1: return 20
        case .level2: return 25
        case .level3: return 50
        case .level4: return 20
        case .level5: return 25
        case .level6: return 100
        }
    }
    
    // 获取当前等级的分值
    var pointsPerQuestion: Int {
        switch self {
        case .level1: return 5  // 20题 × 5分 = 100分
        case .level2: return 4  // 25题 × 4分 = 100分
        case .level3: return 2  // 50题 × 2分 = 100分
        case .level4: return 5  // 20题 × 5分 = 100分
        case .level5: return 4  // 25题 × 4分 = 100分
        case .level6: return 1  // 100题 × 1分 = 100分
        }
    }
}
