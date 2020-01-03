import AppKit

final class Stats: NSView {
    override var mouseDownCanMoveWindow: Bool { false }
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        
        heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
}
