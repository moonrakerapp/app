import Moonraker
import UIKit

let moonraker = Moonraker()
@UIApplicationMain final class App: UIViewController, UIApplicationDelegate {
    var window: UIWindow?
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        moonraker.date = .init()
        view.traitCollectionDidChange(traitCollection)
    }
}
