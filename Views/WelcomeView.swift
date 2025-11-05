import SwiftUI

struct WelcomeView: View {
    @State private var currentPage = 0
    @Binding var showWelcome: Bool
    
    var body: some View {
        NavigationView {
            TabView(selection: $currentPage) {
                // Page 1: App Introduction
                VStack(spacing: 20) {
                    Image(systemName: "figure.walk.arithmetic")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .padding()
                    
                    Text("welcome.title".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("welcome.intro".localized)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .tag(0)
                
                // Page 2: Difficulty Levels
                VStack(spacing: 20) {
                    Image(systemName: "number")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                        .padding()
                    
                    Text("welcome.levels.title".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(DifficultyLevel.allCases, id: \.self) { level in
                                HStack {
                                    Text(level.localizedName)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text(level.localizedDescription)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .tag(1)
                
                // Page 3: Main Features
                VStack(spacing: 20) {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                        .padding()
                    
                    Text("welcome.features.title".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(spacing: 15) {
                        FeatureRow(icon: "gamecontroller", title: "welcome.feature.game.title".localized, description: "welcome.feature.game.desc".localized)
                        FeatureRow(icon: "text.book.closed", title: "welcome.feature.solutions.title".localized, description: "welcome.feature.solutions.desc".localized)
                        FeatureRow(icon: "doc.text.magnifyingglass", title: "welcome.feature.wrongquestions.title".localized, description: "welcome.feature.wrongquestions.desc".localized)
                        FeatureRow(icon: "multiply", title: "welcome.feature.multiplication.title".localized, description: "welcome.feature.multiplication.desc".localized)
                    }
                    .padding(.horizontal)
                }
                .tag(2)
                
                // Page 4: How to Use
                VStack(spacing: 20) {
                    Image(systemName: "hand.tap")
                        .font(.system(size: 80))
                        .foregroundColor(.purple)
                        .padding()
                    
                    Text("welcome.howto.title".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(spacing: 15) {
                        HowToRow(number: "1", title: "welcome.howto.step1.title".localized, description: "welcome.howto.step1.desc".localized)
                        HowToRow(number: "2", title: "welcome.howto.step2.title".localized, description: "welcome.howto.step2.desc".localized)
                        HowToRow(number: "3", title: "welcome.howto.step3.title".localized, description: "welcome.howto.step3.desc".localized)
                    }
                    .padding(.horizontal)
                }
                .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            .navigationBarItems(
                trailing: Button(action: {
                    showWelcome = false
                }) {
                    Text("welcome.start_button".localized)
                        .fontWeight(.bold)
                }
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct HowToRow: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Text(number)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color.blue)
                .cornerRadius(15)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

extension DifficultyLevel {
    var localizedDescription: String {
        switch self {
        case .level1:
            return "welcome.level1.desc".localized
        case .level2:
            return "welcome.level2.desc".localized
        case .level3:
            return "welcome.level3.desc".localized
        case .level4:
            return "welcome.level4.desc".localized
        case .level5:
            return "welcome.level5.desc".localized
        case .level6:
            return "welcome.level6.desc".localized
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        @State var showWelcome = true
        return WelcomeView(showWelcome: $showWelcome)
            .environmentObject(LocalizationManager())
    }
}