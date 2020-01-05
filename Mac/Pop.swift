import Moonraker
import AppKit

final class Pop: NSPopover {
    var info: Info! {
        didSet {
            percent.attributed([("\(Float(Int(info.fraction * 100000)) / 1000)", .medium(16), .init(white: 1, alpha: 0.4)),
                                ("%", .medium(14), .init(white: 1, alpha: 0.4))])
            illumination.strokeEnd = .init(info.fraction)
        }
    }
    
    private weak var percent: Label!
    private weak var illumination: CAShapeLayer!
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        contentSize = .init(width: 240, height: 200)
        contentViewController = .init()
        contentViewController!.view = .init()
        behavior = .transient
        appearance = NSAppearance(named: .darkAqua)
        
        let _illumination = Label("Illumination", .medium(16), .white)
        contentViewController!.view.addSubview(_illumination)
        
        let percent = Label([])
        contentViewController!.view.addSubview(percent)
        self.percent = percent
        
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.wantsLayer = true
        container.layer!.cornerRadius = 5
        container.layer!.borderWidth = 1
        container.layer!.borderColor = .white
        contentViewController!.view.addSubview(container)
        
        let illumination = CAShapeLayer()
        illumination.fillColor = .clear
        illumination.strokeColor = .white
        illumination.lineWidth = 10
        illumination.path = {
            $0.move(to: .init(x: 0, y: 5))
            $0.addLine(to: .init(x: 200, y: 5))
            return $0
        } (CGMutablePath())
        container.layer!.addSublayer(illumination)
        self.illumination = illumination
        
        _illumination.topAnchor.constraint(equalTo: contentViewController!.view.topAnchor, constant: 20).isActive = true
        _illumination.leftAnchor.constraint(equalTo: contentViewController!.view.leftAnchor, constant: 20).isActive = true
        
        percent.topAnchor.constraint(equalTo: _illumination.topAnchor).isActive = true
        percent.rightAnchor.constraint(equalTo: contentViewController!.view.rightAnchor, constant: -20).isActive = true
        
        container.topAnchor.constraint(equalTo: _illumination.bottomAnchor, constant: 6).isActive = true
        container.heightAnchor.constraint(equalToConstant: 10).isActive = true
        container.widthAnchor.constraint(equalToConstant: 200).isActive = true
        container.leftAnchor.constraint(equalTo: contentViewController!.view.leftAnchor, constant: 20).isActive = true
    }
    
}
