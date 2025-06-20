import SwiftUI

struct ResultView: View {
    let gameState: GameState
    @State private var navigateToHome = false
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
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
        VStack(spacing: 30) {
            // 标题
            Text("result.final_score".localized)
                .font(.adaptiveTitle())
                .padding(.top, 50)
            
            // 得分
            Text("\(gameState.score)")
                .font(.system(size: 70, weight: .bold))
                .foregroundColor(.blue)
            
            // 评价
            let rating = gameState.getPerformanceRating()
            VStack {
                Text(rating.0)
                    .font(.adaptiveHeadline())
                Text(rating.1)
                    .font(.system(size: 40))
            }
            .padding()
            
            // 详细信息
            VStack(alignment: .leading, spacing: 15) {
                // 答对题目数量
                HStack {
                    Text("result.correct_count".localizedFormat(String(gameState.correctAnswersCount), String(gameState.totalQuestions)))
                        .font(.adaptiveBody())
                    Spacer()
                }
                
                // 用时
                HStack {
                    Text("result.time_used".localized)
                        .font(.adaptiveBody())
                    Spacer()
                    Text(gameState.timeUsedText)
                        .font(.adaptiveBody())
                        .foregroundColor(.blue)
                }
                
                // 难度
                HStack {
                    Text("difficulty.level".localized)
                        .font(.adaptiveBody())
                    Spacer()
                    Text(gameState.difficultyLevel.localizedName)
                        .font(.adaptiveBody())
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(.adaptiveCornerRadius)
            .padding(.horizontal)
            
            Spacer()
            
            // 按钮
            HStack(spacing: 20) {
                // 重新开始按钮
                Button(action: {
                    // 返回到上一个视图（GameView）
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("button.restart".localized)
                        .font(.adaptiveHeadline())
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(.adaptiveCornerRadius)
                }
                
                // 返回主页按钮
                Button(action: {
                    // 返回到根视图（ContentView）
                    navigateToHome = true
                }) {
                    Text("button.home".localized)
                        .font(.adaptiveHeadline())
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(.adaptiveCornerRadius)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 50)
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(destination: EmptyView(), isActive: $navigateToHome) {
                EmptyView()
            }
            .hidden()
            .onAppear {
                if navigateToHome {
                    // 使用环境值获取根导航控制器并弹出到根视图
                    DispatchQueue.main.async {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        )
    }
    
    // iPad横屏专用布局
    var iPadLandscapeLayout: some View {
        HStack(spacing: 0) {
            // 左侧：得分展示和评价
            VStack {
                Spacer()
                
                // 标题
                Text("result.final_score".localized)
                    .font(.adaptiveTitle())
                
                // 得分
                Text("\(gameState.score)")
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(.blue)
                    .padding()
                
                // 评价
                let rating = gameState.getPerformanceRating()
                VStack {
                    Text(rating.0)
                        .font(.adaptiveHeadline())
                    Text(rating.1)
                        .font(.system(size: 60))
                }
                .padding()
                
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width * 0.5)
            .background(Color.gray.opacity(0.05))
            
            // 右侧：详细统计信息和操作按钮
            VStack {
                Spacer()
                
                // 详细信息
                VStack(alignment: .leading, spacing: 20) {
                    // 答对题目数量
                    HStack {
                        Text("result.correct_count".localizedFormat(String(gameState.correctAnswersCount), String(gameState.totalQuestions)))
                            .font(.title2)
                        Spacer()
                    }
                    
                    // 用时
                    HStack {
                        Text("result.time_used".localized)
                            .font(.title2)
                        Spacer()
                        Text(gameState.timeUsedText)
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    // 难度
                    HStack {
                        Text("difficulty.level".localized)
                            .font(.title2)
                        Spacer()
                        Text(gameState.difficultyLevel.localizedName)
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(.adaptiveCornerRadius)
                .padding(.horizontal, 50)
                
                Spacer()
                
                // 按钮
                VStack(spacing: 20) {
                    // 重新开始按钮
                    Button(action: {
                        // 返回到上一个视图（GameView）
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("button.restart".localized)
                            .font(.adaptiveHeadline())
                            .padding()
                            .frame(width: 250)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(.adaptiveCornerRadius)
                    }
                    
                    // 返回主页按钮
                    Button(action: {
                        // 返回到根视图（ContentView）
                        navigateToHome = true
                    }) {
                        Text("button.home".localized)
                            .font(.adaptiveHeadline())
                            .padding()
                            .frame(width: 250)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(.adaptiveCornerRadius)
                    }
                }
                .padding(.bottom, 50)
            }
            .frame(width: UIScreen.main.bounds.width * 0.5)
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(destination: EmptyView(), isActive: $navigateToHome) {
                EmptyView()
            }
            .hidden()
            .onAppear {
                if navigateToHome {
                    // 使用环境值获取根导航控制器并弹出到根视图
                    DispatchQueue.main.async {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        )
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView(gameState: GameState(difficultyLevel: .level1, timeInMinutes: 10))
    }
}
