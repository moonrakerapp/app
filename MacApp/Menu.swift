import AppKit

final class Menu: NSMenu {
    required init(coder: NSCoder) { fatalError() }
    init() {
        super.init(title: "")
        items = [moonraker, window, help]
    }

    private var moonraker: NSMenuItem {
        {
            $0.submenu = .init(title: .key("Menu.title"))
            $0.submenu!.items = [
                .init(title: .key("Menu.about"), action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: ","),
                .separator(),
                .init(title: .key("Menu.hide"), action: #selector(NSApplication.hide(_:)), keyEquivalent: "h"),
                { $0.keyEquivalentModifierMask = [.option, .command]
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
}
