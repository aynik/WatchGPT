import Speech

final class SpeechRecognizer: NSObject {
  static let shared = SpeechRecognizer()
  private(set) var isEnable = false
  
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  private let audioEngine = AVAudioEngine()
  private override init() {}
  
  func startRecording(language: String, progressHandler: @escaping (String) -> Void = {_ in }) {
    guard !audioEngine.isRunning else { return }
    try? recorde(language: language, progressHandler: progressHandler)
  }
  
  func stopRecording() {
    if audioEngine.isRunning {
      audioEngine.stop()
      recognitionRequest?.endAudio()
    } else {
      // do nothing
    }
  }
  
  private func recorde(language: String, progressHandler: @escaping (String) -> Void) throws {
    
    recognitionTask?.cancel()
    recognitionTask = nil
    
    let audioSession = AVAudioSession.sharedInstance()
    try audioSession.setCategory(.playAndRecord, options: .mixWithOthers)
    
    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    let inputNode = audioEngine.inputNode
    
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    guard let recognitionRequest else {
      fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
    recognitionRequest.shouldReportPartialResults = true
    
    let recognizer = SFSpeechRecognizer(locale: Locale(identifier: language))!
    recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
      var isFinal = false
      
      if let result {
        progressHandler(result.bestTranscription.formattedString)
        isFinal = result.isFinal
      }
      
      if error != nil || isFinal {
        self.audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        
        self.recognitionRequest = nil
        self.recognitionTask = nil
      }
    }
    
    let recordingFormat = inputNode.outputFormat(forBus: 0)
    inputNode.installTap(onBus: 0, bufferSize: 1024,
                         format: recordingFormat) { (buffer: AVAudioPCMBuffer, _: AVAudioTime) in
      self.recognitionRequest?.append(buffer)
    }
    
    audioEngine.prepare()
    try audioEngine.start()
  }
}

extension SpeechRecognizer: SFSpeechRecognizerDelegate {
  public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    isEnable = available
  }
}
