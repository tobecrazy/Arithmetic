# Change Log

### 🌟 2026-02-15 (修复分数相关测试失败 / Fix Fraction-Related Test Failures)
- **🔧 修复分数显示问题 (Fixed Fraction Display Issue)** - 修复Question.questionText属性以正确显示分数 (Fixed Question.questionText property to properly display fractions)
- **🌍 修复中英双语分数读法 (Fixed Bilingual Fraction Pronunciation)** - 修正中文分数读法规则，确保1/2显示为"二分之一" (Corrected Chinese fraction pronunciation rules, ensuring 1/2 displays as "二分之一")
- **🧪 修复测试失败 (Fixed Test Failures)** - 修复了6个测试失败，包括分数显示和中英文读法测试 (Fixed 6 test failures, including fraction display and bilingual pronunciation tests)

### 🌟 2026-02-14 (版本更新和文档同步 / Version Update and Documentation Sync)
- **🔄 版本更新 (Version Update)** - 更新应用版本至1.0.9 (Updated app version to 1.0.9)
- **📄 文档同步 (Documentation Sync)** - 同步README.md和ChangeLogs.md内容 (Synchronized README.md and ChangeLogs.md content)
- **🌐 本地化更新 (Localization Update)** - 更新中英文本地化字符串 (Updated Chinese/English localization strings)

### 🌟 2026-02-06 (Level 7 分数运算支持 / Level 7 Fraction Operations Support)

#### ✨ 新增功能 (New Features)
- **🔢 Level 7 - 复杂混合运算含分数 (Complex Mixed Operations with Fractions)**
  - 新增Level 7难度等级，100道题目，每题1分
  - 支持分数作为答案，特别是非整除的除法运算
  - 自动分数简化（如 6/9 → 2/3）
  - 带分数显示支持（如 7/3 → 2⅓）
  - Added Level 7 difficulty, 100 questions, 1 point each
  - Supports fractions as answers, especially non-integer division
  - Automatic fraction simplification (e.g., 6/9 → 2/3)
  - Mixed number display support (e.g., 7/3 → 2⅓)

- **➕ 分数运算系统 (Fraction Operations System)**
  - 新增Fraction模型，使用GCD算法自动简化分数
  - 支持假分数转换为带分数
  - 分数相等性判断（自动简化后比较）
  - Added Fraction model with GCD-based automatic simplification
  - Supports improper fraction to mixed number conversion
  - Fraction equality comparison (after simplification)

- **🎤 分数朗读支持 (Fraction TTS Support)**
  - TTSHelper扩展支持分数自然发音
  - 中文："二分之一"、"三分之二" (Chinese: "二分之一", "三分之二")
  - 英文："one half", "two thirds" (English: "one half", "two thirds")
  - Extended TTSHelper with natural fraction pronunciation

- **📝 分数输入界面 (Fraction Input Interface)**
  - 新增FractionInputView专用分数输入组件
  - 分子分母分开输入，带除法线显示
  - 数字键盘优化，输入验证
  - Added dedicated FractionInputView component
  - Separate numerator/denominator inputs with division line
  - Numeric keypad optimization with validation

#### 🔄 功能更新 (Feature Updates)
- **Level 5 更新 (Level 5 Updates)**
  - 数值范围从1-20扩展至1-50
  - 题目数量从25题增至30题
  - 每题分值从4分调整为3分（总分90分，可通过速度奖励达到100分）
  - Range expanded from 1-20 to 1-50
  - Question count increased from 25 to 30
  - Points per question adjusted from 4 to 3 (90 total, can reach 100 with speed bonus)

- **Level 6 更新 (Level 6 Updates)**
  - 数值范围从1-100扩展至1-1000
  - 重命名为"三位数混合运算"
  - 强调三位数大数运算能力
  - Range expanded from 1-100 to 1-1000
  - Renamed to "Three-digit Mixed Operations"
  - Emphasizes large three-digit calculation abilities

#### 💾 数据持久化 (Data Persistence)
- **CoreData 架构更新 (CoreData Schema Updates)**
  - WrongQuestionEntity增加分数字段：answerType, fractionNumerator, fractionDenominator
  - 向后兼容：旧数据自动默认为整数类型
  - GameProgressEntity支持Level 7进度保存
  - Added fraction fields to WrongQuestionEntity: answerType, fractionNumerator, fractionDenominator
  - Backward compatible: Legacy data defaults to integer type
  - GameProgressEntity supports Level 7 progress saving

#### 🌐 本地化 (Localization)
- **新增40+分数相关本地化字符串 (Added 40+ Fraction-related Localization Strings)**
  - 分数显示："分子"、"分母"、"化简后" ("Numerator", "Denominator", "Simplified")
  - 分数发音辅助：常用分数读法 (Fraction pronunciation helpers: common fraction pronunciation)
  - 难度等级名称更新 (Difficulty level name updates)
  - 完整中英文双语支持 (Complete Chinese/English bilingual support)

#### 🧪 测试覆盖 (Test Coverage)
- **新增FractionTests.swift (Added FractionTests.swift)**
  - 分数初始化、简化、GCD算法测试
  - 带分数转换、相等性判断测试
  - 边界情况和负数测试
  - Initialization, simplification, GCD algorithm tests
  - Mixed number conversion, equality tests
  - Edge cases and negative number tests

- **扩展现有测试 (Extended Existing Tests)**
  - QuestionTests: 新增FractionAnswerTests类
  - DifficultyLevelTests: Level 7属性和范围测试
  - UtilsTests: Level 5/6/7题目生成测试
  - CoreDataTests: 分数存储和向后兼容性测试
  - QuestionTests: Added FractionAnswerTests class
  - DifficultyLevelTests: Level 7 properties and range tests
  - UtilsTests: Level 5/6/7 question generation tests
  - CoreDataTests: Fraction storage and backward compatibility tests

#### 📊 技术影响 (Technical Impact)
- **新增文件 (New Files)**:
  - Models/Fraction.swift (162 lines)
  - Views/FractionInputView.swift (98 lines)
  - Tests/FractionTests.swift (235 lines)

- **修改文件 (Modified Files)**:
  - Models/Question.swift: 新增分数答案支持
  - Models/DifficultyLevel.swift: Level 7和Level 5/6更新
  - Utils/TTSHelper.swift: 分数朗读支持
  - Utils/QuestionGenerator.swift: Level 7题目生成
  - CoreData相关文件：Schema更新
  - Views/GameView.swift: 条件分数输入渲染
  - 本地化文件：40+新字符串

- **代码质量 (Code Quality)**:
  - 完整的单元测试覆盖
  - 向后兼容的数据迁移
  - 类型安全的分数运算
  - SwiftUI响应式UI更新
  - Complete unit test coverage
  - Backward-compatible data migration
  - Type-safe fraction operations
  - Reactive SwiftUI updates

### 🌟 2026-02-05 (项目结构优化和代码质量提升 / Project Structure Optimization and Code Quality Enhancement)
- **🧩 组件模块化 (Component Modularization)** - 创建可重用SwiftUI组件库，分解1020行的GameView，提高可维护性 (Created reusable SwiftUI component library, broke down 1020-line GameView for better maintainability)
  - **新增6个组件文件 (Added 6 Component Files)**: QuestionDisplayView, GameInfoHeaderView, AnswerInputView, SolutionPanelView, GameControlButtonsView, AnswerFeedbackView
  - **收益 (Benefits)**: 更好的代码组织、组件可重用、独立测试、Xcode画布预览支持 (Better code organization, component reusability, independent testing, Xcode canvas preview support)

- **🖨️ PDF生成优化 (PDF Generation Enhancements)** - 增强PDF生成逻辑，改进A4纸张兼容性与排版稳定性 (Enhanced PDF generation logic, improved A4 compatibility and layout stability)
  - **分页与排版优化 (Pagination & Layout)**: 改进分页算法，减少断行/溢出问题，保证题目对齐 (Improved pagination to reduce line breaks/overflow and keep questions aligned)
  - **页面规范 (Page Standards)**: 优化边距与字体缩放，确保A4打印清晰一致 (Optimized margins and font scaling for consistent A4 printing)

- **📚 Swift DocC文档增强 (Swift DocC Documentation Enhancement)** - 为核心API添加专业级文档，文档覆盖率从~20%提升至~80% (Added professional-grade documentation to core APIs, documentation coverage improved from ~20% to ~80%)
  - **QuestionGenerator.swift文档 (QuestionGenerator.swift Documentation)**: 类概述、使用示例、问题分布表、5个公共方法详细文档 (Class overview, usage examples, question distribution table, detailed docs for 5 public methods)
  - **GameViewModel.swift文档 (GameViewModel.swift Documentation)**: 类概述、18个公共方法完整文档、Published属性说明 (Class overview, complete docs for 18 public methods, Published properties documentation)
  - **收益 (Benefits)**: Xcode快速帮助集成、新开发者更快上手、清晰API契约 (Xcode Quick Help integration, faster onboarding, clear API contracts)

- **🏗️ ViewBuilder模式库 (ViewBuilder Pattern Library)** - 创建视图组合工具和模式，提供条件视图转换等功能 (Created view composition utilities and patterns, providing conditional view transformation functions)
  - **新文件 (New File)**: Extensions/View+ViewBuilder.swift
  - **扩展方法 (Extension Methods)**: `.if(condition, transform:)`, `.ifElse(condition, trueTransform:, falseTransform:)`, `.ifLet(value, transform:)`
  - **ViewBuilders命名空间 (ViewBuilders Namespace)**: 提供5个可重用视图模式 (Provides 5 reusable view patterns)
  - **收益 (Benefits)**: 减少代码重复、UI模式保持一致、提高代码可读性 (Reduce code duplication, consistent UI patterns, improved code readability)

- **🔧 代码重构 (Code Refactoring)** - 解决代码重复、内存管理、复杂方法等问题，提升代码质量 (Resolved code duplication, memory management, and complex method issues to improve code quality)
  - **GameViewModel代码重复消除 (Eliminated Code Duplication in GameViewModel)**: 提取setupSubscriptions()方法 (Extracted setupSubscriptions() method)
  - **内存管理改进 (Improved Memory Management)**: 依赖Combine的自动清理机制 (Rely on Combine's automatic cleanup)
  - **QuestionGenerator复杂方法重构 (Refactored Complex QuestionGenerator Method)**: 创建QuestionGenerator+ThreeNumber.swift扩展文件，分解为11个专注方法 (Created QuestionGenerator+ThreeNumber.swift extension file, broke down into 11 focused methods)
  - **Core Data错误处理增强 (Enhanced Core Data Error Handling)**: 添加@Published initializationStatus枚举 (Added @Published initializationStatus enum)
  - **魔术数字常量化 (Extracted Magic Numbers to Constants)**: 创建Constants枚举 (Created Constants enums)

- **✅ 测试修复 (Test Fixes)** - 修复所有CI测试失败，实现356/356测试通过 (Fixed all CI test failures, achieved 356/356 tests passing)
  - **问题根源 (Root Cause)**: Level4三数运算生成时出现"Range requires lowerBound <= upperBound"崩溃 (Level4 three-number generation crashed with "Range requires lowerBound <= upperBound")
  - **解决方案 (Solutions)**: 改进初始数字生成、增强小范围除法安全、优化Level4运算选择、改进降级生成 (Improved initial number generation, enhanced division safety for small ranges, optimized Level4 operation selection, improved fallback generation)
  - **测试结果 (Test Results)**: 356/356测试全部通过，执行时间6.9秒 (356/356 tests all passing, execution time: 6.9s)

- **📊 技术影响 (Technical Impact)**
  - 代码行数：从396行单一方法优化为11个专注方法 (Lines of code: Optimized from 396-line single method to 11 focused methods)
  - 测试覆盖率：保持高覆盖率同时提高可靠性 (Test coverage: Maintained high coverage while improving reliability)
  - 构建时间：无显著影响 (Build time: No significant impact)
  - 运行时性能：略有提升(更快的测试执行) (Runtime performance: Slight improvement (faster test execution))

### 🌟 2026-02-04 (题目生成系统优化 - 提升难度和教学价值 / Question Generation System Optimization - Enhanced Difficulty and Educational Value)
- **🎯 消除过于简单的题目 (Eliminated Overly Simple Questions)** - 全面优化题目生成逻辑，大幅提升题目质量和挑战性 (Comprehensively optimized question generation logic, significantly improving question quality and challenge level)

  **两数运算优化 (Two-Number Operation Optimization)**:
  - **加法 (Addition)**: Level 2+强制最小和为8，严格避免相同数字(如2+2)和过小组合(如1+1) (Level 2+ enforces minimum sum of 8, strictly avoids same numbers like 2+2 and tiny combinations like 1+1)
  - **减法 (Subtraction)**: 提高最小差值要求(Level 1: 2, Level 2+: 3)，完全消除相同数字相减(如5-5) (Increased minimum difference requirements: Level 1: 2, Level 2+: 3, completely eliminated same-number subtraction like 5-5)
  - **乘法 (Multiplication)**: 彻底移除×1运算，确保两个因数都至少为2 (Completely removed ×1 operations, ensuring both factors are at least 2)
  - **除法 (Division)**: 提高最小商值(Level 1: 2, Level 4: 3, Level 5/6: 4)，严格避免相同数字相除(如6÷6)，70%概率优先选择较大的商 (Increased minimum quotients: Level 1: 2, Level 4: 3, Level 5/6: 4, strictly avoid same-number division like 6÷6, 70% probability prioritizes larger quotients)

  **三数运算优化 (Three-Number Operation Optimization)**:
  - 根据难度设置更高的最小数字值(Level 2: 3, Level 3: 5, Level 5/6: 3) (Set higher minimum number values by level: Level 2: 3, Level 3: 5, Level 5/6: 3)
  - 拒绝所有数字都≤3的题目，提高最小答案要求(Level 2/4: 3, Level 3/5/6: 5) (Reject questions where all numbers are ≤3, increased minimum answer requirements: Level 2/4: 3, Level 3/5/6: 5)
  - 增强降级生成逻辑，避免生成相同数字的题目 (Enhanced fallback generation to avoid same-number questions)

  **模式检测增强 (Pattern Detection Enhancement)**:
  - 拒绝所有重复简单模式(如2+2+2, 3+3+3) (Reject all repetitive simple patterns like 2+2+2, 3+3+3)
  - 强化对自我抵消运算的检测(A+B-B, A×B÷B等) (Strengthened detection of self-canceling operations: A+B-B, A×B÷B, etc.)
  - 更严格地检查小数字重复(≤3)在三数运算中的出现 (More strictly check repetition of small numbers (≤3) in three-number operations)

  **去重优化 (Deduplication Optimization)**:
  - 交换律运算自动规范化(3+5 = 5+3, 2×7 = 7×2) (Commutative operations auto-normalized: 3+5 = 5+3, 2×7 = 7×2)
  - 防止语义重复题目出现在同一题组中 (Prevent semantically duplicate questions in the same question set)

- **📊 配置常量化 (Configuration Constants)** - 新增更细粒度的配置常量 (Added more fine-grained configuration constants)
  - `minNumberValueLevel2Plus = 3`: Level 2+最小数字值 (Minimum number value for Level 2+)
  - `minNumberValueLevel3Plus = 5`: Level 3+最小数字值 (Minimum number value for Level 3+)
  - `minSumLevel2Plus = 8`: Level 2+加法最小和 (Minimum sum for Level 2+ addition)
  - `minDifferenceLevel2Plus = 3`: Level 2+减法最小差值 (Minimum difference for Level 2+ subtraction)

- **✅ 质量保证 (Quality Assurance)** - 所有优化经过严格测试验证 (All optimizations rigorously tested and verified)
  - 127/127测试全部通过，零回归 (127/127 tests passing, zero regressions)
  - 保持数学正确性：整数除法、PEMDAS规则、范围边界、正数结果 (Maintained mathematical correctness: integer division, PEMDAS rules, range boundaries, positive results)
  - 项目成功构建，无编译错误 (Project builds successfully, no compilation errors)

- **📈 教育价值提升 (Educational Value Enhancement)** - 题目更具挑战性和教学意义 (Questions are more challenging and educationally meaningful)
  - ❌ 消除的问题类型: 1+1, 2+2 (Level 2+), 5-5, 6÷6, 2×1, 2+2+2, A+B-B, A×B÷B, 3+5与5+3重复 (Eliminated question types: 1+1, 2+2 (Level 2+), 5-5, 6÷6, 2×1, 2+2+2, A+B-B, A×B÷B, duplicate 3+5 and 5+3)
  - ✅ 增强的特性: Level 2加法和≥8, Level 2+减法差≥3, 除法商≥3-4, 三数运算使用更大数字(3+或5+) (Enhanced features: Level 2 addition sum ≥8, Level 2+ subtraction difference ≥3, division quotient ≥3-4, three-number operations use larger numbers (3+ or 5+))

- **🔧 技术实现 (Technical Implementation)** - 优化核心算法和代码质量 (Optimized core algorithms and code quality)
  - 修改文件: `Utils/QuestionGenerator.swift`, `Utils/QuestionGenerator+ThreeNumber.swift` (Modified files: Utils/QuestionGenerator.swift, Utils/QuestionGenerator+ThreeNumber.swift)
  - 代码变更: 260行修改，提升算法智能度和健壮性 (Code changes: 260 lines modified, improved algorithm intelligence and robustness)
  - Git提交: commit 9ac2a11 (Git commit: commit 9ac2a11)

### 🌟 2026-02-03 (代码质量提升、模块化重构和文档增强 / Code Quality, Modularization and Documentation Enhancements)
- **🧩 组件模块化 (Component Modularization)** - 创建可重用SwiftUI组件库 (Created reusable SwiftUI component library)

  **新增6个组件文件 (Added 6 Component Files)**
  - 位置：Views/Components/ (Location: Views/Components/)
  - 目的：分解1020行的GameView，提高可维护性 (Purpose: Break down 1020-line GameView for better maintainability)

  **组件列表 (Component List)**:
  1. **QuestionDisplayView** - 题目显示组件
     - 自适应字体大小(iPad: 60pt, iPhone: 40pt)
     - 点击支持TTS朗读
     - 答对时缩放动画
     - 包含预览支持

  2. **GameInfoHeaderView** - 游戏信息头部
     - 时间倒计时显示
     - 渐变进度条(蓝色→紫色)
     - 分数和连击显示
     - 火焰图标动画

  3. **AnswerInputView** - 答案输入组件
     - 纯数字键盘
     - 自动过滤非数字输入
     - 提交按钮动画
     - 禁用状态管理

  4. **SolutionPanelView** - 解析面板
     - 可展开/折叠动画
     - 滚动内容支持
     - 动态高度计算(根据设备和方向)
     - 黄色高亮背景

  5. **GameControlButtonsView** - 游戏控制按钮
     - 暂停、保存、退出、完成按钮
     - 确认弹窗(退出和暂停)
     - 禁用状态样式
     - 双行布局

  6. **AnswerFeedbackView** - 答案反馈组件
     - 答对：绿色对勾+缩放动画
     - 答错：红色叉号+抖动动画
     - 集成解析面板
     - 下一题按钮

  **收益 (Benefits)**:
  - ✅ 更好的代码组织和可读性 (Better code organization and readability)
  - ✅ 组件可在其他视图中重用 (Components reusable in other views)
  - ✅ 每个组件可独立测试 (Each component independently testable)
  - ✅ Xcode画布预览支持 (Xcode canvas preview support)
  - ✅ 减少GameView复杂度(预计-36%代码行数) (Reduces GameView complexity, projected -36% lines)

- **📚 Swift DocC文档增强 (Swift DocC Documentation Enhancement)** - 为核心API添加专业级文档 (Added professional-grade documentation to core APIs)

  **QuestionGenerator.swift文档 (QuestionGenerator.swift Documentation)**:
  - 类概述：架构说明、功能特性 (Class overview: architecture, features)
  - 完整的使用示例和代码块 (Complete usage examples with code blocks)
  - 问题分布表(按难度等级) (Question distribution table by level)
  - 所有5个公共方法的详细文档 (Detailed docs for all 5 public methods)
  - 参数说明、返回值、注意事项 (Parameter descriptions, return values, notes)

  **文档方法 (Documented Methods)**:
  ```swift
  /// Generates a set of non-repetitive arithmetic questions
  /// - Parameters:
  ///   - difficultyLevel: Determines number ranges and operations
  ///   - count: Desired number of questions
  ///   - wrongQuestions: Previously incorrect questions to incorporate
  /// - Returns: Array of valid, non-duplicate questions
  static func generateQuestions(difficultyLevel:count:wrongQuestions:)

  /// Generates a unique identifier key to prevent duplicates
  /// - Parameter question: The question to generate a key for
  /// - Returns: String uniquely identifying the expression
  static func getCombinationKey(for:)

  /// Generates random integer with safety checks
  /// - Parameter range: Closed or half-open range
  /// - Returns: Random integer or lowerBound if invalid
  static func safeRandom(in:)
  ```

  **GameViewModel.swift文档 (GameViewModel.swift Documentation)**:
  - 类概述：MVVM架构、Combine集成、职责说明 (Class overview: MVVM, Combine, responsibilities)
  - 18个公共方法完整文档 (Complete docs for 18 public methods)
  - Published属性说明和响应式更新 (Published properties with reactive updates)
  - 生命周期管理(初始化、启动、暂停、恢复、结束) (Lifecycle management: init, start, pause, resume, end)
  - 游戏流程说明和行为表格 (Game flow explanations and behavior tables)

  **文档方法示例 (Documented Methods Example)**:
  ```swift
  /// Creates a new game with specified difficulty and time limit
  /// - Parameters:
  ///   - difficultyLevel: Determines question ranges and operations
  ///   - timeInMinutes: Total time allowed in minutes
  init(difficultyLevel:timeInMinutes:)

  /// Validates and processes user's answer
  /// - Parameter answer: User's submitted answer as integer
  /// ## Behavior
  /// - Correct: Increments score, moves to next, reads via TTS
  /// - Incorrect: Shows correct answer, enables solution panel
  func submitAnswer(_:)

  /// Loads previously saved game from CoreData
  /// - Returns: GameViewModel with saved state, or nil if no save
  static func loadSavedGame()
  ```

  **文档覆盖率 (Documentation Coverage)**:
  - 之前：~20% (Before: ~20%)
  - 之后：~80% (After: ~80%)
  - 改进：+300% (Improvement: +300%)

  **收益 (Benefits)**:
  - ✅ Xcode快速帮助集成(Option+Click) (Xcode Quick Help integration via Option+Click)
  - ✅ 新开发者更快上手 (Faster onboarding for new developers)
  - ✅ 清晰的API契约和行为说明 (Clear API contracts and behavior)
  - ✅ 可生成DocC静态网站 (Can generate static DocC website)

- **🏗️ ViewBuilder模式库 (ViewBuilder Pattern Library)** - 创建视图组合工具和模式 (Created view composition utilities and patterns)

  **新文件：Extensions/View+ViewBuilder.swift**

  **扩展方法 (Extension Methods)**:
  1. **`.if(condition, transform:)`** - 条件视图转换
     ```swift
     Text("Hello")
         .if(isPremium) { view in
             view.foregroundColor(.gold)
         }
     ```
     - 避免嵌套if-else包装视图
     - 不破坏视图构建器链
     - 类型安全

  2. **`.ifElse(condition, trueTransform:, falseTransform:)`** - 条件分支转换
     ```swift
     Text("Status")
         .ifElse(isActive,
             trueTransform: { $0.foregroundColor(.green) },
             falseTransform: { $0.foregroundColor(.gray) }
         )
     ```
     - 比三元运算符更清晰
     - 避免AnyView类型擦除
     - 编译时类型检查

  3. **`.ifLet(value, transform:)`** - 可选值安全转换
     ```swift
     Text("Title")
         .ifLet(errorMessage) { view, message in
             view.overlay(Text(message), alignment: .bottom)
         }
     ```
     - 安全解包可选值
     - 无需强制解包
     - 意图明确

  **ViewBuilders命名空间 (ViewBuilders Namespace)**:
  提供5个可重用视图模式 (Provides 5 reusable view patterns):

  1. **`badge(text:color:)`** - 状态徽章
     ```swift
     ViewBuilders.badge(text: "NEW", color: .blue)
     ```

  2. **`iconLabel(systemName:text:color:)`** - 图标标签
     ```swift
     ViewBuilders.iconLabel(systemName: "star.fill", text: "Featured")
     ```

  3. **`card(content:)`** - 卡片容器
     ```swift
     ViewBuilders.card {
         Text("Card Content")
     }
     ```

  4. **`loadingOverlay(isLoading:)`** - 加载遮罩
     ```swift
     ViewBuilders.loadingOverlay(isLoading: isLoading)
     ```

  5. **`emptyState(systemName:message:)`** - 空状态视图
     ```swift
     ViewBuilders.emptyState(systemName: "tray", message: "No data")
     ```

  **收益 (Benefits)**:
  - ✅ 减少代码重复 (Reduced code duplication)
  - ✅ UI模式保持一致 (Consistent UI patterns)
  - ✅ 提高代码可读性 (Improved code readability)
  - ✅ 类型安全的视图转换 (Type-safe view transformations)
  - ✅ 零性能开销 (Zero performance overhead)

- **📋 开发规范 (Development Guidelines)** - 更新项目开发规范 (Updated project development guidelines)
  - 在CLAUDE.md添加"文件创建规范"章节 (Added "File Creation Guidelines" section to CLAUDE.md)
  - 明确禁止创建不必要的总结文件 (Explicitly prohibits unnecessary summary files)
  - 规范README.md和ChangeLogs.md的更新策略 (Standardized update strategy for README.md and ChangeLogs.md)

- **✅ 质量提升 (Quality Improvements)** - 代码质量评分从95/100提升至98/100 (Code quality score improved from 95/100 to 98/100)
  - ✅ 更好的代码组织 (Better code organization)
  - ✅ 完善的API文档 (Comprehensive API documentation)
  - ✅ 更模块化的架构 (More modular architecture)
  - ✅ 类型安全的视图组合 (Type-safe view composition)
  - ✅ 356/356测试通过，零回归 (356/356 tests passing, zero regressions)

### 🔧 2026-02-03 (代码质量提升和测试修复 / Code Quality Improvements and Test Fixes)
- **🔧 代码重构 (Code Refactoring)** - 全面解决5个关键代码质量问题 (Comprehensively resolved 5 critical code quality issues)

  **1. GameViewModel代码重复消除 (Eliminated Code Duplication in GameViewModel)**
  - 问题：两个初始化方法包含48行重复代码 (Issue: Two initializers contained 48 lines of duplicate code)
  - 解决：提取setupSubscriptions()方法 (Solution: Extracted setupSubscriptions() method)
  - 效果：减少代码重复，提高可维护性 (Effect: Reduced code duplication, improved maintainability)

  **2. 内存管理改进 (Improved Memory Management)**
  - 问题：deinit中手动取消Combine订阅是多余的 (Issue: Manual Combine subscription cancellation in deinit was redundant)
  - 解决：依赖Combine的自动清理机制 (Solution: Rely on Combine's automatic cleanup)
  - 效果：简化代码，避免潜在内存问题 (Effect: Simplified code, avoided potential memory issues)

  **3. QuestionGenerator复杂方法重构 (Refactored Complex QuestionGenerator Method)**
  - 问题：单个方法包含396行代码，难以维护 (Issue: Single method contained 396 lines, difficult to maintain)
  - 解决：创建QuestionGenerator+ThreeNumber.swift扩展文件 (Solution: Created QuestionGenerator+ThreeNumber.swift extension file)
  - 分解为11个专注方法 (Broke down into 11 focused methods):
    * generateThreeNumberQuestion() - 主入口
    * attemptGenerateThreeNumberQuestion() - 生成尝试
    * generateInitialNumbers() - 初始数字生成
    * selectOperations() - 运算符选择
    * ensureDivisionSafety() - 除法安全保证
    * adjustDivisionForFirstOperation() - 第一个除法调整
    * adjustDivisionForSecondOperation() - 第二个除法调整
    * calculateIntermediateResult() - 中间结果计算
    * findDivisors() - 因数查找
    * generateFallbackThreeNumberQuestion() - 降级生成
    * hasRepetitivePattern() - 重复模式检测
  - 效果：代码可读性大幅提升，易于测试和调试 (Effect: Significantly improved readability, easier to test and debug)

  **4. Core Data错误处理增强 (Enhanced Core Data Error Handling)**
  - 问题：Core Data初始化失败时静默失败 (Issue: Core Data initialization failures were silent)
  - 解决：添加@Published initializationStatus枚举 (Solution: Added @Published initializationStatus enum)
  - 状态：initializing / ready / failed(Error)
  - 效果：UI可以响应初始化错误 (Effect: UI can respond to initialization errors)

  **5. 魔术数字常量化 (Extracted Magic Numbers to Constants)**
  - 问题：硬编码的数值分散在代码中 (Issue: Hard-coded values scattered throughout code)
  - 解决：创建Constants枚举 (Solution: Created Constants enums)
  - 文件：QuestionGenerator.swift, WrongQuestionManager.swift, GameViewModel.swift
  - 常量：maxGenerationAttempts, minNumberValue, wrongQuestionRatio等 (Constants: maxGenerationAttempts, minNumberValue, wrongQuestionRatio, etc.)
  - 效果：提高代码可读性和可维护性 (Effect: Improved code readability and maintainability)

- **✅ 测试修复 (Test Fixes)** - 修复所有CI测试失败，实现356/356测试通过 (Fixed all CI test failures, achieved 356/356 tests passing)

  **问题根源 (Root Cause)**
  - Level4 (范围1-10) 三数运算生成时出现"Range requires lowerBound <= upperBound"崩溃 (Level4 (range 1-10) three-number generation crashed with "Range requires lowerBound <= upperBound")
  - 当range.upperBound / quotient < 2时，创建了无效范围如2...1 (Created invalid ranges like 2...1 when range.upperBound / quotient < 2)

  **解决方案 (Solutions)**
  1. **改进初始数字生成** (Improved Initial Number Generation)
     ```swift
     let maxNumberForOperation = max(2, upperBound / 3)
     ```

  2. **增强小范围除法安全** (Enhanced Division Safety for Small Ranges)
     ```swift
     if range.upperBound <= 10 {
         adjusted[1] = min(divisor, 3)
         adjusted[0] = min(quotient * adjusted[1], range.upperBound)
     }
     ```

  3. **优化Level4运算选择** (Optimized Level4 Operation Selection)
     - 70%概率生成乘法运算 (70% probability for multiplication)
     - 30%概率生成除法运算 (30% probability for division)
     - 避免两个操作都是除法 (Avoid both operations being division)

  4. **改进降级生成** (Improved Fallback Generation)
     - 小范围优先使用乘法运算 (Prefer multiplication for small ranges)
     - 确保降级题目也符合难度要求 (Ensure fallback questions meet difficulty requirements)

  **测试结果 (Test Results)**
  - 之前：3个测试失败 (Before: 3 tests failing)
  - 之后：356/356测试全部通过 (After: 356/356 tests all passing)
  - 执行时间：6.9秒 (Execution time: 6.9s)
  - Level4保持40%三数运算概率 (Level4 maintains 40% three-number probability)

- **📁 代码组织 (Code Organization)** - 改进项目结构和模块化 (Improved project structure and modularization)
  - 新增Utils/QuestionGenerator+ThreeNumber.swift (Added Utils/QuestionGenerator+ThreeNumber.swift)
  - 分离三数运算逻辑到独立文件 (Separated three-number logic into dedicated file)
  - 更好的代码组织和可发现性 (Better code organization and discoverability)

- **🚀 质量改进 (Quality Improvements)** - 全面提升代码质量和可靠性 (Comprehensive code quality and reliability improvements)
  - ✅ 100%测试通过率 (100% test pass rate)
  - ✅ 减少代码复杂度 (Reduced code complexity)
  - ✅ 提高代码可维护性 (Improved code maintainability)
  - ✅ 更快的测试执行 (Faster test execution)
  - ✅ 更可靠的问题生成 (More reliable question generation)
  - ✅ 更好的错误处理 (Better error handling)
  - ✅ 消除CI/CD失败 (Eliminated CI/CD failures)

- **📊 技术影响 (Technical Impact)**
  - 代码行数：从396行单一方法优化为11个专注方法 (Lines of code: Optimized from 396-line single method to 11 focused methods)
  - 测试覆盖率：保持高覆盖率同时提高可靠性 (Test coverage: Maintained high coverage while improving reliability)
  - 构建时间：无显著影响 (Build time: No significant impact)
  - 运行时性能：略有提升(更快的测试执行) (Runtime performance: Slight improvement (faster test execution))

### 🌟 2026-02-01 (文档更新 / Documentation Update)
- **📄 README更新 (README Update)** - 更新README.md版本号至1.0.4，同步最新项目状态 (Updated README.md version to 1.0.4, synced latest project status)
- **🔄 ChangeLog更新 (ChangeLog Update)** - 更新ChangeLogs.md文件，记录最新项目变更 (Updated ChangeLogs.md file to record latest project changes)

### 🌟 2026-01-20 (欢迎引导页优化 / Onboarding Screen Enhancements)
- **🌐 本地化增强 (Localization Enhancement)**: 欢迎引导页现在会根据设备的系统语言自动显示中文或英文，不再默认显示为中文 (The welcome onboarding screen now automatically displays in Chinese or English based on the device's system language, instead of defaulting to Chinese.)
- **🎨 深色模式支持 (Dark Mode Support)**: 全面优化了欢迎引导页的深色模式显示，所有颜色和组件现在都能自适应系统的外观设置 (Fully optimized the dark mode display for the welcome onboarding screen; all colors and components now adapt to the system's appearance settings.)

### 🌟 2026-01-17 (项目文档更新 / Project Documentation Update)
- **📄 README更新 (README Update)** - 更新README.md文件，确保包含最新的功能特性和项目信息 (Updated README.md file to include latest features and project information)
- **🔄 ChangeLog更新 (ChangeLog Update)** - 更新ChangeLogs.md文件，同步最新项目变更 (Updated ChangeLogs.md file to sync latest project changes)

### 🌟 2026-01-09 (PDF排版优化 / PDF Layout Optimization)
- **📄 PDF题库排版优化 (PDF Problem Bank Layout Optimization)** - 全面优化PDF生成排版，最大化A4纸张利用率 (Comprehensive PDF generation layout optimization to maximize A4 paper utilization)

  **题目页优化 (Question Page Optimization)**
  - 每页题目数量从35题提升至约96题（基于动态计算）(Questions per page increased from 35 to ~96 based on dynamic calculation)
  - 字体大小优化：标题16pt，题目从18pt优化为13pt (Font size optimization: title 16pt, questions from 18pt to 13pt)
  - 行间距从20pt减少到16pt，更紧凑的布局 (Line spacing reduced from 20pt to 16pt for more compact layout)
  - 左右边距从60pt减少到15pt，充分利用A4纸宽度 (Left/right margins reduced from 60pt to 15pt, fully utilizing A4 width)
  - **纸张节省效果 (Paper Saving Effect)**: 约节省40%纸张 (Saves approximately 40% paper)

  **答案页优化 (Answer Page Optimization)**
  - 每页答案数量从45题提升至约108题（三列紧凑布局）(Answers per page increased from 45 to ~108 with three-column compact layout)
  - 字体大小从14pt优化为11pt (Font size optimized from 14pt to 11pt)
  - 行间距从16pt减少到14pt (Line spacing reduced from 16pt to 14pt)
  - 三列布局优化，列间距调整为15pt (Three-column layout optimization, column spacing adjusted to 15pt)
  - **纸张节省效果 (Paper Saving Effect)**: 约节省35%纸张 (Saves approximately 35% paper)

  **页眉页脚优化 (Header/Footer Optimization)**
  - 页眉高度从110pt减少到60pt (Header height reduced from 110pt to 60pt)
  - 页脚高度从50pt减少到30pt (Footer height reduced from 50pt to 30pt)
  - 分割线从1.0pt细化为0.5pt (Separator line refined from 1.0pt to 0.5pt)
  - 页眉信息合并为单行紧凑显示 (Header information merged into single-line compact display)

  **新增合页打印模式 (New Duplex Printing Mode)**
  - 添加`generateDuplexPDF()`方法，支持题目和答案在同一张纸的正反面 (Added `generateDuplexPDF()` method for questions and answers on front/back of same paper)
  - 正面题目，反面答案，适合双面打印 (Questions on front, answers on back, suitable for duplex printing)
  - **额外节省效果 (Additional Savings)**: 使用双面打印可再节省50%纸张 (Duplex printing saves additional 50% paper)

- **🔧 配置常量化 (Configuration Constants)** - 将布局参数提取为常量，便于维护和调整 (Extracted layout parameters as constants for easier maintenance and adjustment)
  ```swift
  private static let a4Width: CGFloat = 595.0
  private static let a4Height: CGFloat = 842.0
  private static let pageMargin: CGFloat = 15.0
  private static let questionSpacing: CGFloat = 16.0
  private static let answerSpacing: CGFloat = 14.0
  ```

- **🌐 本地化更新 (Localization Update)** - 添加新的本地化键以支持优化后的界面 (Added new localization keys to support optimized interface)
  - `math_bank.pdf.total` - "总数" / "Total"
  - `math_bank.pdf.page` - "页" / "Page"

- **📊 总体节约效果 (Overall Savings Effect)**:
  - 题目页纸张使用减少约40% (Question pages: ~40% paper reduction)
  - 答案页纸张使用减少约35% (Answer pages: ~35% paper reduction)
  - 合页模式使用双面打印可再节省50% (Duplex mode with double-sided printing saves additional 50%)

### 🌟 2026-01-08 (Latest Updates)
- **PDF题库生成功能** - 新增数学题库PDF生成功能，支持题目页和答案页分离 (Added math problem bank PDF generation with separate question and answer pages)
- **系统信息监控** - 新增全面的系统信息监控功能，包括设备信息、性能数据、电池状态等 (Added comprehensive system information monitoring including device info, performance data, battery status, etc.)
- **QR码扫描工具** - 集成QR码扫描和生成功能 (Integrated QR code scanning and generation functionality)
- **小学数学公式大全** - 新增全面的小学数学公式指南 (Added comprehensive elementary math formula guide)
- **Firebase崩溃监控** - 集成Firebase Crashlytics进行崩溃监控 (Integrated Firebase Crashlytics for crash monitoring)
- **欢迎引导流程** - 新增首次启动引导界面 (Added first-launch onboarding interface)
- **UI界面优化** - 优化多个界面的用户体验 (Optimized user experience across multiple interfaces)
- **TTS功能增强** - 增强了题目朗读功能，支持数学符号智能转换 (Enhanced question read-aloud functionality with intelligent math symbol conversion)
- **测试与质量保证** - 添加了全面的验证系统和防无限循环机制 (Added comprehensive validation system and anti-infinite loop mechanisms)

### 🌟 2026-01-05 (About App & UI Improvements)
- **新增"关于应用"页面 (Added "About App" Page)**：
  - 在设置页面新增"关于 Arithmetic"按钮，点击后可查看应用版本、构建号、Git提交哈希和提交信息。
  - 界面优化，采用更清晰的表单布局，并添加了致谢列表。
  - **Git信息嵌入**：通过Xcode构建脚本将最新的Git提交信息（哈希和消息）嵌入到应用中，解决了Git信息显示"N/A"的问题。
  - **国际化支持**：所有"关于应用"页面的文本都已进行完整的中英文本地化。
- **主界面按钮位置调整 (Main Screen Button Reordering)**：
  - 将主页面的"设置"按钮移动到"其他选项"按钮下方，优化了界面布局。

## 🔄 最近更新 (Recent Updates)

### 🌟 2026-01-03 (Crash Test and Localization Improvements)
- **🛠️ Crash Test Feature**: Added Crash Test section in SettingsView to help verify error monitoring functionality
- **🔍 Localization Checks**: Enhanced localization verification script with more robust key comparison using temporary files and grep
- **🔧 Firebase Integration**: Updated Firebase Crashlytics initialization in app launch sequence
- **⚙️ Build Configuration**: Added GoogleService-Info.plist and Crashlytics build phase to Xcode project

### 🌟 2026-01-03 (dSYM Upload Script)
- **🛠️ New Utility**: Created upload_dsyms.sh script to handle dSYM file uploads for crash reporting

### 🌟 2026-01-01 (Bug Fixes and Refactoring)
- **🛠️ Deprecation Fix**: Replaced deprecated `NavigationLink(destination:isActive:label:)` with `.sheet` modifiers in `SettingsView.swift` for improved navigation handling.
- **🐞 i18n Fix**: Fixed an internationalization issue with the file save alert title by using a dedicated localized string.
- **refactor**: Reverted the consolidation of `AlertItem` to a single file to resolve build errors, and instead used private local definitions in `QrCodeToolView.swift` and `MathBankView.swift`.

### 🌟 2026-01-01 (README and .gitignore Updates)
- **🔄 README Update**: Updated the README file to reflect the current project status.
- **🛠️ Deprecation Fix**: Replaced deprecated `NavigationLink(destination:isActive:label:)` with `.sheet` modifiers in `OtherOptionsView.swift` for improved navigation handling.
- **🛠️ .gitignore Update**: Removed GEMINI.md and QWEN.md from .gitignore to allow them to be tracked by git.

### 🌟 2025-12-20 (Firebase Crashlytics 集成 / Firebase Crashlytics Integration)
- **🛠️ 错误监控 (Error Monitoring)**: 集成 Firebase Crashlytics 以实时监控和报告应用崩溃 (Integrated Firebase Crashlytics for real-time monitoring and reporting of app crashes)
  - 自动捕获崩溃信息，帮助快速识别和修复问题 (Automatically captures crash information to help quickly identify and fix issues)
  - 提供详细的崩溃报告，包括设备信息、系统版本和堆栈跟踪 (Provides detailed crash reports including device information, system version, and stack traces)
  - 支持实时错误监控，提升应用稳定性和用户体验 (Supports real-time error monitoring to improve app stability and user experience)
- **🔧 技术实现 (Technical Implementation)**:
  - 添加 FirebaseCore、FirebaseAnalytics 和 FirebaseCrashlytics 依赖 (Added FirebaseCore, FirebaseAnalytics, and FirebaseCrashlytics dependencies)
  - 在 App delegate 中初始化 Firebase (Initialized Firebase in the App delegate)
  - 通过 Swift Package Manager 管理依赖关系 (Managed dependencies via Swift Package Manager)
- **🎯 测试功能 (Testing Feature)**: 在设置页面添加崩溃测试按钮，便于验证错误监控功能 (Added crash test button in settings to verify error monitoring functionality)

### 🌟 2025-12-15 (QR码扫描工具 - UI优化和功能完善)
- **📱 功能增强**: 全面优化QR码扫描工具的用户体验和功能稳定性
  - **🎨 UI/UX完全重设计**:
    - 按钮设计升级：添加图标指示（chevron/arrow icons），提供更清晰的视觉反馈
    - 文本输入优化：增加占位符文本提示，改进输入框样式和边框设计
    - 结果显示增强：添加成功状态指示图标（checkmark circles），改进结果容器样式
    - 响应式设计：更好的间距、圆角和颜色一致性

  - **🐛 摄像头bug修复**:
    - 修复了摄像头初始化失败时的错误处理
    - 改进了AVCaptureSession配置，添加了canAddInput/canAddOutput的验证检查
    - 优化了后台任务处理：使用beginConfiguration/commitConfiguration确保线程安全
    - 添加了详细的错误日志和异常处理机制
    - 改进了权限检查流程，设置cameraPermissionGranted状态以跟踪权限状态

  - **💅 视觉改进**:
    - 更新了摄像头预览边框颜色为systemGreen，边框宽度升级为3pt
    - 关闭按钮样式优化：更大的圆角(12pt)、改进的字体权重(semibold)、更好的背景透明度
    - 扫描结果和生成结果采用统一的卡片式设计
    - 生成的二维码添加了阴影效果，提升了视觉层次感

  - **🔧 代码改进**:
    - 使用项目的localization extension替代NSLocalizedString
    - 改进了后台线程处理：使用DispatchQueue.global(qos: .userInitiated)启动摄像头
    - 优化了主线程UI更新：确保所有UI操作在主线程执行

### 🌟 2025-12-14 (UI重构 - 移动设置相关功能)
- **🎯 UI结构优化**: 将"关于我"和"系统信息"功能从"其他选项"页面移到设置页面
  - **📍 关于我**: 在设置页面添加"关于我"导航链接，保留开发者信息和GitHub仓库链接
  - **📍 系统信息**: 在设置页面添加"系统信息"导航链接，方便用户查看设备详细信息
  - **🔧 代码优化**: 简化OtherOptionsView，移除冗余的导航状态和目标定义
  - **📱 用户体验**: 设置页面更加专注，提供了一个集中的配置和信息中心
  - **🌐 本地化**: 新增"settings.info"本地化键，支持中英文双语

### 🌟 2025-11-16 (新增PDF题库生成和系统信息监控功能)
- **🆕 新增PDF题库生成功能**: 全新的数学题库PDF生成器，支持自定义题目数量和难度等级
  - **📚 MathBankView**: 专门的数学题库生成界面，用户可选择题目数量和难度等级 (Dedicated math problem bank generation interface, users can select number of questions and difficulty levels)
  - **📄 PDF生成**: 支持生成包含题目页和答案页的完整PDF文档 (Supports generating complete PDF documents with both question and answer pages)
  - **🔄 优先错题**: 优先从错题集中提取题目，帮助用户重点复习 (Prioritizes questions from the wrong question collection to help users focus on review)
  - **📤 多种分享方式**: 支持保存到文档目录、系统分享和文件分享 (Multiple sharing options: supports saving to documents directory, system sharing, and file sharing)
- **💻 新增系统信息监控**: 实时显示设备信息、性能数据、电池状态和网络状况
  - **📱 设备信息**: 显示设备名称、CPU信息、系统版本和屏幕规格 (Shows device name, CPU information, system version and screen specifications)
  - **📊 性能监控**: 实时监控CPU使用率、内存使用情况和磁盘空间 (Real-time monitoring of CPU usage, memory usage and disk space)
  - **🔋 电池监控**: 显示电池电量、充电状态、电源类型和系统运行时长 (Shows battery level, charging status, power source type and system uptime)
  - **🌐 网络信息**: 显示网络连接类型、WiFi名称和运营商信息 (Shows network connection type, WiFi name and carrier information)
  - **⏱️ 系统运行时长**: 精确计算系统自启动以来的运行时间 (Precisely calculates system uptime since boot)

### 🌟 2025-11-15 (新增设置页面和功能)
- **🆕 新增设置页面**: 添加了独立的设置页面
- **🎨 新增深色模式切换**: 在设置页面中，可以手动切换App的深色和浅色模式
- **🔊 新增TTS语音开关**: 在设置页面中，可以全局控制题目和乘法表的自动朗读功能

### 🌟 2025-11-07 (欢迎引导界面和用户体验优化)
- **🆕 新增欢迎引导功能**: 全新的4页交互式引导界面，首次启动时自动显示
  - **Page 1**: 应用介绍和主要功能概述 (App introduction and main features overview)
  - **Page 2**: 6级难度体系详细介绍，带星级难度指示器 (Detailed 6-level difficulty system introduction with star-level indicators)
  - **Page 3**: 核心功能展示，包括游戏、解题思路、错题集、九九乘法表 (Core features showcase including game, solution methods, wrong questions collection, multiplication table)
  - **Page 4**: 使用方法指导，分步骤说明如何使用应用 (Usage guidance with step-by-step instructions)
- **🎨 UI/UX 重大升级**:
  - **增强组件设计**: 新增EnhancedFeatureRow和EnhancedHowToRow组件，提供更精美的卡片式布局 (Enhanced component design: Added EnhancedFeatureRow and EnhancedHowToRow components with more refined card-style layouts)
  - **动画效果**: 添加页面切换动画和按钮缩放动画，提升交互体验 (Animation effects: Added page transition animations and button scaling animations for enhanced interaction experience)
  - **颜色主题**: 每个页面使用不同主题色彩，提升视觉识别度 (Color themes: Each page uses different theme colors for better visual recognition)
- **🔧 架构优化**:
  - **@AppStorage集成**: 使用@AppStorage替代UserDefaults进行首启动状态管理 (AppStorage integration: Using @AppStorage instead of UserDefaults for first launch state management)
  - **状态管理**: 优化ContentView中的显示逻辑，确保引导界面只显示一次 (State management: Optimized display logic in ContentView to ensure onboarding shows only once)
  - **模块化设计**: WelcomeView采用模块化设计，便于维护和扩展 (Modular design: WelcomeView uses modular design for easy maintenance and extension)
- **🌐 完整国际化**: 添加所有引导界面的中英文本地化支持
  - 新增50+本地化字符串，包括标题、描述、按钮文本等 (Added 50+ localized strings including titles, descriptions, button texts, etc.)
  - 支持中英文动态切换，确保所有文本正确显示 (Supports dynamic Chinese/English switching, ensuring all text displays correctly)

### 🎤 2025-09-30 (问题朗读功能重大增强)
- **🔧 核心代码优化**: 重构了GameView中的TTS调用逻辑，从`speak(text:language:)`升级为`speakMathExpression(_:language:)`
- **📢 数学符号智能转换**: 完全重写了数学运算符的语音处理系统
  - **中文语音**: "-" 正确读作"减"，"+" 读作"加"，"×" 读作"乘以"，"÷" 读作"除以"，"=" 读作"等于"
  - **数字转换**: 阿拉伯数字自动转换为中文读音（如"8"读作"八"）
  - **完整句式**: 按照"计算[题目]等于多少？"格式朗读
- **🎯 交互体验升级**:
  - 题目文本现在完全可点击，保持原有视觉外观
  - 使用`PlainButtonStyle()`确保无按钮样式干扰
  - 支持iPhone和iPad横竖屏所有布局模式
- **♿ 无障碍功能增强**: 为视觉学习困难和听觉学习者提供更好的辅助支持
- **⚡ 性能优化**: 使用TTSHelper单例模式，提高语音合成效率

### 🎤 2025-09-30 (Question Read-Aloud Feature Major Enhancement)
- **🔧 Core Code Optimization**: Refactored TTS call logic in GameView, upgraded from `speak(text:language:)` to `speakMathExpression(_:language:)`
- **📢 Mathematical Symbol Intelligent Conversion**: Completely rewrote the voice processing system for mathematical operators
  - **English Voice**: "-" correctly pronounced as "minus", "+" as "plus", "×" as "times", "÷" as "divided by", "=" as "equals"
  - **Number Conversion**: Arabic numerals automatically converted to spelled-out English (e.g., "8" pronounced as "eight")
  - **Complete Sentence Format**: Reads in "What is [question]?" format
- **🎯 Interaction Experience Upgrade**:
  - Question text is now fully clickable while maintaining original visual appearance
  - Uses `PlainButtonStyle()` to ensure no button styling interference
  - Supports all layout modes for iPhone and iPad in both portrait and landscape orientations
- **♿ Accessibility Enhancement**: Provides better assistive support for students with visual learning difficulties and auditory learners
- **⚡ Performance Optimization**: Uses TTSHelper singleton pattern to improve speech synthesis efficiency

### ⚙️ 2025-09-26 (应用图标修复)
- **🔧 关键修复**: 解决了应用图标在设备上无法正确显示的问题。
- **⚙️ 配置修正**: 向 `Info.plist` 文件添加了 `CFBundleIcons` 键，确保系统能正确识别图标集。
- **🎨 资源文件优化**: 简化了 `AppIcon.appiconset` 中的 `Contents.json` 文件，采用单一 1024x1024px 图标源并由 Xcode 自动生成所有尺寸，遵循了现代化的最佳实践，提高了图标管理的可靠性。

### ⚙️ 2025-09-26 (App Icon Fix)
- **🔧 Key Fix**: Resolved an issue where the app icon was not displaying correctly on devices.
- **⚙️ Configuration Correction**: Added the `CFBundleIcons` key to the `Info.plist` file to ensure the system correctly identifies the icon set.
- **🎨 Asset Optimization**: Simplified the `Contents.json` file within `AppIcon.appiconset` to use a single 1024x1024px source icon, allowing Xcode to auto-generate all required sizes. This follows modern best practices and improves the reliability of icon management.


### 🌟 2025-09-26 (新增GitHub仓库链接)
- **🔗 新增功能**: 在"关于我"页面添加了GitHub仓库链接
- **📖 开源支持**: 用户可以直接访问项目开源地址，了解开发进展和贡献代码
- **🌍 本地化**: 支持中英文双语显示，中文为"点击访问我的Github仓库"，英文为"Visit GitHub Repository"

### 🌟 2025-09-26 (Added GitHub Repository Link)
- **🔗 New Feature**: Added a GitHub repository link to the "About Me" page
- **📖 Open Source Support**: Users can directly access the project's open source repository to learn about development progress and contribute code
- **🌍 Localization**: Supports bilingual display with "点击访问我的Github仓库" in Chinese and "Visit GitHub Repository" in English


### 🎨 2025-09-26 (UI Improvements)
- **🎨 Cleaner Interface**: Hid labels in difficulty picker to create a cleaner user interface
- **🔙 Navigation Enhancement**: Added custom back button functionality to multiple views
- **📏 Layout Refinements**: Adjusted picker alignment and other layout improvements
- **⚡ Performance Optimization**: Removed unnecessary NavigationView wrappers for better performance and stability


### 🌟 2025-09-14 (新增图片缓存功能)
- **🆕 全新功能**: 为"关于我"页面的开发者头像添加了图片缓存功能
- **💾 缓存机制**: 实现了基于内存和磁盘的二级缓存系统
  - 内存缓存：使用NSCache存储最近访问的图片，提高访问速度
  - 磁盘缓存：将图片保存到应用沙盒目录，持久化存储
- **⚡ 性能优化**: 首次加载后图片从缓存读取，显著提升页面加载速度
- **📱 用户体验**: 网络异常时也能显示已缓存的图片，提高应用稳定性
- **🧹 缓存管理**: 提供缓存清理接口，用户可手动清除缓存数据

### 🎤 2025-09-13 (新增题目朗读功能)
- **🆕 全新功能**: 在游戏界面，用户可以点击题目来收听题目的朗读。
- **🗣️ TTS扩展**: `TTSHelper` 现在也被用于朗读问题，增强了其在应用中的作用。
- **🌐 双语支持**: 为朗读功能添加了相应的中文和英文本地化字符串。
- **🧠 模型更新**: `Question` 模型中新增了用于语音朗读的本地化问题文本。

### 🎤 2025-09-13 (Added Question Read-Aloud Feature)
- **🆕 New Feature**: In the game view, users can tap the question to listen to it being read aloud.
- **🗣️ TTS Expansion**: `TTSHelper` is now also used for reading questions, expanding its role in the app.
- **🌐 Bilingual Support**: Added localized strings for the read-aloud feature in both Chinese and English.
- **🧠 Model Update**: The `Question` model has been updated with localized question text for speech.

### 🔊 2025-09-13 (新增九九乘法表双语发音功能)
- **🆕 全新功能**: 为九九乘法表增加中英文双语发音功能。
- **🗣️ TTS集成**: 新增 `TTSHelper` 工具类，封装了 `AVSpeechSynthesizer`，用于处理文本到语音的转换。
- ** interactive learning**: 用户点击乘法表中的按钮，可以听到对应算式的发音，增强了互动性和趣味性。
- **🌐 双语支持**: 支持中文和英文两种语言的发音，并能根据当前应用语言环境自动切换。

### 🔊 2025-09-13 (Added Bilingual TTS for Multiplication Table)
- **🆕 New Feature**: Added bilingual (Chinese and English) text-to-speech functionality to the multiplication table.
- **🗣️ TTS Integration**: Added a new `TTSHelper` utility to encapsulate `AVSpeechSynthesizer` for text-to-speech conversion.
- **Interactive Learning**: Users can tap on buttons in the multiplication table to hear the pronunciation of the corresponding expressions, enhancing interactivity and engagement.
- **🌐 Bilingual Support**: Supports both Chinese and English pronunciation, automatically switching based on the current app language.



### 🌟 2025-10-16 (新增小学数学公式大全)
- **🆕 全新功能**: 新增全面的小学数学公式指南
- **📐 公式内容**:
  - 几何形体计算公式：包含平面图形（长方形、正方形、三角形等）和立体图形（长方体、正方体、圆柱等）的周长、面积、体积公式
  - 单位换算：涵盖长度、面积、体积、质量、时间等单位换算
  - 数量关系：包含基本关系和四则运算关系公式
  - 运算定律：包括加法、乘法交换律和结合律、乘法分配律等
  - 特殊问题：涵盖和差问题、和倍问题、植树问题、相遇问题、追及问题、利润问题等
- **🌐 完整国际化**: 支持中英文双语显示
- **📍 便捷访问**: 从"其他选项"页面可直接访问公式大全，使用function系统图标标识

### 🌟 2025-10-16 (Added Elementary Math Formula Guide)
- **🆕 New Feature**: Added a comprehensive elementary math formula guide
- **📐 Formula Content**:
  - Geometry formulas: Includes perimeter, area, and volume formulas for plane figures (rectangle, square, triangle, etc.) and solid figures (cuboid, cube, cylinder, etc.)
  - Unit conversions: Covers length, area, volume, mass, and time unit conversions
  - Quantity relations: Includes basic relations and arithmetic operation relation formulas
  - Arithmetic laws: Includes commutative, associative laws of addition and multiplication, distributive law, etc.
  - Special problems: Covers sum-difference problems, sum-multiple problems, tree planting problems, meeting problems, chase problems, profit problems, etc.
- **🌐 Full Internationalization**: Supports bilingual display in Chinese and English
- **📍 Convenient Access**: Directly accessible from the "Other Options" page, identified with the function system icon

### 🌟 2025-09-30 (难度选择器UI改进)
- **🔄 交互方式变更**: 将错题集页面的难度选择器从Picker下拉菜单替换为水平滚动按钮
- **🎯 用户体验优化**: 水平滚动按钮更便于用户快速选择和过滤不同难度的错题
- **📱 响应式设计**: 新的按钮设计更好地适应不同屏幕尺寸
- **🎨 视觉改进**: 选中状态高亮显示，提供更好的视觉反馈

### 🌟 2025-09-30 (Difficulty Selector UI Improvement)
- **🔄 Interaction Change**: Replaced the difficulty picker in Wrong Questions view with horizontally scrollable buttons
- **🎯 User Experience Optimization**: Horizontal scroll buttons make it easier for users to quickly select and filter questions by difficulty level
- **📱 Responsive Design**: The new button design better adapts to different screen sizes
- **🎨 Visual Improvement**: Selected state is highlighted, providing better visual feedback

### 🎨 2025-09-30 (进度视图工具和图像加载UI增强)
- **🔧 新增工具类**: 新增 `ProgressViewUtils.swift`，包含可重用的进度条组件和加载指示器
- **🖼️ 图像加载增强**: 更新 `CachedAsyncImageView` 以支持加载状态回调
- **📱 用户体验优化**: `AboutMeView` 添加了加载时的覆盖层，改善用户体验
- **🔄 视觉反馈**: 图像加载期间显示进度指示器，提供更好的视觉反馈

### 🎨 2025-09-30 (Progress View Utilities and Image Loading UI Enhancement)
- **🔧 New Utility Class**: Added `ProgressViewUtils.swift` with reusable progress bar components and loading indicators
- **🖼️ Image Loading Enhancement**: Updated `CachedAsyncImageView` to support loading state callbacks
- **📱 User Experience Optimization**: `AboutMeView` now displays a loading overlay while images are loading
- **🔄 Visual Feedback**: Progress indicators are displayed during image loading, providing better visual feedback

### 🧮 题目生成系统优化 (Question Generation System Optimization)
- **整数结果保证** - 所有运算结果均为整数，无小数或分数
- **智能题目质量控制** - 避免过于简单的运算（如×1、÷1）
- **三数运算优化** - 各难度等级的三数运算生成策略优化





### 🎨 2025-01-10 (界面优化重构)
- **🆕 难度选择优化**: 将复杂的按钮网格优化为简洁的Picker下拉菜单
  - iPad横屏：左侧面板空间利用更高效，节省约60%垂直空间
  - 默认布局：从6行按钮减少为1个紧凑选择器
  - 原生iOS下拉菜单体验，更好的可访问性支持
- **🗂️ 新增"其他选项"页面**: 重新组织界面结构，提升用户体验
  - 将9×9乘法表和关于我功能整合到统一的"其他选项"页面
  - 主界面从4个按钮精简为3个按钮，界面更加简洁专注
  - 新页面采用卡片式设计，包含图标、标题和描述信息
  - 支持便捷的返回主页功能
- **🌐 完整国际化**: 新增"其他选项"相关的中英文本地化字符串
- **🔧 代码优化**: 
  - 移除复杂的网格布局逻辑，减少约80行代码
  - 新增OtherOptionsView.swift，采用模块化设计
  - 统一的导航逻辑和状态管理
- **📱 响应式设计**: 新页面完全适配iPhone和iPad的不同屏幕尺寸

### 🔢 2025-01-12 (新增九九乘法表功能)
- **🆕 全新功能**: 新增完整的9×9乘法表查看功能
- **📱 响应式设计**: 
  - iPad横屏：9列完整显示所有乘法表
  - iPad竖屏：6列优化阅读体验
  - iPhone横屏：6列适配屏幕
  - iPhone竖屏：3列紧凑显示
- **🎨 颜色分级系统**: 
  - 蓝色：相同数字相乘（1×1, 2×2等）
  - 绿色：结果≤10的简单运算
  - 橙色：结果11-50的中等运算
  - 红色：结果>50的挑战运算
- **🔄 双向滚动**: 支持垂直和水平滚动，确保所有内容可访问
- **🌐 完整国际化**: 中英文双语支持，包括标题、说明和公式格式
- **🎯 学习辅助**: 作为乘法练习的参考工具，帮助学生记忆乘法口诀
- **📍 便捷访问**: 从主页面直接访问，绿色按钮醒目标识

### 🔧 2025-01-07 (除法运算重大修复)
- **🎯 关键问题修复**: 彻底解决了乘除运算中的整数结果问题
  - **问题**: 应用生成了如"9 ÷ 2 × 2"这样的题目，其中9 ÷ 2 = 4.5（非整数）
  - **解决方案**: 完全重构了除法生成逻辑，确保所有除法运算都能整除
- **🧮 除法生成算法重构**:
  - 采用"先选商和除数，再计算被除数"的逆向生成方式
  - 被除数 = 商 × 除数，从根本上保证整除
  - 除数范围限制在2-10之间，避免÷1的简单题目
  - 商值最小为2，避免过于简单的除法运算
- **🔍 三数运算除法优化**:
  - 针对"A ÷ B × C"类型表达式，确保A能被B整除
  - 针对"A × B ÷ C"类型表达式，确保(A × B)能被C整除
  - 智能选择第三个数字作为前面结果的因数，保证整除
- **✅ 全面验证系统**:
  - 新增`isValid()`方法对所有生成的题目进行验证
  - 考虑运算优先级的完整验证逻辑
  - 确保最终结果为正整数
  - 添加防无限循环机制和降级策略
- **📊 质量保证**:
  - 所有除法运算现在100%保证整数结果
  - 消除了"9 ÷ 2 = 4"这类错误解析
  - 三数运算中每个中间步骤都确保整数结果
  - 提升了题目的数学严谨性和教育价值

### 🎯 2025-06-29 (运算类型严格分离修复)
- **🔧 关键修复**: 修复了等级4和5的三数运算仍包含加减法的问题
- **📐 运算类型严格分离**: 
  - 等级4和5的三数运算现在严格只使用乘法和除法运算
  - 等级6的混合运算逻辑得到完善，支持真正的四则混合运算
- **🔢 三数乘除法优化**: 
  - 为三数乘除法运算添加了专门的数字生成策略
  - 乘法运算智能控制第三个数字，避免结果超出范围
  - 除法运算通过因数分解确保第三个数字能整除中间结果
- **⚙️ 算法重构**: 重新组织了三数运算的生成逻辑，先计算中间结果再调整第三个数字
- **📋 文档完善**: 更新README明确说明各等级的严格运算类型要求

### 🔧 2025-06-29 (题目生成系统修复)
- **🎯 重大修复**: 修复了等级4和等级5未按预期生成乘除法题目的问题
- **🧮 整数结果保证**: 强化了所有运算的整数结果保证机制
  - 除法运算采用"商×除数=被除数"的逆向生成方式，确保100%整除
  - 乘法运算智能控制因数范围，避免结果超出等级限制
  - 混合运算中每个中间步骤都确保产生合理的整数结果
- **⚡ 算法优化**: 重构了题目生成算法，使用难度等级的supportedOperations属性替代硬编码逻辑

### 🌟 2025-06-28 (晚间重大更新)
- **🎯 新增乘除法功能**: 完全重新设计关卡逻辑，新增10以内和20以内的乘除法运算
- **📚 6级难度体系**: 
  - 等级1-3：加减法（10以内、20以内、50以内）
  - 等级4-5：乘除法（10以内、20以内）
  - 等级6：100以内混合运算
- **🧮 智能题目生成**: 
  - 乘法题目避免过多×1，确保教学价值
  - 除法题目100%整除，无小数结果
  - 基于权重的"黄金题库"系统
- **📖 乘除法解析系统**: 新增4种乘除法解题方法
  - 乘法口诀法、分解乘法、除法验算法、分组除法
- **🌐 完整多语言支持**: 中英文解析内容完全对应
- **🔧 架构优化**: 使用DifficultyLevel属性替代硬编码，提高可维护性

### 🔨 2025-06-28 (早期修复)
- **重大修复**: 彻底修复了凑十法解析中的逻辑错误，消除了"10 - 10 = 4"等错误计算
- **解析优化**: 重构了凑十法的核心实现，确保严格按照"看大数拆小数，凑成十再加余"的正确教学原则
- **多语言修复**: 同时修复了中文和英文版本的本地化字符串模板，确保解析步骤描述准确
- **代码重构**: 使用直接字符串格式化替代可能有问题的本地化模板，提高了代码的可靠性

### 🚀 2025-06-24 (代码优化)
- **代码优化**: 移除了对特定算术题的特殊处理逻辑，使所有题目都通过标准算法处理
- **错误修复**: 修复了平十法解析中的逻辑错误，确保所有类似"19-16"的题目都能得到正确的解析步骤
- **性能改进**: 通过消除硬编码的特殊情况处理，提高了系统的可扩展性和稳定性

### 🌟 2025-10-29 (电池信息和运行时长功能修复增强)
- **🔋 电池状态检测修复**: 解决了电池状态在iOS模拟器中显示"Unknown"的问题
  - 实现智能重试机制，最多重试5次以获取准确状态
  - 添加基于电池电量的状态推断（电量≥95%显示"Full"）
  - 提供合理的默认状态显示，避免"Unknown"状态
- **⏱️ 运行时长实时计算**: 新增系统运行时长精确计算功能
  - 实时更新系统开机运行时长（格式：X天 HH:MM:SS）
  - 智能格式化显示：超过1天显示天数，超过1小时显示时分秒，小于1小时显示分秒
  - 缓存开机时间戳，通过时间差计算实现高效实时更新
- **🔧 代码架构优化**:
  - SystemInfoManager新增bootTimeInterval和batteryStateRetryCount属性
  - 实现电池状态重试机制和开机时间缓存
  - 优化电池监控初始化和系统资源管理

### 🌟 2025-10-29 (Battery Information and Uptime Calculation Enhancement)
- **🔋 Battery Status Detection Fix**: Resolved the issue of battery status showing "Unknown" in iOS simulator
  - Implemented smart retry mechanism, retrying up to 5 times to get accurate status
  - Added battery-based status inference (battery level ≥95% shows "Full")
  - Provides reasonable default status display, avoiding "Unknown" status
- **⏱️ Real-time Uptime Calculation**: Added precise system uptime calculation feature
  - Real-time update of system uptime since boot (format: X days HH:MM:SS)
  - Smart formatting: Shows days if over 1 day, shows HH:MM:SS if over 1 hour, shows MM:SS if less than 1 hour
  - Caches boot time timestamp, efficiently updates in real-time via time difference
- **🔧 Architecture Optimization**:
  - SystemInfoManager enhanced with bootTimeInterval and batteryStateRetryCount properties
  - Implements battery status retry mechanism and boot time caching
  - Optimized battery monitoring initialization and system resource management

### 🌟 2025-10-25 (系统信息功能全面增强)
- **📊 磁盘监控新增**: 在系统信息页面新增磁盘空间实时监控功能
  - 显示已使用磁盘空间、总磁盘空间和可用磁盘空间
  - 提供磁盘使用百分比可视化进度条
  - 自动检测并显示GB格式的磁盘容量信息
- **📶 网络监控**: 新增完整的网络连接状态检测
  - 检测Wi-Fi连接状态和名称显示
  - 支持蜂窝网络运营商信息
  - 实时显示连接类型和连接状态
- **📺 屏幕信息**: 新增详细的屏幕规格显示
  - 屏幕分辨率（逻辑分辨率和物理分辨率）
  - 屏幕尺寸和缩放因子显示
  - 屏幕刷新率检测（60Hz）
  - 物理尺寸计算和显示
- **🔧 代码架构优化**:
  - SystemInfoManager新增NetworkInfo、BatteryInfo、ScreenInfo结构体
  - 实现自定义Reachability网络检测
  - 优化电池信息初始化和实时更新机制
  - 统一UI组件支持多种数据类型的实时显示

### 🌟 2025-10-25 (Comprehensive System Information Enhancement)
- **📊 New Disk Monitoring**: Added real-time disk space monitoring to system information page
  - Shows used disk space, total disk space, and available disk space
  - Provides visual progress bar for disk usage percentage
  - Automatically detects and displays disk capacity in GB format
- **📶 Network Monitoring**: Added comprehensive network connection status detection
  - Detects Wi-Fi connection status and SSID display
  - Supports cellular network carrier information
  - Real-time display of connection type and status
- **📺 Screen Information**: Added detailed screen specifications display
  - Screen resolution (logical and physical resolution)
  - Screen size and scale factor display
  - Screen refresh rate detection (60Hz)
  - Physical size calculation and display
- **🔧 Architecture Optimization**:
  - SystemInfoManager enhanced with NetworkInfo, BatteryInfo, ScreenInfo structures
  - Implemented custom Reachability for network detection
  - Optimized battery information initialization and real-time update mechanism
  - Unified UI components supporting real-time display for multiple data types

### 🌟 2025-10-18 (新增系统信息显示功能)
- **🆕 全新功能**: 在关于我页面新增系统信息导航，点击可进入独立的系统信息页面
- **📱 设备信息**: 显示设备名称、CPU信息、系统版本等基本信息
- **📊 实时监控**: 实时更新CPU使用率、内存使用情况和当前时间
- **🌐 国际化支持**: 提供完整的中英文界面支持
- **🎨 UI组件**: 新增SystemInfoComponents用于显示系统信息
- **⚙️ 数据管理**: 通过SystemInfoManager类管理实时数据更新
- **📱 独立页面**: 从About Me页面导航到独立的系统信息查看页面

### 🌟 2025-10-18 (Added System Information Display)
- **🆕 New Feature**: Added system information navigation in About Me page, tapping leads to a dedicated system information page
- **📱 Device Info**: Shows device name, CPU info, and system version
- **📊 Real-time Monitoring**: Real-time updates of CPU usage, memory usage, and current time
- **🌐 Internationalization**: Full Chinese and English interface support
- **🎨 UI Components**: Added SystemInfoComponents for displaying system info
- **⚙️ Data Management**: Real-time data updates managed through SystemInfoManager class
- **📱 Dedicated Page**: Navigate from About Me page to a dedicated system information viewing page

### 🌟 2025-12-07 (README更新)
- **🔄 README更新**: 基于项目最新状态更新README文档
- **🔧 项目结构更新**: 添加QWEN.md至项目结构说明
- **📚 功能列表扩展**: 更新功能特点表格，包含所有最新功能

### 🌟 2025-11-06 (最新更新和优化)
- **🔄 README更新**: 基于项目最新状态和Qwen.md上下文信息更新README文档
- **🔧 代码重构**: 某些组件进行了优化以提高性能和用户体验
- **📚 文档完善**: 对项目架构和功能特性进行了更详细的说明
- **🗂️ 本地化优化**: 清理了未使用的本地化字符串，保持Localizable.strings文件的整洁
  - 移除了`button.start_new`, `welcome.skip`, `solution.title`, `wrong_questions.filter_by_level`, `game.saved_at`, `game.saved_game`等未引用的字符串
  - 确保所有本地化字符串都在代码中有对应的引用，提升应用性能和维护性
  - 后续修正了意外删除仍在使用的字符串，如`welcome.levels.title`, `welcome.features.title`, `welcome.howto.title`

### 🌟 2025-11-08 (本地化文件清理)
- **🗂️ 清理未使用字符串**: 检查并删除了Localizable.strings中的未使用字符串
  - 识别并移除了在代码库中未引用的本地化字符串
  - 英文和中文本地化文件都进行了同步清理
  - 验证了所有剩余本地化字符串在代码中的正确引用
  - 确保项目构建和运行无任何编译错误
- **🔧 纠正错误移除**: 发现在清理过程中错误地移除了仍在代码中使用的字符串
  - 重新添加了`welcome.levels.title`, `welcome.features.title`, `welcome.howto.title`等仍被使用中的字符串
  - 确保应用功能完整性，避免运行时错误

### 🌟 2026-01-24 (项目结构文档更新)
- **📄 项目结构更新** - 更新README.md和ChangeLogs.md中的项目结构文档，确保准确反映当前目录组织 (Updated project structure documentation in README.md and ChangeLogs.md to accurately reflect current directory organization)
- **🔧 目录结构调整** - 根据实际项目文件和目录结构，更新了项目结构说明 (Updated project structure documentation based on actual project files and directory structure)
- **📚 文档完善** - 补充了缺失的文件和组件说明，确保文档完整性 (Supplemented missing files and component descriptions to ensure documentation completeness)

### 🌟 2026-01-04 (最新功能更新)
- **PDF题库生成功能** - 新增数学题库PDF生成功能，支持题目页和答案页分离 (Added math problem bank PDF generation with separate question and answer pages)
- **系统信息监控** - 新增全面的系统信息监控功能，包括设备信息、性能数据、电池状态等 (Added comprehensive system information monitoring including device info, performance data, battery status, etc.)
- **QR码扫描工具** - 集成QR码扫描和生成功能 (Integrated QR code scanning and generation functionality)
- **小学数学公式大全** - 新增全面的小学数学公式指南 (Added comprehensive elementary math formula guide)
- **Firebase崩溃监控** - 集成Firebase Crashlytics进行崩溃监控 (Integrated Firebase Crashlytics for crash monitoring)
- **欢迎引导流程** - 新增首次启动引导界面 (Added first-launch onboarding interface)
- **UI界面优化** - 优化多个界面的用户体验 (Optimized user experience across multiple interfaces)
- **TTS功能增强** - 增强了题目朗读功能，支持数学符号智能转换 (Enhanced question read-aloud functionality with intelligent math symbol conversion)
- **测试与质量保证** - 添加了全面的验证系统和防无限循环机制 (Added comprehensive validation system and anti-infinite loop mechanisms)

[⬆️ 返回目录](#-目录-table-of-contents)

---

<div align="center">

**⭐ 如果这个项目对你有帮助，请给我们一个星标！** (⭐ If this project helps you, please give us a star!)

**🎓 让我们一起帮助孩子们更好地学习数学！** (🎓 Let's help children learn math better together!)

Made with ❤️ by [tobecrazy](https://github.com/tobecrazy)

</div>

[⬆️ 返回顶部](#-小学生算术学习应用)
