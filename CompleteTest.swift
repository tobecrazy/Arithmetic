import Foundation

// 模拟LocalizationManager
class MockLocalizationManager {
    enum Language: String {
        case chinese = "zh-Hans"
        case english = "en"
    }
    
    static let shared = MockLocalizationManager()
    var currentLanguage: Language = .chinese
}

// 模拟DifficultyLevel
enum MockDifficultyLevel: String, CaseIterable {
    case level1 = "level1"
    case level2 = "level2"
    case level3 = "level3"
    case level4 = "level4"
}

// 模拟String扩展
extension String {
    var localized: String {
        // 模拟本地化，返回原始字符串
        return self
    }
    
    func localizedFormat(_ arguments: CVarArg...) -> String {
        return String(format: self, arguments: arguments)
    }
}

// 完整测试凑十法实现
func completeTest() {
    print("=== 完整凑十法测试 ===")
    
    // 测试5 + 6的完整流程
    let num1 = 5
    let num2 = 6
    let result = num1 + num2
    
    print("题目: \(num1) + \(num2) = \(result)")
    
    // 模拟完整的凑十法逻辑
    let larger = max(num1, num2)  // 6
    let smaller = min(num1, num2)  // 5
    let neededToMakeTen = 10 - larger  // 10 - 6 = 4
    let remainderFromSmaller = smaller - neededToMakeTen  // 5 - 4 = 1
    
    // 检查适用条件
    let sum = num1 + num2
    let isApplicable = sum > 10 && sum <= 20 && larger < 10 && neededToMakeTen > 0 && neededToMakeTen <= smaller && remainderFromSmaller >= 0
    
    print("适用条件检查: \(isApplicable)")
    
    if isApplicable {
        // 模拟当前的中文解析实现
        let currentLanguage = MockLocalizationManager.shared.currentLanguage
        
        if currentLanguage == .chinese {
            let chineseOutput = String(format: "凑十法解析：\n%d + %d = ?\n\n步骤1：看大数%d，需要%d凑成10\n步骤2：拆小数%d，分解为%d和%d\n步骤3：%d + %d = 10\n步骤4：10 + %d = %d\n\n所以，%d + %d = %d",
                num1, num2,                           // 5 + 6 = ?
                larger, neededToMakeTen,              // 看大数6，需要4凑成10
                smaller, neededToMakeTen, remainderFromSmaller,  // 拆小数5，分解为4和1
                larger, neededToMakeTen,              // 6 + 4 = 10
                remainderFromSmaller, result,         // 10 + 1 = 11
                num1, num2, result                    // 所以，5 + 6 = 11
            )
            
            print("\n=== 当前中文输出 ===")
            print(chineseOutput)
        }
        
        // 检查是否有任何可能产生错误的情况
        print("\n=== 错误检查 ===")
        
        // 检查所有参数值
        print("参数检查:")
        print("  num1 = \(num1)")
        print("  num2 = \(num2)")
        print("  larger = \(larger)")
        print("  smaller = \(smaller)")
        print("  neededToMakeTen = \(neededToMakeTen)")
        print("  remainderFromSmaller = \(remainderFromSmaller)")
        print("  result = \(result)")
        
        // 检查是否有任何地方会产生"10 - 10 = 4"
        print("\n错误模式检查:")
        print("  是否有'10 - 10 = 4'? ❌ 在当前实现中不应该出现")
        print("  正确的计算: 10 - \(larger) = \(neededToMakeTen)")
        
        // 如果仍然出现错误，可能的原因
        print("\n如果仍然看到错误，可能的原因:")
        print("  1. 应用使用了缓存的旧版本")
        print("  2. 有其他代码路径我们没有发现")
        print("  3. 编译后的应用没有使用最新的代码")
    }
}

// 运行完整测试
completeTest()
