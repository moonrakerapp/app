import Moonraker
import WatchKit
import CoreLocation

let moonraker = Moonraker()
final class App: NSObject, WKExtensionDelegate, CLLocationManagerDelegate {
    private let location = CLLocationManager()
    
    func applicationDidFinishLaunching() {
        location.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        location.delegate = self
    }
    
    func applicationDidBecomeActive() {
        moonraker.date = .init()
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            location.requestLocation()
        }
    }
    
    func locationManager(_: CLLocationManager, didChangeAuthorization: CLAuthorizationStatus) {
        switch didChangeAuthorization {
        case .denied: break
        case .notDetermined: location.requestWhenInUseAuthorization()
        default: location.requestLocation()
        }
    }
    
    func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) {
        didUpdateLocations.first.map {
            moonraker.coords = ($0.coordinate.latitude, $0.coordinate.longitude)
        }
    }
    
    func locationManager(_: CLLocationManager, didFailWithError: Error) {

    }
}
