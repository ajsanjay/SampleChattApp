//
//  WelcomeScreenViewModel.swift
//  SampleChattApp
//
//  Created by Jaya Sabeen on 23/04/25.
//

import Foundation
import Starscream
import Network

class WelcomeScreenViewModel: ObservableObject, WebSocketDelegate {
    
    @Published var supportBot: [ChattMessage] = []
    @Published var salesBot: [ChattMessage] = []
    @Published var faqBot: [ChattMessage] = []
    @Published var chatText = ""
    @Published var connectionStatus: ConnectionStatus = .connecting
    @Published var selectedBot: ChatBot = .supportBot
    @Published var unKnownMessage: [String] = []
    
    private var pathMonitor: NWPathMonitor?
    private let queue = DispatchQueue.global(qos: .background)
    
    let chatBots = ["SupportBot", "SalesBot", "FAQBot"]
    var socket: WebSocket!
    
    init() {
        connect()
        startNetworkMonitoring()
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
        let messageArray: [ChattMessage]
        
        switch botTyp {
        case .supportBot:
            messageArray = supportBot
        case .salesBot:
            messageArray = salesBot
        case .faqBot:
            messageArray = faqBot
        }
        
        return messageArray.last.map { getConversationSubtitle(for: $0) } ?? "No conversations available"
    }
    
    func getLastMessageStatus(for botType: ChatBot) -> MessageStatus? {
        let messageArray: [ChattMessage]
        
        switch botType {
        case .supportBot:
            messageArray = supportBot
        case .salesBot:
            messageArray = salesBot
        case .faqBot:
            messageArray = faqBot
        }
        
        return messageArray.last?.status
    }

    private func getConversationSubtitle(for message: ChattMessage) -> String {
        return message.message
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
    
    func appendMessage(_ message: ChattMessage) {
        switch message.botType {
        case .supportBot:
            supportBot.append(message)
        case .salesBot:
            salesBot.append(message)
        case .faqBot:
            faqBot.append(message)
        }
    }
    
    func handleReceivedText(_ jsonString: String) {
        let decoder = JSONDecoder()
        if let data = jsonString.data(using: .utf8) {
            do {
                var message = try decoder.decode(ChattMessage.self, from: data)
                message.status = message.status ?? .received
                
                switch message.botType {
                case .supportBot:
                    updateMessageList(&supportBot, with: message)
                case .salesBot:
                    updateMessageList(&salesBot, with: message)
                case .faqBot:
                    updateMessageList(&faqBot, with: message)
                }
                
            } catch {
                unKnownMessage.append(jsonString)
                print("Failed to decode message: \(error)")
            }
        }
    }
    
    private func updateMessageList(_ messages: inout [ChattMessage], with message: ChattMessage) {
        guard let status = message.status else {
            messages.append(message)
            return
        }
        if status == .draft {
            if let index = messages.firstIndex(where: { $0.id == message.id }) {
                messages[index].status = .sent
                print("Updated message \(message.message) to .sent")
                return
            }
        }
        messages.append(message)
    }
    
    func messages(for bot: ChatBot) -> [ChattMessage] {
        switch bot {
        case .supportBot: return supportBot
        case .salesBot: return salesBot
        case .faqBot: return faqBot
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
            connectionStatus = .connected
            handleReceivedText(text)
            print("Received text: \(text)")
        case .binary(let data):
            connectionStatus = .connected
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
    
    private func startNetworkMonitoring() {
        pathMonitor = NWPathMonitor()
        pathMonitor?.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self?.connectionStatus = .connected
                } else {
                    self?.connectionStatus = .noInternet
                }
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        pathMonitor?.start(queue: queue)
    }
    
    deinit {
        pathMonitor?.cancel()
    }
    
}
