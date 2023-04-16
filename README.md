# ChatGPT SwiftUI App

This is a hackable SwiftUI Chat application that utilizes the [ChatGPT Bridge server](https://gist.github.com/aynik/9160a02686e34b114ecfa7bdcbf2f559) to provide an interactive conversation experience. The app allows users to send and receive messages with the ChatGPT AI model. The app also supports configurable speech synthesis, enabling the user to hear the AI's response.

## Images

<img src="https://github.com/aynik/WatchGPT/blob/master/simulator-0.png?raw=true" width="175"> <img src="https://github.com/aynik/WatchGPT/blob/master/simulator-1.png?raw=true" width="175"> <img src="https://github.com/aynik/WatchGPT/blob/master/simulator-2.png?raw=true" width="175"> <img src="https://github.com/aynik/WatchGPT/blob/master/simulator-3.png?raw=true" width="175">

## Features

- Send and receive messages with ChatGPT
- Speech synthesis for AI responses
- Retry sending failed messages
- Clear the chat history
- Enable/disable speech synthesis
- Choose the language for speech synthesis (English, Spanish, Japanese), but you can add your own.
- Take dictation in different languages by adding new keyboard languages in your iPhone settings.

## Files

- `AppMain.swift`: The main entry point for the SwiftUI application.
- `ViewModel.swift`: Contains the logic for the application, including sending messages, managing chat history, and handling speech synthesis.
- `APIController.swift`: Handles API communication with the ChatGPT server.
- `SettingsView.swift`: Provides a view for users to configure app settings, such as language and speech synthesis.
- `MessageRowView.swift`: Renders a message row in the chat history, displaying both the user's message and the AI's response.
- `ContentView.swift`: Displays the main chat interface and manages user interactions.

## Usage

1. Clone the repository.
2. Create `Secrets.xcconfig` with `API_HOST=my.chatgpt.bridge.com:12345`.
2. Open the project in Xcode.
3. Run the app on an iOS simulator or an iOS device.

Note: You may need to update the API endpoints in `APIController.swift` to match your ChatGPT Bridge server configuration.

## Disclaimer

It was developed for my Apple Watch Series 3 (38mm) so maybe you will need new complication images if you want to use it with another model.

## Requirements

- Xcode 14 or later
- WatchOS 8 or later
- A running ChatGPT Bridge server

## Copyright

2023 © ChatGPT
