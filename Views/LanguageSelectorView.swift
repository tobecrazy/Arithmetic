import SwiftUI

struct LanguageSelectorView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("settings.language".localized)
                .font(.adaptiveHeadline())
                .padding(.bottom, 5)
            
            HStack {
                ForEach(LocalizationManager.Language.allCases) { language in
                    Button(action: {
                        localizationManager.switchLanguage(to: language)
                    }) {
                        Text(language.displayName)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                                    .fill(localizationManager.currentLanguage == language ? 
                                          Color.blue : Color.gray.opacity(0.2))
                            )
                            .foregroundColor(localizationManager.currentLanguage == language ? 
                                            Color.white : Color.primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 10)
                }
            }
        }
        .padding(.vertical)
    }
}

struct LanguageSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageSelectorView()
            .environmentObject(LocalizationManager())
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
