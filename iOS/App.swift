import Moonraker
import UIKit
import CoreLocation

let moonraker = Moonraker()
@UIApplicationMain final class App: UIViewController, UIApplicationDelegate, CLLocationManagerDelegate {
    var window: UIWindow?
    private let location = CLLocationManager()
    
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let window = UIWindow()
        window.overrideUserInterfaceStyle = .dark
        window.rootViewController = self
        window.backgroundColor = .black
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
    
    func applicationWillEnterForeground(_: UIApplication) {
        moonraker.date = .init()
    }
    
    override func loadView() {
        view = View()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        location.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        location.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        moonraker.date = .init()
        (view as! View).align()
    }
    
    override func viewWillTransition(to size: CGSize, with: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: with)
        with.animate(alongsideTransition: { _ in
            (self.view as! View).align()
        }, completion: nil)
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
