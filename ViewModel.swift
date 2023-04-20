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
  @ObservedObject var synthesizer = SpeechSynthesizer.shared
  @AppStorage("model") var model: String = "gpt-3.5-turbo"
  @AppStorage("baseUrl") var baseUrl: String = ""
  @AppStorage("listeningLanguage") var listeningLanguage: String = "en-US"
  @AppStorage("enableSpeaking") var enableSpeaking: Bool = true
  @AppStorage("speakingLanguage") var speakingLanguage: String = "en-US"
  @Published var isInteractingWithChatGPT = false
  @Published var messages: [MessageRow] = []
  @Published var inputMessage: String = ""
  @Published var textInputForiOS: String = ""
  @Published var stopSpeaking: Bool = false
  
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
    synthesizer.stopSpeaking()
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
    stopSpeaking = !enableSpeaking
    var streamText = ""
    var textBuffer = ""
    var speakingBuffer = ""
    
    var messageRow = MessageRow(
      id: UUID(),
      isInteractingWithChatGPT: true,
      sendText: text,
      responseText: streamText,
      responseError: nil
    )
    
    self.messages.append(messageRow)
    
    do {
      let stream = try await api.sendMessageStream(text: text)
      for try await text in stream {
        streamText += text
        textBuffer += text
        messageRow.responseText = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
        self.messages[self.messages.count - 1] = messageRow
        
        if let periodIndex = textBuffer.lastIndex(of: ".") ?? textBuffer.lastIndex(of: ":") {
          speakingBuffer = String(textBuffer[...periodIndex])
          textBuffer = String(textBuffer[periodIndex...].dropFirst())
          speakTextAndClearBuffer(&speakingBuffer)
        }
      }
      
      if !textBuffer.isEmpty {
        speakTextAndClearBuffer(&textBuffer)
      }
    } catch {
      updateMessageRow(id: messageRow.id, error: error.localizedDescription)
    }
    
    updateMessageRow(id: messageRow.id, interacting: false)
    isInteractingWithChatGPT = false
  }
  
  private func updateMessageRow(id: UUID, text: String? = nil, error: String? = nil, interacting: Bool? = nil) {
    if let index = self.messages.firstIndex(where: { $0.id == id }) {
      var messageRow = self.messages[index]
      
      if let text = text {
        messageRow.responseText = text
      }
      
      if let error = error {
        messageRow.responseError = error
      }
      
      if let interacting = interacting {
        messageRow.isInteractingWithChatGPT = interacting
      }
      
      self.messages[index] = messageRow
    }
  }
  
  private func speakTextAndClearBuffer(_ textBuffer: inout String) {
    if enableSpeaking && !stopSpeaking {
      synthesizer.speak(language: speakingLanguage, text: textBuffer)
    }
    textBuffer = ""
  }
}

