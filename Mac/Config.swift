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
            y: window.frame.maxY - 680,
            width: 410, height: 680),
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
        
        let _today = Control(self, #selector(today))
        _today.setAccessibilityLabel(.key("Config.today"))
        _today.wantsLayer = true
        _today.layer!.cornerRadius = 14
        _today.layer!.backgroundColor = .shade()
        contentView!.addSubview(_today)
        
        let label = Label(.key("Config.today"), .medium(14), .black)
        _today.addSubview(label)
        
        let stats = Stats()
        contentView!.addSubview(stats)
        
        control("prev", .key("Config.prev.year"), #selector(prevYear), year.centerYAnchor, left: nil, right: year.leftAnchor)
        control("next", .key("Config.next.year"), #selector(nextYear), year.centerYAnchor, left: year.rightAnchor, right: nil)
        control("prev", .key("Config.prev.month"), #selector(prevMonth), month.centerYAnchor, left: nil, right: month.leftAnchor)
        control("next", .key("Config.next.month"), #selector(nextMonth), month.centerYAnchor, left: month.rightAnchor, right: nil)
        
        (0 ..< 7).forEach {
            let weekday = Label(.key("Config.weekday.\($0)"), .regular(12), .shade())
            contentView!.addSubview(weekday)
            
            weekday.topAnchor.constraint(equalTo: month.bottomAnchor, constant: 40).isActive = true
            weekday.centerXAnchor.constraint(equalTo: contentView!.leftAnchor, constant: (column * (.init($0) + 0.5)) + margin).isActive = true
        }
        
        sub = moonraker.calendar.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.refresh($0)
        }
        
        year.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        year.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 50).isActive = true
        
        month.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        month.topAnchor.constraint(equalTo: year.bottomAnchor, constant: 20).isActive = true
        
        _today.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        _today.widthAnchor.constraint(equalToConstant: 80).isActive = true
        _today.heightAnchor.constraint(equalToConstant: 28).isActive = true
        _today.bottomAnchor.constraint(equalTo: stats.topAnchor).isActive = true
        
        label.centerXAnchor.constraint(equalTo: _today.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: _today.centerYAnchor).isActive = true
        
        stats.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        stats.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        stats.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
    }
    
    @objc func day(_ day: Day) {
        guard selected.day != day.day else { return }
        selected.day = day.day
        selected.hour = 12
        animate()
        
        moonraker.offset = calendar.date(from: selected)!.timeIntervalSince1970 - moonraker.date.timeIntervalSince1970
    }
    
    private func refresh(_ date: Date) {
        let new = calendar.dateComponents([.year, .month, .day, .timeZone, .hour], from: date)
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
        var top = CGFloat(70)
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
    
    private func control(_ image: String, _ label: String, _ selector: Selector, _ center: NSLayoutYAxisAnchor, left: NSLayoutXAxisAnchor?, right: NSLayoutXAxisAnchor?) {
        let control = Control(self, selector)
        control.setAccessibilityLabel(label)
        contentView!.addSubview(control)
        
        let image = Image(image)
        control.addSubview(image)
        
        control.centerYAnchor.constraint(equalTo: center).isActive = true
        control.widthAnchor.constraint(equalToConstant: 50).isActive = true
        control.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        image.topAnchor.constraint(equalTo: control.topAnchor).isActive = true
        image.bottomAnchor.constraint(equalTo: control.bottomAnchor).isActive = true
        image.leftAnchor.constraint(equalTo: control.leftAnchor).isActive = true
        image.rightAnchor.constraint(equalTo: control.rightAnchor).isActive = true
        
        if let left = left {
            control.leftAnchor.constraint(equalTo: left, constant: -12).isActive = true
        }
        if let right = right {
            control.rightAnchor.constraint(equalTo: right, constant: 12).isActive = true
        }
    }
    
    private func add(_ amount: Int, _ component: Calendar.Component) {
        selected.hour = 12
        moonraker.offset = calendar.date(byAdding: component, value: amount, to:
            calendar.date(from: selected)!)!.timeIntervalSince1970 - moonraker.date.timeIntervalSince1970
    }
    
    @objc private func today() {
        moonraker.offset = 0
    }
    
    @objc private func prevMonth() {
        add(-1, .month)
    }
    
    @objc private func nextMonth() {
        add(1, .month)
    }
    
    @objc private func prevYear() {
        add(-1, .year)
    }
    
    @objc private func nextYear() {
        add(1, .year)
    }
}
