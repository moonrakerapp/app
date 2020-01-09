import AppKit

final class About: NSWindow {
    init() {
        super.init(contentRect: .init(x: 0, y: 0, width: 350, height: 200), styleMask: [.borderless, .closable, .titled, .unifiedTitleAndToolbar, .fullSizeContentView], backing: .buffered, defer: false)
        center()
        appearance = NSAppearance(named: .darkAqua)
        backgroundColor = .clear
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        toolbar = .init()
        toolbar!.showsBaselineSeparator = false
        isOpaque = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        isMovableByWindowBackground = true
        contentView!.wantsLayer = true
        contentView!.layer!.backgroundColor = .black
        contentView!.layer!.borderColor = .shade(0.5)
        contentView!.layer!.borderWidth = 1
        contentView!.layer!.cornerRadius = 5
        
        let icon = Image("splash")
        contentView!.addSubview(icon)
        
        let title = Label([(.key("About.title") + "\n", .bold(20), .haze()),
                           (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String, .regular(14), .shade())])
        contentView!.addSubview(title)
        
        icon.widthAnchor.constraint(equalToConstant: 120).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 120).isActive = true
        icon.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor, constant: 10).isActive = true
        icon.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 40).isActive = true
        
        title.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
    }
}
