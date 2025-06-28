import Foundation

extension String {
    var localized: String {
        let localizationManager = LocalizationManager.shared
        guard let path = Bundle.main.path(forResource: localizationManager.currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            print("Warning: Could not load localization bundle for language: \(localizationManager.currentLanguage.rawValue)")
            return NSLocalizedString(self, comment: "")
        }
        
        let localizedString = NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
        
        // Debug: Print localization info
        #if DEBUG
        if localizedString == self || localizedString.isEmpty {
            print("Localization missing for key: '\(self)' in language: \(localizationManager.currentLanguage.rawValue)")
        }
        #endif
        
        return localizedString
    }
    
    func localizedFormat(_ arguments: CVarArg...) -> String {
        let localizedTemplate = self.localized
        return String(format: localizedTemplate, arguments: arguments)
    }
}
