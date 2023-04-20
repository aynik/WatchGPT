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
  @AppStorage("model") var model: String = "gpt-3.5-turbo"
  @AppStorage("baseUrl") var baseUrl: String = ""
  @AppStorage("listeningLanguage") var listeningLanguage: String = "en-US"
  @AppStorage("enableSpeaking") var enableSpeaking: Bool = true
  @AppStorage("speakingLanguage") var speakingLanguage: String = "en-US"
  @Published var isSpeaking = false
  @Published var isInteractingWithChatGPT = false
  @Published var messages: [MessageRow] = []
  @Published var inputMessage: String = ""
  @Published var textInputForiOS: String = ""
  
  let api: APIController
  
  init(api: APIController) {
    self.api = api
  }
  
  // Speech control methods
  func toggleSpeech() {
    enableSpeaking.toggle()
  }
  
  // Message handling methods
  @MainActor
  func clearMessages() {
    Synthesizer.shared.stopSpeaking()
    isSpeaking = false
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
  
  @MainActor
  func send(text: String) async {
    isInteractingWithChatGPT = true
    isSpeaking = true
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
          if enableSpeaking && isSpeaking {
            Synthesizer.shared.speak(language: speakingLanguage, text: String(sentence))
          }
        }
      }
      
      // Speak any remaining text in the buffer
      if !sentenceBuffer.isEmpty && enableSpeaking && isSpeaking {
        Synthesizer.shared.speak(language: speakingLanguage, text: sentenceBuffer)
      }
    } catch {
      messageRow.responseError = error.localizedDescription
    }
    
    messageRow.isInteractingWithChatGPT = false
    self.messages[self.messages.count - 1] = messageRow
    isInteractingWithChatGPT = false
    isSpeaking = false
  }
}
