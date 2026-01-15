import AVFoundation

/// A helper class for managing sound effects throughout the app
/// Provides simple methods to play various sound effects for game interactions
class SoundEffectsHelper {
    static let shared = SoundEffectsHelper()

    private var audioPlayer: AVAudioPlayer?
    private let soundEnabledKey = "soundEffectsEnabled"

    private init() {
        setupAudioSession()
    }

    /// Check if sound effects are enabled
    var isSoundEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: soundEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: soundEnabledKey)
        }
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    /// Play a system sound by ID
    private func playSystemSound(_ soundID: SystemSoundID) {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(soundID)
    }

    /// Play correct answer sound (positive chime)
    func playCorrectAnswer() {
        guard isSoundEnabled else { return }
        // Using system sound for positive feedback
        playSystemSound(1025) // Glass tap sound
    }

    /// Play wrong answer sound (gentle error)
    func playWrongAnswer() {
        guard isSoundEnabled else { return }
        playSystemSound(1053) // Error sound
    }

    /// Play button tap sound
    func playButtonTap() {
        guard isSoundEnabled else { return }
        playSystemSound(1104) // Light tap
    }

    /// Play success/celebration sound
    func playSuccess() {
        guard isSoundEnabled else { return }
        playSystemSound(1020) // Mail sent sound
    }

    /// Play level up sound
    func playLevelUp() {
        guard isSoundEnabled else { return }
        // Play a sequence of sounds for level up
        playSystemSound(1025)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.playSystemSound(1025)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.playSystemSound(1020)
        }
    }

    /// Play achievement unlock sound
    func playAchievement() {
        guard isSoundEnabled else { return }
        // Triumphant sequence
        playSystemSound(1016) // Prediction complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.playSystemSound(1020)
        }
    }

    /// Play time warning sound
    func playTimeWarning() {
        guard isSoundEnabled else { return }
        playSystemSound(1013) // Anticipate
    }

    /// Play pause sound
    func playPause() {
        guard isSoundEnabled else { return }
        playSystemSound(1110) // Low click
    }

    /// Play resume sound
    func playResume() {
        guard isSoundEnabled else { return }
        playSystemSound(1109) // High click
    }
}
