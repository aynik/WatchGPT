import SwiftUI

struct TextFieldClearButton: ViewModifier {
  @Binding var fieldText: String
  
  func body(content: Content) -> some View {
    content
      .overlay {
        if !fieldText.isEmpty {
          HStack {
            Spacer()
            Button {
              fieldText = ""
            } label: {
              Image(systemName: "multiply.circle.fill")
            }
            .foregroundColor(.secondary)
            .padding(.trailing, 10)
          }
        }
      }
  }
}

extension View {
  func showClearButton(_ text: Binding<String>) -> some View {
    self.modifier(TextFieldClearButton(fieldText: text))
  }
}
