# 小学生算术学习应用开发详细Prompt

## 项目概述
请使用SwiftUI开发一个小学生算术学习应用，帮助学生练习基础的加减法运算。

## 核心功能需求

### 1. 难度等级系统
创建四个难度等级，用户可以选择：
- **等级1**：10以内（数字范围1-10）
- **等级2**：20以内（数字范围1-20）
- **等级3**：50以内（数字范围1-50）
- **等级4**：100以内（数字范围1-100）

### 2. 题目生成系统
- 每个难度等级生成20道不重复的算术题
- 随机生成两个数字进行加法或减法运算
- 确保减法运算结果为正数（被减数大于减数）
- 题目不重复算法：记录已生成的题目组合，避免重复

### 3. 计分系统
- 总分：100分
- 每题分值：5分
- 答对得5分，答错不得分
- 实时显示当前得分

### 4. 时间管理系统
- 可配置限制时间：10-30分钟（整数分钟）
- 显示倒计时器
- 时间到自动结束答题并计算成绩
- 提前完成可手动提交

### 5. 答题界面设计
- 清晰显示数学题目（如：8 + 5 = ?）
- 答案输入框（数字键盘）
- 提交按钮
- 显示当前题目进度（如：第3题/共20题）
- 显示剩余时间
- 显示当前得分

### 6. 答案验证系统
- 实时验证用户输入的答案
- **答对反馈**：
  - 显示"正确！+5分"提示
  - 自动跳转到下一题
  - 更新得分
- **答错反馈**：
  - 显示"答案错误"提示
  - 显示正确答案（如：正确答案是13）
  - 不计分
  - 3秒后自动跳转下一题

### 7. 结果页面
- 显示最终得分
- 显示答对题目数量（如：答对16题/共20题）
- 显示用时
- 根据得分给出评价等级：
  - 90-100分：优秀⭐⭐⭐
  - 80-89分：良好⭐⭐
  - 70-79分：及格⭐
  - 70分以下：需要加油💪
- 提供"重新开始"和"返回主页"按钮

## 界面设计要求

### 1. 主页面
- 应用标题："小学算术练习"
- 四个难度等级选择按钮
- 时间设置滑块或选择器（10-30分钟）
- 开始游戏按钮

### 2. 答题页面
- 顶部信息栏：剩余时间、当前进度、当前得分
- 中央题目显示区域（大字体）
- 答案输入框
- 提交按钮
- 底部可选择"暂停"或"退出"按钮

### 3. 设置页面（可选）
- 时间设置
- 音效开关
- 难度设置说明

## iPad适配要求

### 1. 响应式布局设计
- **屏幕尺寸适配**：支持所有iPad型号（iPad mini、iPad Air、iPad Pro等）
- **横竖屏布局优化**：
  - 竖屏：保持iPhone布局风格，内容居中显示
  - 横屏：充分利用宽屏空间，采用左右分栏或网格布局

### 2. iPad专属界面优化

#### 主页面iPad布局
- **竖屏**：单列布局，按钮和控件适当放大
- **横屏**：双列布局
  - 左侧：应用标题和难度选择（2x2网格）
  - 右侧：时间设置和开始按钮

#### 答题页面iPad布局
- **竖屏**：
  - 顶部信息栏占用更多空间，信息分布更均匀
  - 题目显示区域使用更大字体
  - 答案输入框和按钮适当放大
- **横屏**：
  - 左侧：题目显示区域（占2/3空间）
  - 右侧：答题控制面板
    - 当前进度和得分
    - 答案输入框
    - 提交按钮
    - 暂停/退出按钮

#### 结果页面iPad布局
- **竖屏**：单列展示所有结果信息
- **横屏**：
  - 左侧：得分展示和评价
  - 右侧：详细统计信息和操作按钮

### 3. 字体和间距适配
```swift
// 响应式字体大小
extension Font {
    static func adaptiveTitle() -> Font {
        return UIDevice.current.userInterfaceIdiom == .pad ? .largeTitle : .title
    }
    
    static func adaptiveHeadline() -> Font {
        return UIDevice.current.userInterfaceIdiom == .pad ? .title : .headline
    }
    
    static func adaptiveBody() -> Font {
        return UIDevice.current.userInterfaceIdiom == .pad ? .title3 : .body
    }
}

// 响应式间距
extension CGFloat {
    static let adaptivePadding: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16
    static let adaptiveCornerRadius: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 12 : 8
}
```

### 4. 交互优化
- **触控区域**：所有按钮最小44x44点，iPad上建议60x60点
- **键盘处理**：
  - iPad横屏时键盘不遮挡内容
  - 支持外接键盘数字输入
  - 支持iPad的分屏和滑动覆盖功能

### 5. iPad专属功能增强
- **Split View支持**：应用在分屏模式下正常工作
- **Slide Over支持**：应用在滑动覆盖模式下保持功能完整
- **Apple Pencil支持**（可选）：可以用Apple Pencil在输入框中手写数字
- **键盘快捷键**：支持数字键和回车键快速答题

### 6. 性能优化
- 针对iPad的更大屏幕优化渲染性能
- 合理使用iPad的更大内存空间
- 优化动画效果在大屏幕上的表现

## 技术实现要点

### 1. 数据模型
```swift
// 题目结构
struct Question {
    let number1: Int
    let number2: Int
    let operation: String // "+" 或 "-"
    let correctAnswer: Int
}

// 游戏状态
struct GameState {
    var currentQuestionIndex: Int
    var score: Int
    var timeRemaining: Int
    var questions: [Question]
    var userAnswers: [Int?]
}
```

### 2. 关键功能实现
- 使用Timer管理倒计时
- 使用@State和@ObservableObject管理状态
- 随机数生成确保题目不重复
- 输入验证确保只能输入数字
- 自动保存答题进度
- **设备类型检测**：使用`UIDevice.current.userInterfaceIdiom`区分iPad和iPhone
- **屏幕方向检测**：使用`@Environment(\.horizontalSizeClass)`和`@Environment(\.verticalSizeClass)`
- **动态布局**：使用`GeometryReader`获取屏幕尺寸并动态调整布局

### 3. 用户体验优化
- 流畅的页面转换动画
- 适当的音效反馈（可选）
- 清晰的字体和配色方案
- 适合儿童使用的UI设计
- 支持横竖屏切换
- **iPad适配优化**（详见iPad适配要求）

## 额外功能建议
1. 答题历史记录
2. 错题本功能
3. 进度统计图表
4. 家长查看功能
5. 不同主题皮肤

## 代码结构建议
```
ArithmeticApp/
├── Views/
│   ├── ContentView.swift (主页)
│   ├── GameView.swift (答题页)
│   ├── ResultView.swift (结果页)
│   ├── SettingsView.swift (设置页)
│   └── iPad/
│       ├── iPadContentView.swift (iPad专用主页)
│       ├── iPadGameView.swift (iPad专用答题页)
│       └── iPadResultView.swift (iPad专用结果页)
├── Models/
│   ├── Question.swift
│   └── GameManager.swift
├── ViewModels/
│   └── GameViewModel.swift
├── Utils/
│   ├── QuestionGenerator.swift
│   └── DeviceUtils.swift (设备检测工具)
└── Extensions/
    ├── Font+Adaptive.swift
    └── CGFloat+Adaptive.swift
```

### 通用视图组件建议
```swift
// 自适应容器视图
struct AdaptiveContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            content
                .padding(.adaptivePadding)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(.adaptiveCornerRadius)
        } else {
            content
                .padding(.adaptivePadding)
        }
    }
}
```

请基于以上完整需求（包含iPad适配）开发一个支持iPhone和iPad的SwiftUI应用，确保在不同设备上都有优秀的用户体验。
