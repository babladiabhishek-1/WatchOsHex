//
//  ContentView.swift
//  HEXWatch
//
//  Created by abhishekbabladi on 2025-02-07.
//

import SwiftUI
import Combine
import WatchConnectivity
import FirebaseDatabase

struct ContentViewPhone: View {
    @StateObject private var watchSession = WatchSessionManager.shared  // ✅ Observing updates

    var body: some View {
        VStack {
            HStack {
                Text("❤️")
                    .font(.system(size: 50))
                Spacer()
            }
            
            HStack {
                Text("\(watchSession.receivedHeartRate)") // ✅ Automatically updates via Combine
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
    
    @Published var receivedHeartRate: Int = 0  // ✅ Automatically updates UI

    private var cancellables = Set<AnyCancellable>()  // ✅ Store Combine subscriptions
    private let ref = Database.database().reference()  // ✅ Firebase reference

    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }

        // 🔄 Automatically update Firebase when heart rate changes
        $receivedHeartRate
            .removeDuplicates()  // ✅ Only update if value actually changes
            .sink { bpm in
                self.updateFirebase(bpm: bpm)
            }
            .store(in: &cancellables)
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
        WCSession.default.activate()  // 🔄 Reactivate session if needed
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let bpm = message["heartRate"] as? Int {
            DispatchQueue.main.async {
                self.receivedHeartRate = bpm  // ✅ Triggers UI update & Firebase update
            }
        }
    }
    
    private func updateFirebase(bpm: Int) {
        ref.child("BPM").setValue(bpm) { (error, _) in
            if let error = error {
                print("❌ Firebase Write Error: \(error.localizedDescription)")
            } else {
                print("✅ BPM successfully written to Firebase: \(bpm)")
            }
        }
    }
}
#Preview {
    ContentViewPhone()
}
