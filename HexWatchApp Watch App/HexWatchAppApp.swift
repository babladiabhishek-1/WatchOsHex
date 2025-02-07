//
//  HexWatchAppApp.swift
//  HexWatchApp Watch App
//
//  Created by abhishekbabladi on 2025-02-07.
//

import SwiftUI
import FirebaseCore
@main
struct HexWatchApp_Watch_AppApp: App {
    init() {
           FirebaseApp.configure()
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
