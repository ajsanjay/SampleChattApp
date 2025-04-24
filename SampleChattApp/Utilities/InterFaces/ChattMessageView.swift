//
//  ChattMessageView.swift
//  SampleChattApp
//
//  Created by Jaya Sabeen on 23/04/25.
//

import SwiftUI

struct ChattMessageView: View {
    
    @Binding var chattMessage: String
    @Binding var sendTapped: Bool
    
    var body: some View {
        HStack {
            TextField("Type a message", text: $chattMessage)
            Button {
                sendTapped.toggle()
            } label: {
                Image(systemName: "paperplane.fill")
            }
        }
    }
}

#Preview {
    ChattMessageView(chattMessage: .constant(""), sendTapped: .constant(false))
}
