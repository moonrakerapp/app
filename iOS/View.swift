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
        
        let horizon = Horizon()
        addSubview(horizon)
        self.horizon = horizon
        
        let wheel = Wheel()
        wheel.horizon = horizon
        addSubview(wheel)
        
        horizon.topAnchor.constraint(equalTo: topAnchor).isActive = true
        horizon.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        horizon.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        
        wheel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        wheel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func traitCollectionDidChange(_: UITraitCollection?) {
        height = horizon.heightAnchor.constraint(equalTo: heightAnchor, multiplier: bounds.width > bounds.height ? 1 : 0.3)
        layoutIfNeeded()
        horizon.resize()
    }
}
