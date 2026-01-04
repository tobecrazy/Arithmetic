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
}
