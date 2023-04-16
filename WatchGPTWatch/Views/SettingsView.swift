import SwiftUI

struct SettingsView: View {
    @ObservedObject var vm: ViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Language")) {
                Picker("Language", selection: $vm.language) {
                    Text("English").tag("en-US")
                    Text("Español").tag("es-ES")
                    Text("日本語").tag("ja-JP")
                }
            }
            
            Section(header: Text("Speech")) {
                Toggle("Enable Speech", isOn: $vm.enableSpeech)
            }
        }
        .navigationTitle("Settings")
    }
}
