//
//  NextPrayerTimeLocationManager.swift
//  PrayPal Watch App
//
//  Created by Rangga Biner on 21/05/24.
//

import Foundation
import CoreLocation
import Combine

class NextPrayerTimeLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var cancellable: AnyCancellable?
    
    @Published var province: String = "Unknown"
    @Published var city: String = "Unknown"
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard let placemark = placemarks?.first else { return }
            self.province = placemark.administrativeArea ?? "Unknown"
            self.city = placemark.locality ?? "Unknown"
            
            // Call your function to load prayer times here
            if let prayerTimes = loadPrayerTimes(for: Date(), province: self.province, city: self.city) {
                let nextPrayerTime = getNextPrayerTime(currentTime: Date(), prayerTimes: prayerTimes)
                print("Next prayer time: \(nextPrayerTime)")
            } else {
                print("Prayer times not available for the current location.")
            }
        }
    }
}
