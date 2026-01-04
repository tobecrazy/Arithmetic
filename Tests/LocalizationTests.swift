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
        // Assuming "Welcome" key exists in en.lproj/Localizable.strings and its value is "Welcome"
        // If not, this test might fail or need adjustment based on actual string file content.
        let welcomeKey = "Welcome"
        let localizedString = welcomeKey.localized
        // This assertion relies on the actual content of Localizable.strings
        // For 'en', if "Welcome" -> "Welcome", this passes.
        // If "Welcome" -> "Welcome to the App", this test needs to change to "Welcome to the App"
        // I will assume for now that "Welcome" localized in English is "Welcome"
        XCTAssertEqual(localizedString, "Welcome", "Existing localization should return the correct value")
    }
}
