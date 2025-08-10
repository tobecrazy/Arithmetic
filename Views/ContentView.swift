import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedDifficulty: DifficultyLevel = .level1
    @State private var timeInMinutes: Int = 5
    @State private var navigateToGame = false
    @State private var navigateToWrongQuestions = false
    @State private var navigateToOtherOptions = false
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    // Computed properties for navigation destinations
    private var gameDestination: some View {
        GameView(viewModel: GameViewModel(difficultyLevel: selectedDifficulty, timeInMinutes: timeInMinutes))
            .environmentObject(localizationManager)
    }
    
    private var wrongQuestionsDestination: some View {
        WrongQuestionsView()
            .environmentObject(localizationManager)
    }
    
    private var otherOptionsDestination: some View {
        OtherOptionsView()
            .environmentObject(localizationManager)
    }
    
    // 难度选择器组件
    @ViewBuilder
    private func difficultyPicker() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("difficulty.level".localized)
                .font(.adaptiveHeadline())
            
            Picker("difficulty.level".localized, selection: $selectedDifficulty) {
                ForEach(DifficultyLevel.allCases) { level in
                    Text(level.localizedName)
                        .tag(level)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                    .fill(Color.gray.opacity(0.1))
            )
        }
    }
    
    // iPad横屏专用布局
    var iPadLandscapeLayout: some View {
        NavigationView {
            HStack(spacing: 0) {
                // 左侧：标题和难度选择
                VStack {
                    Text("app.title".localized)
                        .font(.adaptiveTitle())
                        .padding()
                    
                    // 难度选择器
                    difficultyPicker()
                        .padding()
                    
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width * 0.5)
                .background(Color.gray.opacity(0.05))
                
                // 右侧：时间设置、语言选择和开始按钮 (添加滚动支持)
                ScrollView {
                    VStack {
                        Spacer(minLength: 20)
                        
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
                        
                        Spacer(minLength: 30)
                        
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
                        .padding(.bottom, 10)
                        
                        // 其他选项按钮
                        Button(action: {
                            navigateToOtherOptions = true
                        }) {
                            Text("button.other_options".localized)
                                .font(.adaptiveBody())
                                .padding()
                                .frame(width: 200)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(.adaptiveCornerRadius)
                        }
                        .padding(.bottom, 50)
                        
                        // Navigation Links
                        NavigationLink(
                            destination: gameDestination,
                            isActive: $navigateToGame
                        ) {
                            EmptyView()
                        }
                        
                        NavigationLink(
                            destination: wrongQuestionsDestination,
                            isActive: $navigateToWrongQuestions
                        ) {
                            EmptyView()
                        }
                        
                        NavigationLink(
                            destination: otherOptionsDestination,
                            isActive: $navigateToOtherOptions
                        ) {
                            EmptyView()
                        }
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
            ScrollView {
                VStack(spacing: 20) {
                    Text("app.title".localized)
                        .font(.adaptiveTitle())
                        .padding()
                    
                    // 难度选择器
                    difficultyPicker()
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
                    .background(
                        RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                            .fill(Color.gray.opacity(0.1))
                    )
                    .padding(.horizontal)
                    
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
                    
                    // 其他选项按钮
                    Button(action: {
                        navigateToOtherOptions = true
                    }) {
                        Text("button.other_options".localized)
                            .font(.adaptiveBody())
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(.adaptiveCornerRadius)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 30) // 添加底部间距
                    
                    // Navigation Links
                    NavigationLink(
                        destination: gameDestination,
                        isActive: $navigateToGame
                    ) {
                        EmptyView()
                    }
                    
                    NavigationLink(
                        destination: wrongQuestionsDestination,
                        isActive: $navigateToWrongQuestions
                    ) {
                        EmptyView()
                    }
                    
                    NavigationLink(
                        destination: otherOptionsDestination,
                        isActive: $navigateToOtherOptions
                    ) {
                        EmptyView()
                    }
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
