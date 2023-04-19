import SwiftUI

struct MessageRowView: View {
  let message: MessageRow
  let retryCallback: (MessageRow) -> Void
  
  var body: some View {
    VStack(spacing: 0) {
      sentMessageRow()
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
        bgColor: .black,
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
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()
      .contextMenu {
        Button(action: {
          UIPasteboard.general.string = text
        }) {
          Text("Copy")
        }
      }
  }
  
  // Loading indicator component
  private func loadingIndicator(show: Bool) -> some View {
    if show {
      return AnyView(ProgressView()
        .progressViewStyle(CircularProgressViewStyle(tint: .white))
        .scaleEffect(0.7))
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
