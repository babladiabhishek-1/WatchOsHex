//
//  ContentView.swift
//  HEXWatch
//
//  Created by abhishekbabladi on 2025-02-07.
//

import SwiftUI
import WatchConnectivity
import FirebaseDatabase

struct ContentView: View {
    @StateObject private var watchSession = WatchSessionManager.shared  // 🔥 Observe the shared session

    var body: some View {
        VStack {
            HStack {
                Text("❤️")
                    .font(.system(size: 50))
                Spacer()
            }
            
            HStack {
                Text("\(watchSession.receivedHeartRate)") // ✅ Dynamically updates UI
                    .fontWeight(.regular)
                    .font(.system(size: 70))
                
                Text("BPM")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.red)
                    .padding(.bottom, 28.0)
                
                Spacer()
            }
        }
        .padding()
        .onAppear {
            watchSession.activateSession()
        }
    }
}

class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchSessionManager()
    
    @Published var receivedHeartRate: Int = 0  // ✅ Now linked to UI

    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("📡 WCSession activated with state: \(activationState.rawValue)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("📡 WCSession inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()  // 🔄 Reactivate session if deactivated
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let bpm = message["heartRate"] as? Int {
            DispatchQueue.main.async {
                self.receivedHeartRate = bpm  // ✅ Triggers UI update
            }
            
            // Save to Firebase
            let ref = Database.database().reference()
            ref.child("BPM").setValue(bpm) { (error, _) in
                if let error = error {
                    print("❌ Firebase Write Error: \(error.localizedDescription)")
                } else {
                    print("✅ BPM value successfully written to Firebase: \(bpm)")
                }
            }
        }
    }
}
#Preview {
    ContentView()
}
