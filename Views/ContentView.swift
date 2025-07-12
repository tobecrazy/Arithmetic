import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedDifficulty: DifficultyLevel = .level1
    @State private var timeInMinutes: Int = 5
    @State private var navigateToGame = false
    @State private var navigateToWrongQuestions = false
    @State private var navigateToMultiplicationTable = false
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    // 动态网格列数计算
    private var gridColumns: [GridItem] {
        let levelCount = DifficultyLevel.allCases.count
        let minItemWidth: CGFloat = 150
        let screenWidth = UIScreen.main.bounds.width * 0.5 // iPad横屏左侧区域
        let maxColumns = max(1, Int(screenWidth / minItemWidth))
        let optimalColumns = min(maxColumns, 3) // 最多3列，保持美观
        
        return Array(repeating: GridItem(.flexible()), count: optimalColumns)
    }
    
    // 难度级别卡片组件
    @ViewBuilder
    private func difficultyLevelCard(for level: DifficultyLevel) -> some View {
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
            .frame(maxWidth: .infinity)
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
    
    // iPad横屏专用布局
    var iPadLandscapeLayout: some View {
        NavigationView {
            HStack(spacing: 0) {
                // 左侧：标题和难度选择
                VStack {
                    Text("app.title".localized)
                        .font(.adaptiveTitle())
                        .padding()
                    
                    // 难度选择 (动态网格，支持滚动)
                    ScrollView {
                        LazyVGrid(columns: gridColumns, spacing: 20) {
                            ForEach(DifficultyLevel.allCases) { level in
                                difficultyLevelCard(for: level)
                            }
                        }
                        .padding()
                    }
                    
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
                        
                        // 9×9乘法表按钮
                        Button(action: {
                            navigateToMultiplicationTable = true
                        }) {
                            Text("button.multiplication_table".localized)
                                .font(.adaptiveBody())
                                .padding()
                                .frame(width: 200)
                                .background(Color.green)
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
                        
                        NavigationLink(
                            destination: MultiplicationTableView()
                                .environmentObject(localizationManager),
                            isActive: $navigateToMultiplicationTable
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
                    
                    // 难度选择
                    LazyVStack(alignment: .leading, spacing: 10) {
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
                    
                    // 9×9乘法表按钮
                    Button(action: {
                        navigateToMultiplicationTable = true
                    }) {
                        Text("button.multiplication_table".localized)
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
                    
                    NavigationLink(
                        destination: MultiplicationTableView()
                            .environmentObject(localizationManager),
                        isActive: $navigateToMultiplicationTable
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
