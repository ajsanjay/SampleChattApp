//
//  MockData.swift
//  SampleChattApp
//
//  Created by Jaya Sabeen on 23/04/25.
//

import Foundation
import UIKit

struct MockData {

    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    
    static let mockChatt: [ChattMessage] = [ChattMessage(message: "Hello", bot: "SupportBot"), ChattMessage(message: "Updates", bot: "SalesBot"), ChattMessage(message: "Hai", bot: "FAQBot")]
    
}
