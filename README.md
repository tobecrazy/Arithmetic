# 小学生算术学习应用 (Elementary Arithmetic Learning App)

一个使用SwiftUI开发的小学生算术学习应用，帮助学生练习基础的加减法运算。支持中文和英文界面，适配iPhone和iPad设备。

An elementary arithmetic learning application developed with SwiftUI to help students practice basic addition and subtraction operations. Supports both Chinese and English interfaces, and is optimized for iPhone and iPad devices.

## 功能特点 (Features)

### 难度等级系统 (Difficulty Level System)
- **等级1**: 10以内数字 (Numbers 1-10)，20道题 (20 questions)
- **等级2**: 20以内数字 (Numbers 1-20)，25道题 (25 questions)
- **等级3**: 50以内数字 (Numbers 1-50)，50道题 (50 questions)
- **等级4**: 100以内数字 (Numbers 1-100)，100道题 (100 questions)

### 题目生成系统 (Question Generation System)
- 根据难度等级生成不同数量的不重复算术题
- 等级1：两个数字的加减法运算
- 等级2及以上：
  - 两个数字的加减法运算
  - 三个数字的连加、连减或加减混合运算（如 5 + 3 - 2 = ?）
  - 难度越高，三数运算出现概率越大（等级2：40%，等级3：60%，等级4：80%）
- 确保所有运算结果不为负数
- 确保所有运算过程中的中间结果和最终结果不超过当前难度等级的上限：
  - 等级2：不超过20
  - 等级3：不超过50
  - 等级4：不超过100
- 随着难度等级提高，题目难度逐渐增加：
  - 更高概率生成减法题（比加法更具挑战性）
  - 倾向于使用更大的数字
  - 减法运算中，两个数字差值更小（更难计算）

### 计分系统 (Scoring System)
- 根据难度等级设置不同的分值：
  - **等级1**: 每题5分，总分100分
  - **等级2**: 每题4分，总分100分
  - **等级3**: 每题2分，总分100分
  - **等级4**: 每题1分，总分100分
- 答对得分，答错不得分
- 实时显示当前得分

### 时间管理系统 (Time Management System)
- 可配置限制时间：3-30分钟
- 显示倒计时器
- 时间到自动结束答题并计算成绩
- 重新开始游戏时自动重置计时器

### 输入验证系统 (Input Validation System)
- 仅允许输入数字字符
- 自动过滤非数字输入
- 支持数字键盘和外部键盘输入

### 语言设置 (Language Settings)
- 支持中文和英文界面
- 可随时切换语言

### 设备适配 (Device Adaptation)
- 支持iPhone和iPad设备
- 针对iPad的横屏模式进行了特别优化
- 响应式布局设计

## 安装说明 (Installation)

1. 确保你已安装最新版本的Xcode (13.0+)
2. 克隆此仓库到本地:
   ```bash
   git clone https://github.com/tobecrazy/Arithmetic.git
   ```
3. 打开Arithmetic.xcodeproj文件
4. 选择目标设备（iPhone或iPad模拟器或实机）
5. 点击运行按钮或按下Cmd+R开始构建和运行应用

## 技术实现 (Technical Implementation)

- **架构模式**: MVVM (Model-View-ViewModel)
- **UI框架**: SwiftUI
- **本地化**: 使用标准的iOS本地化机制
- **响应式设计**: 使用GeometryReader和环境值适配不同设备和方向

## 项目结构 (Project Structure)

```
Arithmetic/
├── App/
│   └── ArithmeticApp.swift
├── Views/
│   ├── ContentView.swift
│   ├── GameView.swift
│   ├── ResultView.swift
│   └── LanguageSelectorView.swift
├── Models/
│   ├── Question.swift
│   ├── DifficultyLevel.swift
│   └── GameState.swift
├── ViewModels/
│   └── GameViewModel.swift
├── Utils/
│   ├── LocalizationManager.swift
│   ├── QuestionGenerator.swift
│   └── DeviceUtils.swift
├── Extensions/
│   ├── String+Localized.swift
│   ├── Font+Adaptive.swift
│   └── CGFloat+Adaptive.swift
└── Resources/
    ├── zh-Hans.lproj/Localizable.strings
    └── en.lproj/Localizable.strings
```

## 系统要求 (System Requirements)

- iOS 15.0+
- iPadOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## 使用说明 (Usage Instructions)

1. 在主页面选择难度等级
2. 设置答题时间（3-30分钟）
3. 选择界面语言（中文或英文）
4. 点击"开始游戏"按钮开始答题
5. 在答题页面输入答案并点击"提交"
6. 完成所有题目或时间结束后，查看结果页面的得分和评价
7. 可以点击"重新开始"按钮重新开始游戏，所有数据将被重置
8. 或点击"返回主页"按钮返回到主页面

## 贡献指南 (Contribution Guidelines)

我们欢迎所有形式的贡献，包括但不限于：

1. 报告问题和错误
2. 提交功能请求
3. 提交代码改进
4. 改进文档

请遵循以下步骤进行贡献：

1. Fork此仓库
2. 创建你的特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交你的更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 打开一个Pull Request

## 许可证 (License)

此项目采用MIT许可证 - 详情请查看 [LICENSE](LICENSE) 文件

## 联系与支持 (Contact & Support)

如有任何问题或建议，请通过以下方式联系我们：

- 提交GitHub Issue
- 发送电子邮件至: [tobecrazy@qq.com](mailto:tobecrazy@qq.com)
