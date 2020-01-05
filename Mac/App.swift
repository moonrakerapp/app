import Moonraker
import Combine
import AppKit
import CoreLocation

@NSApplicationMain final class App: NSApplication, NSApplicationDelegate, CLLocationManagerDelegate {
    private var coords = CLLocationCoordinate2D() {
        didSet {
            update()
        }
    }
    
    private var location: CLLocationManager?
    private var subs = Set<AnyCancellable>()
    private let moonraker = Moonraker()
    private let timer = DispatchSource.makeTimerSource(queue: .main)

    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        delegate = self
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }
    
    func applicationWillFinishLaunching(_: Notification) {
        mainMenu = Menu()
        
        let window = Window()
        window.makeKeyAndOrderFront(nil)
        moonraker.info.receive(on: DispatchQueue.main).sink { window.horizon.info = $0 }.store(in: &subs)
        moonraker.info.receive(on: DispatchQueue.main).sink { window.stats.info = $0 }.store(in: &subs)
        moonraker.info.receive(on: DispatchQueue.main).sink { window.graph.info = $0 }.store(in: &subs)
        moonraker.times.receive(on: DispatchQueue.main).sink { window.stats.times = $0 }.store(in: &subs)
        
        timer.activate()
        timer.schedule(deadline: .distantFuture)
        timer.setEventHandler {
            window.stats.tick()
        }
        
        location = CLLocationManager()
        location!.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        location!.delegate = self
        location!.requestLocation()
    }
    
    func applicationDidBecomeActive(_: Notification) {
        update()
        timer.schedule(deadline: .now(), repeating: 1)
    }
    
    func applicationDidResignActive(_: Notification) {
        timer.schedule(deadline: .distantFuture)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }
    
    func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) {
        didUpdateLocations.first.map { coords = $0.coordinate }
        location?.stopUpdatingLocation()
        location = nil
    }
    
    func locationManager(_: CLLocationManager, didFailWithError: Error) {
        location?.stopUpdatingLocation()
        location = nil
    }
    
    private func update() {
        moonraker.update(.init(), latitude: coords.latitude, longitude: coords.longitude)
    }
}
