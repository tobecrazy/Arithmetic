import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedDifficulty: DifficultyLevel = .level1
    @State private var timeInMinutes: Int = 5
    @State private var navigateToGame = false
    @State private var navigateToWrongQuestions = false
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    // iPad横屏专用布局
    var iPadLandscapeLayout: some View {
        NavigationView {
            HStack(spacing: 0) {
                // 左侧：标题和难度选择
                VStack {
                    Text("app.title".localized)
                        .font(.adaptiveTitle())
                        .padding()
                    
                    // 难度选择 (2x2网格)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(DifficultyLevel.allCases) { level in
                            Button(action: {
                                selectedDifficulty = level
                            }) {
                                VStack {
                                    Text(level.localizedName)
                                        .font(.adaptiveBody())
                                        .multilineTextAlignment(.center)
                                    
                                    if selectedDifficulty == level {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                            .padding(.top, 5)
                                    }
                                }
                                .padding()
                                .frame(minHeight: 100)
                                .background(
                                    RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                                        .fill(selectedDifficulty == level ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                                                .stroke(selectedDifficulty == level ? Color.blue : Color.clear, lineWidth: 2)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width * 0.5)
                .background(Color.gray.opacity(0.05))
                
                // 右侧：时间设置、语言选择和开始按钮
                VStack {
                    Spacer()
                    
                    // 时间设置
                    VStack(alignment: .leading) {
                        Text("settings.time".localized)
                            .font(.adaptiveHeadline())
                        
                        HStack {
                            Text("3")
                            Slider(value: Binding(
                                get: { Double(timeInMinutes) },
                                set: { timeInMinutes = Int($0) }
                            ), in: 3...30, step: 1)
                            Text("30")
                        }
                        Text("\(timeInMinutes) \("settings.minutes".localized)")
                            .font(.adaptiveBody())
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                            .fill(Color.gray.opacity(0.1))
                    )
                    .padding()
                    
                    // 语言选择器
                    LanguageSelectorView()
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                                .fill(Color.gray.opacity(0.1))
                        )
                        .padding()
                    
                    Spacer()
                    
                    // 开始按钮
                    Button(action: {
                        navigateToGame = true
                    }) {
                        Text("button.start".localized)
                            .font(.adaptiveHeadline())
                            .padding()
                            .frame(width: 200)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(.adaptiveCornerRadius)
                    }
                    .padding(.bottom, 20)
                    
                    // 错题集按钮
                    Button(action: {
                        navigateToWrongQuestions = true
                    }) {
                        Text("button.wrong_questions".localized)
                            .font(.adaptiveBody())
                            .padding()
                            .frame(width: 200)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(.adaptiveCornerRadius)
                    }
                    .padding(.bottom, 50)
                    
                    NavigationLink(
                        destination: GameView(viewModel: GameViewModel(difficultyLevel: selectedDifficulty, timeInMinutes: timeInMinutes))
                            .environmentObject(localizationManager),
                        isActive: $navigateToGame
                    ) {
                        EmptyView()
                    }
                    
                    NavigationLink(
                        destination: WrongQuestionsView()
                            .environmentObject(localizationManager),
                        isActive: $navigateToWrongQuestions
                    ) {
                        EmptyView()
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.5)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // 默认布局（iPhone和iPad竖屏）
    var defaultLayout: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("app.title".localized)
                    .font(.adaptiveTitle())
                    .padding()
                
                // 难度选择
                VStack(alignment: .leading) {
                    ForEach(DifficultyLevel.allCases) { level in
                        Button(action: {
                            selectedDifficulty = level
                        }) {
                            HStack {
                                Text(level.localizedName)
                                    .font(.adaptiveBody())
                                Spacer()
                                if selectedDifficulty == level {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                                    .fill(Color.gray.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                
                // 时间设置
                VStack(alignment: .leading) {
                    Text("settings.time".localized)
                        .font(.adaptiveHeadline())
                    
                    HStack {
                        Text("3")
                        Slider(value: Binding(
                            get: { Double(timeInMinutes) },
                            set: { timeInMinutes = Int($0) }
                        ), in: 3...30, step: 1)
                        Text("30")
                    }
                    Text("\(timeInMinutes) \("settings.minutes".localized)")
                        .font(.adaptiveBody())
                }
                .padding()
                
                // 语言选择器
                LanguageSelectorView()
                    .padding(.horizontal)
                
                // 开始按钮
                Button(action: {
                    navigateToGame = true
                }) {
                    Text("button.start".localized)
                        .font(.adaptiveHeadline())
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(.adaptiveCornerRadius)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // 错题集按钮
                Button(action: {
                    navigateToWrongQuestions = true
                }) {
                    Text("button.wrong_questions".localized)
                        .font(.adaptiveBody())
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(.adaptiveCornerRadius)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                NavigationLink(
                    destination: GameView(viewModel: GameViewModel(difficultyLevel: selectedDifficulty, timeInMinutes: timeInMinutes))
                        .environmentObject(localizationManager),
                    isActive: $navigateToGame
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: WrongQuestionsView()
                        .environmentObject(localizationManager),
                    isActive: $navigateToWrongQuestions
                ) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var body: some View {
        // 根据设备类型和方向选择不同布局
        if DeviceUtils.isIPad && DeviceUtils.isLandscape(with: (horizontalSizeClass, verticalSizeClass)) {
            iPadLandscapeLayout
        } else {
            defaultLayout
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LocalizationManager())
    }
}
