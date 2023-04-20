import AVFoundation

class SpeechSynthesizer: NSObject, ObservableObject {
  @Published var isSpeaking: Bool = false
  static let shared = SpeechSynthesizer()
  private var speechSynthesizer: AVSpeechSynthesizer
  
  override init() {
    speechSynthesizer = AVSpeechSynthesizer()
    super.init()
    speechSynthesizer.delegate = self
  }
  
  func speak(language: String, text: String) {
    guard !speechSynthesizer.isPaused else { return }
    
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = .init(language: language)
    
    let avSession = AVAudioSession.sharedInstance()
    try? avSession.setCategory(AVAudioSession.Category.playback, options: .mixWithOthers)
    
    speechSynthesizer.speak(utterance)
  }
  
  func stopSpeaking() {
    guard speechSynthesizer.isSpeaking else { return }
    speechSynthesizer.stopSpeaking(at: .immediate)
  }
}

extension SpeechSynthesizer: AVSpeechSynthesizerDelegate {
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
    isSpeaking = true
  }
  
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    isSpeaking = false
  }
}
