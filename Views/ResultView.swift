import SwiftUI
import UIKit
import CoreData

struct ResultView: View {
    let gameState: GameState
    var onHomePressed: (() -> Void)? = nil
    @Environment(\.presentationMode) var presentationMode
    @State private var shouldPopToRoot = false
    @State private var showWrongQuestionsView = false
    @EnvironmentObject var localizationManager: LocalizationManager
    
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
        ScrollView {
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
                
                // 按钮
                VStack(spacing: 15) {
                    // 查看错题集按钮
                    Button(action: {
                        showWrongQuestionsView = true
                    }) {
                        Text("button.wrong_questions".localized)
                            .font(.adaptiveHeadline())
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(.adaptiveCornerRadius)
                    }
                    .padding(.horizontal)
                    
                    // Removed NavigationLink - using sheet presentation instead
                    
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
                            // Use the provided closure for clean navigation
                            if let onHomePressed = onHomePressed {
                                onHomePressed()
                            } else {
                                // Fallback to original UIKit method
                                let scenes = UIApplication.shared.connectedScenes
                                let windowScene = scenes.first as? UIWindowScene
                                let window = windowScene?.windows.first

                                if let navigationController = window?.rootViewController?.children.first as? UINavigationController {
                                    navigationController.popToRootViewController(animated: true)
                                } else {
                                    // 如果找不到导航控制器，尝试关闭所有模态视图
                                    var currentVC = window?.rootViewController
                                    while let presentedVC = currentVC?.presentedViewController {
                                        currentVC = presentedVC
                                    }
                                    currentVC?.dismiss(animated: true)
                                }
                            }
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
                }
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showWrongQuestionsView) {
            NavigationView {
                WrongQuestionsView()
                    .environmentObject(localizationManager)
            }
        }
    }

    // iPad横屏专用布局
    var iPadLandscapeLayout: some View {
        HStack(spacing: 0) {
            // 左侧：得分展示和评价
            ScrollView {
                VStack {
                    Spacer(minLength: 50)
                    
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
                    
                    Spacer(minLength: 50)
                }
            }
            .frame(width: UIScreen.main.bounds.width * 0.5)
            .background(Color.gray.opacity(0.05))
            
            // 右侧：详细统计信息和操作按钮
            ScrollView {
                VStack {
                    Spacer(minLength: 50)
                    
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
                    
                    Spacer(minLength: 30)
                    
                    // 按钮
                    VStack(spacing: 20) {
                        // 查看错题集按钮
                        Button(action: {
                            showWrongQuestionsView = true
                        }) {
                            Text("button.wrong_questions".localized)
                                .font(.adaptiveHeadline())
                                .padding()
                                .frame(width: 250)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(.adaptiveCornerRadius)
                        }
                        
                        // Removed NavigationLink - using sheet presentation instead
                        
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
                            // Use the provided closure for clean navigation
                            if let onHomePressed = onHomePressed {
                                onHomePressed()
                            } else {
                                // Fallback to original UIKit method
                                let scenes = UIApplication.shared.connectedScenes
                                let windowScene = scenes.first as? UIWindowScene
                                let window = windowScene?.windows.first

                                if let navigationController = window?.rootViewController?.children.first as? UINavigationController {
                                    navigationController.popToRootViewController(animated: true)
                                } else {
                                    // 如果找不到导航控制器，尝试关闭所有模态视图
                                    var currentVC = window?.rootViewController
                                    while let presentedVC = currentVC?.presentedViewController {
                                        currentVC = presentedVC
                                    }
                                    currentVC?.dismiss(animated: true)
                                }
                            }
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
            }
            .frame(width: UIScreen.main.bounds.width * 0.5)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showWrongQuestionsView) {
            NavigationView {
                WrongQuestionsView()
                    .environmentObject(localizationManager)
            }
        }
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView(gameState: GameState(difficultyLevel: .level1, timeInMinutes: 10))
            .environmentObject(LocalizationManager())
    }
}
