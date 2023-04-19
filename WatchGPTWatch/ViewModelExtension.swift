import Foundation
import SwiftUI
import AVKit

extension ViewModel {
  @MainActor
  func presentTextInputAndSend() async {
    WKExtension.shared()
      .visibleInterfaceController?
      .presentTextInputController(
        withSuggestions: [],
        allowedInputMode: .allowEmoji
      ) { [weak self] result in
        guard let self = self,
              let result = result as? [String],
              let firstElement = result.first,
              !firstElement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }
        
        Task { @MainActor in
          self.inputMessage = firstElement.trimmingCharacters(in: .whitespacesAndNewlines)
          await self.sendTapped()
        }
      }
  }
}
