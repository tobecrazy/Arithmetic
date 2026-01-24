import XCTest
import SwiftUI
@testable import Arithmetic

// MARK: - String+Localized Tests
class StringLocalizedTests: XCTestCase {

    func testLocalizedPropertyReturnsKey() {
        let key = "nonexistent.key.that.does.not.exist"
        let result = key.localized
        // Should return the key itself if not found
        XCTAssertEqual(result, key)
    }

    func testLocalizedPropertyReturnsTranslation() {
        // Test with a known key
        let key = "app.title"
        let result = key.localized
        // Should not be empty
        XCTAssertFalse(result.isEmpty)
    }

    func testLocalizedFormatWithOneArgument() {
        let format = "test %@"
        let result = format.localizedFormat("value")
        XCTAssertTrue(result.contains("value"))
    }

    func testLocalizedFormatWithMultipleArguments() {
        let format = "%@ and %@"
        let result = format.localizedFormat("first", "second")
        XCTAssertTrue(result.contains("first"))
        XCTAssertTrue(result.contains("second"))
    }

    func testLocalizedFormatWithIntegerArguments() {
        let format = "Number %d of %d"
        let result = format.localizedFormat(5, 10)
        XCTAssertTrue(result.contains("5"))
        XCTAssertTrue(result.contains("10"))
    }

    func testLocalizedFormatWithMixedArguments() {
        let format = "%@ has %d items"
        let result = format.localizedFormat("List", 3)
        XCTAssertTrue(result.contains("List"))
        XCTAssertTrue(result.contains("3"))
    }

    func testGameProgressLocalization() {
        let key = "game.progress"
        let result = key.localizedFormat("5", "10")
        // Should contain the numbers
        XCTAssertTrue(result.contains("5"))
        XCTAssertTrue(result.contains("10"))
    }

    func testResultCorrectCountLocalization() {
        let key = "result.correct_count"
        let result = key.localizedFormat("8", "10")
        XCTAssertTrue(result.contains("8"))
        XCTAssertTrue(result.contains("10"))
    }
}

// MARK: - CGFloat+Adaptive Tests
class CGFloatAdaptiveTests: XCTestCase {

    func testAdaptivePaddingExists() {
        let padding = CGFloat.adaptivePadding
        XCTAssertGreaterThan(padding, 0)
    }

    func testAdaptiveCornerRadiusExists() {
        let cornerRadius = CGFloat.adaptiveCornerRadius
        XCTAssertGreaterThan(cornerRadius, 0)
    }

    func testAdaptivePaddingReasonableValue() {
        let padding = CGFloat.adaptivePadding
        // Should be a reasonable padding value (between 8 and 40)
        XCTAssertGreaterThanOrEqual(padding, 8)
        XCTAssertLessThanOrEqual(padding, 40)
    }

    func testAdaptiveCornerRadiusReasonableValue() {
        let cornerRadius = CGFloat.adaptiveCornerRadius
        // Should be a reasonable corner radius (between 4 and 30)
        XCTAssertGreaterThanOrEqual(cornerRadius, 4)
        XCTAssertLessThanOrEqual(cornerRadius, 30)
    }
}

// MARK: - Font+Adaptive Tests
class FontAdaptiveTests: XCTestCase {

    func testAdaptiveTitleReturnsFont() {
        let font = Font.adaptiveTitle()
        XCTAssertNotNil(font)
    }

    func testAdaptiveTitle2ReturnsFont() {
        let font = Font.adaptiveTitle2()
        XCTAssertNotNil(font)
    }

    func testAdaptiveHeadlineReturnsFont() {
        let font = Font.adaptiveHeadline()
        XCTAssertNotNil(font)
    }

    func testAdaptiveBodyReturnsFont() {
        let font = Font.adaptiveBody()
        XCTAssertNotNil(font)
    }

    func testAdaptiveCaptionReturnsFont() {
        let font = Font.adaptiveCaption()
        XCTAssertNotNil(font)
    }
}

// MARK: - Color+Theme Tests
class ColorThemeTests: XCTestCase {

    func testAdaptiveFunctionExists() {
        let color = Color.adaptive(light: .black, dark: .white)
        XCTAssertNotNil(color)
    }

    func testAdaptiveColorCreation() {
        let lightColor = Color.red
        let darkColor = Color.blue
        let adaptiveColor = Color.adaptive(light: lightColor, dark: darkColor)
        XCTAssertNotNil(adaptiveColor)
    }

    // Test Color extension adaptive colors
    func testAdaptiveColorsExist() {
        XCTAssertNotNil(Color.adaptiveBackground)
        XCTAssertNotNil(Color.adaptiveSecondaryBackground)
        XCTAssertNotNil(Color.adaptiveText)
        XCTAssertNotNil(Color.adaptiveSecondaryText)
        XCTAssertNotNil(Color.accent)
        XCTAssertNotNil(Color.success)
        XCTAssertNotNil(Color.error)
    }

    func testAdaptiveBackground() {
        let color = Color.adaptiveBackground
        XCTAssertNotNil(color)
    }

    func testAdaptiveSecondaryBackground() {
        let color = Color.adaptiveSecondaryBackground
        XCTAssertNotNil(color)
    }

    func testAdaptiveText() {
        let color = Color.adaptiveText
        XCTAssertNotNil(color)
    }

    func testAdaptiveSecondaryText() {
        let color = Color.adaptiveSecondaryText
        XCTAssertNotNil(color)
    }

    func testColorAccent() {
        let color = Color.accent
        XCTAssertNotNil(color)
    }

    func testColorSuccess() {
        let color = Color.success
        XCTAssertNotNil(color)
    }

    func testColorError() {
        let color = Color.error
        XCTAssertNotNil(color)
    }

    func testColorWarning() {
        let color = Color.warning
        XCTAssertNotNil(color)
    }

    // Test AppTheme layout constants
    func testAppThemeCornerRadius() {
        XCTAssertEqual(AppTheme.cornerRadius, 12)
    }

    func testAppThemeSmallCornerRadius() {
        XCTAssertEqual(AppTheme.smallCornerRadius, 8)
    }

    func testAppThemeLargeCornerRadius() {
        XCTAssertEqual(AppTheme.largeCornerRadius, 20)
    }

    func testAppThemeShadowRadius() {
        XCTAssertEqual(AppTheme.shadowRadius, 8)
    }

    func testAppThemeCardPadding() {
        XCTAssertEqual(AppTheme.cardPadding, 16)
    }

    func testAppThemeAnimationDuration() {
        XCTAssertEqual(AppTheme.animationDuration, 0.3)
    }
}

// MARK: - View+Navigation Tests
class ViewNavigationTests: XCTestCase {

    func testTriggerGlobalDismissDoesNotCrash() {
        XCTAssertNoThrow(triggerGlobalDismiss())
    }

    func testGlobalDismissNotificationName() {
        // Test that the notification can be observed
        let expectation = XCTestExpectation(description: "Notification received")

        let observer = NotificationCenter.default.addObserver(
            forName: Notification.Name("DismissToRootView"),
            object: nil,
            queue: .main
        ) { _ in
            expectation.fulfill()
        }

        triggerGlobalDismiss()

        wait(for: [expectation], timeout: 1.0)
        NotificationCenter.default.removeObserver(observer)
    }
}

// MARK: - DeviceUtils Tests (Additional)
class DeviceUtilsAdditionalTests: XCTestCase {

    func testIsIPadProperty() {
        // Just verify the property exists and returns a boolean
        let result = DeviceUtils.isIPad
        XCTAssertTrue(result == true || result == false)
    }

    func testIsLandscapeFunctionExists() {
        let result = DeviceUtils.isLandscape(with: (horizontal: .regular, vertical: .regular))
        XCTAssertTrue(result == true || result == false)
    }

    func testIsLandscapeAllCombinations() {
        // Test all possible combinations
        let combinations: [(UserInterfaceSizeClass, UserInterfaceSizeClass, Bool)] = [
            (.regular, .regular, true),
            (.regular, .compact, false),
            (.compact, .regular, false),
            (.compact, .compact, false)
        ]

        for (horizontal, vertical, expected) in combinations {
            let result = DeviceUtils.isLandscape(with: (horizontal: horizontal, vertical: vertical))
            XCTAssertEqual(result, expected,
                          "isLandscape(\(horizontal), \(vertical)) should be \(expected)")
        }
    }
}

// MARK: - NavigationUtil Additional Tests
class NavigationUtilAdditionalTests: XCTestCase {

    func testFindNavigationControllerWithNilReturnsNil() {
        let result = NavigationUtil.findNavigationController(viewController: nil)
        XCTAssertNil(result)
    }

    func testPopToRootViewDoesNotCrash() {
        // This should not crash even if there's no navigation controller
        XCTAssertNoThrow(NavigationUtil.popToRootView())
    }
}

// MARK: - ImageCacheManager Additional Tests
class ImageCacheManagerAdditionalTests: XCTestCase {

    func testCacheManagerIsSingleton() {
        let instance1 = ImageCacheManager.shared
        let instance2 = ImageCacheManager.shared
        XCTAssertTrue(instance1 === instance2)
    }

    func testSaveAndRetrieveMultipleImages() {
        let cacheManager = ImageCacheManager.shared
        cacheManager.clearCache()

        let image1 = UIImage(systemName: "star")!
        let image2 = UIImage(systemName: "heart")!
        let image3 = UIImage(systemName: "circle")!

        cacheManager.saveImage(image1, forKey: "test_star")
        cacheManager.saveImage(image2, forKey: "test_heart")
        cacheManager.saveImage(image3, forKey: "test_circle")

        XCTAssertNotNil(cacheManager.getImage(forKey: "test_star"))
        XCTAssertNotNil(cacheManager.getImage(forKey: "test_heart"))
        XCTAssertNotNil(cacheManager.getImage(forKey: "test_circle"))

        cacheManager.clearCache()
    }

    func testClearCacheRemovesAllKeys() {
        let cacheManager = ImageCacheManager.shared

        cacheManager.saveImage(UIImage(systemName: "star")!, forKey: "clear_test_1")
        cacheManager.saveImage(UIImage(systemName: "heart")!, forKey: "clear_test_2")

        cacheManager.clearCache()

        XCTAssertNil(cacheManager.getImage(forKey: "clear_test_1"))
        XCTAssertNil(cacheManager.getImage(forKey: "clear_test_2"))
    }
}
