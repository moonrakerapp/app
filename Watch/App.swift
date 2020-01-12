import Moonraker
import WatchKit

let moonraker = Moonraker()
final class App: NSObject, WKExtensionDelegate {
    func applicationDidBecomeActive() {
        moonraker.date = .init()
    }
}
