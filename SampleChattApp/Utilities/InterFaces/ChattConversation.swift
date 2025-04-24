//
//  ChattConversation.swift
//  SampleChattApp
//
//  Created by Jaya Sabeen on 24/04/25.
//

import SwiftUI

struct ChattConversation: View {
    let message: String
    let status: MessageStatus
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
            HStack {
                if status == .received {
                    Image(systemName: "platter.filled.bottom.and.arrow.down.iphone")
                        .padding(.leading)
                    Text(message)
                        .font(.headline)
                        .padding(.top)
                        .padding(.bottom)
                    Spacer()
                } else if status == .sent {
                    Spacer()
                    Text(message)
                        .font(.headline)
                        .padding(.top)
                        .padding(.bottom)
                    Image(systemName: "platter.filled.top.and.arrow.up.iphone")
                        .padding(.trailing)
                } else {
                    Image(systemName: "rectangle.2.swap")
                    Text(message)
                        .font(.headline)
                        .padding(.top)
                        .padding(.bottom)
                }
            }
        }
        .frame(width: MockData.screenWidth * 0.9)
        .cornerRadius(15)
        .opacity(0.5)
        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ChattConversation(message: "Hello", status: .draft)
}
