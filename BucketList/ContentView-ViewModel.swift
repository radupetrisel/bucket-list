//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Radu Petrisel on 20.07.2023.
//

import Foundation
import LocalAuthentication
import MapKit

extension ContentView {
    @MainActor final class ViewModel: ObservableObject {
        private let savePath = FileManager.documetsDirectory.appending(path: "SavedPlaces")
        
        @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
        @Published private(set) var locations: [Location]
        @Published var selectedLoation: Location?
        @Published var isUnlocked = false
        
        @Published var biometricError: BiometricError?
        @Published var hasError = false
        
        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }
        
        func addLocation() {
            let location = Location(id: UUID(), name: "New location", description: "", latitude: region.center.latitude, longitude: region.center.longitude)
            locations.append(location)
            save()
        }
        
        func updateLocation(location: Location) {
            guard let selectedLoation = selectedLoation else { return }
            
            if let index = locations.firstIndex(of: selectedLoation) {
                locations[index] = location
                save()
            }
        }
        
        func authenticate() {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate yourself to unlock your places"
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    if success {
                        Task { @MainActor in
                            self.isUnlocked = true
                        }
                    } else {
                        Task { @MainActor in
                            self.biometricError = .nonMatching
                            self.hasError = true
                        }
                    }
                }
            } else {
                biometricError = .unavailable
                hasError = true
            }
        }
        
        private func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomic, .completeFileProtection])
            } catch {
                print("Unable to save data.")
            }
        }
        
        enum BiometricError: LocalizedError {
            case unavailable, nonMatching
            
            var errorDescription: String? {
                switch self {
                case .unavailable:
                    return "Biometrics not available"
                case .nonMatching:
                    return "ID did not match"
                }
            }
        }
    }
}
