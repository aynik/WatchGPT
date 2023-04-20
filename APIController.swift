import Foundation
import SwiftUI

struct Message {
  let role: String
  let content: String
}

extension Array where Element == Message {
  var contentCount: Int { reduce(0, { $0 + $1.content.count })}
}

class APIController: @unchecked Sendable {
  @AppStorage("model") var model: String = "gpt-3.5-turbo"
  @AppStorage("baseUrl") var baseUrl: String = ""
  
  private var historyList = [Message]()
  private let urlSession = URLSession.shared
  private var urlRequest: URLRequest {
    var chatEndpoint = ""
    var chatContinueEndpoint = ""
    for gptModel in GptModel.allCases {
      if gptModel.rawValue == model {
        chatEndpoint = gptModel.chatEndpoint
        chatContinueEndpoint = gptModel.chatContinueEndpoint
      }
    }
    let url = historyList.count > 0 ?
    URL(string: "\(baseUrl)\(chatContinueEndpoint)") :
    URL(string: "\(baseUrl)\(chatEndpoint)")
    var urlRequest = URLRequest(url: url!)
    urlRequest.httpMethod = "POST"
    return urlRequest
  }
  
  private func appendToHistoryList(userText: String, responseText: String) {
    self.historyList.append(.init(role: "user", content: userText))
    self.historyList.append(.init(role: "assistant", content: responseText))
  }
  
  func sendMessageStream(text: String) async throws -> AsyncThrowingStream<String, Error> {
    var urlRequest = self.urlRequest
    urlRequest.httpBody = text.data(using: .utf8)
    
    let (result, response) = try await urlSession.bytes(for: urlRequest)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      throw "Invalid response"
    }
    
    guard 200...299 ~= httpResponse.statusCode else {
      var errorText = ""
      for try await line in result.lines {
        errorText += line
      }
      
      throw "Bad Response: \(httpResponse.statusCode), \(errorText)"
    }
    
    return AsyncThrowingStream<String, Error> { continuation in
      Task(priority: .userInitiated) { [weak self] in
        guard let self = self else { return }
        do {
          var responseText = ""
          for try await character in result.characters {
            let text = String(character)
            responseText += text
            continuation.yield(text)
          }
          self.appendToHistoryList(userText: text, responseText: responseText)
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }
    }
  }
  
  func deleteHistoryList() {
    self.historyList.removeAll()
  }
}

extension String: CustomNSError {
  public var errorUserInfo: [String : Any] {
    [
      NSLocalizedDescriptionKey: self
    ]
  }
}
