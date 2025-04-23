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
            ScrollView {
                ForEach(viewModel.chatBots, id: \.self) { bot in
                    BotView(title: bot)
                        .padding(.leading)
                        .padding(.trailing)
                }
            }
        }
    }
}

#Preview {
    WelcomeScreen()
}
