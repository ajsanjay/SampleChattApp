//
//  ChattMessageView.swift
//  SampleChattApp
//
//  Created by Jaya Sabeen on 23/04/25.
//

import SwiftUI

struct ChattMessageView: View {
    
    let botType: ChatBot
    
    @Binding var chattMessage: String
    var onSend: () -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: botType.iconName)
                Text("Conversation with \(botType.rawValue)")
                Spacer()
            }
            HStack {
                TextField("Type your message...", text: $chattMessage)
                    .autocorrectionDisabled(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .focused($isFocused)
                    .foregroundColor(.black)
                
                Button(action: {
                    if !chattMessage.trimmingCharacters(in: .whitespaces).isEmpty {
                        onSend()
                        chattMessage = ""
                        isFocused = false
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.bottom, 10)
        .onTapGesture {
            isFocused = true
        }
        .opacity(0.5)
        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ChattMessageView(botType: .supportBot, chattMessage: .constant("")) {
        print("Send tapped")
    }
}
