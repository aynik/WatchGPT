import AVFoundation

final class Synthesizer {
    static let shared = Synthesizer()

    private let synthesizer = AVSpeechSynthesizer()
    private init() {}

    var isSpeaking: Bool {
        synthesizer.isSpeaking
    }

    func speak(language:  String, text: String) {
        guard !synthesizer.isPaused else { return }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = .init(language: language)

        let avSession = AVAudioSession.sharedInstance()
        try? avSession.setCategory(AVAudioSession.Category.playback, options: .mixWithOthers)
      
        synthesizer.speak(utterance)
    }

    func stopSpeaking() {
        guard synthesizer.isSpeaking else { return }
        synthesizer.stopSpeaking(at: .immediate)
    }
}
