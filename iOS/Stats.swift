import Moonraker
import UIKit
import Combine

final class Stats: UIViewController {
    private var times: AnyCancellable!
    private var phases: AnyCancellable!
    private let timer = DispatchSource.makeTimerSource(queue: .main)
    private weak var top: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .init(white: 0, alpha: 0.85)
        let counter = RelativeDateTimeFormatter()
        let remains = DateComponentsFormatter()
        remains.allowedUnits = [.month, .weekOfMonth, .day]
        
        let date = DateFormatter()
        date.dateFormat = "d/M"
        
        let time = DateFormatter()
        time.dateFormat = "HH:mm"
        
        let outside = Button(self, #selector(close))
        view.addSubview(outside)
        
        let base = UIView()
        base.backgroundColor = .black
        base.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(base)
        
        let _close = Button(self, #selector(close))
        view.addSubview(_close)
        
        let icon = Image("close")
        _close.addSubview(icon)
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.isUserInteractionEnabled = false
        border.backgroundColor = .shade(0.3)
        view.addSubview(border)
        
        let rise = Stat("rise")
        rise.accessibilityLabel = .key("Stats.rise")
        base.addSubview(rise)
        
        let set = Stat("set")
        set.accessibilityLabel = .key("Stats.set")
        base.addSubview(set)
        
        let new = Stat("new")
        new.accessibilityLabel = .key("Stats.new")
        base.addSubview(new)
        
        let full = Stat("full")
        full.accessibilityLabel = .key("Stats.full")
        base.addSubview(full)
        
        times = moonraker.times.receive(on: DispatchQueue.main).sink {
            switch $0 {
            case .down:
                rise.date.text = "-"
                rise.counter.text = ""
                set.date.text = .key("Stats.down")
            case .up:
                rise.date.text = .key("Stats.up")
                set.date.text = "-"
                set.counter.text = ""
            case .rise(let _rise):
                rise.date.text = time.string(from: _rise)
                set.date.text = "-"
                set.counter.text = ""
            case .set(let _set):
                rise.date.text = "-"
                rise.counter.text = ""
                set.date.text = time.string(from: _set)
            case .both(let _rise, let _set):
                rise.date.text = time.string(from: _rise)
                set.date.text = time.string(from: _set)
            }
        }
        
        phases = moonraker.phases.receive(on: DispatchQueue.main).sink {
            let now = Date()
            if Calendar.current.date(byAdding: .hour, value: -23, to: $0.0)! < now {
                new.date.text = .key("Stats.now")
                new.counter.text = ""
            } else {
                new.date.text = date.string(from: $0.0)
                new.counter.text = remains.string(from: now, to: $0.0) ?? ""
            }
            
            if Calendar.current.date(byAdding: .hour, value: -23, to: $0.1)! < now {
                full.date.text = .key("Stats.now")
                full.counter.text = ""
            } else {
                full.date.text = date.string(from: $0.1)
                full.counter.text = remains.string(from: now, to: $0.1) ?? ""
            }
        }
        
        timer.activate()
        timer.schedule(deadline: .now(), repeating: 1)
        timer.setEventHandler {
            let now = Date()
            switch moonraker.times.value {
            case .rise(let time):
                rise.counter.text = counter.localizedString(for: time, relativeTo: now)
            case .set(let time):
                set.counter.text = counter.localizedString(for: time, relativeTo: now)
            case .both(let _rise, let _set):
                rise.counter.text = counter.localizedString(for: _rise, relativeTo: now)
                set.counter.text = counter.localizedString(for: _set, relativeTo: now)
            default: break
            }
        }
        
        outside.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        outside.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        outside.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        outside.bottomAnchor.constraint(equalTo: base.topAnchor).isActive = true
        
        border.topAnchor.constraint(equalTo: base.topAnchor, constant: 1).isActive = true
        border.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        rise.topAnchor.constraint(equalTo: base.topAnchor, constant: 40).isActive = true
        rise.rightAnchor.constraint(equalTo: set.leftAnchor).isActive = true
        
        set.topAnchor.constraint(equalTo: base.topAnchor, constant: 40).isActive = true
        set.rightAnchor.constraint(equalTo: base.centerXAnchor, constant: -5).isActive = true
        
        new.topAnchor.constraint(equalTo: base.topAnchor, constant: 40).isActive = true
        new.leftAnchor.constraint(equalTo: base.centerXAnchor, constant: 5).isActive = true
        
        full.topAnchor.constraint(equalTo: base.topAnchor, constant: 40).isActive = true
        full.leftAnchor.constraint(equalTo: new.rightAnchor).isActive = true
        
        _close.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        _close.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _close.heightAnchor.constraint(equalToConstant: 60).isActive = true
        _close.bottomAnchor.constraint(equalTo: base.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        
        icon.leftAnchor.constraint(equalTo: _close.leftAnchor).isActive = true
        icon.rightAnchor.constraint(equalTo: _close.rightAnchor).isActive = true
        icon.topAnchor.constraint(equalTo: _close.topAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: _close.bottomAnchor).isActive = true
        
        base.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        base.heightAnchor.constraint(equalToConstant: 250).isActive = true
        top = base.topAnchor.constraint(equalTo: view.bottomAnchor)
        top.isActive = true
        
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        top.constant = -250
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc private final func close() {
        top.constant = 0
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
        presentingViewController!.dismiss(animated: true)
    }
}
