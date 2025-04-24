//
//  ConnectionStatusView.swift
//  SampleChattApp
//
//  Created by Jaya Sabeen on 23/04/25.
//

import SwiftUI

struct ConnectionStatusView: View {
    
    let status: ConnectionStatus
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(ConnectionStatus.getBgColor(status: status))
                .opacity(isVisible ? 1 : 0)
                .animation(
                    .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                    value: isVisible
                )
            HStack {
                Text(status.rawValue.capitalized)
                    .foregroundColor(.white)
                    .padding(.leading)
                Spacer()
            }
        }
        .frame(height: 25)
        .onAppear {
            isVisible = true
        }
    }
}

#Preview {
    ConnectionStatusView(status: .connecting)
}
