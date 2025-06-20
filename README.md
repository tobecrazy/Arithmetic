# 小学生算术学习应用 (Elementary Arithmetic Learning App)

一个使用SwiftUI开发的小学生算术学习应用，帮助学生练习基础的加减法运算。支持中文和英文界面，适配iPhone和iPad设备。

An elementary arithmetic learning application developed with SwiftUI to help students practice basic addition and subtraction operations. Supports both Chinese and English interfaces, and is optimized for iPhone and iPad devices.

## 功能特点 (Features)

### 难度等级系统 (Difficulty Level System)
- **等级1**: 10以内数字 (Numbers 1-10)
- **等级2**: 20以内数字 (Numbers 1-20)
- **等级3**: 50以内数字 (Numbers 1-50)
- **等级4**: 100以内数字 (Numbers 1-100)

### 题目生成系统 (Question Generation System)
- 每个难度等级生成20道不重复的算术题
- 随机生成两个数字进行加法或减法运算
- 确保减法运算结果为正数（被减数大于减数）

### 计分系统 (Scoring System)
- 总分：100分
- 每题分值：5分
- 答对得5分，答错不得分
- 实时显示当前得分

### 时间管理系统 (Time Management System)
- 可配置限制时间：10-30分钟
- 显示倒计时器
- 时间到自动结束答题并计算成绩

### 语言设置 (Language Settings)
- 支持中文和英文界面
- 可随时切换语言

### 设备适配 (Device Adaptation)
- 支持iPhone和iPad设备
- 针对iPad的横屏模式进行了特别优化
- 响应式布局设计

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
2. 设置答题时间（10-30分钟）
3. 选择界面语言（中文或英文）
4. 点击"开始游戏"按钮开始答题
5. 在答题页面输入答案并点击"提交"
6. 完成所有题目或时间结束后，查看结果页面的得分和评价
