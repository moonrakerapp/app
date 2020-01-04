import Moonraker
import Combine
import AppKit

@NSApplicationMain final class App: NSApplication, NSApplicationDelegate {
    private var subs = Set<AnyCancellable>()
    private let moonraker = Moonraker()
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        delegate = self
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }
    
    func applicationWillFinishLaunching(_: Notification) {
        let window = Window()
        window.makeKeyAndOrderFront(nil)
        moonraker.info.receive(on: DispatchQueue.main).sink { window.horizon.info = $0 }.store(in: &subs)
        moonraker.times.receive(on: DispatchQueue.main).sink { window.stats.times = $0 }.store(in: &subs)
    }
    
    func applicationDidBecomeActive(_: Notification) {
        moonraker.update(.init(timeIntervalSinceNow: 60 * 60 * 20), latitude: 52.483343, longitude: 13.452053)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }
}
