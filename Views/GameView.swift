import SwiftUI
import Combine

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var userInput: String = ""
    @State private var showingAlert = false
    @State private var showingPauseAlert = false
    @State private var navigateToResults = false
    @State private var currentTime: Int = 0 // Local state to track time for UI updates
    @State private var hasAppeared = false // Track if view has appeared before
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    // 创建一个每秒触发一次的计时器发布者
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        // 根据设备类型和方向选择不同布局
        if DeviceUtils.isIPad && DeviceUtils.isLandscape(with: (horizontalSizeClass, verticalSizeClass)) {
            iPadLandscapeLayout
        } else {
            defaultLayout
        }
    }
    
    // 默认布局（iPhone和iPad竖屏）
    var defaultLayout: some View {
        ZStack {
            VStack {
                // 顶部信息栏
                VStack(spacing: 0) {
                    HStack {
                        // 剩余时间
                        VStack(alignment: .leading) {
                            Text("game.time".localized)
                                .font(.footnote)
                            Text(viewModel.gameState.timeRemainingText)
                                .font(.adaptiveHeadline())
                                .foregroundColor(.blue)
                                .id(currentTime) // Use local state to force refresh
                        }
                        
                        Spacer()
                        
                        // 当前进度
                        VStack {
                            Text(viewModel.gameState.progressText)
                                .font(.adaptiveBody())
                        }
                        
                        Spacer()
                        
                        // 当前得分
                        VStack(alignment: .trailing) {
                            Text("game.score".localized)
                                .font(.footnote)
                            Text("\(viewModel.gameState.score)")
                                .font(.adaptiveHeadline())
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    
                    // 暂停状态提示
                    if viewModel.gameState.isPaused {
                        HStack {
                            Text("game.paused".localized)
                                .font(.adaptiveHeadline())
                                .foregroundColor(.orange)
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.resumeGame()
                            }) {
                                Text("game.resume".localized)
                                    .font(.adaptiveBody())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(.adaptiveCornerRadius)
                            }
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                    }
                    
                    // 保存进度成功/失败提示
                    if viewModel.showSaveProgressSuccess {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("game.save_success".localized)
                                .font(.adaptiveBody())
                                .foregroundColor(.green)
                            Spacer()
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                    } else if viewModel.showSaveProgressError {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text("game.save_error".localized)
                                .font(.adaptiveBody())
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                    }
                }
                
                Spacer()
                
                // 题目显示
                if viewModel.gameState.questions.count > viewModel.gameState.currentQuestionIndex {
                    let currentQuestion = viewModel.gameState.questions[viewModel.gameState.currentQuestionIndex]
                    
                    Text(currentQuestion.questionText)
                        .font(.system(size: 40, weight: .bold))
                        .padding()
                    
                    // 答案反馈
                    if viewModel.gameState.showingCorrectAnswer {
                        VStack {
                            Text("game.wrong".localized)
                                .foregroundColor(.red)
                                .font(.adaptiveHeadline())
                            
                            Text("game.correct_answer".localizedFormat(String(currentQuestion.correctAnswer)))
                                .foregroundColor(.blue)
                                .font(.adaptiveBody())
                            
                            // 添加解析按钮
                            Button(action: {
                                viewModel.showSolutionSteps.toggle()
                            }) {
                                Text(viewModel.showSolutionSteps ? "button.hide_solution".localized : "button.show_solution".localized)
                                    .font(.adaptiveBody())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(.adaptiveCornerRadius)
                            }
                            .padding(.top, 5)
                            
                            // 显示解析内容
                            if viewModel.showSolutionSteps {
                                VStack(spacing: 0) {
                                    // 解析内容标题栏
                                    HStack {
                                        Text("solution.content".localized)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Image(systemName: "scroll")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.top, 8)
                                    
                                    // 解析内容区域
                                    ScrollView(.vertical, showsIndicators: true) {
                                        Text(currentQuestion.getSolutionSteps(for: viewModel.gameState.difficultyLevel))
                                            .font(.footnote)
                                            .lineSpacing(2)
                                            .padding(12)
                                            .background(Color.yellow.opacity(0.1))
                                            .cornerRadius(8)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 6) // 内部padding，为滚动条留出空间
                                    }
                                    .frame(height: calculateGameSolutionHeight())
                                    .padding(.horizontal, 10) // 左右两端10px padding
                                    .padding(.bottom, 8)
                                }
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                            
                            // Next Question button
                            Button(action: {
                                viewModel.moveToNextQuestion()
                            }) {
                                Text("button.next_question".localized)
                                    .font(.adaptiveHeadline())
                                    .padding()
                                    .frame(width: 200)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(.adaptiveCornerRadius)
                            }
                            .id(UUID()) // Force view refresh
                            .padding(.top, 10)
                        }
                        .padding()
                    } else if viewModel.gameState.isCorrect {
                        Text("game.correct".localized)
                            .foregroundColor(.green)
                            .font(.adaptiveHeadline())
                            .padding()
                    }
                    
                    // 答案输入框
                    HStack {
                        TextField("", text: $userInput)
                            .keyboardType(.numberPad)
                            .font(.adaptiveHeadline())
                            .multilineTextAlignment(.center)
                            .frame(width: 100)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(.adaptiveCornerRadius)
                            .disabled(viewModel.gameState.showingCorrectAnswer)
                            .onReceive(Just(userInput)) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    self.userInput = filtered
                                }
                            }
                    }
                    .padding()
                    
                    // 提交按钮
                    Button(action: submitAnswer) {
                        Text("game.submit".localized)
                            .font(.adaptiveHeadline())
                            .padding()
                            .frame(width: 200)
                            .background(userInput.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(.adaptiveCornerRadius)
                    }
                    .disabled(userInput.isEmpty || viewModel.gameState.showingCorrectAnswer)
                    .padding()
                }
                
                Spacer()
                
                // 底部按钮
                VStack(spacing: 0) {
                    // 暂停和保存按钮
                    HStack {
                        // 暂停按钮
                        Button(action: {
                            if !viewModel.gameState.pauseUsed {
                                showingPauseAlert = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "pause.circle")
                                Text("button.pause".localized)
                            }
                            .foregroundColor(viewModel.gameState.pauseUsed ? .gray : .orange)
                        }
                        .disabled(viewModel.gameState.pauseUsed || viewModel.gameState.isPaused)
                        .padding(.horizontal)
                        .alert(isPresented: $showingPauseAlert) {
                            Alert(
                                title: Text("alert.pause_title".localized),
                                message: Text("alert.pause_message".localized),
                                primaryButton: .destructive(Text("alert.pause_confirm".localized)) {
                                    viewModel.pauseGame()
                                },
                                secondaryButton: .cancel(Text("alert.cancel".localized))
                            )
                        }
                        
                        Spacer()
                        
                        // 保存进度按钮
                        Button(action: {
                            viewModel.saveProgress()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("button.save".localized)
                            }
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.05))
                    
                    // 退出和完成按钮
                    HStack {
                        Button(action: {
                            showingAlert = true
                        }) {
                            Text("button.exit".localized)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .alert(isPresented: $showingAlert) {
                            Alert(
                                title: Text("alert.exit_title".localized),
                                message: Text("alert.exit_message".localized),
                                primaryButton: .destructive(Text("alert.exit_confirm".localized)) {
                                    presentationMode.wrappedValue.dismiss()
                                },
                                secondaryButton: .cancel(Text("alert.cancel".localized))
                            )
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.endGame()
                        }) {
                            Text("button.finish".localized)
                                .foregroundColor(.blue)
                        }
                        .padding()
                    }
                    .background(Color.gray.opacity(0.1))
                }
            }
            
            // 导航到结果页面
            NavigationLink(
                destination: ResultView(gameState: viewModel.gameState)
                    .environmentObject(localizationManager),
                isActive: $navigateToResults
            ) {
                EmptyView()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if hasAppeared {
                // 如果视图已经出现过（从ResultView返回），则重置游戏
                viewModel.resetGame()
            } else {
                // 首次出现，启动游戏
                viewModel.startGame()
                hasAppeared = true
            }
            
            // Initialize the local time state
            currentTime = viewModel.gameState.timeRemaining
        }
        .onReceive(viewModel.gameState.$gameCompleted) { completed in
            if completed {
                navigateToResults = true
            }
        }
        .onReceive(timer) { _ in
            if viewModel.timerActive {
                viewModel.decrementTimer()
                // Update local state to force UI refresh
                currentTime = viewModel.gameState.timeRemaining
            }
        }
    }
    
    // iPad横屏专用布局
    var iPadLandscapeLayout: some View {
        ZStack {
            HStack(spacing: 0) {
                // 左侧：题目显示区域（占2/3空间）
                VStack {
                    // 顶部信息栏
                    VStack(spacing: 0) {
                        HStack {
                            // 剩余时间
                            VStack(alignment: .leading) {
                                Text("game.time".localized)
                                    .font(.footnote)
                                Text(viewModel.gameState.timeRemainingText)
                                    .font(.adaptiveHeadline())
                                    .foregroundColor(.blue)
                                    .id(currentTime) // Use local state to force refresh
                            }
                            
                            Spacer()
                            
                            // 当前进度
                            VStack {
                                Text(viewModel.gameState.progressText)
                                    .font(.adaptiveBody())
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        
                        // 暂停状态提示
                        if viewModel.gameState.isPaused {
                            HStack {
                                Text("game.paused".localized)
                                    .font(.adaptiveHeadline())
                                    .foregroundColor(.orange)
                                
                                Spacer()
                                
                                Button(action: {
                                    viewModel.resumeGame()
                                }) {
                                    Text("game.resume".localized)
                                        .font(.adaptiveBody())
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(.adaptiveCornerRadius)
                                }
                            }
                            .padding()
                            .background(Color.yellow.opacity(0.1))
                        }
                        
                        // 保存进度成功/失败提示
                        if viewModel.showSaveProgressSuccess {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("game.save_success".localized)
                                    .font(.adaptiveBody())
                                    .foregroundColor(.green)
                                Spacer()
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                        } else if viewModel.showSaveProgressError {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("game.save_error".localized)
                                    .font(.adaptiveBody())
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                        }
                    }
                    
                    Spacer()
                    
                    // 题目显示
                    if viewModel.gameState.questions.count > viewModel.gameState.currentQuestionIndex {
                        let currentQuestion = viewModel.gameState.questions[viewModel.gameState.currentQuestionIndex]
                        
                        Text(currentQuestion.questionText)
                            .font(.system(size: 60, weight: .bold))
                            .padding()
                    }
                    
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width * 0.65)
                .background(Color.white)
                
                // 右侧：答题控制面板
                VStack {
                    // 当前得分
                    VStack(alignment: .center) {
                        Text("game.score".localized)
                            .font(.adaptiveHeadline())
                        Text("\(viewModel.gameState.score)")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    
                    Spacer()
                    
                    // 答案反馈
                    if viewModel.gameState.questions.count > viewModel.gameState.currentQuestionIndex {
                        let currentQuestion = viewModel.gameState.questions[viewModel.gameState.currentQuestionIndex]
                        
                        if viewModel.gameState.showingCorrectAnswer {
                            VStack {
                                Text("game.wrong".localized)
                                    .foregroundColor(.red)
                                    .font(.adaptiveHeadline())
                                
                                Text("game.correct_answer".localizedFormat(String(currentQuestion.correctAnswer)))
                                    .foregroundColor(.blue)
                                    .font(.adaptiveBody())
                                
                                // 添加解析按钮
                                Button(action: {
                                    viewModel.showSolutionSteps.toggle()
                                }) {
                                    Text(viewModel.showSolutionSteps ? "button.hide_solution".localized : "button.show_solution".localized)
                                        .font(.adaptiveBody())
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(.adaptiveCornerRadius)
                                }
                                .padding(.top, 5)
                                
                                // 显示解析内容
                                if viewModel.showSolutionSteps {
                                    VStack(spacing: 0) {
                                        // 解析内容标题栏
                                        HStack {
                                            Text("solution.content".localized)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Image(systemName: "scroll")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.top, 6)
                                        
                                        // 解析内容区域
                                        ScrollView(.vertical, showsIndicators: true) {
                                            Text(currentQuestion.getSolutionSteps(for: viewModel.gameState.difficultyLevel))
                                                .font(.caption)
                                                .lineSpacing(1.5)
                                                .padding(10)
                                                .background(Color.yellow.opacity(0.1))
                                                .cornerRadius(6)
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.horizontal, 4) // 内部padding，为滚动条留出空间
                                        }
                                        .frame(height: calculateGameSolutionHeight())
                                        .padding(.horizontal, 10) // 左右两端10px padding
                                        .padding(.bottom, 6)
                                    }
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                                }
                                
                                // Next Question button
                                Button(action: {
                                    viewModel.moveToNextQuestion()
                                }) {
                                    Text("button.next_question".localized)
                                        .font(.adaptiveHeadline())
                                        .padding()
                                        .frame(width: 200)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(.adaptiveCornerRadius)
                                }
                                .id(UUID()) // Force view refresh
                                .padding(.top, 10)
                            }
                            .padding()
                        } else if viewModel.gameState.isCorrect {
                            Text("game.correct".localized)
                                .foregroundColor(.green)
                                .font(.adaptiveHeadline())
                                .padding()
                        }
                        
                        // 答案输入框
                        HStack {
                            TextField("", text: $userInput)
                                .keyboardType(.numberPad)
                                .font(.system(size: 30))
                                .multilineTextAlignment(.center)
                                .frame(width: 150, height: 60)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(.adaptiveCornerRadius)
                                .disabled(viewModel.gameState.showingCorrectAnswer)
                                .onReceive(Just(userInput)) { newValue in
                                    let filtered = newValue.filter { "0123456789".contains($0) }
                                    if filtered != newValue {
                                        self.userInput = filtered
                                    }
                                }
                        }
                        .padding()
                        
                        // 提交按钮
                        Button(action: submitAnswer) {
                            Text("game.submit".localized)
                                .font(.adaptiveHeadline())
                                .padding()
                                .frame(width: 200)
                                .background(userInput.isEmpty ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(.adaptiveCornerRadius)
                        }
                        .disabled(userInput.isEmpty || viewModel.gameState.showingCorrectAnswer)
                        .padding()
                    }
                    
                    Spacer()
                    
                    // 底部按钮
                    VStack(spacing: 0) {
                        // 暂停和保存按钮
                        HStack {
                            // 暂停按钮
                            Button(action: {
                                if !viewModel.gameState.pauseUsed {
                                    showingPauseAlert = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "pause.circle")
                                    Text("button.pause".localized)
                                }
                                .foregroundColor(viewModel.gameState.pauseUsed ? .gray : .orange)
                                .padding()
                                .frame(width: 120)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(.adaptiveCornerRadius)
                            }
                            .disabled(viewModel.gameState.pauseUsed || viewModel.gameState.isPaused)
                            .alert(isPresented: $showingPauseAlert) {
                                Alert(
                                    title: Text("alert.pause_title".localized),
                                    message: Text("alert.pause_message".localized),
                                    primaryButton: .destructive(Text("alert.pause_confirm".localized)) {
                                        viewModel.pauseGame()
                                    },
                                    secondaryButton: .cancel(Text("alert.cancel".localized))
                                )
                            }
                            
                            Spacer()
                            
                            // 保存进度按钮
                            Button(action: {
                                viewModel.saveProgress()
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("button.save".localized)
                                }
                                .foregroundColor(.blue)
                                .padding()
                                .frame(width: 120)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(.adaptiveCornerRadius)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        
                        // 退出和完成按钮
                        HStack {
                            Button(action: {
                                showingAlert = true
                            }) {
                                Text("button.exit".localized)
                                    .foregroundColor(.red)
                                    .padding()
                                    .frame(width: 100)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(.adaptiveCornerRadius)
                            }
                            .alert(isPresented: $showingAlert) {
                                Alert(
                                    title: Text("alert.exit_title".localized),
                                    message: Text("alert.exit_message".localized),
                                    primaryButton: .destructive(Text("alert.exit_confirm".localized)) {
                                        presentationMode.wrappedValue.dismiss()
                                    },
                                    secondaryButton: .cancel(Text("alert.cancel".localized))
                                )
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.endGame()
                            }) {
                                Text("button.finish".localized)
                                    .foregroundColor(.blue)
                                    .padding()
                                    .frame(width: 100)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(.adaptiveCornerRadius)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.35)
                .background(Color.gray.opacity(0.05))
            }
            
            // 导航到结果页面
            NavigationLink(
                destination: ResultView(gameState: viewModel.gameState)
                    .environmentObject(localizationManager),
                isActive: $navigateToResults
            ) {
                EmptyView()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if hasAppeared {
                // 如果视图已经出现过（从ResultView返回），则重置游戏
                viewModel.resetGame()
            } else {
                // 首次出现，启动游戏
                viewModel.startGame()
                hasAppeared = true
            }
            
            // Initialize the local time state
            currentTime = viewModel.gameState.timeRemaining
        }
        .onReceive(viewModel.gameState.$gameCompleted) { completed in
            if completed {
                navigateToResults = true
            }
        }
        .onReceive(timer) { _ in
            if viewModel.timerActive {
                viewModel.decrementTimer()
                // Update local state to force UI refresh
                currentTime = viewModel.gameState.timeRemaining
            }
        }
    }
    
    // 计算解析内容的动态高度（答题界面专用）
    private func calculateGameSolutionHeight() -> CGFloat {
        // 获取当前屏幕尺寸
        let screenBounds = UIScreen.main.bounds
        let currentScreenHeight = screenBounds.height
        let currentScreenWidth = screenBounds.width
        
        // 判断是否为横屏模式
        let isLandscape = currentScreenWidth > currentScreenHeight
        
        // 计算答题界面固定UI元素占用的高度
        let topInfoHeight: CGFloat = 80 // 顶部信息栏
        let questionHeight: CGFloat = 100 // 题目显示区域
        let inputHeight: CGFloat = 80 // 输入框区域
        let buttonHeight: CGFloat = 120 // 按钮区域
        let safeAreaHeight: CGFloat = DeviceUtils.isIPad ? 100 : 80 // 安全区域
        
        // 计算可用高度
        let availableHeight = currentScreenHeight - topInfoHeight - questionHeight - inputHeight - buttonHeight - safeAreaHeight
        
        // 根据设备类型和方向调整最大高度
        let maxHeight: CGFloat
        let minHeight: CGFloat = 100
        
        if DeviceUtils.isIPad {
            if isLandscape {
                // iPad横屏：右侧面板空间有限
                maxHeight = max(availableHeight * 0.4, 120)
            } else {
                // iPad竖屏：可以使用更多空间
                maxHeight = max(availableHeight * 0.5, 180)
            }
        } else {
            if isLandscape {
                // iPhone横屏：垂直空间非常有限
                maxHeight = max(availableHeight * 0.3, 80)
            } else {
                // iPhone竖屏：适中的空间分配
                maxHeight = max(availableHeight * 0.4, 150)
            }
        }
        
        // 根据size class进一步调整
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            // 大屏设备（如iPad）
            return max(min(maxHeight * 1.1, availableHeight * 0.6), minHeight)
        } else if horizontalSizeClass == .compact && verticalSizeClass == .compact {
            // 紧凑模式（如iPhone横屏）
            return max(min(maxHeight * 0.8, availableHeight * 0.3), minHeight)
        } else {
            // 标准模式
            return max(min(maxHeight, availableHeight * 0.4), minHeight)
        }
    }
    
    // 提交答案
    private func submitAnswer() {
        guard let answer = Int(userInput) else { return }
        viewModel.submitAnswer(answer)
        userInput = ""
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(viewModel: GameViewModel(difficultyLevel: .level1, timeInMinutes: 10))
            .environmentObject(LocalizationManager())
    }
}
