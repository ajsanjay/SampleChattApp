//
//  BotView.swift
//  SampleChattApp
//
//  Created by Jaya Sabeen on 23/04/25.
//

import SwiftUI

struct BotView: View {
    
    let title: String
    let subtitle: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
            VStack {
                HStack {
                    Text(title)
                        .padding(.leading)
                    Spacer()
                    Image(systemName: ChatBot.getChatBotFrom(bot: title).iconName)
                        .padding(.trailing)
                }
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .foregroundColor(.black)
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .padding(.leading)
                    Text(subtitle)
                    Spacer()
                }
            }
        }
        .frame(width: MockData.screenWidth * 0.9, height: 90)
        .cornerRadius(15)
        .opacity(0.5)
        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    BotView(title: "Faq", subtitle: "No message history")
}
