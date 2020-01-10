import UIKit

final class View: UIView {
    private weak var horizon: Horizon!
    private weak var wheel: Wheel!
    
    private weak var horizonTop: NSLayoutConstraint! {
        didSet {
            oldValue?.isActive = false
            horizonTop.isActive = true
        }
    }
    
    private weak var horizonLeft: NSLayoutConstraint! {
        didSet {
            oldValue?.isActive = false
            horizonLeft.isActive = true
        }
    }
    
    private weak var horizonBottom: NSLayoutConstraint! {
        didSet {
            oldValue?.isActive = false
            horizonBottom.isActive = true
        }
    }
    
    private weak var horizonRight: NSLayoutConstraint! {
        didSet {
            oldValue?.isActive = false
            horizonRight.isActive = true
        }
    }
    
    private weak var wheelX: NSLayoutConstraint! {
        didSet {
            oldValue?.isActive = false
            wheelX.isActive = true
        }
    }
    
    private weak var wheelY: NSLayoutConstraint! {
        didSet {
            oldValue?.isActive = false
            wheelY.isActive = true
        }
    }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        backgroundColor = .black
        
        let graph = Graph()
        addSubview(graph)
        
        let horizon = Horizon()
        addSubview(horizon)
        self.horizon = horizon
        
        let wheel = Wheel()
        wheel.horizon = horizon
        addSubview(wheel)
        self.wheel = wheel
        
        graph.centerXAnchor.constraint(equalTo: horizon.centerXAnchor).isActive = true
        graph.topAnchor.constraint(equalTo: horizon.centerYAnchor, constant: 50).isActive = true
    }
    
    override func traitCollectionDidChange(_: UITraitCollection?) {
        if bounds.height > bounds.width || (bounds.height < bounds.width && bounds.height > 600) {
            horizonTop = horizon.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20)
            horizonLeft = horizon.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor)
            horizonRight = horizon.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor)
            horizonBottom = horizon.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.33)
            wheelX = wheel.centerXAnchor.constraint(equalTo: centerXAnchor)
            wheelY = wheel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -30)
        } else {
            horizonTop = horizon.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
            horizonLeft = horizon.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 30)
            horizonRight = horizon.rightAnchor.constraint(equalTo: wheel.leftAnchor, constant: -30)
            horizonBottom = horizon.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
            wheelX = wheel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -30)
            wheelY = wheel.centerYAnchor.constraint(equalTo: centerYAnchor)
        }
        layoutIfNeeded()
        horizon.resize()
    }
}
