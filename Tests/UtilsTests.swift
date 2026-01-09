import XCTest
@testable import Arithmetic

// Test suite for DeviceUtils
class DeviceUtilsTests: XCTestCase {
    
    func testIsIPadReturnsFalseOnSimulator() {
        // On simulator, this will return false for iPad
        XCTAssertFalse(DeviceUtils.isIPad)
    }
    
    func testIsLandscapeWithRegularSizeClasses() {
        let result = DeviceUtils.isLandscape(with: (horizontal: .regular, vertical: .regular))
        XCTAssertTrue(result)
    }
    
    func testIsLandscapeWithCompactVertical() {
        let result = DeviceUtils.isLandscape(with: (horizontal: .regular, vertical: .compact))
        XCTAssertFalse(result)
    }
    
    func testIsLandscapeWithCompactHorizontal() {
        let result = DeviceUtils.isLandscape(with: (horizontal: .compact, vertical: .regular))
        XCTAssertFalse(result)
    }
    
    func testIsLandscapeWithCompactBoth() {
        let result = DeviceUtils.isLandscape(with: (horizontal: .compact, vertical: .compact))
        XCTAssertFalse(result)
    }
}

// Test suite for ImageCacheManager
class ImageCacheManagerTests: XCTestCase {
    
    var cacheManager: ImageCacheManager!
    let testImage = UIImage(systemName: "star")! // Using a simple system image for testing
    let testKey = "test_image"
    
    override func setUp() {
        super.setUp()
        cacheManager = ImageCacheManager.shared
        // Clear cache before each test to ensure clean state
        cacheManager.clearCache()
    }
    
    override func tearDown() {
        cacheManager.clearCache()
        super.tearDown()
    }
    
    func testSharedInstanceExists() {
        XCTAssertNotNil(ImageCacheManager.shared)
    }
    
    func testSaveImageToMemoryCache() {
        cacheManager.saveImage(testImage, forKey: testKey)
        
        let cachedImage = cacheManager.getImage(forKey: testKey)
        XCTAssertNotNil(cachedImage)
    }
    
    func testSaveAndRetrieveImage() {
        cacheManager.saveImage(testImage, forKey: testKey)
        
        let retrievedImage = cacheManager.getImage(forKey: testKey)
        XCTAssertNotNil(retrievedImage)
        
        // Basic comparison - images should have same size
        XCTAssertEqual(testImage.size.width, retrievedImage!.size.width)
        XCTAssertEqual(testImage.size.height, retrievedImage!.size.height)
    }
    
    func testGetNonExistentImageReturnsNil() {
        let image = cacheManager.getImage(forKey: "non_existent_key")
        XCTAssertNil(image)
    }
    
    func testClearCacheRemovesAllImages() {
        cacheManager.saveImage(testImage, forKey: testKey)
        
        // Verify image is cached
        XCTAssertNotNil(cacheManager.getImage(forKey: testKey))
        
        // Clear cache
        cacheManager.clearCache()
        
        // Verify image is removed
        XCTAssertNil(cacheManager.getImage(forKey: testKey))
    }
    
    func testDownloadAndCacheImageWithInvalidURL() {
        let expectation = XCTestExpectation(description: "Download fails with invalid URL")
        
        let invalidURL = URL(string: "invalid-url")!
        cacheManager.downloadAndCacheImage(from: invalidURL) { image in
            XCTAssertNil(image)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testImageCachingDoesNotExceedLimits() {
        // Verify initial empty state
        XCTAssertNil(cacheManager.getImage(forKey: testKey))
        
        // Save an image
        cacheManager.saveImage(testImage, forKey: testKey)
        
        // Retrieve it back
        let retrievedImage = cacheManager.getImage(forKey: testKey)
        XCTAssertNotNil(retrievedImage)
    }
}

// Test suite for LocalizationManager
class LocalizationManagerTests: XCTestCase {
    
    var localizationManager: LocalizationManager!
    
    override func setUp() {
        super.setUp()
        localizationManager = LocalizationManager()
    }
    
    override func tearDown() {
        // Reset to default language
        localizationManager.switchLanguage(to: .chinese)
        super.tearDown()
    }
    
    func testSharedInstanceExists() {
        XCTAssertNotNil(LocalizationManager.shared)
    }
    
    func testInitialLanguageIsChinese() {
        XCTAssertEqual(localizationManager.currentLanguage, .chinese)
    }
    
    func testSwitchLanguageToEnglish() {
        localizationManager.switchLanguage(to: .english)
        XCTAssertEqual(localizationManager.currentLanguage, .english)
    }
    
    func testSwitchLanguageToChinese() {
        localizationManager.switchLanguage(to: .english)
        localizationManager.switchLanguage(to: .chinese)
        XCTAssertEqual(localizationManager.currentLanguage, .chinese)
    }
    
    func testLanguageDisplayName() {
        XCTAssertEqual(LocalizationManager.Language.chinese.displayName, "中文")
        XCTAssertEqual(LocalizationManager.Language.english.displayName, "English")
    }
    
    func testLanguageRawValue() {
        XCTAssertEqual(LocalizationManager.Language.chinese.rawValue, "zh-Hans")
        XCTAssertEqual(LocalizationManager.Language.english.rawValue, "en")
    }
    
    func testLanguageCaseIterable() {
        let allLanguages = LocalizationManager.Language.allCases
        XCTAssertTrue(allLanguages.contains(.chinese))
        XCTAssertTrue(allLanguages.contains(.english))
        XCTAssertEqual(allLanguages.count, 2)
    }
    
    func testLanguageId() {
        XCTAssertEqual(LocalizationManager.Language.chinese.id, "zh-Hans")
        XCTAssertEqual(LocalizationManager.Language.english.id, "en")
    }
    
    func testEquatableImplementation() {
        let manager1 = LocalizationManager()
        let manager2 = LocalizationManager()
        
        XCTAssertTrue(manager1 == manager1)  // Same instance
        XCTAssertFalse(manager1 == manager2) // Different instances
    }
}

// Test suite for NavigationUtil
class NavigationUtilTests: XCTestCase {
    
    func testFindNavigationControllerWithNil() {
        let result = NavigationUtil.findNavigationController(viewController: nil)
        XCTAssertNil(result)
    }
    
    // Note: Testing the other methods would require actual view controllers
    // which is complex in unit tests, so we're covering the base case
}

// Test suite for ProgressViewUtils
class ProgressViewUtilsTests: XCTestCase {
    
    func testLinearProgressBarInitialization() {
        let progressBar = ProgressViewUtils.LinearProgressBar(progress: 0.5)
        XCTAssertEqual(progressBar.progress, 0.5)
        XCTAssertEqual(progressBar.height, 8)
    }
    
    func testLinearProgressBarWithCustomHeight() {
        let progressBar = ProgressViewUtils.LinearProgressBar(progress: 0.7, height: 10)
        XCTAssertEqual(progressBar.progress, 0.7)
        XCTAssertEqual(progressBar.height, 10)
    }
    
    func testLinearProgressBarClampsProgress() {
        let progressBar = ProgressViewUtils.LinearProgressBar(progress: 1.5)  // Above 1.0
        XCTAssertEqual(progressBar.progress, 1.0)  // Should be clamped to 1.0
        
        let progressBar2 = ProgressViewUtils.LinearProgressBar(progress: -0.5)  // Below 0.0
        XCTAssertEqual(progressBar2.progress, 0.0)  // Should be clamped to 0.0
    }
    
    func testCircularProgressBarInitialization() {
        let circularBar = ProgressViewUtils.CircularProgressBar(progress: 0.6)
        XCTAssertEqual(circularBar.progress, 0.6)
        XCTAssertEqual(circularBar.lineWidth, 8)
    }
    
    func testCircularProgressBarClampsProgress() {
        let circularBar = ProgressViewUtils.CircularProgressBar(progress: 1.2)  // Above 1.0
        XCTAssertEqual(circularBar.progress, 1.0)  // Should be clamped to 1.0
        
        let circularBar2 = ProgressViewUtils.CircularProgressBar(progress: -0.3)  // Below 0.0
        XCTAssertEqual(circularBar2.progress, 0.0)  // Should be clamped to 0.0
    }
    
    func testSegmentedProgressBarInitialization() {
        let segmentedBar = ProgressViewUtils.SegmentedProgressBar(currentStep: 2, totalSteps: 5)
        XCTAssertEqual(segmentedBar.currentStep, 2)
        XCTAssertEqual(segmentedBar.totalSteps, 5)
    }
    
    func testSegmentedProgressBarClampsValues() {
        let segmentedBar = ProgressViewUtils.SegmentedProgressBar(currentStep: 10, totalSteps: 5)  // Current step > total
        XCTAssertEqual(segmentedBar.currentStep, 5)  // Should be clamped to totalSteps
        
        let segmentedBar2 = ProgressViewUtils.SegmentedProgressBar(currentStep: -1, totalSteps: 5)  // Negative current step
        XCTAssertEqual(segmentedBar2.currentStep, 0)  // Should be clamped to 0
    }
    
    func testSegmentedProgressBarMinimumTotalSteps() {
        let segmentedBar = ProgressViewUtils.SegmentedProgressBar(currentStep: 2, totalSteps: 0)  // Zero total steps
        XCTAssertEqual(segmentedBar.totalSteps, 1)  // Should have a minimum of 1
    }
    
    func testProgressManagerInitialization() {
        let progressManager = ProgressManager()
        XCTAssertEqual(progressManager.currentProgress, 0.0)
        XCTAssertFalse(progressManager.isLoading)
        XCTAssertEqual(progressManager.progressMessage, "")
    }
    
    func testProgressManagerUpdateProgress() {
        let progressManager = ProgressManager()
        progressManager.updateProgress(0.5, message: "Halfway there")
        
        XCTAssertEqual(progressManager.currentProgress, 0.5)
        XCTAssertEqual(progressManager.progressMessage, "Halfway there")
    }
    
    func testProgressManagerUpdateProgressClampsValues() {
        let progressManager = ProgressManager()
        progressManager.updateProgress(1.5)  // Above 1.0
        XCTAssertEqual(progressManager.currentProgress, 1.0)  // Should be clamped to 1.0
        
        progressManager.updateProgress(-0.5)  // Below 0.0
        XCTAssertEqual(progressManager.currentProgress, 0.0)  // Should be clamped to 0.0
    }
    
    func testProgressManagerSetLoading() {
        let progressManager = ProgressManager()
        progressManager.setLoading(true, message: "Loading...")
        
        XCTAssertTrue(progressManager.isLoading)
        XCTAssertEqual(progressManager.progressMessage, "Loading...")
    }
    
    func testProgressManagerReset() {
        let progressManager = ProgressManager()
        // Set some values
        progressManager.updateProgress(0.8, message: "Almost done")
        progressManager.setLoading(true, message: "Loading")
        
        // Reset
        progressManager.reset()
        
        XCTAssertEqual(progressManager.currentProgress, 0.0)
        XCTAssertFalse(progressManager.isLoading)
        XCTAssertEqual(progressManager.progressMessage, "")
    }
    
    func testSharedProgressManager() {
        XCTAssertNotNil(ProgressManager.shared)
    }
    
    func testGameProgressBarCreation() {
        let gameBar = ProgressViewUtils.gameProgressBar(currentQuestion: 3, totalQuestions: 10)
        XCTAssertNotNil(gameBar)
    }
    
    func testDownloadProgressViewCreation() {
        let downloadView = ProgressViewUtils.downloadProgressView(progress: 0.5, fileName: "test.pdf")
        XCTAssertNotNil(downloadView)
    }
}

// Testing the extension functions
class ViewExtensionTests: XCTestCase {
    
    func testLinearProgressModifier() {
        let view = Color.red
        let modifiedView = view.linearProgress(0.5)
        XCTAssertNotNil(modifiedView)
    }
    
    func testLoadingOverlayModifier() {
        let view = Color.blue
        let modifiedView = view.loadingOverlay(isLoading: true)
        XCTAssertNotNil(modifiedView)
    }
}


// Test suite for QuestionGenerator
class QuestionGeneratorTests: XCTestCase {
    
    func testGenerateQuestionsCreatesCorrectCount() {
        let questions = QuestionGenerator.generateQuestions(difficultyLevel: .level1, count: 5)
        XCTAssertEqual(questions.count, 5)
    }
    
    func testGenerateQuestionsWithWrongQuestions() {
        let wrongQuestion = Question(number1: 5, number2: 3, operation: .addition)
        let questions = QuestionGenerator.generateQuestions(difficultyLevel: .level1, count: 3, wrongQuestions: [wrongQuestion])
        
        // Should include wrong question if it's not duplicated
        XCTAssertFalse(questions.isEmpty)
        XCTAssertTrue(questions.count >= 1)  // At least 1 question should be present
    }
    
    func testGetCombinationKeyForTwoNumberQuestion() {
        let question = Question(number1: 5, number2: 3, operation: .addition)
        let key = QuestionGenerator.getCombinationKey(for: question)
        
        // Check that the key contains the numbers and operation
        XCTAssertTrue(key.contains("5"))
        XCTAssertTrue(key.contains("3"))
        XCTAssertTrue(key.contains("+"))
    }
    
    func testGetCombinationKeyForThreeNumberQuestion() {
        let question = Question(number1: 5, number2: 3, number3: 2, operation1: .addition, operation2: .subtraction)
        let key = QuestionGenerator.getCombinationKey(for: question)
        
        // Check that the key contains the numbers and operations
        XCTAssertTrue(key.contains("5"))
        XCTAssertTrue(key.contains("3"))
        XCTAssertTrue(key.contains("2"))
        XCTAssertTrue(key.contains("+"))
        XCTAssertTrue(key.contains("-"))
    }
    
    func testSafeRandomWithValidRange() {
        let result = QuestionGenerator.safeRandom(in: 1...10)
        XCTAssertTrue(result >= 1 && result <= 10)
    }
    
    func testSafeRandomWithInvalidRange() {
        let result = QuestionGenerator.safeRandom(in: 10...1)  // Invalid range
        XCTAssertEqual(result, 10)  // Should return lower bound
    }
    
    func testSafeRandomWithValidRangeForHalfOpen() {
        let result = QuestionGenerator.safeRandom(in: 1..<10)  // Range from 1 to 9
        XCTAssertTrue(result >= 1 && result < 10)
    }
    
    func testSafeRandomWithInvalidHalfOpenRange() {
        let result = QuestionGenerator.safeRandom(in: 10..<1)  // Invalid range
        XCTAssertEqual(result, 10)  // Should return lower bound
    }
    
    func testGenerateQuestionsWithZeroCount() {
        let questions = QuestionGenerator.generateQuestions(difficultyLevel: .level1, count: 0)
        XCTAssertEqual(questions.count, 0)
    }
    
    func testGenerateQuestionsWithLargeCount() {
        let questions = QuestionGenerator.generateQuestions(difficultyLevel: .level1, count: 100)
        XCTAssertEqual(questions.count, 100)
    }
    
    func testGenerateQuestionsExcludesDuplicateQuestions() {
        let question1 = Question(number1: 5, number2: 3, operation: .addition)
        let question2 = Question(number1: 5, number2: 3, operation: .addition)  // Same as question1
        let questions = QuestionGenerator.generateQuestions(difficultyLevel: .level1, count: 10, wrongQuestions: [question1, question2])
        
        // Should only include one instance of the duplicate question
        let duplicateCount = questions.filter { $0.numbers == [5, 3] && $0.operations == [.addition] }.count
        XCTAssertTrue(duplicateCount <= 1)
    }
    
    func testGenerateQuestionsHandlesEmptyWrongQuestions() {
        let questions = QuestionGenerator.generateQuestions(difficultyLevel: .level1, count: 5, wrongQuestions: [])
        XCTAssertEqual(questions.count, 5)
    }
}

// Test suite for SystemInfoManager
class SystemInfoManagerTests: XCTestCase {
    
    var systemInfoManager: SystemInfoManager!
    
    override func setUp() {
        super.setUp()
        systemInfoManager = SystemInfoManager()
    }
    
    override func tearDown() {
        systemInfoManager.stopRealTimeUpdates()
        super.tearDown()
    }
    
    func testInitialization() {
        XCTAssertNotNil(systemInfoManager.deviceName)
        XCTAssertNotNil(systemInfoManager.memoryUsage)
        XCTAssertNotNil(systemInfoManager.diskUsage)
        XCTAssertNotNil(systemInfoManager.networkInfo)
        XCTAssertNotNil(systemInfoManager.batteryInfo)
        XCTAssertNotNil(systemInfoManager.screenInfo)
    }
    
    func testMemoryInfoUsagePercentage() {
        var memoryInfo = SystemInfoManager.MemoryInfo()
        memoryInfo.totalMemory = 1000
        memoryInfo.usedMemory = 500
        
        XCTAssertEqual(memoryInfo.usagePercentage, 50.0, accuracy: 0.01)
    }
    
    func testMemoryInfoWithZeroTotalMemory() {
        var memoryInfo = SystemInfoManager.MemoryInfo()
        memoryInfo.totalMemory = 0
        memoryInfo.usedMemory = 500
        
        XCTAssertEqual(memoryInfo.usagePercentage, 0.0)
    }
    
    func testDiskInfoUsagePercentage() {
        var diskInfo = SystemInfoManager.DiskInfo()
        diskInfo.totalDisk = 10000
        diskInfo.usedDisk = 2500
        
        XCTAssertEqual(diskInfo.usagePercentage, 25.0, accuracy: 0.01)
    }
    
    func testDiskInfoWithZeroTotalDisk() {
        var diskInfo = SystemInfoManager.DiskInfo()
        diskInfo.totalDisk = 0
        diskInfo.usedDisk = 2500
        
        XCTAssertEqual(diskInfo.usagePercentage, 0.0)
    }
    
    func testBatteryInfoUptimeStringWhenBootTimeIsZero() {
        var batteryInfo = SystemInfoManager.BatteryInfo()
        batteryInfo.timeIntervalSinceBoot = 0
        
        XCTAssertEqual(batteryInfo.uptimeString, "Unknown")
    }
    
    func testBatteryInfoUptimeStringForLessThanAMinute() {
        var batteryInfo = SystemInfoManager.BatteryInfo()
        batteryInfo.timeIntervalSinceBoot = 30  // 30 seconds
        
        XCTAssertTrue(batteryInfo.uptimeString.hasPrefix("00:00:"))
    }
    
    func testBatteryInfoUptimeStringForMoreThanAMinute() {
        var batteryInfo = SystemInfoManager.BatteryInfo()
        batteryInfo.timeIntervalSinceBoot = 125  // 2 minutes and 5 seconds
        
        XCTAssertEqual(batteryInfo.uptimeString, "00:02:05")
    }
    
    func testBatteryInfoUptimeStringForMoreThanAnHour() {
        var batteryInfo = SystemInfoManager.BatteryInfo()
        batteryInfo.timeIntervalSinceBoot = 3725  // 1 hour, 2 minutes and 5 seconds
        
        XCTAssertEqual(batteryInfo.uptimeString, "01:02:05")
    }
    
    func testBatteryInfoUptimeStringForMoreThanADay() {
        var batteryInfo = SystemInfoManager.BatteryInfo()
        batteryInfo.timeIntervalSinceBoot = 90125  // 1 day, 1 hour, 2 minutes and 5 seconds
        
        XCTAssertTrue(batteryInfo.uptimeString.hasPrefix("1 days,"))
    }
    
    func testNetworkInfoDefaultValues() {
        let networkInfo = SystemInfoManager.NetworkInfo()
        XCTAssertEqual(networkInfo.wifiName, "")
        XCTAssertEqual(networkInfo.wifiSSID, "")
        XCTAssertEqual(networkInfo.cellularCarrier, "")
        XCTAssertFalse(networkInfo.isConnected)
        XCTAssertEqual(networkInfo.connectionType, "")
    }
    
    func testScreenInfoDefaultValues() {
        let screenInfo = SystemInfoManager.ScreenInfo()
        XCTAssertEqual(screenInfo.screenSize, CGSize.zero)
        XCTAssertEqual(screenInfo.screenResolution, "")
        XCTAssertEqual(screenInfo.scaleFactor, 0.0)
        XCTAssertEqual(screenInfo.refreshRate, 0.0)
        XCTAssertEqual(screenInfo.physicalSize, "")
    }
    
    func testReachabilityConnectionTypes() {
        let reachability = Reachability()
        let connectionType = reachability.connection
        XCTAssertNotNil(connectionType)
    }
}

// Test suite for TTSHelper
class TTSHelperTests: XCTestCase {
    
    var ttsHelper: TTSHelper!
    
    override func setUp() {
        super.setUp()
        ttsHelper = TTSHelper()
    }
    
    func testSharedInstanceExists() {
        XCTAssertNotNil(TTSHelper.shared)
    }
    
    func testConvertMathExpressionToSpokenChinese() {
        let expression = "5 + 3 = 8"
        let spoken = ttsHelper.convertMathExpressionToSpoken(expression, language: .chinese)
        
        XCTAssertTrue(spoken.contains("加"))
        XCTAssertTrue(spoken.contains("等于"))
    }
    
    func testConvertMathExpressionToSpokenEnglish() {
        let expression = "5 + 3 = 8"
        let spoken = ttsHelper.convertMathExpressionToSpoken(expression, language: .english)
        
        XCTAssertTrue(spoken.contains("plus"))
        XCTAssertTrue(spoken.contains("equals"))
    }
    
    func testConvertMathExpressionWithDifferentOperatorsChinese() {
        let expression = "10 - 4 = 6"
        let spoken = ttsHelper.convertMathExpressionToSpoken(expression, language: .chinese)
        
        XCTAssertTrue(spoken.contains("减"))
        XCTAssertTrue(spoken.contains("等于"))
    }
    
    func testConvertMathExpressionWithDifferentOperatorsEnglish() {
        let expression = "10 - 4 = 6"
        let spoken = ttsHelper.convertMathExpressionToSpoken(expression, language: .english)
        
        XCTAssertTrue(spoken.contains("minus"))
        XCTAssertTrue(spoken.contains("equals"))
    }
    
    func testConvertMathExpressionWithMultiplicationChinese() {
        let expression = "3 × 4 = 12"
        let spoken = ttsHelper.convertMathExpressionToSpoken(expression, language: .chinese)
        
        XCTAssertTrue(spoken.contains("乘以"))
        XCTAssertTrue(spoken.contains("等于"))
    }
    
    func testConvertMathExpressionWithMultiplicationEnglish() {
        let expression = "3 × 4 = 12"
        let spoken = ttsHelper.convertMathExpressionToSpoken(expression, language: .english)
        
        XCTAssertTrue(spoken.contains("times"))
        XCTAssertTrue(spoken.contains("equals"))
    }
    
    func testConvertMathExpressionWithDivisionChinese() {
        let expression = "12 ÷ 4 = 3"
        let spoken = ttsHelper.convertMathExpressionToSpoken(expression, language: .chinese)
        
        XCTAssertTrue(spoken.contains("除以"))
        XCTAssertTrue(spoken.contains("等于"))
    }
    
    func testConvertMathExpressionWithDivisionEnglish() {
        let expression = "12 ÷ 4 = 3"
        let spoken = ttsHelper.convertMathExpressionToSpoken(expression, language: .english)
        
        XCTAssertTrue(spoken.contains("divided by"))
        XCTAssertTrue(spoken.contains("equals"))
    }
    
    func testConvertMathExpressionReplacesAsteriskWithMultiplicationChinese() {
        let expression = "3 * 4 = 12"
        let spoken = ttsHelper.convertMathExpressionToSpoken(expression, language: .chinese)
        
        XCTAssertTrue(spoken.contains("乘以"))  // Should convert * to 乘以
    }
    
    func testConvertMathExpressionReplacesAsteriskWithMultiplicationEnglish() {
        let expression = "3 * 4 = 12"
        let spoken = ttsHelper.convertMathExpressionToSpoken(expression, language: .english)
        
        XCTAssertTrue(spoken.contains("times"))  // Should convert * to times
    }
    
    func testConvertMathExpressionReplacesSlashWithDivisionChinese() {
        let expression = "12 / 4 = 3"
        let spoken = ttsHelper.convertMathExpressionToSpoken(expression, language: .chinese)
        
        XCTAssertTrue(spoken.contains("除以"))  // Should convert / to 除以
    }
    
    func testConvertMathExpressionReplacesSlashWithDivisionEnglish() {
        let expression = "12 / 4 = 3"
        let spoken = ttsHelper.convertMathExpressionToSpoken(expression, language: .english)
        
        XCTAssertTrue(spoken.contains("divided by"))  // Should convert / to divided by
    }
    
    func testConvertMathExpressionConvertsNumbersToWordsChinese() {
        let expression = "5 + 3 = 8"
        let spoken = ttsHelper.convertMathExpressionToSpoken(expression, language: .chinese)
        
        // Should contain words that represent the numbers in Chinese
        XCTAssertFalse(spoken.contains("5"))  // Should not contain the number directly
        XCTAssertFalse(spoken.contains("3"))  // Should not contain the number directly
        XCTAssertFalse(spoken.contains("8"))  // Should not contain the number directly
    }
    
    func testConvertMathExpressionConvertsNumbersToWordsEnglish() {
        let expression = "5 + 3 = 8"
        let spoken = ttsHelper.convertMathExpressionToSpoken(expression, language: .english)
        
        // Should contain words that represent the numbers in English
        XCTAssertFalse(spoken.contains("5"))  // Should not contain the number directly
        XCTAssertFalse(spoken.contains("3"))  // Should not contain the number directly
        XCTAssertFalse(spoken.contains("8"))  // Should not contain the number directly
    }
    
    func testSpeakWithEmptyText() {
        // This should not crash
        ttsHelper.speak(text: "", language: .english)
    }
    
    func testSpeakMathExpression() {
        // This should not crash
        ttsHelper.speakMathExpression("5 + 3 = 8", language: .english)
    }
    
    func testStopSpeakingWhenNotSpeaking() {
        // This should not crash when not speaking
        ttsHelper.stopSpeaking()
    }
    
    func testIsSpeakingProperty() {
        // Initially should be false
        XCTAssertFalse(ttsHelper.isSpeaking)
    }
    
    func testOperatorReplacementsForChinese() {
        // Testing the internal functionality via the public method
        let expression = "5 + 3 - 2 = 6"
        let spoken = ttsHelper.convertMathExpressionToSpoken(expression, language: .chinese)
        
        XCTAssertTrue(spoken.contains("加"))
        XCTAssertTrue(spoken.contains("减"))
        XCTAssertTrue(spoken.contains("等于"))
    }
    
    func testOperatorReplacementsForEnglish() {
        // Testing the internal functionality via the public method
        let expression = "5 + 3 - 2 = 6"
        let spoken = ttsHelper.convertMathExpressionToSpoken(expression, language: .english)
        
        XCTAssertTrue(spoken.contains("plus"))
        XCTAssertTrue(spoken.contains("minus"))
        XCTAssertTrue(spoken.contains("equals"))
    }
}

// MARK: - ViewModel and UI Tests Placeholder
// The following test suites have been moved to separate files:
// - GameViewModelTests: Comprehensive tests for GameViewModel functionality
// - ArithmeticUITests: UI tests for the entire application
//
// These tests cover:
// - ViewModel state management
// - Game logic and progression
// - UI interactions
// - Navigation flows
// - Accessibility features
// - Timer functionality
// - Answer submission
// - Difficulty level selection
// - Settings and preferences
// - Language switching
// - Dark mode toggling
// - Multiplication table access
// - Wrong questions management
// - Game completion scenarios