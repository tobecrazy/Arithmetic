import Foundation

// MARK: - Three Number Question Generation
extension QuestionGenerator {
    /// Generates a three-number arithmetic question
    static func generateThreeNumberQuestion(difficultyLevel: DifficultyLevel) -> Question {
        // For small ranges with division (like level4: 1-10), use fewer attempts and simpler logic
        let maxAttempts = difficultyLevel.range.upperBound <= 10 ? 10 : 20
        var attempts = 0

        while attempts < maxAttempts {
            if let question = attemptGenerateThreeNumberQuestion(difficultyLevel: difficultyLevel) {
                return question
            }
            attempts += 1
        }

        // Fallback: generate simple addition if all attempts failed
        return generateFallbackThreeNumberQuestion(difficultyLevel: difficultyLevel)
    }

    // MARK: - Private Helper Methods

    private static func attemptGenerateThreeNumberQuestion(difficultyLevel: DifficultyLevel) -> Question? {
        var numbers = generateInitialNumbers(for: difficultyLevel)
        let operations = selectOperations(for: difficultyLevel)

        // Check for repetitive patterns early
        if hasRepetitivePattern(num1: numbers[0], num2: numbers[1], num3: numbers[2], op1: operations[0], op2: operations[1]) {
            return nil
        }

        // Adjust numbers for division operations
        if operations.contains(.division) {
            numbers = ensureDivisionSafety(numbers: numbers, operations: operations, range: difficultyLevel.range)
        }

        // Validate final result
        let question = Question(number1: numbers[0], number2: numbers[1], number3: numbers[2], operation1: operations[0], operation2: operations[1])

        guard question.isValid() && question.correctAnswer > 1 && question.correctAnswer <= difficultyLevel.range.upperBound else {
            return nil
        }

        return question
    }

    /// Generates initial numbers for three-number operations
    private static func generateInitialNumbers(for difficultyLevel: DifficultyLevel) -> [Int] {
        let upperBound = difficultyLevel.range.upperBound
        let maxNumberForOperation = max(2, upperBound / 3)

        let num1 = safeRandom(in: Constants.minNumberValue...min(maxNumberForOperation, upperBound))
        let num2 = safeRandom(in: Constants.minNumberValue...min(maxNumberForOperation, upperBound))
        let num3 = safeRandom(in: Constants.minNumberValue...min(maxNumberForOperation, upperBound))

        return [num1, num2, num3]
    }

    /// Selects appropriate operations based on difficulty level
    private static func selectOperations(for difficultyLevel: DifficultyLevel) -> [Question.Operation] {
        let supportedOperations = difficultyLevel.supportedOperations

        switch difficultyLevel {
        case .level6:
            // Mixed operations - any combination
            let op1 = supportedOperations.randomElement() ?? .addition
            let op2 = supportedOperations.randomElement() ?? .addition
            return [op1, op2]

        case .level4, .level5:
            // Multiplication and division only
            // For level4 (small range), prefer multiplication to avoid division edge cases
            if difficultyLevel == .level4 {
                // 70% multiplication, 30% division for level4
                let useDivision = Double.random(in: 0...1) < 0.3
                if useDivision {
                    // Only use division in one operation, not both
                    let firstIsDivision = Bool.random()
                    return firstIsDivision ? [.division, .multiplication] : [.multiplication, .division]
                } else {
                    return [.multiplication, .multiplication]
                }
            } else {
                // Level5 can handle more division
                let op1 = supportedOperations.randomElement() ?? .multiplication
                let op2 = supportedOperations.randomElement() ?? .multiplication
                return [op1, op2]
            }

        default:
            // Addition and subtraction only
            let op1 = Double.random(in: 0...1) < 0.5 ? Question.Operation.addition : .subtraction
            let op2 = Double.random(in: 0...1) < 0.5 ? Question.Operation.addition : .subtraction
            return [op1, op2]
        }
    }

    /// Ensures division operations produce integer results
    private static func ensureDivisionSafety(numbers: [Int], operations: [Question.Operation], range: ClosedRange<Int>) -> [Int] {
        var adjustedNumbers = numbers
        let op1 = operations[0]
        let op2 = operations[1]

        // Handle first operation division
        if op1 == .division {
            adjustedNumbers = adjustDivisionForFirstOperation(numbers: adjustedNumbers, range: range)
        }

        // Handle second operation division with precedence consideration
        if op2 == .division {
            adjustedNumbers = adjustDivisionForSecondOperation(numbers: adjustedNumbers, operations: operations, range: range)
        }

        return adjustedNumbers
    }

    /// Adjusts numbers when first operation is division
    private static func adjustDivisionForFirstOperation(numbers: [Int], range: ClosedRange<Int>) -> [Int] {
        var adjusted = numbers
        let divisor = max(2, adjusted[1])
        let quotient = max(2, adjusted[0] / divisor)

        // Ensure integer division
        adjusted[0] = quotient * divisor
        adjusted[1] = divisor

        // Validate range
        if adjusted[0] > range.upperBound {
            // For small ranges, use simpler division
            if range.upperBound <= 10 {
                // Use small, safe divisors for small ranges
                adjusted[1] = min(divisor, 3)
                adjusted[0] = min(quotient * adjusted[1], range.upperBound)
            } else {
                let maxNewDivisor = max(2, range.upperBound / quotient)
                let newDivisor = max(2, min(maxNewDivisor, quotient))
                adjusted[0] = quotient * newDivisor
                adjusted[1] = newDivisor
            }
        }

        return adjusted
    }

    /// Adjusts numbers when second operation is division
    private static func adjustDivisionForSecondOperation(numbers: [Int], operations: [Question.Operation], range: ClosedRange<Int>) -> [Int] {
        var adjusted = numbers
        let op1 = operations[0]
        let op2 = operations[1]

        if op1.precedence < op2.precedence {
            // Second operation has higher precedence: A + (B ÷ C)
            let divisor = max(2, adjusted[2])
            let quotient = max(2, adjusted[1] / divisor)
            adjusted[1] = quotient * divisor
            adjusted[2] = divisor
        } else {
            // Left-to-right evaluation: (A op1 B) ÷ C
            let intermediateResult = calculateIntermediateResult(num1: adjusted[0], num2: adjusted[1], operation: op1)

            if intermediateResult > 0 {
                // Find a valid divisor
                let divisors = findDivisors(of: intermediateResult, maxDivisor: min(10, intermediateResult))
                if let divisor = divisors.randomElement() {
                    adjusted[2] = divisor
                } else {
                    // No valid divisor found, change operation to addition
                    adjusted[2] = Constants.minNumberValue
                }
            }
        }

        return adjusted
    }

    /// Calculates intermediate result for operation precedence
    private static func calculateIntermediateResult(num1: Int, num2: Int, operation: Question.Operation) -> Int {
        switch operation {
        case .addition: return num1 + num2
        case .subtraction: return num1 - num2
        case .multiplication: return num1 * num2
        case .division: return num2 != 0 ? num1 / num2 : 0
        }
    }

    /// Finds all divisors of a number within a range
    private static func findDivisors(of number: Int, maxDivisor: Int) -> [Int] {
        var divisors: [Int] = []
        let absNumber = abs(number)

        for i in 2...min(maxDivisor, absNumber) {
            if absNumber % i == 0 {
                divisors.append(i)
            }
        }

        return divisors
    }

    /// Generates a simple fallback question when generation fails
    private static func generateFallbackThreeNumberQuestion(difficultyLevel: DifficultyLevel) -> Question {
        let maxNum = min(10, difficultyLevel.range.upperBound / 3)
        let minNum = max(2, difficultyLevel.range.lowerBound)

        let num1 = safeRandom(in: minNum...maxNum)
        let num2 = safeRandom(in: minNum...maxNum)
        let num3 = safeRandom(in: minNum...maxNum)

        // For small ranges (like level4: 1-10), use multiplication only to avoid edge cases
        if difficultyLevel.range.upperBound <= 10 && difficultyLevel.supportedOperations.contains(.multiplication) {
            return Question(number1: num1, number2: num2, number3: num3, operation1: .multiplication, operation2: .multiplication)
        }

        return Question(number1: num1, number2: num2, number3: num3, operation1: .addition, operation2: .addition)
    }
}
