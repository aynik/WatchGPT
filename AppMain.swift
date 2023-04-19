import SwiftUI

@main
struct AppMain: App {
  @StateObject var vm = ViewModel(api: APIController())

  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView(vm: vm)
      }
    }
  }
}
