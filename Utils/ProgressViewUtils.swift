//
//  ProgressViewUtils.swift
//  Arithmetic
//
//  Created by Cline on 9/30/25.
//

import SwiftUI

// MARK: - Progress View Styles

/// Custom progress view styles for different use cases
struct ProgressViewUtils {
    
    // MARK: - Progress Bar Styles
    
    /// Linear progress bar style with customizable appearance
    struct LinearProgressBar: View {
        let progress: Double
        let height: CGFloat
        let backgroundColor: Color
        let foregroundColor: Color
        let cornerRadius: CGFloat
        let animated: Bool
        
        init(
            progress: Double,
            height: CGFloat = 8,
            backgroundColor: Color = Color(.systemGray5),
            foregroundColor: Color = .blue,
            cornerRadius: CGFloat = 4,
            animated: Bool = true
        ) {
            self.progress = max(0, min(1, progress))
            self.height = height
            self.backgroundColor = backgroundColor
            self.foregroundColor = foregroundColor
            self.cornerRadius = cornerRadius
            self.animated = animated
        }
        
        var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(backgroundColor)
                        .frame(height: height)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(foregroundColor)
                        .frame(width: geometry.size.width * progress, height: height)
                        .animation(animated ? .easeInOut(duration: 0.3) : nil, value: progress)
                }
            }
            .frame(height: height)
        }
    }
    
    /// Circular progress bar style
    struct CircularProgressBar: View {
        let progress: Double
        let lineWidth: CGFloat
        let backgroundColor: Color
        let foregroundColor: Color
        let size: CGFloat
        let animated: Bool
        
        init(
            progress: Double,
            lineWidth: CGFloat = 8,
            backgroundColor: Color = Color(.systemGray5),
            foregroundColor: Color = .blue,
            size: CGFloat = 60,
            animated: Bool = true
        ) {
            self.progress = max(0, min(1, progress))
            self.lineWidth = lineWidth
            self.backgroundColor = backgroundColor
            self.foregroundColor = foregroundColor
            self.size = size
            self.animated = animated
        }
        
        var body: some View {
            ZStack {
                // Background circle
                Circle()
                    .stroke(backgroundColor, lineWidth: lineWidth)
                
                // Progress arc
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        foregroundColor,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(animated ? .easeInOut(duration: 0.3) : nil, value: progress)
                
                // Progress percentage text
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(width: size, height: size)
        }
    }
    
    /// Segmented progress bar for step-by-step progress
    struct SegmentedProgressBar: View {
        let currentStep: Int
        let totalSteps: Int
        let segmentHeight: CGFloat
        let spacing: CGFloat
        let completedColor: Color
        let incompleteColor: Color
        let cornerRadius: CGFloat
        
        init(
            currentStep: Int,
            totalSteps: Int,
            segmentHeight: CGFloat = 6,
            spacing: CGFloat = 4,
            completedColor: Color = .green,
            incompleteColor: Color = Color(.systemGray5),
            cornerRadius: CGFloat = 3
        ) {
            self.currentStep = max(0, min(totalSteps, currentStep))
            self.totalSteps = max(1, totalSteps)
            self.segmentHeight = segmentHeight
            self.spacing = spacing
            self.completedColor = completedColor
            self.incompleteColor = incompleteColor
            self.cornerRadius = cornerRadius
        }
        
        var body: some View {
            HStack(spacing: spacing) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(index < currentStep ? completedColor : incompleteColor)
                        .frame(height: segmentHeight)
                        .animation(.easeInOut(duration: 0.2), value: currentStep)
                }
            }
        }
    }
    
    /// Animated loading progress indicator
    struct LoadingProgressIndicator: View {
        @State private var isAnimating = false
        let color: Color
        let size: CGFloat
        
        init(color: Color = .blue, size: CGFloat = 40) {
            self.color = color
            self.size = size
        }
        
        var body: some View {
            Circle()
                .trim(from: 0, to: 0.8)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 1.0).repeatForever(autoreverses: false),
                    value: isAnimating
                )
                .onAppear {
                    isAnimating = true
                }
                .onDisappear {
                    isAnimating = false
                }
        }
    }
}

// MARK: - Progress View Modifiers

extension View {
    /// Applies a linear progress overlay
    func linearProgress(
        _ progress: Double,
        height: CGFloat = 4,
        backgroundColor: Color = Color(.systemGray5),
        foregroundColor: Color = .blue
    ) -> some View {
        self.overlay(
            VStack {
                Spacer()
                ProgressViewUtils.LinearProgressBar(
                    progress: progress,
                    height: height,
                    backgroundColor: backgroundColor,
                    foregroundColor: foregroundColor
                )
            }
        )
    }
    
    /// Shows a loading overlay with progress indicator
    func loadingOverlay(
        isLoading: Bool,
        color: Color = .blue,
        backgroundColor: Color = Color.black.opacity(0.3)
    ) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    ZStack {
                        backgroundColor
                            .ignoresSafeArea()
                        
                        ProgressViewUtils.LoadingProgressIndicator(color: color)
                    }
                }
            }
        )
    }
}

// MARK: - Progress Manager

/// Observable object for managing progress state across the app
class ProgressManager: ObservableObject {
    @Published var currentProgress: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var progressMessage: String = ""
    
    /// Updates progress with optional message
    func updateProgress(_ progress: Double, message: String = "") {
        DispatchQueue.main.async {
            self.currentProgress = max(0, min(1, progress))
            self.progressMessage = message
        }
    }
    
    /// Sets loading state
    func setLoading(_ loading: Bool, message: String = "") {
        DispatchQueue.main.async {
            self.isLoading = loading
            self.progressMessage = message
        }
    }
    
    /// Resets progress to initial state
    func reset() {
        DispatchQueue.main.async {
            self.currentProgress = 0.0
            self.isLoading = false
            self.progressMessage = ""
        }
    }
    
    /// Animates progress to target value
    func animateProgress(to targetProgress: Double, duration: Double = 0.5) {
        let startProgress = currentProgress
        let progressDifference = targetProgress - startProgress
        let startTime = Date()
        
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            let elapsed = Date().timeIntervalSince(startTime)
            let progress = min(elapsed / duration, 1.0)
            
            DispatchQueue.main.async {
                self.currentProgress = startProgress + (progressDifference * progress)
            }
            
            if progress >= 1.0 {
                timer.invalidate()
            }
        }
    }
}

// MARK: - Convenience Extensions

extension ProgressViewUtils {
    /// Creates a game progress bar for quiz/game scenarios
    static func gameProgressBar(
        currentQuestion: Int,
        totalQuestions: Int,
        accentColor: Color = .blue
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Progress")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(currentQuestion)/\(totalQuestions)")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            LinearProgressBar(
                progress: Double(currentQuestion) / Double(totalQuestions),
                foregroundColor: accentColor
            )
        }
    }
    
    /// Creates a download/upload progress view
    static func downloadProgressView(
        progress: Double,
        fileName: String,
        showPercentage: Bool = true
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(.blue)
                Text(fileName)
                    .font(.caption)
                    .lineLimit(1)
                Spacer()
                if showPercentage {
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            
            LinearProgressBar(
                progress: progress,
                height: 6,
                foregroundColor: .blue
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Singleton Instance

extension ProgressManager {
    static let shared = ProgressManager()
}
