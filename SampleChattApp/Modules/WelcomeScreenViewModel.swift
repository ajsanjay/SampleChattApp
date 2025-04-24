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
        print("Connecting to WebSocket...")
    }
    
    func disconnect() {
        socket.disconnect()
        connectionStatus = .disconnected
        print("Disconnected from WebSocket")
    }
    
    func send(person: ChattMessage) {
        let encoder = JSONEncoder()
        
        do {
            let jsonData = try encoder.encode(person)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                socket.write(string: jsonString) {
                    print("Person sent: \(jsonString)")
                }
            }
        } catch {
            print("Failed to encode Person: \(error)")
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
