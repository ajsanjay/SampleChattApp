//
//  ChattMessage.swift
//  SampleChattApp
//
//  Created by Jaya Sabeen on 23/04/25.
//

import Foundation


struct ChattMessage: Codable {
    let message: String
    let bot: String
    var botType: ChatBot {
        return ChatBot.getChatBotFrom(bot: bot)
    }
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
}
