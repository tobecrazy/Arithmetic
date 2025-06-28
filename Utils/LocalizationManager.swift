import SwiftUI
import Combine

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_language")
            
            // Debug: Print language change
            #if DEBUG
            print("Language changed to: \(currentLanguage.rawValue)")
            #endif
            
            // Post notification on main thread to ensure UI updates
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
            }
            
            // Ensure the shared instance is also updated
            if self != LocalizationManager.shared {
                LocalizationManager.shared.currentLanguage = self.currentLanguage
            }
        }
    }
    
    enum Language: String, CaseIterable, Identifiable {
        case chinese = "zh-Hans"
        case english = "en"
        
        var id: String { self.rawValue }
        
        var displayName: String {
            switch self {
            case .chinese: return "中文"
            case .english: return "English"
            }
        }
    }
    
    init() {
        // 从UserDefaults读取已保存的语言设置，默认为中文
        let savedLanguage = UserDefaults.standard.string(forKey: "app_language") ?? Language.chinese.rawValue
        self.currentLanguage = Language(rawValue: savedLanguage) ?? .chinese
    }
    
    func switchLanguage(to language: Language) {
        self.currentLanguage = language
    }
}

// Add Equatable conformance for LocalizationManager
extension LocalizationManager: Equatable {
    static func == (lhs: LocalizationManager, rhs: LocalizationManager) -> Bool {
        return lhs === rhs // Compare object references
    }
}
