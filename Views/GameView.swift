import SwiftUI
import Combine

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var userInput: String = ""
    @State private var showingAlert = false
    @State private var navigateToResults = false
    @Environment(\.presentationMode) var presentationMode
    
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
                HStack {
                    // 剩余时间
                    VStack(alignment: .leading) {
                        Text("game.time".localized)
                            .font(.footnote)
                        Text(viewModel.gameState.timeRemainingText)
                            .font(.adaptiveHeadline())
                            .foregroundColor(.blue)
                            .id(viewModel.gameState.timeRemaining) // Force refresh when timeRemaining changes
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
            
            // 导航到结果页面
            NavigationLink(
                destination: ResultView(gameState: viewModel.gameState),
                isActive: $navigateToResults
            ) {
                EmptyView()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.startGame()
        }
        .onReceive(viewModel.gameState.$gameCompleted) { completed in
            if completed {
                navigateToResults = true
            }
        }
        .onReceive(timer) { _ in
            if viewModel.timerActive {
                viewModel.decrementTimer()
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
                    HStack {
                        // 剩余时间
                        VStack(alignment: .leading) {
                            Text("game.time".localized)
                                .font(.footnote)
                            Text(viewModel.gameState.timeRemainingText)
                                .font(.adaptiveHeadline())
                                .foregroundColor(.blue)
                                .id(viewModel.gameState.timeRemaining) // Force refresh when timeRemaining changes
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
                .frame(width: UIScreen.main.bounds.width * 0.35)
                .background(Color.gray.opacity(0.05))
            }
            
            // 导航到结果页面
            NavigationLink(
                destination: ResultView(gameState: viewModel.gameState),
                isActive: $navigateToResults
            ) {
                EmptyView()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.startGame()
        }
        .onReceive(viewModel.gameState.$gameCompleted) { completed in
            if completed {
                navigateToResults = true
            }
        }
        .onReceive(timer) { _ in
            if viewModel.timerActive {
                viewModel.decrementTimer()
            }
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
    }
}
