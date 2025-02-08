
import SwiftUI
import HealthKit
import WatchConnectivity
import Combine

class HeartRateManager: NSObject, ObservableObject {
    private var healthStore = HKHealthStore()
    private let heartRateUnit = HKUnit(from: "count/min")

    @Published var heartRate: Int = 0  // ✅ Automatically updates UI
    private var cancellables = Set<AnyCancellable>()  // ✅ Store Combine subscriptions

    override init() {
        super.init()
        authorizeHealthKit()
        
        // 🔄 Automatically send heart rate updates to iPhone
        $heartRate
            .removeDuplicates()  // ✅ Avoid redundant sends
            .sink { bpm in
                self.sendHeartRateToiPhone(bpm)
            }
            .store(in: &cancellables)
    }

    func authorizeHealthKit() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let typesToRead: Set = [heartRateType]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                print("✅ HealthKit Authorization Granted")
                self.startHeartRateMonitoring()
            } else {
                print("❌ HealthKit Authorization Failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func startHeartRateMonitoring() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }

        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { _, samples, _, _, _ in
            guard let samples = samples as? [HKQuantitySample] else { return }
            self.processHeartRate(samples)
        }
        
        query.updateHandler = { _, samples, _, _, _ in
            guard let samples = samples as? [HKQuantitySample] else { return }
            self.processHeartRate(samples)
        }
        
        healthStore.execute(query)
    }

    private func processHeartRate(_ samples: [HKQuantitySample]) {
        guard let lastSample = samples.last else { return }
        let bpm = Int(lastSample.quantity.doubleValue(for: heartRateUnit))
        
        DispatchQueue.main.async {
            self.heartRate = bpm  // ✅ UI automatically updates
        }
    }

    private func sendHeartRateToiPhone(_ bpm: Int) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["heartRate": bpm], replyHandler: nil, errorHandler: nil)
            print("📡 Sent heart rate: \(bpm) BPM to iPhone")
        }
    }
}

struct ContentViewWatch: View {
    @StateObject private var heartRateManager = HeartRateManager()  // ✅ Uses Combine for updates

    var body: some View {
        VStack {
            Text("Heart Rate: \(heartRateManager.heartRate) BPM")
                .font(.largeTitle)
                .foregroundColor(.red)
                .padding()
        }
    }
}




class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchSessionManager()

     override init() {
        super.init()

        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {}

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewWatch()
    }
}
