import UIKit

final class Wheel: UIView {
    weak var horizon: Horizon!
    private weak var date: Label!
    private weak var offset: Label!
    private weak var modifier: Label!
    private weak var ring: CAShapeLayer!
    private weak var outer: CAShapeLayer!
    private weak var inner: CAShapeLayer!
    private weak var zoom: Image!
    private weak var now: Image!
    private weak var forward: Image!
    private weak var backward: Image!
    private let components = DateComponentsFormatter()
    private let formatter = DateFormatter()
    private let ratio = CGFloat(120)
    
    private var drag = Drag.no {
        didSet {
            highlight()
        }
    }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        components.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute]
        components.unitsStyle = .abbreviated
        formatter.timeStyle = .short
        
        widthAnchor.constraint(equalToConstant: 260).isActive = true
        heightAnchor.constraint(equalToConstant: 310).isActive = true
        
        let ring = CAShapeLayer()
        ring.fillColor = .clear
        ring.lineWidth = 2
        ring.path = {
            $0.addArc(center: .init(x: 130, y: 180), radius: 122.5, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        layer.addSublayer(ring)
        self.ring = ring
        
        let outer = CAShapeLayer()
        outer.fillColor = .clear
        outer.lineWidth = 5
        outer.path = {
            $0.addArc(center: .init(x: 130, y: 180), radius: 126, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        layer.addSublayer(outer)
        self.outer = outer
        
        let inner = CAShapeLayer()
        inner.path = {
            $0.addArc(center: .init(x: 130, y: 180), radius: 47, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        layer.addSublayer(inner)
        self.inner = inner
        
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.locations = [0, 1]
        gradient.colors = [CGColor.clear, UIColor(white: 0, alpha: 0.2).cgColor]
        gradient.cornerRadius = 45
        gradient.frame = .init(x: 85, y: 135, width: 90, height: 90)
        inner.addSublayer(gradient)
        
        let offset = Label("", .regular(12), .haze())
        addSubview(offset)
        self.offset = offset
        
        let modifier = Label("", .medium(14), .rain())
        addSubview(modifier)
        self.modifier = modifier
        
        let date = Label("", .regular(12), .haze())
        addSubview(date)
        self.date = date
        
        zoom = control("zoom")
        now = control("now")
        forward = control("forward")
        backward = control("backward")
        
        offset.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        offset.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        modifier.centerYAnchor.constraint(equalTo: offset.centerYAnchor).isActive = true
        modifier.rightAnchor.constraint(equalTo: offset.leftAnchor).isActive = true
        
        date.topAnchor.constraint(equalTo: offset.bottomAnchor).isActive = true
        date.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        zoom.centerYAnchor.constraint(equalTo: topAnchor, constant: 82).isActive = true
        zoom.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        now.centerYAnchor.constraint(equalTo: bottomAnchor, constant: -32).isActive = true
        now.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        forward.centerYAnchor.constraint(equalTo: topAnchor, constant: 150).isActive = true
        forward.centerXAnchor.constraint(equalTo: rightAnchor, constant: -32).isActive = true
        
        backward.centerYAnchor.constraint(equalTo: topAnchor, constant: 150).isActive = true
        backward.centerXAnchor.constraint(equalTo: leftAnchor, constant: 32).isActive = true
        
        highlight()
        update()
    }
    /*
    override func mouseMoved(with: NSEvent) {
        if valid(convert(with.locationInWindow, from: nil)) {
            NSCursor.pointingHand.set()
        } else {
            NSCursor.arrow.set()
        }
    }
    
    override func mouseExited(with: NSEvent) {
        NSCursor.arrow.set()
    }
    
    override func mouseDragged(with: NSEvent) {
        let point = convert(with.locationInWindow, from: nil)
        if valid(point) {
            switch drag {
            case .drag:
                rotate(point, with.deltaX, with.deltaY)
            case .start(var x, var y):
                x += with.deltaX
                y += with.deltaY
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
    
    override func mouseUp(with: NSEvent) {
        var flashed = false
        switch drag {
        case .start(_, _):
            let point = convert(with.locationInWindow, from: nil)
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
    
    override func mouseDown(with: NSEvent) {
        if valid(convert(with.locationInWindow, from: nil)) {
            drag = .start(x: 0, y: 0)
        } else {
            drag = .no
        }
    }
    */
    private func rotate(_ point: CGPoint, _ x: CGFloat, _ y: CGFloat) {
        var delta = CGFloat()
        
        if point.y > 100 {
            delta += x
        } else {
            delta -= x
        }
        
        if point.x > 100 {
            delta += y
        } else {
            delta -= y
        }
        
        moonraker.offset += .init(delta * ratio)
        update()
    }
    
    private func update() {
        if moonraker.offset == 0 {
            offset.text = .key("Wheel.now")
            modifier.text = ""
            date.text = ""
        } else {
            offset.text = components.string(from: abs(moonraker.offset)) ?? ""
            modifier.text = moonraker.offset > 0 ? "+" : "-"
            if abs(moonraker.offset) > 3600 {
                formatter.dateStyle = abs(moonraker.offset) >= 86400 ? .short : .none
                date.text = formatter.string(from: moonraker.date.addingTimeInterval(moonraker.offset))
            }
        }
    }
    
    private func highlight() {
        UIView.animate(withDuration: 0.6) {
            self.animate()
        }
    }
    
    private func animate() {
        switch drag {
        case .no:
            ring.strokeColor = .shade(0.3)
            outer.strokeColor = .shade(0.4)
            inner.fillColor = .shade(0.4)
            forward.alpha = 0.6
            backward.alpha = 0.6
            now.alpha = 0.6
            zoom.alpha = 0.6
            offset.alpha = 0.4
            modifier.alpha = 0.4
            date.alpha = 0.4
        case .drag:
            ring.strokeColor = .dark()
            outer.strokeColor = .shade()
            inner.fillColor = .shade()
            forward.alpha = 0.3
            backward.alpha = 0.3
            now.alpha = 0.3
            zoom.alpha = 0.3
            offset.alpha = 1
            modifier.alpha = 1
            date.alpha = 1
        default:
            ring.strokeColor = .dark()
            outer.strokeColor = .shade()
            inner.fillColor = .shade()
            forward.alpha = 1
            backward.alpha = 1
            now.alpha = 1
            zoom.alpha = 1
        }
    }
    
    private func valid(_ point: CGPoint) -> Bool {
        let distance = pow(point.x - 100, 2) + pow(point.y - 100, 2)
        return distance > 400 && distance < 12_100
    }
    
    private func flash(_ image: Image) {
        image.alpha = 1
        image.backgroundColor = .shade(0.5)
        offset.alpha = 1
        modifier.alpha = 1
        date.alpha = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.animate(withDuration: 0.3, animations: {
                image.backgroundColor = .clear
            }) { _ in
                self.drag = .no
            }
        }
    }
    
    private func control(_ image: String) -> Image {
        let control = Image(image)
        control.layer.borderColor = .clear
        control.layer.cornerRadius = 25
        addSubview(control)
        
        control.widthAnchor.constraint(equalToConstant: 50).isActive = true
        control.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        return control
    }
}
