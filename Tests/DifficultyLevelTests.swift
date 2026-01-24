import XCTest
@testable import Arithmetic

// MARK: - DifficultyLevel Tests
class DifficultyLevelTests: XCTestCase {

    // MARK: - Basic Properties Tests

    func testAllCasesCount() {
        XCTAssertEqual(DifficultyLevel.allCases.count, 6)
    }

    func testRawValues() {
        XCTAssertEqual(DifficultyLevel.level1.rawValue, "level1")
        XCTAssertEqual(DifficultyLevel.level2.rawValue, "level2")
        XCTAssertEqual(DifficultyLevel.level3.rawValue, "level3")
        XCTAssertEqual(DifficultyLevel.level4.rawValue, "level4")
        XCTAssertEqual(DifficultyLevel.level5.rawValue, "level5")
        XCTAssertEqual(DifficultyLevel.level6.rawValue, "level6")
    }

    func testIdentifiable() {
        XCTAssertEqual(DifficultyLevel.level1.id, "level1")
        XCTAssertEqual(DifficultyLevel.level2.id, "level2")
        XCTAssertEqual(DifficultyLevel.level3.id, "level3")
        XCTAssertEqual(DifficultyLevel.level4.id, "level4")
        XCTAssertEqual(DifficultyLevel.level5.id, "level5")
        XCTAssertEqual(DifficultyLevel.level6.id, "level6")
    }

    // MARK: - Range Tests

    func testLevel1Range() {
        let range = DifficultyLevel.level1.range
        XCTAssertEqual(range.lowerBound, 1)
        XCTAssertEqual(range.upperBound, 10)
    }

    func testLevel2Range() {
        let range = DifficultyLevel.level2.range
        XCTAssertEqual(range.lowerBound, 1)
        XCTAssertEqual(range.upperBound, 20)
    }

    func testLevel3Range() {
        let range = DifficultyLevel.level3.range
        XCTAssertEqual(range.lowerBound, 1)
        XCTAssertEqual(range.upperBound, 50)
    }

    func testLevel4Range() {
        let range = DifficultyLevel.level4.range
        XCTAssertEqual(range.lowerBound, 1)
        XCTAssertEqual(range.upperBound, 10)
    }

    func testLevel5Range() {
        let range = DifficultyLevel.level5.range
        XCTAssertEqual(range.lowerBound, 1)
        XCTAssertEqual(range.upperBound, 20)
    }

    func testLevel6Range() {
        let range = DifficultyLevel.level6.range
        XCTAssertEqual(range.lowerBound, 1)
        XCTAssertEqual(range.upperBound, 100)
    }

    // MARK: - Supported Operations Tests

    func testLevel1SupportedOperations() {
        let ops = DifficultyLevel.level1.supportedOperations
        XCTAssertEqual(ops.count, 2)
        XCTAssertTrue(ops.contains(.addition))
        XCTAssertTrue(ops.contains(.subtraction))
        XCTAssertFalse(ops.contains(.multiplication))
        XCTAssertFalse(ops.contains(.division))
    }

    func testLevel2SupportedOperations() {
        let ops = DifficultyLevel.level2.supportedOperations
        XCTAssertEqual(ops.count, 2)
        XCTAssertTrue(ops.contains(.addition))
        XCTAssertTrue(ops.contains(.subtraction))
    }

    func testLevel3SupportedOperations() {
        let ops = DifficultyLevel.level3.supportedOperations
        XCTAssertEqual(ops.count, 2)
        XCTAssertTrue(ops.contains(.addition))
        XCTAssertTrue(ops.contains(.subtraction))
    }

    func testLevel4SupportedOperations() {
        let ops = DifficultyLevel.level4.supportedOperations
        XCTAssertEqual(ops.count, 2)
        XCTAssertTrue(ops.contains(.multiplication))
        XCTAssertTrue(ops.contains(.division))
        XCTAssertFalse(ops.contains(.addition))
        XCTAssertFalse(ops.contains(.subtraction))
    }

    func testLevel5SupportedOperations() {
        let ops = DifficultyLevel.level5.supportedOperations
        XCTAssertEqual(ops.count, 2)
        XCTAssertTrue(ops.contains(.multiplication))
        XCTAssertTrue(ops.contains(.division))
    }

    func testLevel6SupportedOperations() {
        let ops = DifficultyLevel.level6.supportedOperations
        XCTAssertEqual(ops.count, 4)
        XCTAssertTrue(ops.contains(.addition))
        XCTAssertTrue(ops.contains(.subtraction))
        XCTAssertTrue(ops.contains(.multiplication))
        XCTAssertTrue(ops.contains(.division))
    }

    // MARK: - Question Count Tests

    func testLevel1QuestionCount() {
        XCTAssertEqual(DifficultyLevel.level1.questionCount, 20)
    }

    func testLevel2QuestionCount() {
        XCTAssertEqual(DifficultyLevel.level2.questionCount, 25)
    }

    func testLevel3QuestionCount() {
        XCTAssertEqual(DifficultyLevel.level3.questionCount, 50)
    }

    func testLevel4QuestionCount() {
        XCTAssertEqual(DifficultyLevel.level4.questionCount, 20)
    }

    func testLevel5QuestionCount() {
        XCTAssertEqual(DifficultyLevel.level5.questionCount, 25)
    }

    func testLevel6QuestionCount() {
        XCTAssertEqual(DifficultyLevel.level6.questionCount, 100)
    }

    // MARK: - Points Per Question Tests

    func testLevel1PointsPerQuestion() {
        XCTAssertEqual(DifficultyLevel.level1.pointsPerQuestion, 5)
    }

    func testLevel2PointsPerQuestion() {
        XCTAssertEqual(DifficultyLevel.level2.pointsPerQuestion, 4)
    }

    func testLevel3PointsPerQuestion() {
        XCTAssertEqual(DifficultyLevel.level3.pointsPerQuestion, 2)
    }

    func testLevel4PointsPerQuestion() {
        XCTAssertEqual(DifficultyLevel.level4.pointsPerQuestion, 5)
    }

    func testLevel5PointsPerQuestion() {
        XCTAssertEqual(DifficultyLevel.level5.pointsPerQuestion, 4)
    }

    func testLevel6PointsPerQuestion() {
        XCTAssertEqual(DifficultyLevel.level6.pointsPerQuestion, 1)
    }

    // MARK: - Total Points Validation Tests

    func testTotalPointsEqual100ForAllLevels() {
        for level in DifficultyLevel.allCases {
            let totalPoints = level.questionCount * level.pointsPerQuestion
            XCTAssertEqual(totalPoints, 100, "Total points for \(level.rawValue) should be 100, got \(totalPoints)")
        }
    }

    // MARK: - Localized Name Tests

    func testLocalizedNameNotEmpty() {
        for level in DifficultyLevel.allCases {
            XCTAssertFalse(level.localizedName.isEmpty, "Localized name for \(level.rawValue) should not be empty")
        }
    }

    func testLocalizedNameContainsLevel() {
        // Each localized name should contain some indication of the level
        for level in DifficultyLevel.allCases {
            let name = level.localizedName.lowercased()
            // The localized name should contain either "level" or a number or Chinese characters
            XCTAssertTrue(
                name.contains("level") || name.contains("1") || name.contains("2") ||
                name.contains("3") || name.contains("4") || name.contains("5") ||
                name.contains("6") || name.contains("等级"),
                "Localized name '\(level.localizedName)' should contain level indicator"
            )
        }
    }

    // MARK: - Operations Progression Tests

    func testOperationsProgressionFromAddSubToMulDiv() {
        // Levels 1-3 have addition/subtraction
        for level in [DifficultyLevel.level1, .level2, .level3] {
            XCTAssertTrue(level.supportedOperations.contains(.addition))
            XCTAssertTrue(level.supportedOperations.contains(.subtraction))
        }

        // Levels 4-5 have multiplication/division
        for level in [DifficultyLevel.level4, .level5] {
            XCTAssertTrue(level.supportedOperations.contains(.multiplication))
            XCTAssertTrue(level.supportedOperations.contains(.division))
        }

        // Level 6 has all operations
        XCTAssertEqual(DifficultyLevel.level6.supportedOperations.count, 4)
    }

    // MARK: - Range Progression Tests

    func testRangeProgressesWithDifficulty() {
        // Addition/subtraction levels should progress: 10 -> 20 -> 50
        XCTAssertLessThan(DifficultyLevel.level1.range.upperBound, DifficultyLevel.level2.range.upperBound)
        XCTAssertLessThan(DifficultyLevel.level2.range.upperBound, DifficultyLevel.level3.range.upperBound)

        // Multiplication/division levels should progress: 10 -> 20
        XCTAssertLessThan(DifficultyLevel.level4.range.upperBound, DifficultyLevel.level5.range.upperBound)

        // Level 6 should have the largest range
        XCTAssertEqual(DifficultyLevel.level6.range.upperBound, 100)
    }
}
