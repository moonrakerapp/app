import AppKit

final class Menu: NSMenu {
    private let status = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    required init(coder: NSCoder) { fatalError() }
    init() {
        super.init(title: "")
        items = [moonraker, window, help]
        status.button!.image = NSImage(named: "status")
        status.button!.target = self
        status.button!.action = #selector(show)
    }
    
    @objc func calendar() {
        (NSApp.windows.first { $0 is Config } ?? Config()).makeKeyAndOrderFront(nil)
    }

    private var moonraker: NSMenuItem {
        {
            $0.submenu = .init(title: .key("Menu.title"))
            $0.submenu!.items = [
                {
                    $0.target = self
                    return $0
                } (NSMenuItem(title: .key("Menu.about"), action: #selector(about), keyEquivalent: "")),
                .separator(),
                {
                    $0.target = self
                    return $0
                } (NSMenuItem(title: .key("Menu.calendar"), action: #selector(calendar), keyEquivalent: ",")),
                .separator(),
                .init(title: .key("Menu.hide"), action: #selector(NSApplication.hide(_:)), keyEquivalent: "h"),
                {
                    $0.keyEquivalentModifierMask = [.option, .command]
                    return $0
                } (NSMenuItem(title: .key("Menu.hideOthers"), action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h")),
                .init(title: .key("Menu.showAll"), action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: ""),
                .separator(),
                .init(title: .key("Menu.quit"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    }
    
    private var window: NSMenuItem {
        {
            $0.submenu = .init(title: .key("Menu.window"))
            $0.submenu!.items = [
                .init(title: .key("Menu.minimize"), action: #selector(NSWindow.miniaturize(_:)), keyEquivalent: "m"),
                .init(title: .key("Menu.zoom"), action: #selector(NSWindow.zoom(_:)), keyEquivalent: "p"),
                .separator(),
                .init(title: .key("Menu.bringAllToFront"), action: #selector(NSApplication.arrangeInFront(_:)), keyEquivalent: ""),
                .separator(),
                .init(title: .key("Menu.close"), action: #selector(NSWindow.close), keyEquivalent: "w")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    }
    
    private var help: NSMenuItem {
        {
            $0.submenu = .init(title: .key("Menu.help"))
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    }
    
    @objc private func about() {
        (NSApp.windows.first { $0 is About } ?? About()).makeKeyAndOrderFront(nil)
    }
    
    @objc private func show() {
        let pop = Pop()
        pop.show(relativeTo: status.button!.bounds, of: status.button!, preferredEdge: .minY)
        pop.contentViewController!.view.window!.makeKey()
    }
}
