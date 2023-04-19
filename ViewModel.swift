import Foundation
import AVFoundation
import SwiftUI
import AVKit

struct MessageRow: Identifiable, Codable {
  let id: UUID
  var isInteractingWithChatGPT: Bool
  let sendText: String
  var responseText: String?
  var responseError: String?
}

class ViewModel: ObservableObject {
  @AppStorage("language") var language: String = "en-US"
  @AppStorage("enableSpeech") var enableSpeech: Bool = true
  @Published var isInteractingWithChatGPT = false
  @Published var messages: [MessageRow] = []
  @Published var inputMessage: String = ""
  @Published var textInputForiOS: String = ""
  
  private var synthesizer = AVSpeechSynthesizer()
  private let api: APIController
  
  init(api: APIController) {
    self.api = api
  }
  
  // Speech control methods
  func toggleSpeech() {
    enableSpeech.toggle()
  }
  
  private func speakText(_ text: String) {
    if enableSpeech {
      let utterance = AVSpeechUtterance(string: text)
      utterance.voice = .init(language: language)
      synthesizer.speak(utterance)
    }
  }
  
  func speakLastResponse() {
    if enableSpeech {
      guard let responseText = self.messages.last?.responseText, !responseText.isEmpty else {
        return
      }
      stopSpeaking()
      let utterance = AVSpeechUtterance(string: responseText)
      utterance.voice = .init(language: language)
      synthesizer.speak(utterance)
    }
  }
  
  func stopSpeaking() {
    synthesizer.stopSpeaking(at: .immediate)
  }
  
  // Message handling methods
  @MainActor
  func sendTapped() async {
    let text = inputMessage
    inputMessage = ""
    await send(text: text)
  }
  
  @MainActor
  func clearMessages() {
    stopSpeaking()
    api.deleteHistoryList()
    withAnimation { [weak self] in
      self?.messages = []
    }
  }
  
  @MainActor
  func retry(message: MessageRow) async {
    guard let index = messages.firstIndex(where: { $0.id == message.id }) else {
      return
    }
    self.messages.remove(at: index)
    await send(text: message.sendText)
  }
  
  // Private methods
  @MainActor
  private func send(text: String) async {
    isInteractingWithChatGPT = true
    var streamText = ""
    var sentenceBuffer = ""
    var messageRow = MessageRow(
      id: UUID(),
      isInteractingWithChatGPT: true,
      sendText: text,
      responseText: streamText,
      responseError: nil)
    
    self.messages.append(messageRow)
    
    do {
      let stream = try await api.sendMessageStream(text: text)
      for try await text in stream {
        streamText += text
        sentenceBuffer += text
        messageRow.responseText = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
        self.messages[self.messages.count - 1] = messageRow
        
        // Check if a sentence is completed (ends with a period)
        if let periodIndex = sentenceBuffer.lastIndex(of: ".") {
          let sentence = sentenceBuffer[...periodIndex]
          sentenceBuffer = String(sentenceBuffer[periodIndex...].dropFirst())
          
          // Speak the completed sentence
          speakText(String(sentence))
        }
      }
      
      // Speak any remaining text in the buffer
      if !sentenceBuffer.isEmpty {
        speakText(sentenceBuffer)
      }
    } catch {
      messageRow.responseError = error.localizedDescription
    }
    
    messageRow.isInteractingWithChatGPT = false
    self.messages[self.messages.count - 1] = messageRow
    isInteractingWithChatGPT = false
  }
  
}
