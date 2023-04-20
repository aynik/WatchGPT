import Foundation

enum GptModel: String, CaseIterable, Identifiable {
  case gpt35 = "gpt-3.5-turbo"
  case gpt4 = "gpt-4"
  
  var id: String {
    self.rawValue
  }
  
  var displayName: String {
    switch self {
    case .gpt35:
      return "GPT 3.5 Turbo"
    case .gpt4:
      return "GPT 4"
    }
  }
  
  var chatEndpoint: String {
    switch self {
    case .gpt35:
      return "/chat"
    case .gpt4:
      return "/chat-4"
    }
  }
  
  var chatContinueEndpoint: String {
    switch self {
    case .gpt35:
      return "/chat-continue"
    case .gpt4:
      return "/chat-continue-4"
    }
  }
}
