import Moonraker
import AppKit
import Combine

final class Stats: NSView {
    private var sub: AnyCancellable!
    private let timer = DispatchSource.makeTimerSource(queue: .main)
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let formatter = DateComponentsFormatter()
        let rise = item()
        let set = item()
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = .shade(0.4)
        addSubview(border)
        
        sub = moonraker.times.receive(on: DispatchQueue.main).sink {
            switch $0 {
            case .down:
                rise.0.stringValue = .key("Stats.rise") + " -"
                rise.1.stringValue = ""
                set.0.stringValue = .key("Stats.down")
            case .up:
                rise.0.stringValue = .key("Stats.up")
                set.0.stringValue = .key("Stats.set") + " -"
                set.1.stringValue = ""
            case .rise(_):
                rise.0.stringValue = .key("Stats.rise")
                set.0.stringValue = .key("Stats.set") + " -"
                set.1.stringValue = ""
            case .set(_):
                rise.0.stringValue = .key("Stats.rise") + " -"
                rise.1.stringValue = ""
                set.0.stringValue = .key("Stats.set")
            case .both( _, _):
                rise.0.stringValue = .key("Stats.rise")
                set.0.stringValue = .key("Stats.set")
            }
        }
        
        timer.activate()
        timer.schedule(deadline: .now(), repeating: 1)
        timer.setEventHandler {
            let now = Date()
            switch moonraker.times.value {
            case .rise(let time):
                rise.1.stringValue = formatter.string(from: now, to: time) ?? ""
            case .set(let time):
                set.1.stringValue = formatter.string(from: now, to: time) ?? ""
            case .both(let _rise, let _set):
                rise.1.stringValue = formatter.string(from: now, to: _rise) ?? ""
                set.1.stringValue = formatter.string(from: now, to: _set) ?? ""
            default: break
            }
        }
        
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        rise.0.bottomAnchor.constraint(equalTo: border.topAnchor, constant: -5).isActive = true
        set.0.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40).isActive = true
        
        border.bottomAnchor.constraint(equalTo: set.0.topAnchor, constant: -5).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.rightAnchor.constraint(greaterThanOrEqualTo: rise.1.rightAnchor).isActive = true
        border.rightAnchor.constraint(greaterThanOrEqualTo: set.1.rightAnchor).isActive = true
    }
    
    private func item() -> (Label, Label) {
        let title = Label("", .bold(14), .shade())
        addSubview(title)
        
        let counter = Label("", .regular(14), .rain())
        addSubview(counter)
        
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -10).isActive = true
        
        counter.leftAnchor.constraint(equalTo: title.rightAnchor).isActive = true
        counter.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -10).isActive = true
        counter.bottomAnchor.constraint(equalTo: title.bottomAnchor).isActive = true
        
        return (title, counter)
    }
}
