import Moonraker
import AppKit

final class Stats: NSView {
    var times: Times! {
        didSet {
            switch times {
            case .down:
                riseTime.stringValue = "-"
                riseCounter.stringValue = ""
                setTime.stringValue = .key("Stats.down")
                setCounter.stringValue = ""
            case .up:
                riseTime.stringValue = .key("Stats.up")
                riseCounter.stringValue = ""
                setTime.stringValue = "-"
                setCounter.stringValue = ""
            case .rise(let time):
                riseTime.stringValue = formatter.string(from: time)
                riseCounter.stringValue = ""
                setTime.stringValue = "-"
                setCounter.stringValue = ""
            case .set(let time):
                riseTime.stringValue = "-"
                riseCounter.stringValue = ""
                setTime.stringValue = formatter.string(from: time)
                setCounter.stringValue = ""
            case .both(let rise, let set):
                riseTime.stringValue = formatter.string(from: rise)
                riseCounter.stringValue = relative.localizedString(for: rise, relativeTo: .init())
                setTime.stringValue = formatter.string(from: set)
                setCounter.stringValue = relative.localizedString(for: set, relativeTo: .init())
            case .none: break
            }
        }
    }
    
    private weak var riseTime: Label!
    private weak var riseCounter: Label!
    private weak var setTime: Label!
    private weak var setCounter: Label!
    private let formatter = DateFormatter()
    private let relative = RelativeDateTimeFormatter()
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        
        let rise = item(.key("Stats.rise"))
        riseTime = rise.1
        riseCounter = rise.2
        
        let set = item(.key("Stats.set"))
        setTime = set.1
        setCounter = set.2
        
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        rise.0.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        set.0.topAnchor.constraint(equalTo: rise.3.bottomAnchor, constant: 10).isActive = true
    }
    
    private func item(_ title: String) -> (Label, Label, Label, NSView) {
        let title = Label(title, .medium(14), .shade())
        title.maximumNumberOfLines = 1
        addSubview(title)
        
        let time = Label("", .regular(14), .rain())
        time.maximumNumberOfLines = 1
        addSubview(time)
        
        let counter = Label("", .regular(14), .white)
        counter.maximumNumberOfLines = 1
        addSubview(counter)
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = .shade(0.3)
        addSubview(border)
        
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -30).isActive = true
        
        time.leftAnchor.constraint(equalTo: title.rightAnchor, constant: 5).isActive = true
        time.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -30).isActive = true
        time.bottomAnchor.constraint(equalTo: title.bottomAnchor).isActive = true
        
        counter.leftAnchor.constraint(equalTo: time.rightAnchor, constant: 5).isActive = true
        counter.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -30).isActive = true
        counter.bottomAnchor.constraint(equalTo: title.bottomAnchor).isActive = true
        
        border.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return (title, time, counter, border)
    }
}
