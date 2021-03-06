#if os(macOS)
import AppKit

extension NSFont {
    class func light(_ size: CGFloat) -> NSFont {
        NSFont(name: "Rubik-Light", size: size)!
    }
    
    class func regular(_ size: CGFloat) -> NSFont {
        NSFont(name: "Rubik-Regular", size: size)!
    }
    
    class func medium(_ size: CGFloat) -> NSFont {
        NSFont(name: "Rubik-Medium", size: size)!
    }
    
    class func bold(_ size: CGFloat) -> NSFont {
        NSFont(name: "Rubik-Bold", size: size)!
    }
}
#endif
#if os(iOS)
import UIKit

extension UIFont {
    class func light(_ size: CGFloat) -> UIFont {
        font("Rubik-Light", size)
    }
    
    class func regular(_ size: CGFloat) -> UIFont {
        font("Rubik-Regular", size)
    }
    
    class func medium(_ size: CGFloat) -> UIFont {
        font("Rubik-Medium", size)
    }
    
    class func bold(_ size: CGFloat) -> UIFont {
        font("Rubik-Bold", size)
    }
    
    private class func font(_ name: String, _ size: CGFloat) -> UIFont {
        UIFont(name: name, size: UIFontMetrics.default.scaledValue(for: size))!
    }
}
#endif
