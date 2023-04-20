import SwiftUI

struct SettingsView: View {
  @ObservedObject var vm: ViewModel
  
  var body: some View {
    NavigationView {
      Form {
        modelPicker()
        #if os(iOS)
        listeningLanguagePicker()
        #endif
        speakingToggle()
        speakingLanguagePicker()
        baseUrlInput()
      }
      .navigationBarTitle("Settings")
      .padding(.top)
    }
  }
  
  // Model picker component
  private func modelPicker() -> some View {
    Picker("Model", selection: $vm.model) {
      ForEach(GptModel.allCases) { model in
        Text(model.displayName).tag(model.rawValue)
      }
    }
  }
  
  // Listening language picker component
  private func listeningLanguagePicker() -> some View {
    Picker("Listening Language", selection: $vm.listeningLanguage) {
      ForEach(SpeechLanguage.allCases) { language in
        Text(language.displayName).tag(language.rawValue)
      }
    }
  }
  
  // Text to speech toggle component
  private func speakingToggle() -> some View {
    Toggle(isOn: $vm.enableSpeaking) {
      Text("Enable Speaking")
    }
  }
  
  // Speaking language picker component
  private func speakingLanguagePicker() -> some View {
    Picker("Speaking Language", selection: $vm.speakingLanguage) {
      ForEach(SpeechLanguage.allCases) { language in
        Text(language.displayName).tag(language.rawValue)
      }
    }
  }
  
  // URL input component
  private func baseUrlInput() -> some View {
    TextField("Base URL", text: $vm.baseUrl)
      .autocorrectionDisabled()
  }
}
