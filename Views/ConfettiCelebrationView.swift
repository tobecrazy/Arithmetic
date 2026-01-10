import SwiftUI

/// A beautiful confetti celebration view that displays animated confetti particles
/// Used for achievements, streaks, and special moments in the app
struct ConfettiCelebrationView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isActive = false
    let duration: Double
    let onCompletion: (() -> Void)?

    init(duration: Double = 2.0, onCompletion: (() -> Void)? = nil) {
        self.duration = duration
        self.onCompletion = onCompletion
    }

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                ConfettiParticleView(particle: particle)
                    .offset(x: particle.position.x, y: particle.position.y)
                    .rotationEffect(.degrees(particle.rotation))
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
            }
        }
        .onAppear {
            if isActive {
                generateParticles()
                animateParticles()
            }
        }
        .onChange(of: isActive) { newValue in
            if newValue {
                generateParticles()
                animateParticles()
            }
        }
    }

    func trigger() {
        isActive = true
    }

    private func generateParticles() {
        particles = (0..<50).map { _ in
            let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .cyan]
            let randomColor = colors.randomElement() ?? .blue
            let randomDx = CGFloat.random(in: -200...200)
            let randomDy = CGFloat.random(in: -400...200) * -1
            return ConfettiParticle(
                id: UUID(),
                position: CGPoint(x: 0, y: 0),
                color: randomColor,
                velocity: CGVector(dx: randomDx, dy: randomDy),
                rotation: CGFloat.random(in: 0...360),
                rotationSpeed: CGFloat.random(in: -180...180),
                scale: CGFloat.random(in: 0.5...1.2),
                opacity: 1.0
            )
        }
    }

    private func animateParticles() {
        withAnimation(.easeOut(duration: duration)) {
            for index in particles.indices {
                let particle = particles[index]
                particles[index].position = CGPoint(
                    x: particle.position.x + particle.velocity.dx * (duration / 2),
                    y: particle.position.y + particle.velocity.dy * (duration / 2)
                )
                particles[index].rotation += particle.rotationSpeed * duration
                particles[index].opacity = 0.0
                particles[index].scale *= 0.5
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            isActive = false
            onCompletion?()
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: UUID
    var position: CGPoint
    let color: Color
    let velocity: CGVector
    var rotation: CGFloat
    let rotationSpeed: CGFloat
    var scale: CGFloat
    var opacity: Double
}

struct ConfettiParticleView: View {
    let particle: ConfettiParticle

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(particle.color)
            .frame(width: 8, height: 12)
            .shadow(color: particle.color.opacity(0.5), radius: 2, x: 0, y: 1)
    }
}

/// A streak celebration view that shows animated flame effects
struct StreakCelebrationView: View {
    let streakCount: Int
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                ForEach(0..<3) { index in
                    Image(systemName: "flame.fill")
                        .font(.system(size: 60))
                        .foregroundColor(
                            [.orange, .red, .yellow].randomElement() ?? .orange
                        )
                        .opacity(isAnimating ? Double(3 - index) / 3.0 : 0)
                        .scaleEffect(scale + CGFloat(index) * 0.2)
                        .rotationEffect(.degrees(isAnimating ? CGFloat(index * 20) : 0))
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.5)
                            .delay(Double(index) * 0.1),
                            value: isAnimating
                        )
                }

                Text("\(streakCount)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 80)

            Text("streak.title".localized)
                .font(.caption)
                .foregroundColor(.secondary)

            Text("streak.\(min(streakCount, 10))".localized)
                .font(.headline)
                .foregroundColor(.orange)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
                .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                isAnimating = true
                scale = 1.0
                opacity = 1.0
            }

            // Auto-dismiss after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0.0
                    scale = 0.8
                }
            }
        }
    }
}

// MARK: - Preview
struct ConfettiCelebrationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.1)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                ConfettiCelebrationView(duration: 3.0)
                    .frame(width: 200, height: 200)
                    .onAppear {
                        // Cannot trigger here in preview
                    }

                StreakCelebrationView(streakCount: 5)
            }
        }
    }
}
