import AppKit

final class Wheel: NSView {
    private weak var offset: Label!
    private weak var modifier: Label!
    private weak var ring: CAShapeLayer!
    private weak var outer: CAShapeLayer!
    private weak var inner: CAShapeLayer!
    private weak var future: Image!
    private weak var now: Image!
    private weak var forward: Image!
    private weak var backward: Image!
    private let formatter = DateComponentsFormatter()
    private let ratio = CGFloat(120)
    
    private var drag = Drag.no {
        didSet {
            highlight()
        }
    }
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute]
        
        widthAnchor.constraint(equalToConstant: 200).isActive = true
        heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        let ring = CAShapeLayer()
        ring.fillColor = .clear
        ring.lineWidth = 2
        ring.path = {
            $0.addArc(center: .init(x: 100, y: 100), radius: 92.5, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        layer!.addSublayer(ring)
        self.ring = ring
        
        let outer = CAShapeLayer()
        outer.fillColor = .clear
        outer.lineWidth = 5
        outer.path = {
            $0.addArc(center: .init(x: 100, y: 100), radius: 96, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        layer!.addSublayer(outer)
        self.outer = outer
        
        let inner = CAShapeLayer()
        inner.path = {
            $0.addArc(center: .init(x: 100, y: 100), radius: 32, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        layer!.addSublayer(inner)
        self.inner = inner
        
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.locations = [0, 1]
        gradient.colors = [CGColor(gray: 0, alpha: 0.2), CGColor.clear]
        gradient.cornerRadius = 30
        gradient.frame = .init(x: 70, y: 70, width: 60, height: 60)
        inner.addSublayer(gradient)
        
        let offset = Label("", .regular(12), .haze())
        addSubview(offset)
        self.offset = offset
        
        let modifier = Label("", .medium(14), .rain())
        addSubview(modifier)
        self.modifier = modifier
        
        future = control("future")
        now = control("now")
        forward = control("forward")
        backward = control("backward")
        
        offset.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        offset.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        modifier.centerYAnchor.constraint(equalTo: offset.centerYAnchor).isActive = true
        modifier.rightAnchor.constraint(equalTo: offset.leftAnchor).isActive = true
        
        future.centerYAnchor.constraint(equalTo: topAnchor, constant: 82).isActive = true
        future.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        now.centerYAnchor.constraint(equalTo: bottomAnchor, constant: -32).isActive = true
        now.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        forward.centerYAnchor.constraint(equalTo: topAnchor, constant: 150).isActive = true
        forward.centerXAnchor.constraint(equalTo: rightAnchor, constant: -32).isActive = true
        
        backward.centerYAnchor.constraint(equalTo: topAnchor, constant: 150).isActive = true
        backward.centerXAnchor.constraint(equalTo: leftAnchor, constant: 32).isActive = true
        
        highlight()
        update()
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .mouseMoved, .activeInActiveApp, .inVisibleRect], owner: self))
    }
    
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
                moonraker.offset += 86_400
                update()
                flashed = true
            } else if backward.frame.contains(point) {
                flash(backward)
                moonraker.offset -= 86_400
                update()
                flashed = true
            } else if now.frame.contains(point) {
                flash(now)
                moonraker.offset = 0
                update()
                flashed = true
            } else if future.frame.contains(point) {
                flash(future)
                moonraker.offset += 86_400 * 29.53
                update()
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
            offset.stringValue = .key("Wheel.now")
            modifier.stringValue = ""
        } else {
            offset.stringValue = formatter.string(from: abs(moonraker.offset)) ?? ""
            modifier.stringValue = moonraker.offset > 0 ? "+" : "-"
        }
    }
    
    private func highlight() {
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.6
            $0.allowsImplicitAnimation = true
            switch drag {
            case .no:
                ring.strokeColor = .shade(0.3)
                outer.strokeColor = .shade(0.4)
                inner.fillColor = .shade(0.4)
                forward.alphaValue = 0.6
                backward.alphaValue = 0.6
                now.alphaValue = 0.6
                future.alphaValue = 0.6
                offset.alphaValue = 0.4
                modifier.alphaValue = 0.4
            case .drag:
                ring.strokeColor = .dark()
                outer.strokeColor = .shade()
                inner.fillColor = .shade()
                forward.alphaValue = 0.3
                backward.alphaValue = 0.3
                now.alphaValue = 0.3
                future.alphaValue = 0.3
                offset.alphaValue = 1
                modifier.alphaValue = 1
            default:
                ring.strokeColor = .dark()
                outer.strokeColor = .shade()
                inner.fillColor = .shade()
                forward.alphaValue = 1
                backward.alphaValue = 1
                now.alphaValue = 1
                future.alphaValue = 1
            }
        }
    }
    
    private func valid(_ point: CGPoint) -> Bool {
        let distance = pow(point.x - 100, 2) + pow(point.y - 100, 2)
        return distance > 400 && distance < 12_100
    }
    
    private func flash(_ image: Image) {
        image.alphaValue = 1
        image.layer!.backgroundColor = .shade(0.5)
        offset.alphaValue = 1
        modifier.alphaValue = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSAnimationContext.runAnimationGroup ({
                $0.duration = 0.3
                $0.allowsImplicitAnimation = true
                image.layer!.backgroundColor = .clear
            }) {
                self.drag = .no
            }
        }
    }
    
    private func control(_ image: String) -> Image {
        let control = Image(image)
        control.wantsLayer = true
        control.layer!.borderColor = .clear
        control.layer!.cornerRadius = 15
        addSubview(control)
        
        control.widthAnchor.constraint(equalToConstant: 30).isActive = true
        control.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        return control
    }
}

private enum Drag {
    case
    no,
    start(x: CGFloat, y: CGFloat),
    drag
}
