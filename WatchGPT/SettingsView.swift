import SwiftUI

struct SettingsView: View {
    @ObservedObject var vm: ViewModel
    
    var body: some View {
        NavigationView {
            Form {
                textToSpeechToggle()
                languagePicker()
            }
            .navigationBarTitle("Settings")
            .padding(.top)
        }
    }
    
    // Text to speech toggle component
    private func textToSpeechToggle() -> some View {
        Toggle(isOn: $vm.enableSpeech) {
            Text("Enable Text to Speech")
        }
    }
    
    // Language picker component
    private func languagePicker() -> some View {
        Picker("Language", selection: $vm.language) {
            ForEach(SpeechLanguage.allCases) { language in
                Text(language.displayName).tag(language.rawValue)
            }
        }
    }
}
