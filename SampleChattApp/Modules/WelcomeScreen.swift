//
//  WelcomeScreen.swift
//  SampleChattApp
//
//  Created by Jaya Sabeen on 23/04/25.
//

import SwiftUI

struct WelcomeScreen: View {
    
    @StateObject private var viewModel = WelcomeScreenViewModel()
    
    var body: some View {
        ZStack {
            DefaultBG()
            VStack {
                ConnectionStatusView(status: viewModel.connectionStatus)
                ScrollView {
                    ForEach(viewModel.chatBots, id: \.self) { bot in
                        BotView(title: bot, subtitle: viewModel.getSubTitle(botTyp: ChatBot.getChatBotFrom(bot: bot)))
                            .padding(.leading)
                            .padding(.trailing)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.selectedBot = ChatBot.getChatBotFrom(bot: bot)
                                }
                            }
                        if viewModel.selectedBot == ChatBot.getChatBotFrom(bot: bot) {
                            conversationList(for: viewModel.selectedBot)
                        }
                    }
                }
                
                ChattMessageView(botType: viewModel.selectedBot, chattMessage: $viewModel.chatText) {
                    let chattMessage = ChattMessage(message: viewModel.chatText, bot: viewModel.selectedBot.rawValue, status: .sent)
                    viewModel.send(message: chattMessage)
                }
            }
        }
    }
    
    @ViewBuilder
        private func conversationList(for bot: ChatBot) -> some View {
            switch bot {
            case .supportBot:
                ForEach(viewModel.supportBot, id: \.self) { conversation in
                    ChattConversation(message: conversation.message, status: conversation.status ?? .sent)
                }
            case .salesBot:
                ForEach(viewModel.salesBot, id: \.self) { conversation in
                    ChattConversation(message: conversation.message, status: conversation.status ?? .sent)
                }
            case .faqBot:
                ForEach(viewModel.faqBot, id: \.self) { conversation in
                    ChattConversation(message: conversation.message, status: conversation.status ?? .sent)
                }
            }
        }
}

#Preview {
    WelcomeScreen()
}
