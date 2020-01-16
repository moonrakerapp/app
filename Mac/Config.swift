import AppKit
import Combine

final class Config: NSWindow {
    private weak var year: Label!
    private weak var month: Label!
    private var sub: AnyCancellable!
    private let column = CGFloat(50)
    private let margin = CGFloat(30)
    private let calendar = Calendar.current
    private let yearer = DateFormatter()
    private let monther = DateFormatter()
    
    init() {
        super.init(contentRect: .init(x: 0, y: 0, width: 410, height: 540), styleMask: [.borderless, .closable, .titled, .unifiedTitleAndToolbar, .fullSizeContentView], backing: .buffered, defer: false)
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
        
        yearer.dateFormat = "YYYY"
        monther.dateFormat = "MMMM"
        
        let year = Label("", .light(16), .haze())
        contentView!.addSubview(year)
        self.year = year
        
        let month = Label("", .medium(16), .haze())
        contentView!.addSubview(month)
        self.month = month
        
        (0 ..< 7).forEach {
            let weekday = Label(.key("Config.weekday.\($0)"), .regular(12), .shade())
            contentView!.addSubview(weekday)
            
            weekday.topAnchor.constraint(equalTo: month.bottomAnchor, constant: 20).isActive = true
            weekday.centerXAnchor.constraint(equalTo: contentView!.leftAnchor, constant: (column * (.init($0) + 0.5)) + margin).isActive = true
        }
        
        sub = moonraker.calendar.receive(on: DispatchQueue.main).sink {
            let comp = self.calendar.dateComponents([.year, .month], from: $0)
            year.stringValue = self.yearer.string(from: $0)
            month.stringValue = self.monther.string(from: $0)
        }
        
        year.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        year.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: margin).isActive = true
        
        month.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        month.topAnchor.constraint(equalTo: year.bottomAnchor, constant: 5).isActive = true
    }
}
