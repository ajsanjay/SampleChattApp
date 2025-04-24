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
                ConnectionStatusView(status: viewModel.connectionStatus) {
//                    viewModel.recreateSocketAndConnect()
                }
                    .padding(.bottom)
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
                    .padding(.top)
                }
                
                ChattMessageView(botType: viewModel.selectedBot, chattMessage: $viewModel.chatText) {
                    let chattMessage = ChattMessage(message: viewModel.chatText, bot: viewModel.selectedBot.rawValue, status: .draft)
                    viewModel.appendMessage(chattMessage)
                    viewModel.send(message: chattMessage)
                }
            }
        }
    }
    
    @ViewBuilder
    private func conversationList(for bot: ChatBot) -> some View {
        let conversations = viewModel.messages(for: bot)
        
        ForEach(conversations, id: \.self) { conversation in
            ChattConversation(message: conversation.message, status: conversation.status ?? .received)
                .onTapGesture {
                    if conversation.status == .draft {
                        viewModel.send(message: conversation)
                    }
                }
        }
    }
}

#Preview {
    WelcomeScreen()
}
