//
//  HexWatchAppApp.swift
//  HexWatchApp Watch App
//
//  Created by abhishekbabladi on 2025-02-07.
//

import SwiftUI
import FirebaseCore
//@main
//struct HexWatchApp_Watch_AppApp: App {
//    init() {
//           FirebaseApp.configure()
//        }
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

@main
struct WatchApp: App {
    @StateObject private var watchSessionManager = WatchSessionManager()

    var body: some Scene {
        WindowGroup {
            ContentViewWatch()
                .onAppear {
                    watchSessionManager.activateSession()
                }
        }
    }
}
