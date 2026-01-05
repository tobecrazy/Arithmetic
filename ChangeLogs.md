# Change Log

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
