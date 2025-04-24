//
//  ChattMessageView.swift
//  SampleChattApp
//
//  Created by Jaya Sabeen on 23/04/25.
//

import SwiftUI

struct ChattMessageView: View {
    @Binding var chattMessage: String
    var onSend: () -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            TextField("Type your message...", text: $chattMessage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.title2)
                .fontWeight(.medium)
                .focused($isFocused)
                .foregroundColor(.black)
            
            Button(action: {
                if !chattMessage.trimmingCharacters(in: .whitespaces).isEmpty {
                    onSend()
                    chattMessage = ""
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.black)
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
    ChattMessageView(chattMessage: .constant("")) {
        print("Send tapped")
    }
}
