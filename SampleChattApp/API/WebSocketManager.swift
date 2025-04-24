//
//  SampleChattAppApp.swift
//  SampleChattApp
//
//  Created by Jaya Sabeen on 23/04/25.
//

import Foundation

class WebSocketManager: ObservableObject {
    @Published var messages: [String] = []

    private var webSocketTask: URLSessionWebSocketTask?

    func connect() {
        guard let url = URL(string: "wss://s14508.blr1.piesocket.com/v3/1?api_key=WtZFD82cFcdbR6baduhjC03IiuU6Q4ktu73p2VQz&notify_self=1") else {
            print("Invalid WebSocket URL")
            return
        }

        webSocketTask = URLSession(configuration: .default).webSocketTask(with: url)
        webSocketTask?.resume()
        print("WebSocket connecting...")
        receiveMessages()
    }

    private func receiveMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("WebSocket receive error: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received: \(text)")
                    DispatchQueue.main.async {
                        self?.messages.append(text)
                    }
                case .data(let data):
                    print("Received unexpected binary data: \(data.count) bytes")
                @unknown default:
                    print("Received unknown WebSocket message")
                }
            }
            // Keep listening!
            self?.receiveMessages()
        }
    }
    
    func send(person: ChattMessage) {
        let encoder = JSONEncoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase 

        do {
            let jsonData = try encoder.encode(person)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let message = URLSessionWebSocketTask.Message.string(jsonString)
                webSocketTask?.send(message) { error in
                    if let error = error {
                        print("WebSocket send error: \(error)")
                    } else {
                        print("Person sent: \(jsonString)")
                    }
                }
            }
        } catch {
            print("Failed to encode Person: \(error)")
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        print("WebSocket disconnected")
    }
}
