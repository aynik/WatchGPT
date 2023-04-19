import SwiftUI

struct MessageRowView: View {
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
        bgColor: .black,
        responseError: message.responseError,
        showDotLoading: message.isInteractingWithChatGPT
      ))
    } else {
      return AnyView(EmptyView())
    }
  }
  
  // Main message row view component
  func messageRow(text: String, bgColor: Color, responseError: String? = nil, showDotLoading: Bool = false) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      messageText(text: text)
      errorMessage(error: responseError)
      loadingIndicator(show: showDotLoading)
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(bgColor)
  }
  
  // Message text component
  private func messageText(text: String) -> some View {
    if !text.isEmpty {
      return AnyView(Text(text)
        .multilineTextAlignment(.leading))
    } else {
      return AnyView(EmptyView())
    }
  }
  
  // Error message component
  private func errorMessage(error: String?) -> some View {
    if let error = error {
      return AnyView(Text("Error: \(error)")
        .foregroundColor(.red)
        .multilineTextAlignment(.leading))
    } else {
      return AnyView(EmptyView())
    }
  }
  
  // Loading indicator component
  private func loadingIndicator(show: Bool) -> some View {
    if show {
      return AnyView(ProgressView()
        .progressViewStyle(CircularProgressViewStyle()))
    } else {
      return AnyView(EmptyView())
    }
  }
}
