import SwiftUI

struct MessageRowView: View {
    let message: MessageRow
    let retryCallback: (MessageRow) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            messageRow(text: message.sendText, bgColor: .gray.opacity(0.1))
            Divider()
            
            if let text = message.responseText {
                messageRow(text: text, bgColor: .black, responseError: message.responseError, showDotLoading: message.isInteractingWithChatGPT)
            }
        }
    }
    
    func messageRow(text: String, bgColor: Color, responseError: String? = nil, showDotLoading: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            messageRowContent(text: text, responseError: responseError, showDotLoading: showDotLoading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bgColor)
    }
    
    @ViewBuilder
    func messageRowContent(text: String, responseError: String? = nil, showDotLoading: Bool = false) -> some View {
        VStack(alignment: .leading) {
            if !text.isEmpty {
                Text(text)
                    .multilineTextAlignment(.leading)
            }
            
            if let error = responseError {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.leading)
            }
            
            if showDotLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
    }
}
