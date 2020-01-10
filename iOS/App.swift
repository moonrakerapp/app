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
    
    override func viewWillTransition(to size: CGSize, with: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: with)
        with.animate(alongsideTransition: { _ in
            (self.view as! View).align()
        }, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        moonraker.date = .init()
        (view as! View).align()
    }
}
