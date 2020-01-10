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
        
        let _stats = Button(self, #selector(stats))
        _stats.accessibilityLabel = .key("View.stats")
        addSubview(_stats)
        
        let icon = Image("stats")
        _stats.addSubview(icon)
        
        let graph = Graph()
        addSubview(graph)
        
        let horizon = Horizon()
        addSubview(horizon)
        self.horizon = horizon
        
        let wheel = Wheel()
        wheel.horizon = horizon
        addSubview(wheel)
        
        _stats.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        _stats.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        _stats.widthAnchor.constraint(equalToConstant: 50).isActive = true
        _stats.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        icon.leftAnchor.constraint(equalTo: _stats.leftAnchor).isActive = true
        icon.rightAnchor.constraint(equalTo: _stats.rightAnchor).isActive = true
        icon.topAnchor.constraint(equalTo: _stats.topAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: _stats.bottomAnchor).isActive = true
        
        horizon.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        horizon.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        horizon.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        
        graph.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        graph.topAnchor.constraint(equalTo: horizon.bottomAnchor, constant: -70).isActive = true
        
        wheel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        wheel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -80).isActive = true
    }
    
    override func traitCollectionDidChange(_: UITraitCollection?) {
        height = horizon.heightAnchor.constraint(equalToConstant: 250)
        layoutIfNeeded()
        horizon.resize()
    }
    
    @objc private func stats() {
        (UIApplication.shared.delegate as! App).present(Stats(), animated: true)
    }
}
