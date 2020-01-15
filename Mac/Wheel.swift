import AppKit

final class Wheel: NSView {
    weak var horizon: Horizon!
    private weak var disk: Disk!
    private weak var zoom: Image!
    private weak var now: Image!
    private weak var forward: Image!
    private weak var backward: Image!
    private weak var stats: Image!
    private var drag = Drag.no
    private let ratio = CGFloat(360)
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        
        widthAnchor.constraint(equalToConstant: 300).isActive = true
        heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        let disk = Disk()
        layer!.addSublayer(disk)
        self.disk = disk
        
        zoom = control("zoom")
        now = control("now")
        forward = control("forward")
        backward = control("backward")
        stats = control("stats")
        
        zoom.centerYAnchor.constraint(equalTo: topAnchor, constant: 67).isActive = true
        zoom.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        now.centerYAnchor.constraint(equalTo: bottomAnchor, constant: -67).isActive = true
        now.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        forward.centerYAnchor.constraint(equalTo: topAnchor, constant: 150).isActive = true
        forward.centerXAnchor.constraint(equalTo: rightAnchor, constant: -67).isActive = true
        
        backward.centerYAnchor.constraint(equalTo: topAnchor, constant: 150).isActive = true
        backward.centerXAnchor.constraint(equalTo: leftAnchor, constant: 67).isActive = true
        
        stats.centerYAnchor.constraint(equalTo: topAnchor, constant: 150).isActive = true
        stats.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        highlight()
    }
    
    override func mouseDown(with: NSEvent) {
        if valid(convert(with.locationInWindow, from: nil)) {
            drag = .start(x: 0, y: 0)
        } else {
            drag = .no
        }
    }
    
    override func mouseDragged(with: NSEvent) {
        let point = convert(with.locationInWindow, from: nil)
        if valid(point) {
            NSCursor.pointingHand.set()
            switch drag {
            case .drag:
                disk.rotate(atan2(point.x - 150, 150 - point.y))
                rotate(point, with.deltaX, with.deltaY)
            case .start(var x, var y):
                x += with.deltaX
                y += with.deltaY
                if abs(x) + abs(y) > 15 {
                    rotate(point, x, y)
                    drag = .drag
                    highlight()
                } else {
                    drag = .start(x: x, y: y)
                }
            default: break
            }
        } else {
            switch drag {
            case .start(_, _):
                drag = .no
            default: break
            }
        }
    }
    
    override func mouseUp(with: NSEvent) {
        switch drag {
        case .drag: break
        default:
            let point = convert(with.locationInWindow, from: nil)
            if forward.frame.contains(point) {
                forward.alphaValue = 0.1
                moonraker.offset += 518_400
            } else if backward.frame.contains(point) {
                backward.alphaValue = 0.1
                moonraker.offset -= 518_400
            } else if now.frame.contains(point) {
                now.alphaValue = 0.1
                moonraker.offset = 0
            } else if zoom.frame.contains(point) {
                zoom.alphaValue = 0.1
                horizon.zoom.toggle()
            } else if stats.frame.contains(point) {
                stats.alphaValue = 0.1
//                (UIApplication.shared.delegate as! App).present(Stats(), animated: true)
            }
        }
        drag = .no
        NSCursor.arrow.set()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.highlight()
        }
    }
    
    private func rotate(_ point: CGPoint, _ x: CGFloat, _ y: CGFloat) {
        var delta = CGFloat()
        
        if point.y > 150 {
            delta += x
        } else {
            delta -= x
        }
        
        if point.x > 150 {
            delta += y
        } else {
            delta -= y
        }
        
        moonraker.offset += .init(delta * ratio)
    }
    
    private func highlight() {
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.7
            $0.allowsImplicitAnimation = true
            switch drag {
            case .drag:
                forward.alphaValue = 0
                backward.alphaValue = 0
                now.alphaValue = 0
                zoom.alphaValue = 0
                stats.alphaValue = 0
            default:
                forward.alphaValue = 1
                backward.alphaValue = 1
                now.alphaValue = 1
                zoom.alphaValue = 1
                stats.alphaValue = 1
            }
            disk.animate(drag)
        }
    }
    
    private func valid(_ point: CGPoint) -> Bool {
        let distance = pow(point.x - 150, 2) + pow(point.y - 150, 2)
        return distance > 900 && distance < 19_600
    }
    
    private func control(_ image: String) -> Image {
        let control = Image(image)
        addSubview(control)
        
        control.widthAnchor.constraint(equalToConstant: 30).isActive = true
        control.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return control
    }
}
