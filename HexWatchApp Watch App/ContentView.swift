import SwiftUI
import HealthKit
import FirebaseDatabase

struct ContentView: View {
    private var healthStore = HKHealthStore()
    let ref = Database.database().reference()
    let heartRateQuantity = HKUnit(from: "count/min")
    
    @State private var value = 0
    
    var body: some View {
        VStack {
            HStack {
                Text("❤️")
                    .font(.system(size: 50))
                Spacer()
            }
            
            HStack {
                Text("\(value)")
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
        .onAppear(perform: start)
    }
    
    func start() {
        authorizeHealthKit()
    }

    func authorizeHealthKit() {
        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: healthKitTypes) { success, error in
            if success {
                print("✅ HealthKit Authorization Granted")
                self.startHeartRateMonitoring()
            } else {
                print("❌ HealthKit Authorization Failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    private func startHeartRateMonitoring() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }

        let observerQuery = HKObserverQuery(sampleType: heartRateType, predicate: nil) { _, _, error in
            if let error = error {
                print("❌ Observer Query Error: \(error.localizedDescription)")
                return
            }
            self.startAnchoredQuery(for: .heartRate)
        }
        
        healthStore.execute(observerQuery)
        startAnchoredQuery(for: .heartRate) // Start initial query
    }
    
    private func startAnchoredQuery(for quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier) else { return }

        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = { query, samples, deletedObjects, queryAnchor, error in
            guard let samples = samples as? [HKQuantitySample] else { return }
            self.process(samples, type: quantityTypeIdentifier)
        }

        let query = HKAnchoredObjectQuery(type: quantityType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        query.updateHandler = updateHandler

        healthStore.execute(query)
    }

    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        var lastHeartRate = 0.0
        
        for sample in samples {
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
            }
        }
        
        DispatchQueue.main.async {
            self.value = Int(lastHeartRate)  // ✅ Ensure UI update happens on the main thread
        }
        
        ref.child("BPM").setValue(lastHeartRate) { (error, _) in
            if let error = error {
                print("❌ Firebase Write Error: \(error.localizedDescription)")
            } else {
                print("✅ BPM value successfully written to Firebase: \(lastHeartRate)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
