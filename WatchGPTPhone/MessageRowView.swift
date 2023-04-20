import SwiftUI

struct MessageRowView: View {
  @Environment(\.colorScheme) var colorScheme
  @ObservedObject var vm: ViewModel
  
  let message: MessageRow
  let retryCallback: (MessageRow) -> Void
  
  var body: some View {
    VStack(spacing: 0) {
      Divider()
      sentMessageRow()
      Divider()
      receivedMessageRow()
    }
  }
  
  // Sent message row
  private func sentMessageRow() -> some View {
    messageRow(text: message.sendText, bgColor: .gray.opacity(0.1))
  }
  
  // Received message row
  private func receivedMessageRow() -> some View {
    if let text = message.responseText {
      return AnyView(messageRow(
        text: text,
        bgColor: colorScheme == .dark ? .black : .white,
        responseError: message.responseError,
        showDotLoading: message.isInteractingWithChatGPT
      ))
    } else {
      return AnyView(EmptyView())
    }
  }
  
  // Main message row view component
  func messageRow(text: String, bgColor: Color, responseError: Error? = nil, showDotLoading: Bool = false) -> some View {
    VStack {
      messageText(text: text)
      loadingIndicator(show: showDotLoading)
      retryButton(error: responseError)
    }
    .background(bgColor)
  }
  
  // Message text component
  private func messageText(text: String) -> some View {
    Text(text)
      .font(.body)
      .foregroundColor(colorScheme == .dark ? .white : .black)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()
      .contextMenu {
        Button(action: {
          UIPasteboard.general.string = text
        }) {
          Text("Copy")
        }
        Button(action: {
          Synthesizer.shared.speak(language: vm.speakingLanguage, text: text)
        }) {
          Text("Speak")
        }
      }
  }
  
  // Loading indicator component
  private func loadingIndicator(show: Bool) -> some View {
    if show {
      return AnyView(ProgressView()
        .progressViewStyle(CircularProgressViewStyle(tint: colorScheme == .dark ? .white : .black))
        .padding(.bottom))
    } else {
      return AnyView(EmptyView())
    }
  }
  
  // Retry button component
  private func retryButton(error: Error?) -> some View {
    if error != nil {
      return AnyView(VStack {
        Spacer()
        Button(action: { retryCallback(message) }) {
          Text("Retry")
            .font(.body)
            .foregroundColor(.red)
        }
      })
    } else {
      return AnyView(EmptyView())
    }
  }
}
