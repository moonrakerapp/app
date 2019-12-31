import AppKit

private(set) weak var app: App!
@NSApplicationMain final class App: NSApplication, NSApplicationDelegate {
    private(set) weak var main: Main!
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { true }
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        app = self
        delegate = self
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }
    
    func applicationWillFinishLaunching(_: Notification) {
        let _main = Main()
        _main.makeKeyAndOrderFront(nil)
        main = _main
    }
}
