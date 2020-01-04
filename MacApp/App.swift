import Moonraker
import Combine
import AppKit

@NSApplicationMain final class App: NSApplication, NSApplicationDelegate {
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
        let window = Window()
        window.makeKeyAndOrderFront(nil)
        moonraker.info.receive(on: DispatchQueue.main).sink { window.horizon.info = $0 }.store(in: &subs)
        moonraker.times.receive(on: DispatchQueue.main).sink { window.stats.times = $0 }.store(in: &subs)
        
        timer.activate()
        timer.schedule(deadline: .distantFuture)
        timer.setEventHandler {
            window.stats.tick()
        }
    }
    
    func applicationDidBecomeActive(_: Notification) {
        moonraker.update(.init(), latitude: 0, longitude: 0)
        timer.schedule(deadline: .now() + 0.2, repeating: 0.5)
    }
    
    func applicationDidResignActive(_: Notification) {
        timer.schedule(deadline: .distantFuture)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }
}
