import AppKit

final class Day: NSView {
    let day: Int
    private weak var config: Config!
    private weak var label: Label!
    
    var selected = false {
        didSet {
            label.textColor = selected ? .black : .haze()
            layer!.backgroundColor = selected ? .haze() : .black
        }
    }
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ day: Int, _ config: Config) {
        self.day = day
        self.config = config
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.cornerRadius = 20
        
        let label = Label("\(day)", .medium(14), .haze())
        addSubview(label)
        self.label = label
        
        widthAnchor.constraint(equalToConstant: 40).isActive = true
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    override func mouseDown(with: NSEvent) {
        alphaValue = 0.3
    }
    
    override func mouseExited(with: NSEvent) {
        alphaValue = 1
    }
    
    override func mouseUp(with: NSEvent) {
        window!.makeFirstResponder(nil)
        if bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            config.day(day)
        } else {
            super.mouseUp(with: with)
        }
        alphaValue = 1
    }
}
