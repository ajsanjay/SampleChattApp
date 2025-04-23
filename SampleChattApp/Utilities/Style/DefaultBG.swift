//
//  DefaultBG.swift
//  SampleChattApp
//
//  Created by Jaya Sabeen on 23/04/25.
//

import SwiftUI

struct DefaultBG: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.defaultTop, .defaultBottom]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

#Preview {
    DefaultBG()
}
