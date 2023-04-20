import Foundation

enum SpeechLanguage: String, CaseIterable, Identifiable {
  case enUS = "en-US"
  case esES = "es-ES"
  case jaJP = "ja-JP"
  
  var id: String {
    self.rawValue
  }
  
  var displayName: String {
    switch self {
    case .enUS:
      return "English (US)"
    case .esES:
      return "Español (ES)"
    case .jaJP:
      return "日本語 (JP)"
    }
  }
}
