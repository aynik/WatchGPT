import SwiftUI

struct ContentView: View {
  @ObservedObject var vm: ViewModel
  @FocusState var isTextFieldFocused: Bool
  @State private var showSettings: Bool = false
  
  var body: some View {
    ScrollViewReader { proxy in
      ScrollView(showsIndicators: false) {
        HStack {
          if (vm.messages.isEmpty) {
            Button(action: { Task {
              await vm.presentTextInputAndSend()
            } }) {
              Text("Send")
                .font(.footnote)
                .foregroundColor(.white)
            }
          } else {
            Button(action: { vm.clearMessages() }) {
              Text("Clear")
                .font(.footnote)
                .foregroundColor(.red)
            }.disabled(vm.isInteractingWithChatGPT)
          }
          
          NavigationLink(destination: SettingsView(vm: vm)) {
            Image(systemName: "gear")
          }.opacity(0.8)
        }
        .padding(.bottom)

        LazyVStack(spacing: 0) {
          ForEach(vm.messages) { message in
            MessageRowView(message: message) { message in
              Task { @MainActor in
                await vm.retry(message: message)
              }
            }
          }
        }
        .onTapGesture {
          isTextFieldFocused = false
        }

        if let lastMessage = vm.messages.last, lastMessage.isInteractingWithChatGPT == false {
          HStack {
            if lastMessage.responseError == nil {
              Button(action: { Task {
                await vm.presentTextInputAndSend()
              } }) {
                Text("Send")
                  .font(.footnote)
                  .foregroundColor(.gray)
              }
              Button(action: { vm.speakLastResponse() }) {
                Text("Speak")
                  .font(.footnote)
                  .foregroundColor(.green)
              }
            } else {
              Button(action: { Task { @MainActor in
                await vm.retry(message: lastMessage)
              }}) {
                Text("Retry")
                  .font(.footnote)
                  .foregroundColor(.red)
              }
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
