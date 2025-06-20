import Foundation

enum DifficultyLevel: String, CaseIterable, Identifiable {
    case level1 = "level1"
    case level2 = "level2"
    case level3 = "level3"
    case level4 = "level4"
    
    var id: String { self.rawValue }
    
    var localizedName: String {
        switch self {
        case .level1: return "difficulty.level1".localized
        case .level2: return "difficulty.level2".localized
        case .level3: return "difficulty.level3".localized
        case .level4: return "difficulty.level4".localized
        }
    }
    
    var range: ClosedRange<Int> {
        switch self {
        case .level1: return 1...10
        case .level2: return 1...20
        case .level3: return 1...50
        case .level4: return 1...100
        }
    }
}
