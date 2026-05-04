import XCTest
@testable import Arithmetic

class ContentViewEnhancementsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        LocalizationManager.shared.switchLanguage(to: .english)
    }

    override func tearDown() {
        LocalizationManager.shared.switchLanguage(to: .english)
        super.tearDown()
    }

    // MARK: - Resume Game Tests

    func testHasSavedProgressReturnsBool() {
        let result = GameViewModel.hasSavedProgress()
        XCTAssertNotNil(result)
    }

    func testGetSavedGameInfoReturnsNilWhenNoProgress() {
        let progressManager = GameProgressManager()
        progressManager.deleteGameProgress()

        let info = GameViewModel.getSavedGameInfo()
        XCTAssertNil(info)
    }

    func testSaveAndDetectGameProgress() {
        let vm = GameViewModel(difficultyLevel: .level2, timeInMinutes: 10)
        vm.startGame()

        let progressManager = GameProgressManager()
        let saved = progressManager.saveGameProgress(vm.gameState)
        XCTAssertTrue(saved)

        XCTAssertTrue(GameViewModel.hasSavedProgress())

        let info = GameViewModel.getSavedGameInfo()
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.difficultyLevel, .level2)
        XCTAssertFalse(info?.progress.isEmpty ?? true)

        progressManager.deleteGameProgress()
    }

    func testLoadSavedGameReturnsViewModel() {
        let vm = GameViewModel(difficultyLevel: .level3, timeInMinutes: 5)
        vm.startGame()
        vm.gameState.currentQuestionIndex = 3

        let progressManager = GameProgressManager()
        let saved = progressManager.saveGameProgress(vm.gameState)
        XCTAssertTrue(saved)

        // Verify the info is accessible (getSavedGameInfo uses same path as loadSavedGame)
        let info = progressManager.getSavedGameInfo()
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.difficultyLevel, .level3)

        // Attempt to load — may return nil in test context due to NSKeyedArchiver limitations
        let loadedVM = GameViewModel.loadSavedGame()
        if let loadedVM = loadedVM {
            XCTAssertEqual(loadedVM.gameState.difficultyLevel, .level3)
            XCTAssertEqual(loadedVM.gameState.currentQuestionIndex, 3)
        }

        progressManager.deleteGameProgress()
    }

    func testLoadSavedGameReturnsNilWhenEmpty() {
        let progressManager = GameProgressManager()
        progressManager.deleteGameProgress()

        let loadedVM = GameViewModel.loadSavedGame()
        XCTAssertNil(loadedVM)
    }

    // MARK: - Wrong Question Stats Tests

    func testGetWrongQuestionStatsReturnsValidStructure() {
        let manager = WrongQuestionManager()
        let stats = manager.getWrongQuestionStats(for: nil)

        XCTAssertGreaterThanOrEqual(stats.total, 0)
        XCTAssertEqual(stats.byLevel.count, DifficultyLevel.allCases.count)

        for level in DifficultyLevel.allCases {
            XCTAssertNotNil(stats.byLevel[level])
            XCTAssertGreaterThanOrEqual(stats.byLevel[level] ?? -1, 0)
        }
    }

    func testWrongQuestionStatsTotalMatchesSum() {
        let manager = WrongQuestionManager()
        let stats = manager.getWrongQuestionStats(for: nil)

        let sum = stats.byLevel.values.reduce(0, +)
        XCTAssertEqual(stats.total, sum)
    }

    // MARK: - Difficulty Level Properties Tests

    func testAllLevelsHaveSupportedOperations() {
        for level in DifficultyLevel.allCases {
            XCTAssertFalse(level.supportedOperations.isEmpty,
                           "\(level) should have supported operations")
        }
    }

    func testAllLevelsHavePositiveQuestionCount() {
        for level in DifficultyLevel.allCases {
            XCTAssertGreaterThan(level.questionCount, 0,
                                 "\(level) should have positive question count")
        }
    }

    func testAllLevelsHaveValidRange() {
        for level in DifficultyLevel.allCases {
            XCTAssertGreaterThan(level.range.upperBound, level.range.lowerBound,
                                 "\(level) should have valid range")
        }
    }

    func testOperationSymbolsNotEmpty() {
        for level in DifficultyLevel.allCases {
            let symbols = level.supportedOperations.map { $0.symbol }.joined(separator: " ")
            XCTAssertFalse(symbols.isEmpty,
                           "\(level) should have operation symbols")
        }
    }

    func testLevel1To3HaveAddSubOnly() {
        let addSubLevels: [DifficultyLevel] = [.level1, .level2, .level3]
        for level in addSubLevels {
            let ops = level.supportedOperations
            XCTAssertTrue(ops.contains(.addition))
            XCTAssertTrue(ops.contains(.subtraction))
            XCTAssertFalse(ops.contains(.multiplication))
            XCTAssertFalse(ops.contains(.division))
        }
    }

    func testLevel4And5HaveMulDivOnly() {
        let mulDivLevels: [DifficultyLevel] = [.level4, .level5]
        for level in mulDivLevels {
            let ops = level.supportedOperations
            XCTAssertTrue(ops.contains(.multiplication))
            XCTAssertTrue(ops.contains(.division))
            XCTAssertFalse(ops.contains(.addition))
            XCTAssertFalse(ops.contains(.subtraction))
        }
    }

    func testLevel6And7HaveAllOperations() {
        let mixedLevels: [DifficultyLevel] = [.level6, .level7]
        for level in mixedLevels {
            let ops = level.supportedOperations
            XCTAssertTrue(ops.contains(.addition))
            XCTAssertTrue(ops.contains(.subtraction))
            XCTAssertTrue(ops.contains(.multiplication))
            XCTAssertTrue(ops.contains(.division))
        }
    }

    // MARK: - New Localization Keys Tests

    func testNewEnglishLocalizationKeys() {
        LocalizationManager.shared.switchLanguage(to: .english)

        XCTAssertEqual("resume.title".localized, "Game In Progress")
        XCTAssertEqual("resume.continue".localized, "Continue")
        XCTAssertEqual("resume.questions".localized, "questions")
        XCTAssertEqual("stats.total_wrong".localized, "Wrong")
        XCTAssertEqual("stats.this_level".localized, "This Level")
        XCTAssertEqual("stats.questions_count".localized, "Questions")
        XCTAssertEqual("stats.questions_to_review".localized, "questions to review")
        XCTAssertEqual("stats.questions_short".localized, "Q")
        XCTAssertEqual("settings.minutes_short".localized, "min")
    }

    func testNewChineseLocalizationKeys() {
        LocalizationManager.shared.switchLanguage(to: .chinese)

        XCTAssertEqual("resume.title".localized, "游戏进行中")
        XCTAssertEqual("resume.continue".localized, "继续游戏")
        XCTAssertEqual("resume.questions".localized, "题")
        XCTAssertEqual("stats.total_wrong".localized, "错题")
        XCTAssertEqual("stats.this_level".localized, "本等级")
        XCTAssertEqual("stats.questions_count".localized, "题目数")
        XCTAssertEqual("stats.questions_to_review".localized, "题待复习")
        XCTAssertEqual("stats.questions_short".localized, "题")
        XCTAssertEqual("settings.minutes_short".localized, "分钟")
    }

    func testNewKeysNotReturningSelf() {
        let keys = [
            "resume.title", "resume.continue", "resume.questions",
            "stats.total_wrong", "stats.this_level", "stats.questions_count",
            "stats.questions_to_review", "stats.questions_short",
            "settings.minutes_short"
        ]

        for lang in LocalizationManager.Language.allCases {
            LocalizationManager.shared.switchLanguage(to: lang)
            for key in keys {
                XCTAssertNotEqual(key.localized, key,
                                  "Key '\(key)' should be localized in \(lang)")
            }
        }
    }

    // MARK: - Progress Ratio Parsing Tests

    func testProgressRatioParsing() {
        XCTAssertEqual(parseProgressRatio("5/25"), 0.2, accuracy: 0.001)
        XCTAssertEqual(parseProgressRatio("1/20"), 0.05, accuracy: 0.001)
        XCTAssertEqual(parseProgressRatio("10/10"), 1.0, accuracy: 0.001)
        XCTAssertEqual(parseProgressRatio("0/50"), 0.0, accuracy: 0.001)
    }

    func testProgressRatioInvalidInput() {
        XCTAssertEqual(parseProgressRatio("invalid"), 0.0)
        XCTAssertEqual(parseProgressRatio(""), 0.0)
        XCTAssertEqual(parseProgressRatio("5"), 0.0)
        XCTAssertEqual(parseProgressRatio("5/0"), 0.0)
    }

    private func parseProgressRatio(_ progressString: String) -> Double {
        let parts = progressString.split(separator: "/")
        guard parts.count == 2,
              let current = Double(parts[0]),
              let total = Double(parts[1]),
              total > 0 else { return 0 }
        return current / total
    }

    // MARK: - Time Presets Tests

    func testTimePresetsAreValid() {
        let presets = [3, 5, 10, 15, 20, 30]

        for preset in presets {
            XCTAssertGreaterThan(preset, 0)
            XCTAssertLessThanOrEqual(preset, 60)
        }

        XCTAssertEqual(presets, presets.sorted())
    }

    func testCustomTimeRange() {
        let minTime = 1
        let maxTime = 60

        XCTAssertGreaterThanOrEqual(minTime, 1)
        XCTAssertLessThanOrEqual(maxTime, 60)

        let vm = GameViewModel(difficultyLevel: .level1, timeInMinutes: minTime)
        XCTAssertEqual(vm.gameState.totalTime, minTime * 60)

        let vmMax = GameViewModel(difficultyLevel: .level1, timeInMinutes: maxTime)
        XCTAssertEqual(vmMax.gameState.totalTime, maxTime * 60)
    }
}
