import SwiftUI

struct ContentView: View {
  @Environment(\.colorScheme) var colorScheme
  @ObservedObject var vm: ViewModel
  @FocusState var isTextFieldFocused: Bool
  @State var inputMessage = ""
  @State var isRecording = false
  
  // Recording methods
  func startRecording() {
    guard !isRecording else { return }
    isRecording = true
    SpeechRecognizer.shared.startRecording(language: vm.listeningLanguage) { result in
      if isRecording {
        inputMessage = result
      }
    }
  }
  
  func stopRecording() {
    guard isRecording else { return }
    isRecording = false
    SpeechRecognizer.shared.stopRecording()
  }
  
  // Separate action functions for better readability
  internal func retryMessage(message: MessageRow) {
    Task { @MainActor in
      await vm.retry(message: message)
    }
  }
  
  internal func scrollToBottom(proxy: ScrollViewProxy) {
    guard let id = vm.messages.last?.id else { return }
    proxy.scrollTo(id, anchor: .bottomTrailing)
  }
  
  // Separate view components for better readability
  internal var chatListView: some View {
    ScrollViewReader { proxy in
      VStack(spacing: 0) {
        messageList
        bottomView(proxy: proxy)
        Spacer().frame(height: 20)
      }
      .onChange(of: vm.messages.last?.responseText) {
        _ in scrollToBottom(proxy: proxy)
      }
    }
    .background(colorScheme == .dark ? .black : .white)
    .padding(.top)
  }
  
  internal var messageList: some View {
    ScrollView {
      LazyVStack(spacing: 0) {
        ForEach(vm.messages) { message in
          MessageRowView(vm: vm, message: message) { message in
            retryMessage(message: message)
          }
        }
      }
    }
    .clipped()
    .onTapGesture {
      isTextFieldFocused = false
    }
  }
  
  internal func bottomView(proxy: ScrollViewProxy) -> some View {
    HStack(alignment: .center, spacing: 8) {
      recordButton()
      
      TextField("Send message", text: $inputMessage, axis: .vertical)
        .padding([.vertical, .horizontal], 10)
        .overlay(RoundedRectangle(cornerRadius: 10.0)
          .strokeBorder(.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1.0)))
        .showClearButton($inputMessage)
        .focused($isTextFieldFocused)
        .disabled(vm.isInteractingWithChatGPT)
      
      sendButton(proxy: proxy)
    }
    .padding(.horizontal, 16)
    .padding(.top, 12)
  }
  
  internal func recordButton() -> some View {
    if Synthesizer.shared.isSpeaking {
      return AnyView(Button(action: {
        Synthesizer.shared.stopSpeaking()
        vm.isSpeaking = false
      }) {
        Image(systemName: "stop.circle.fill")
          .font(.system(size: 30))
          .foregroundColor(.red)
      })
    } else {
      return AnyView(Button(action: {
        if isRecording {
          stopRecording()
        } else {
          startRecording()
        }
      }) {
        Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
          .font(.system(size: 30))
      }.disabled(vm.isInteractingWithChatGPT))
    }
  }
  
  
  internal func sendButton(proxy: ScrollViewProxy) -> some View {
    Button {
      stopRecording()
      isTextFieldFocused = false
      scrollToBottom(proxy: proxy)
      Task { @MainActor in
        let text = inputMessage
        self.inputMessage = ""
        await vm.send(text: text)
      }
    } label: {
      Image(systemName: "paperplane.circle.fill")
        .rotationEffect(.degrees(45))
        .font(.system(size: 30))
    }
    .disabled(vm.isInteractingWithChatGPT || inputMessage.isEmpty)
  }
  
  var body: some View {
    chatListView
      .navigationTitle("WatchGPT")
      .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(action: { vm.clearMessages() }) {
            Image(systemName: "trash")
              .foregroundColor(vm.isInteractingWithChatGPT || vm.messages.isEmpty ? .gray : .red)
          }.disabled(vm.isInteractingWithChatGPT || vm.messages.isEmpty)
        }
        ToolbarItem(placement: .primaryAction) {
          NavigationLink(destination: SettingsView(vm: vm)) {
            Image(systemName: "gear")
          }
        }
      }
  }
}
