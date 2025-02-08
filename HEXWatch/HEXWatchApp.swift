//
//  HEXWatchApp.swift
//  HEXWatch
//
//  Created by abhishekbabladi on 2025-02-07.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct HEXWatchApp: App {
    init() {
           FirebaseApp.configure()
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
