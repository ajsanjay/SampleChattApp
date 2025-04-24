//
//  BotView.swift
//  SampleChattApp
//
//  Created by Jaya Sabeen on 23/04/25.
//

import SwiftUI

struct BotView: View {
    
    let title: String
    var iconName: String {
        switch ChatBot.getChatBotFrom(bot: title) {
        case .faqBot:
            return "questionmark.circle"
        case .salesBot:
            return "cart"
        case .supportBot:
            return "person.2"
        }
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
            HStack {
                Text(title)
                    .padding(.leading)
                Spacer()
                Image(systemName: iconName)
                    .padding(.trailing)
            }
            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            .foregroundColor(.black)
        }
        .frame(width: MockData.screenWidth * 0.9, height: 90)
        .cornerRadius(15)
        .opacity(0.5)
        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    BotView(title: "Faq")
}
