import Foundation
import AVFoundation
import SwiftUI
import AVKit

struct MessageRow: Identifiable {
    let id = UUID()
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
    
    private var synthesizer: AVSpeechSynthesizer?
    private let api: APIController
    
    init(api: APIController) {
        self.api = api
        if enableSpeech {
            synthesizer = .init()
        }
    }
    
    func toggleSpeech() {
        enableSpeech.toggle()
    }
    
    @MainActor
    func presentTextInputAndSend() async {
        WKExtension.shared()
            .visibleInterfaceController?
            .presentTextInputController(
                withSuggestions: [],
                allowedInputMode: .allowEmoji
            ) { result in
                guard let result = result as? [String], let firstElement = result.first else { return }
                Task { @MainActor in
                    guard !firstElement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    self.inputMessage = firstElement.trimmingCharacters(in: .whitespacesAndNewlines)
                    await self.sendTapped()
                }
            }
    }
    
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
    
    @MainActor
    private func send(text: String) async {
        isInteractingWithChatGPT = true
        var streamText = ""
        var messageRow = MessageRow(
            isInteractingWithChatGPT: true,
            sendText: text,
            responseText: streamText,
            responseError: nil)
        
        self.messages.append(messageRow)
        
        do {
            let stream = try await api.sendMessageStream(text: text)
            for try await text in stream {
                streamText += text
                messageRow.responseText = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
                self.messages[self.messages.count - 1] = messageRow
            }
        } catch {
            messageRow.responseError = error.localizedDescription
        }
        
        messageRow.isInteractingWithChatGPT = false
        self.messages[self.messages.count - 1] = messageRow
        isInteractingWithChatGPT = false
        speakLastResponse()
    }
    
    func speakLastResponse() {
        guard let synthesizer, let responseText = self.messages.last?.responseText, !responseText.isEmpty else {
            return
        }
        stopSpeaking()
        let utterance = AVSpeechUtterance(string: responseText)
        utterance.voice = .init(language: language)
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        synthesizer?.stopSpeaking(at: .immediate)
    }
}
