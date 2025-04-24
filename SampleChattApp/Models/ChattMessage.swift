//
//  ChattMessage.swift
//  SampleChattApp
//
//  Created by Jaya Sabeen on 23/04/25.
//

import Foundation
import SwiftUI


struct ChattMessage: Codable, Hashable {
    let message: String
    let bot: String
    var status: MessageStatus? 
    var botType: ChatBot {
        return ChatBot.getChatBotFrom(bot: bot)
    }
}

enum MessageStatus: String, Codable {
    case sent
    case received
    case unKnown
}

enum ChatBot: String {
    case supportBot = "SupportBot"
    case salesBot = "SalesBot"
    case faqBot = "FAQBot"
    
    static func getChatBotFrom(bot: String) -> ChatBot {
        if bot == "SupportBot" {
            return .supportBot
        } else if bot == "SalesBot" {
            return .salesBot
        } else {
            return .faqBot
        }
    }
    
    var iconName: String {
        switch self {
        case .faqBot:
            return "questionmark.circle"
        case .salesBot:
            return "cart"
        case .supportBot:
            return "person.2"
        }
    }
}

enum ConnectionStatus: String {
    case connecting
    case connected
    case disconnected
    case canceled
    
    static func getBgColor(status: Self) -> Color {
        switch status {
        case .connecting:
            return .connecting
        case .connected:
            return .connected
        case .disconnected:
            return .disConnected
        case .canceled:
            return .canceled
        }
    }
    
}
