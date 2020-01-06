import Moonraker
import AppKit
import CoreLocation

let moonraker = Moonraker()
@NSApplicationMain final class App: NSApplication, NSApplicationDelegate, CLLocationManagerDelegate {
    private let location = CLLocationManager()

    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        delegate = self
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }
    
    func applicationWillFinishLaunching(_: Notification) {
        mainMenu = Menu()
        Window().makeKeyAndOrderFront(nil)
        
        location.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        location.delegate = self
        location.requestLocation()
    }
    
    func applicationDidBecomeActive(_: Notification) {
        moonraker.date = .init()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }
    
    func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) {
        didUpdateLocations.first.map {
            moonraker.coords = ($0.coordinate.latitude, $0.coordinate.longitude)
        }
    }
    
    func locationManager(_: CLLocationManager, didFailWithError: Error) {

    }
}
