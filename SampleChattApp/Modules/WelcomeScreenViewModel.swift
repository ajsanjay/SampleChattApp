//
//  WelcomeScreenViewModel.swift
//  SampleChattApp
//
//  Created by Jaya Sabeen on 23/04/25.
//

import Foundation

class WelcomeScreenViewModel: ObservableObject {
    @Published var supportBot: [ChattMessage] = []
    @Published var salesBot: [ChattMessage] = []
    @Published var faqBot: [ChattMessage] = []
    @Published var chatText = ""
    let chatBots = ["SupportBot", "SalesBot", "FAQBot"]
}
