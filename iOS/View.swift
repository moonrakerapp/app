import UIKit

final class View: UIView {
    private weak var horizon: Horizon!
    private weak var wheel: Wheel!
    private weak var graph: Graph!
    private weak var equalizer: UIView!
    
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
    
    private weak var equalizerY: NSLayoutConstraint! {
        didSet {
            oldValue?.isActive = false
            equalizerY.isActive = true
        }
    }
    
    private weak var graphBottom: NSLayoutConstraint! {
        didSet {
            oldValue?.isActive = false
            graphBottom.isActive = true
        }
    }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        backgroundColor = .black
        
        let equalizer = UIView()
        equalizer.translatesAutoresizingMaskIntoConstraints = false
        equalizer.isUserInteractionEnabled = false
        equalizer.layer.addSublayer(Equalizer())
        addSubview(equalizer)
        self.equalizer = equalizer
        
        let graph = Graph()
        addSubview(graph)
        self.graph = graph
        
        let horizon = Horizon()
        addSubview(horizon)
        self.horizon = horizon
        
        let wheel = Wheel()
        wheel.horizon = horizon
        addSubview(wheel)
        self.wheel = wheel
        
        equalizer.widthAnchor.constraint(equalToConstant: 160).isActive = true
        equalizer.heightAnchor.constraint(equalToConstant: 80).isActive = true
        equalizer.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        graph.centerXAnchor.constraint(equalTo: horizon.centerXAnchor).isActive = true
    }
    
    func align() {
        if bounds.height > bounds.width {
            horizonTop = horizon.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20)
            horizonLeft = horizon.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor)
            horizonRight = horizon.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor)
            horizonBottom = horizon.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.34)
            wheelX = wheel.centerXAnchor.constraint(equalTo: centerXAnchor)
            wheelY = wheel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -30)
            equalizerY = equalizer.bottomAnchor.constraint(equalTo: wheel.topAnchor, constant: 40)
            graphBottom = graph.bottomAnchor.constraint(equalTo: horizon.bottomAnchor, constant: 30)
        } else {
            horizonTop = horizon.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20)
            horizonLeft = horizon.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 30)
            horizonRight = horizon.rightAnchor.constraint(equalTo: centerXAnchor, constant: -40)
            horizonBottom = horizon.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
            wheelX = wheel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -30)
            wheelY = wheel.centerYAnchor.constraint(equalTo: centerYAnchor)
            equalizerY = equalizer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
            graphBottom = graph.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10)
        }
        layoutIfNeeded()
        horizon.resize()
    }
}
