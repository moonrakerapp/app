#if os(macOS)
import AppKit

extension NSFont {
    class func medium(_ size: CGFloat) -> NSFont {
        NSFont(name: "AlteDIN1451Mittelschrift", size: size)!
    }
    
    class func bold(_ size: CGFloat) -> NSFont {
        NSFont(name: "AlteDIN1451Mittelschriftgepraegt", size: size)!
    }
}
#endif
#if os(iOS)
import UIKit

extension UIFont {
    class func medium(_ size: CGFloat) -> UIFont {
        UIFont(name: "AlteDIN1451Mittelschrift", size: UIFontMetrics.default.scaledValue(for: size))!
    }
    
    class func bold(_ size: CGFloat) -> UIFont {
        UIFont(name: "AlteDIN1451Mittelschriftgepraegt", size: UIFontMetrics.default.scaledValue(for: size))!
    }
}
#endif
