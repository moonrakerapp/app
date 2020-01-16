import AppKit
import Combine

final class Config: NSWindow {
    private weak var year: Label!
    private weak var month: Label!
    private var selected = DateComponents()
    private var sub: AnyCancellable!
    private let column = CGFloat(50)
    private let margin = CGFloat(30)
    private let calendar = Calendar.current
    private let yearer = DateFormatter()
    private let monther = DateFormatter()
    
    init() {
        let window = NSApp.windows.first { $0 is Window }!
        super.init(contentRect: .init(
            x: min(window.frame.maxX + 1, NSScreen.main!.frame.maxX - 410),
            y: window.frame.maxY - 640,
            width: 410, height: 640),
                   styleMask: [.borderless, .closable, .titled, .unifiedTitleAndToolbar, .fullSizeContentView], backing: .buffered, defer: false)
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
        contentView!.layer!.borderColor = .shade(0.6)
        contentView!.layer!.borderWidth = 1
        contentView!.layer!.cornerRadius = 5
        
        yearer.dateFormat = "yyyy"
        monther.dateFormat = "MMMM"
        
        let year = Label("", .regular(14), .shade())
        contentView!.addSubview(year)
        self.year = year
        
        let month = Label("", .medium(16), .haze())
        contentView!.addSubview(month)
        self.month = month
        
        (0 ..< 7).forEach {
            let weekday = Label(.key("Config.weekday.\($0)"), .regular(12), .shade())
            contentView!.addSubview(weekday)
            
            weekday.topAnchor.constraint(equalTo: month.bottomAnchor, constant: 30).isActive = true
            weekday.centerXAnchor.constraint(equalTo: contentView!.leftAnchor, constant: (column * (.init($0) + 0.5)) + margin).isActive = true
        }
        
        sub = moonraker.calendar.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.refresh($0)
        }
        
        year.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        year.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: margin).isActive = true
        
        month.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        month.topAnchor.constraint(equalTo: year.bottomAnchor, constant: 5).isActive = true
    }
    
    func day(_ day: Int) {
        selected.day = day
        animate()
        
        moonraker.offset = calendar.date(from: selected)!.timeIntervalSince1970 - moonraker.date.timeIntervalSince1970
    }
    
    private func refresh(_ date: Date) {
        let new = calendar.dateComponents([.year, .month, .day, .timeZone], from: date)
        guard new != selected else { return }
        if new.year == selected.year && new.month == selected.month {
            selected = new
            animate()
        } else {
            changeDays(date)
        }
    }
    
    private func animate() {
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.7
            $0.allowsImplicitAnimation = true
            contentView!.subviews.compactMap { $0 as? Day }.forEach {
                $0.selected = $0.day == selected.day!
            }
        }
    }
    
    private func changeDays(_ date: Date) {
        selected = calendar.dateComponents([.year, .month, .day], from: date)
        year.stringValue = yearer.string(from: date)
        month.stringValue = monther.string(from: date)
        contentView!.subviews.filter { $0 is Day }.forEach { $0.removeFromSuperview() }
        
        let span = calendar.dateInterval(of: .month, for: date)!
        let start = calendar.dateComponents([.weekday, .day], from: span.start)
        var weekday = start.weekday!
        var top = CGFloat(60)
        var left = ((.init(weekday) - 0.5) * column) + margin
        (start.day! ... calendar.component(.day, from: calendar.date(byAdding: .day, value: -1, to: span.end)!)).forEach {
            let day = Day($0, self)
            day.selected = $0 == selected.day!
            contentView!.addSubview(day)
            
            day.topAnchor.constraint(equalTo: month.bottomAnchor, constant: top).isActive = true
            day.centerXAnchor.constraint(equalTo: contentView!.leftAnchor, constant: left).isActive = true
            
            if weekday == 7 {
                weekday = 1
                top += column
                left = (0.5 * column) + margin
            } else {
                weekday += 1
                left += column
            }
        }
    }
}
