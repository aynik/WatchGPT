import SwiftUI

struct ContentView: View {
  @ObservedObject var vm: ViewModel
  @FocusState var isTextFieldFocused: Bool
  
  // Separate action functions for better readability
  private func retryMessage(message: MessageRow) {
    Task { @MainActor in
      await vm.retry(message: message)
    }
  }
  
  private func scrollToBottom(proxy: ScrollViewProxy) {
    guard let id = vm.messages.last?.id else { return }
    proxy.scrollTo(id, anchor: .bottomTrailing)
  }
  
  // Separate view components for better readability
  private var chatListView: some View {
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
    .background(.black)
  }
  
  private var messageList: some View {
    ScrollView {
      LazyVStack(spacing: 0) {
        ForEach(vm.messages) { message in
          MessageRowView(message: message) { message in
            retryMessage(message: message)
          }
        }
      }
      .onTapGesture {
        vm.speakLastResponse()
        isTextFieldFocused = false
      }
    }
    .clipped()
  }
  
  private func bottomView(proxy: ScrollViewProxy) -> some View {
    HStack(alignment: .top, spacing: 8) {
      TextField("Send message", text: $vm.inputMessage)
        .textFieldStyle(.roundedBorder)
        .focused($isTextFieldFocused)
        .disabled(vm.isInteractingWithChatGPT)
      
      sendButton(proxy: proxy)
    }
    .padding(.horizontal, 16)
    .padding(.top, 12)
  }
  
  private func sendButton(proxy: ScrollViewProxy) -> some View {
    Button {
      Task { @MainActor in
        isTextFieldFocused = false
        scrollToBottom(proxy: proxy)
        await vm.sendTapped()
      }
    } label: {
      Image(systemName: "paperplane.circle.fill")
        .rotationEffect(.degrees(45))
        .font(.system(size: 30))
    }
    .disabled(vm.isInteractingWithChatGPT || vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
  }
  
  var body: some View {
    chatListView
      .navigationTitle("WatchGPT")
      .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
      .toolbar {
        if (!vm.messages.isEmpty) {
          ToolbarItem(placement: .cancellationAction) {
            Button(action: { vm.clearMessages() }) {
              Text("Clear")
                .font(.headline)
                .foregroundColor(.red)
            }.disabled(vm.isInteractingWithChatGPT)
          }
        }
        ToolbarItem(placement: .primaryAction) {
          NavigationLink(destination: SettingsView(vm: vm)) {
            Image(systemName: "gear")
          }
        }
      }
  }
}
