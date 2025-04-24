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
        case .supportBot: messageArray = supportBot
        case .salesBot: messageArray = salesBot
        case .faqBot: messageArray = faqBot
        }
        return messageArray.last.map { getConversationSubtitle(for: $0) } ?? "No conversations available"
    }

    func getLastMessageStatus(for botType: ChatBot) -> MessageStatus? {
        let messageArray: [ChattMessage]
        switch botType {
        case .supportBot: messageArray = supportBot
        case .salesBot: messageArray = salesBot
        case .faqBot: messageArray = faqBot
        }
        return messageArray.last?.status
    }

    private func getConversationSubtitle(for message: ChattMessage) -> String {
        return message.message
    }
    
    func send(message: ChattMessage) {
        guard connectionStatus == .connected else {
            print("Connection is not established, message cannot be sent.")
            socket = nil
            DispatchQueue.main.asyncAfter(deadline: .now()+2.0, execute: { [weak self] in
                self?.connect()
            })
            return
        }
        
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(message)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                socket.write(string: jsonString) {
                    print("Message sent: \(jsonString)")
                    
                    var updatedMessage = message
                    updatedMessage.status = .sent
                    
                    DispatchQueue.main.async {
                        switch updatedMessage.botType {
                        case .supportBot:
                            self.updateMessageList(&self.supportBot, with: updatedMessage)
                        case .salesBot:
                            self.updateMessageList(&self.salesBot, with: updatedMessage)
                        case .faqBot:
                            self.updateMessageList(&self.faqBot, with: updatedMessage)
                        }
                    }
                }
            }
        } catch {
            print("Failed to encode message: \(error)")
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
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            if message.status == .draft {
                messages[index].status = .sent
            } else {
                messages[index] = message
            }
        } else {
            var newMessage = message
            if newMessage.status == nil || newMessage.status == .draft {
                newMessage.status = .received
            }
            messages.append(newMessage)
        }
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
            connectionStatus = .disconnected
            print("Error: \(String(describing: error))")
        case .cancelled:
            connectionStatus = .canceled
            print("Connection cancelled")
        default:
            break
        }
    }

    private func checkInternetConnectivity(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://www.google.com") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.httpMethod = "HEAD"

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }

    private func retryInternetConnectivity(retries: Int, delay: TimeInterval) {
        checkInternetConnectivity { [weak self] isConnected in
            guard let self = self else { return }

            if isConnected {
                DispatchQueue.main.async {
                    print("[Network] Internet access confirmed.")
                    self.connectionStatus = .connected
                    self.connect()
                }
            } else if retries > 0 {
                print("[Network] Retry checking internet... (\(retries) retries left)")
                DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                    self.retryInternetConnectivity(retries: retries - 1, delay: delay)
                }
            } else {
                DispatchQueue.main.async {
                    print("[Network] No internet after retries.")
                    self.connectionStatus = .noInternet
                }
            }
        }
    }

    private func startNetworkMonitoring() {
        pathMonitor = NWPathMonitor()
        pathMonitor?.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            if path.status == .satisfied {
                DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
                    self.retryInternetConnectivity(retries: 3, delay: 2.0)
                }
            } else {
                DispatchQueue.main.async {
                    print("[Network] Not connected to a network.")
                    self.connectionStatus = .noInternet
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
