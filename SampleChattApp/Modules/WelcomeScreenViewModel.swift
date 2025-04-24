//
//  WelcomeScreenViewModel.swift
//  SampleChattApp
//
//  Created by Jaya Sabeen on 23/04/25.
//

import Foundation
import Starscream

class WelcomeScreenViewModel: ObservableObject, WebSocketDelegate {
    
    @Published var supportBot: [ChattMessage] = []
    @Published var salesBot: [ChattMessage] = []
    @Published var faqBot: [ChattMessage] = []
    @Published var chatText = ""
    @Published var connectionStatus: ConnectionStatus = .connecting
    @Published var selectedBot: ChatBot = .supportBot
    @Published var unKnownMessage: [String] = []
    
    let chatBots = ["SupportBot", "SalesBot", "FAQBot"]
    var socket: WebSocket!
    
    init() {
        connect()
    }
    
    func connect() {
        guard let url = URL(string: "wss://s14508.blr1.piesocket.com/v3/1?api_key=WtZFD82cFcdbR6baduhjC03IiuU6Q4ktu73p2VQz&notify_self=1") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
        connectionStatus = .connecting
    }
    
    func disconnect() {
        socket.disconnect()
        connectionStatus = .disconnected
    }
    
    func getSubTitle(botTyp: ChatBot) -> String {
        switch botTyp {
        case .supportBot:
            return supportBot.count == 0 ? "No converstions available" : (supportBot.count == 1 ? "1 Conversation available" : "\(supportBot.count) Conversation's available")
        case .salesBot:
            return salesBot.count == 0 ? "No converstions available" : (salesBot.count == 1 ? "1 Conversation available" : "\(salesBot.count) Conversation's available")
        case .faqBot:
            return faqBot.count == 0 ? "No converstions available" : (faqBot.count == 1 ? "1 Conversation available" : "\(faqBot.count) Conversation's available")
        }
    }
    
    func send(message: ChattMessage) {
        let encoder = JSONEncoder()
        
        do {
            let jsonData = try encoder.encode(message)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                socket.write(string: jsonString) {
                    print("Person sent: \(jsonString)")
                }
            }
        } catch {
            print("Failed to encode Person: \(error)")
        }
    }
    
    func handleReceivedText(_ jsonString: String) {
        let decoder = JSONDecoder()
        if let data = jsonString.data(using: .utf8) {
            do {
                var message = try decoder.decode(ChattMessage.self, from: data)
                if let status = message.status {
                    message.status = status
                } else {
                    message.status = .received
                }
                if message.botType == .supportBot {
                    supportBot.append(message)
                } else if message.botType == .salesBot {
                    salesBot.append(message)
                } else {
                    faqBot.append(message)
                }
            } catch {
                unKnownMessage.append(jsonString)
                print("Failed to decode message: \(error)")
            }
        }
    }
    
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            connectionStatus = .connected
            print("Connected with headers: \(headers)")
        case .disconnected(let reason, let code):
            connectionStatus = .disconnected
            print("Disconnected: \(reason) (code: \(code))")
        case .text(let text):
            handleReceivedText(text)
            print("Received text: \(text)")
        case .binary(let data):
            print("Received binary: \(data.count) bytes")
        case .error(let error):
            print("Error: \(String(describing: error))")
        case .cancelled:
            connectionStatus = .canceled
            print("Connection cancelled")
        default:
            break
        }
    }
    
}
