import SwiftUI

struct ContentView: View {
    @ObservedObject var vm: ViewModel
    @FocusState var isTextFieldFocused: Bool
    @State private var showSettings: Bool = false
    
    // Separate action functions for better readability
    private func sendTextInput() {
        Task {
            await vm.presentTextInputAndSend()
        }
    }
    
    private func retryMessage(message: MessageRow) {
        Task { @MainActor in
            await vm.retry(message: message)
        }
    }
    
    // Separate view components for better readability
    private func sendButton() -> some View {
        Button(action: sendTextInput) {
            Text("Send")
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
    
    private func speakButton() -> some View {
        Button(action: { vm.speakLastResponse() }) {
            Text("Speak")
                .font(.footnote)
                .foregroundColor(.green)
        }
    }
    
    private func retryButton(message: MessageRow) -> some View {
        Button(action: { retryMessage(message: message) }) {
            Text("Retry")
                .font(.footnote)
                .foregroundColor(.red)
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                HStack {
                    // Send or clear messages button
                    if (vm.messages.isEmpty) {
                        sendButton()
                    } else {
                        Button(action: { vm.clearMessages() }) {
                            Text("Clear")
                                .font(.footnote)
                                .foregroundColor(.red)
                        }.disabled(vm.isInteractingWithChatGPT)
                    }
                    
                    // Settings button
                    NavigationLink(destination: SettingsView(vm: vm)) {
                        Image(systemName: "gear")
                    }
                }
                .padding(.bottom)
                
                // Message list
                LazyVStack(spacing: 0) {
                    ForEach(vm.messages) { message in
                        MessageRowView(message: message) { message in
                            retryMessage(message: message)
                        }
                    }
                }
                .onTapGesture {
                    isTextFieldFocused = false
                }
                
                // Send, speak, or retry buttons
                if let lastMessage = vm.messages.last, lastMessage.isInteractingWithChatGPT == false {
                    HStack {
                        if lastMessage.responseError == nil {
                            sendButton()
                            speakButton()
                        } else {
                            retryButton(message: lastMessage)
                        }
                    }
                }
            }
            .onChange(of: vm.messages.last?.responseText) { _ in
                guard let id = vm.messages.last?.id else { return }
                proxy.scrollTo(id, anchor: .topLeading)
            }
        }
        .navigationTitle("WatchGPT")
        .background(.black)
        .padding(.top)
    }
}
