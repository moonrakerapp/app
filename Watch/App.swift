import Moonraker
import WatchKit
import CoreLocation
import Combine

private(set) weak var app: App!
final class App: NSObject, WKExtensionDelegate, CLLocationManagerDelegate {
    let moonraker = Moonraker()
    private var background: WKRefreshBackgroundTask?
    private(set) var phase = Phase.new
    private(set) var fraction = CGFloat()
    private var sub: AnyCancellable?
    private let complication = Moonraker()
    private let location = CLLocationManager()
    
    override init() {
        super.init()
        app = self
        sub = complication.info.sink {
            self.phase = $0.phase
            self.fraction = .init($0.fraction)
            CLKComplicationServer.sharedInstance().activeComplications?.forEach(CLKComplicationServer.sharedInstance().reloadTimeline(for:))
            self.background?.setTaskCompletedWithSnapshot(false)
            self.background = nil
        }
    }
    
    func applicationDidFinishLaunching() {
        location.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        location.delegate = self
    }
    
    func applicationDidBecomeActive() {
        moonraker.date = .init()
        complication.date = .init()
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            location.requestLocation()
        }
    }
    
    func applicationWillResignActive() {
        schedule()
        WKExtension.shared().rootInterfaceController!.becomeCurrentPage()
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        background?.setTaskCompletedWithSnapshot(false)
        background = nil
        if let first = backgroundTasks.first {
            background = first
            complication.date = .init()
        }
        schedule()
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
            complication.coords = ($0.coordinate.latitude, $0.coordinate.longitude)
        }
    }
    
    func locationManager(_: CLLocationManager, didFailWithError: Error) {

    }
    
    private func schedule() {
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date().addingTimeInterval(3600), userInfo: nil) { _ in }
    }
}
