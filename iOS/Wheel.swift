import UIKit

final class Wheel: UIView {
    weak var horizon: Horizon!
    private weak var date: Label!
    private weak var disk: Disk!
    private weak var zoom: Image!
    private weak var now: Image!
    private weak var forward: Image!
    private weak var backward: Image!
    private let _date = DateFormatter()
    private let _time = DateFormatter()
    private let ratio = CGFloat(360)
    private let haptics = UIImpactFeedbackGenerator(style: .light)
    
    private var drag = Drag.no {
        didSet {
            highlight()
        }
    }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        haptics.prepare()
        translatesAutoresizingMaskIntoConstraints = false
        _date.dateFormat = "MM.dd.yy\n"
        _time.dateFormat = "h a"
        
        widthAnchor.constraint(equalToConstant: 300).isActive = true
        heightAnchor.constraint(equalToConstant: 320).isActive = true
        
        let disk = Disk()
        layer.addSublayer(disk)
        self.disk = disk
        
        let date = Label([])
        date.numberOfLines = 2
        addSubview(date)
        self.date = date
        
        zoom = control("zoom")
        now = control("now")
        forward = control("forward")
        backward = control("backward")
        
        date.bottomAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
        date.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        zoom.centerYAnchor.constraint(equalTo: topAnchor, constant: 87).isActive = true
        zoom.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        now.centerYAnchor.constraint(equalTo: bottomAnchor, constant: -67).isActive = true
        now.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        forward.centerYAnchor.constraint(equalTo: topAnchor, constant: 170).isActive = true
        forward.centerXAnchor.constraint(equalTo: rightAnchor, constant: -67).isActive = true
        
        backward.centerYAnchor.constraint(equalTo: topAnchor, constant: 170).isActive = true
        backward.centerXAnchor.constraint(equalTo: leftAnchor, constant: 67).isActive = true
        
        highlight()
        update()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        super.touchesBegan(touches, with: with)
        if valid(touches.first!.location(in: self)) {
            haptics.impactOccurred()
            drag = .start(x: 0, y: 0)
        } else {
            drag = .no
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with: UIEvent?) {
        super.touchesMoved(touches, with: with)
        let point = touches.first!.location(in: self)
        let previous = touches.first!.previousLocation(in: self)
        if valid(point) {
            disk.rotate(atan2(point.x - 150, 170 - point.y))
            switch drag {
            case .drag:
                rotate(point, point.x - previous.x, point.y - previous.y)
            case .start(var x, var y):
                x += point.x - previous.x
                y += point.y - previous.y
                if abs(x) + abs(y) > 15 {
                    rotate(point, x, y)
                    drag = .drag
                } else {
                    drag = .start(x: x, y: y)
                }
            default: break
            }
        } else {
            drag = .no
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        super.touchesEnded(touches, with: with)
        var flashed = false
        switch drag {
        case .start(_, _):
            let point = touches.first!.location(in: self)
            if forward.frame.contains(point) {
                flash(forward)
                moonraker.offset += 43_200
                update()
                flashed = true
            } else if backward.frame.contains(point) {
                flash(backward)
                moonraker.offset -= 43_200
                update()
                flashed = true
            } else if now.frame.contains(point) {
                flash(now)
                moonraker.offset = 0
                update()
                flashed = true
            } else if zoom.frame.contains(point) {
                flash(zoom)
                horizon.zoom.toggle()
                flashed = true
            }
        default: break
        }
        if !flashed {
            drag = .no
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        super.touchesCancelled(touches, with: with)
        drag = .no
    }
    
    private func rotate(_ point: CGPoint, _ x: CGFloat, _ y: CGFloat) {
        var delta = CGFloat()
        
        if point.y > 170 {
            delta -= x
        } else {
            delta += x
        }
        
        if point.x > 150 {
            delta += y
        } else {
            delta -= y
        }
        
        moonraker.offset += .init(delta * ratio)
        update()
    }
    
    private func update() {
        if abs(moonraker.offset) > 3600 {
            let date = moonraker.date.addingTimeInterval(moonraker.offset)
            if abs(moonraker.offset) >= 86400 {
                self.date.attributed([(_date.string(from: date), .regular(14), .shade()),
                                      (_time.string(from: date), .medium(14), .haze())], align: .center)
            } else {
                self.date.attributed([(_time.string(from: date), .medium(14), .haze())])
            }
        } else {
            date.text = ""
        }
    }
    
    private func highlight() {
        UIView.animate(withDuration: 0.6) {
            self.animate()
            self.disk.animate(self.drag)
        }
    }
    
    private func animate() {
        switch drag {
        case .no:
            forward.alpha = 0.9
            backward.alpha = 0.9
            now.alpha = 0.9
            zoom.alpha = 0.9
            date.alpha = 0.4
        case .drag:
            forward.alpha = 0.2
            backward.alpha = 0.2
            now.alpha = 0.2
            zoom.alpha = 0.2
            date.alpha = 1
        default:
            forward.alpha = 1
            backward.alpha = 1
            now.alpha = 1
            zoom.alpha = 1
        }
    }
    
    private func valid(_ point: CGPoint) -> Bool {
        let distance = pow(point.x - 150, 2) + pow(point.y - 170, 2)
        return distance > 400 && distance < 12_100
    }
    
    private func flash(_ image: Image) {
        image.alpha = 1
        image.backgroundColor = .haze(0.3)
        date.alpha = 1
        drag = .no
        
        UIView.animate(withDuration: 0.3) {
            image.backgroundColor = .clear
        }
    }
    
    private func control(_ image: String) -> Image {
        let control = Image(image)
        control.layer.cornerRadius = 20
        addSubview(control)
        
        control.widthAnchor.constraint(equalToConstant: 40).isActive = true
        control.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return control
    }
}
