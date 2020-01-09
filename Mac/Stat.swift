import AppKit

final class Stat: NSView {
    private(set) weak var date: Label!
    private(set) weak var counter: Label!
    
    required init?(coder: NSCoder) { nil }
    init(_ image: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.staticText)
        
        let image = Image(image)
        addSubview(image)
        
        let date = Label("", .regular(12), .shade())
        date.maximumNumberOfLines = 1
        addSubview(date)
        self.date = date
        
        let counter = Label("", .regular(12), .haze())
        counter.maximumNumberOfLines = 1
        addSubview(counter)
        self.counter = counter
        
        widthAnchor.constraint(equalToConstant: 80).isActive = true
        bottomAnchor.constraint(equalTo: counter.bottomAnchor, constant: 5).isActive = true
        
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        image.widthAnchor.constraint(equalToConstant: 44).isActive = true
        image.heightAnchor.constraint(equalToConstant: 38).isActive = true
        
        date.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        date.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10).isActive = true
        
        counter.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        counter.topAnchor.constraint(equalTo: date.bottomAnchor).isActive = true
    }
}
