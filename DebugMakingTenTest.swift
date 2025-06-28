import Foundation

// 调试凑十法实现，找出"10 - 10 = 4"错误的来源
func debugMakingTenImplementation() {
    print("=== 调试凑十法实现 ===")
    
    // 测试 5 + 6 = 11
    let num1 = 5
    let num2 = 6
    let result = num1 + num2
    
    print("题目: \(num1) + \(num2) = \(result)")
    
    // 检查所有可能的逻辑路径
    let larger = max(num1, num2)  // 6
    let smaller = min(num1, num2)  // 5
    let neededToMakeTen = 10 - larger  // 10 - 6 = 4
    let remainderFromSmaller = smaller - neededToMakeTen  // 5 - 4 = 1
    
    print("\n=== 变量值检查 ===")
    print("larger = \(larger)")
    print("smaller = \(smaller)")
    print("neededToMakeTen = 10 - \(larger) = \(neededToMakeTen)")
    print("remainderFromSmaller = \(smaller) - \(neededToMakeTen) = \(remainderFromSmaller)")
    
    // 检查可能产生错误的格式化字符串
    print("\n=== 可能的错误格式化检查 ===")
    
    // 错误的格式化1：如果参数顺序错误
    let wrongFormat1 = String(format: "找出%d与10的差值：10 - %d = %d", larger, larger, neededToMakeTen)
    print("正确格式: \(wrongFormat1)")
    
    // 错误的格式化2：如果传递了错误的参数
    let wrongFormat2 = String(format: "找出%d与10的差值：10 - %d = %d", larger, 10, neededToMakeTen)
    print("错误格式(如果传10): \(wrongFormat2)")
    
    // 检查是否有地方会产生"10 - 10 = 4"
    print("\n=== 寻找'10 - 10 = 4'错误源 ===")
    
    // 可能的错误场景1：参数传递错误
    if larger == 6 && neededToMakeTen == 4 {
        // 如果某处错误地传递了10而不是6
        let errorScenario1 = String(format: "找出%d与10的差值：10 - %d = %d", larger, 10, neededToMakeTen)
        print("错误场景1: \(errorScenario1)")
        
        // 如果某处错误地使用了10作为被减数
        let errorScenario2 = String(format: "找出%d与10的差值：%d - %d = %d", larger, 10, 10, neededToMakeTen)
        print("错误场景2: \(errorScenario2)")
    }
    
    // 检查当前正确的实现
    print("\n=== 当前正确实现 ===")
    let correctFormat = String(format: "看大数%d，需要%d凑成10", larger, neededToMakeTen)
    print("正确描述: \(correctFormat)")
    
    // 完整的正确凑十法步骤
    let correctSteps = String(format: "凑十法解析：\n%d + %d = ?\n\n步骤1：看大数%d，需要%d凑成10\n步骤2：拆小数%d，分解为%d和%d\n步骤3：%d + %d = 10\n步骤4：10 + %d = %d\n\n所以，%d + %d = %d",
        num1, num2,                           // 5 + 6 = ?
        larger, neededToMakeTen,              // 看大数6，需要4凑成10
        smaller, neededToMakeTen, remainderFromSmaller,  // 拆小数5，分解为4和1
        larger, neededToMakeTen,              // 6 + 4 = 10
        remainderFromSmaller, result,         // 10 + 1 = 11
        num1, num2, result                    // 所以，5 + 6 = 11
    )
    
    print("\n=== 完整正确步骤 ===")
    print(correctSteps)
}

// 运行调试
debugMakingTenImplementation()
