//
//  Item.swift
//  HEXWatch
//
//  Created by abhishekbabladi on 2025-02-07.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
