import UIKit

final class View: UIView {
    private weak var horizon: Horizon!
    private weak var height: NSLayoutConstraint! {
        didSet {
            oldValue?.isActive = false
            height.isActive = true
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
        
        horizon.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        horizon.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        horizon.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        
        graph.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        graph.topAnchor.constraint(equalTo: horizon.bottomAnchor, constant: -70).isActive = true
        
        wheel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        wheel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -70).isActive = true
    }
    
    override func traitCollectionDidChange(_: UITraitCollection?) {
        height = horizon.heightAnchor.constraint(equalToConstant: 250)
        layoutIfNeeded()
        horizon.resize()
    }
}
