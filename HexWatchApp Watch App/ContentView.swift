//
//  ContentView.swift
//  HexWatchApp Watch App
//
//  Created by abhishekbabladi on 2025-02-07.
//

import SwiftUI
import FirebaseDatabaseInternal
import HealthKit

struct ContentView: View {
    
    let healthStore: HKHealthStore = .init()
    
    let ref :DatabaseReference! = Database.database().reference()
    
    init () {
        autorizeHealthKit()
    }
    
    var body: some View {
        VStack {
            P266_ViscosityCanvas()
        }
        .padding()
    }
    
    func autorizeHealthKit() {
          
          // Used to define the identifiers that create quantity type objects.
            let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
         // Requests permission to save and read the specified data types.
            healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { _, _ in }
        }
}

#Preview {
    ContentView()
}
