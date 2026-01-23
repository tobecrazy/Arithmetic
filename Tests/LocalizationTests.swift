import XCTest
@testable import Arithmetic

class LocalizationTests: XCTestCase {
    
    var originalLanguage: LocalizationManager.Language!
    
    override func setUp() {
        super.setUp()
        // Save the original language setting
        originalLanguage = LocalizationManager.shared.currentLanguage
        // Ensure English is selected for these tests if we're testing for missing keys in English
        // or ensure a consistent language for testing.
        LocalizationManager.shared.switchLanguage(to: .english)
    }
    
    override func tearDown() {
        // Restore the original language setting after each test
        LocalizationManager.shared.switchLanguage(to: originalLanguage)
        super.tearDown()
    }
    
    func testMissingLocalizedStringReturnsKey() {
        let missingKey = "THIS_KEY_DOES_NOT_EXIST_IN_ANY_LOCALIZABLE_FILE"
        let localizedString = missingKey.localized
        XCTAssertEqual(localizedString, missingKey, "Missing localization should return the key itself")
    }
    
    func testMissingLocalizedFormatStringReturnsKeyWithFormatApplied() {
        let missingFormatKey = "THIS_FORMAT_KEY_DOES_NOT_EXIST_AND_HAS_A_PLACEHOLDER_%@"
        let argument = "ARGUMENT"
        let localizedString = missingFormatKey.localizedFormat(argument)
        XCTAssertEqual(localizedString, "THIS_FORMAT_KEY_DOES_NOT_EXIST_AND_HAS_A_PLACEHOLDER_ARGUMENT", "Missing format localization should return the key with format applied")
    }
    
    // Additional test to ensure existing localization works as expected (sanity check)
    func testExistingLocalizedStringReturnsCorrectValue() {
        let welcomeKey = "welcome.title"
        let localizedString = welcomeKey.localized
        XCTAssertEqual(localizedString, "Welcome to Elementary Arithmetic Practice", "Existing localization should return the correct value")
    }
    
    func testEnglishLocalizedStringValues() {
        LocalizationManager.shared.switchLanguage(to: .english)
        XCTAssertEqual("app.title".localized, "Elementary Arithmetic Practice")
        XCTAssertEqual("difficulty.level1".localized, "Level 1 (Addition & Subtraction 1-10)")
        XCTAssertEqual("button.start".localized, "Start Game")
        XCTAssertEqual("game.score".localized, "Score")
        XCTAssertEqual("streak.3".localized, "On Fire!")
    }

    func testChineseLocalizedStringValues() {
        LocalizationManager.shared.switchLanguage(to: .chinese)
        XCTAssertEqual("app.title".localized, "小学算术练习")
        XCTAssertEqual("difficulty.level1".localized, "等级1 (10以内加减法)")
        XCTAssertEqual("button.start".localized, "开始游戏")
        XCTAssertEqual("game.score".localized, "得分")
        XCTAssertEqual("streak.3".localized, "火力全开！")
    }
    
    func testLanguageSwitching() {
        // Test switching to Chinese
        LocalizationManager.shared.switchLanguage(to: .chinese)
        XCTAssertEqual(LocalizationManager.shared.currentLanguage, .chinese)
        XCTAssertEqual("button.start".localized, "开始游戏")
        
        // Test switching to English
        LocalizationManager.shared.switchLanguage(to: .english)
        XCTAssertEqual(LocalizationManager.shared.currentLanguage, .english)
        XCTAssertEqual("button.start".localized, "Start Game")
    }

    func testLocalizedFormatStringWithPlaceholders() {
        // Test with a string that has an object placeholder
        LocalizationManager.shared.switchLanguage(to: .english)
        XCTAssertEqual("game.progress".localizedFormat("5", "10"), "Question 5 of 10")
        
        // Test with a string that has multiple object placeholders
        XCTAssertEqual("result.correct_count".localizedFormat("8", "10"), "8 correct out of 10")

        LocalizationManager.shared.switchLanguage(to: .chinese)
        XCTAssertEqual("game.progress".localizedFormat("5", "10"), "第 5 题/共 10 题")
        XCTAssertEqual("result.correct_count".localizedFormat("8", "10"), "答对 8 题/共 10 题")
    }
    
    func testSolutionStandardThreeNumbersOp2FirstLocalization() {
        LocalizationManager.shared.switchLanguage(to: .english)
        let expectedEnglish = "Multi-Step Calculation (Order of Operations):\nSolve: 10 + 2 × 3 = ?\n\nStep 1 (higher precedence): 2 × 3 = 6\nStep 2: 10 + 6 = 16\n\nFinal Answer: 10 + 2 × 3 = 16"
        let localizedEnglish = "solution.standard.three_numbers_op2_first".localizedFormat(10, "+", 2, "×", 3, 2, "×", 3, 6, 10, "+", 6, 16, 10, "+", 2, "×", 3, 16)
        XCTAssertEqual(localizedEnglish.trimmingCharacters(in: .whitespacesAndNewlines), expectedEnglish.trimmingCharacters(in: .whitespacesAndNewlines))
        
        LocalizationManager.shared.switchLanguage(to: .chinese)
        let expectedChinese = "标准计算解析（按运算顺序）：\n题目：10 + 2 × 3 = ?\n\n步骤1（先算乘除）：2 × 3 = 6\n步骤2（后算加减）：10 + 6 = 16\n\n所以，10 + 2 × 3 = 16"
        let localizedChinese = "solution.standard.three_numbers_op2_first".localizedFormat(10, "+", 2, "×", 3, 2, "×", 3, 6, 10, "+", 6, 16, 10, "+", 2, "×", 3, 16)
        XCTAssertEqual(localizedChinese.trimmingCharacters(in: .whitespacesAndNewlines), expectedChinese.trimmingCharacters(in: .whitespacesAndNewlines))
    }

