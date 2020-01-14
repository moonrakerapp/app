import ClockKit

extension UIImage {
    static func make(_ size: CGFloat) -> UIImage {
        let middle = size * 0.5
        let center = CGPoint(x: middle, y: middle)
        let radius = middle - 8
        
        UIGraphicsBeginImageContext(.init(width: size, height: size))
        let c = UIGraphicsGetCurrentContext()!
        c.addArc(center: center, radius: radius + 1, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        c.setFillColor(UIColor.black.cgColor)
        c.setStrokeColor(UIColor(named: "shade")!.cgColor)
        c.setLineWidth(1)
        c.setShadow(offset: .zero, blur: radius / 2, color: UIColor(named: "haze")!.cgColor)
        c.drawPath(using: .fillStroke)
        
        switch app.phase {
        case .waxingCrescent: c.addPath(waxingCrescent(center, radius))
        case .firstQuarter: c.addPath(firstQuarter(center, radius))
        case .waxingGibbous: c.addPath(waxingGibbous(center, radius))
        case .full: c.addPath(full(center, radius))
        case .waningGibbous: c.addPath(waningGibbous(center, radius))
        case .lastQuarter: c.addPath(lastQuarter(center, radius))
        case .waningCrescent: c.addPath(waningCrescent(center, radius))
        default: break
        }
        
        c.setFillColor(UIColor(named: "haze")!.cgColor)
        c.drawPath(using: .fill)
        
        c.addPath(craters(middle, radius))
        c.setFillColor(.init(srgbRed: 0, green: 0, blue: 0, alpha: 0.2))
        c.drawPath(using: .fill)
        
        let image = UIImage(cgImage: c.makeImage()!)
        UIGraphicsEndImageContext()
        return image
    }
    
    private static func waxingCrescent(_ center: CGPoint, _ radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.addArc(center: center, radius: radius, startAngle: .pi / 2, endAngle: .pi / -2, clockwise: true)
        path.addLine(to: CGPoint(x: center.x, y: center.y - radius))
        path.addCurve(to: CGPoint(x: center.x, y: center.y + radius),
                    control1: CGPoint(x: center.x + (((app.fraction - 0.5) / -0.5) * (radius * 1.35)),
                                      y: center.y + (((app.fraction - 0.5) / 0.5) * radius)),
                    control2: CGPoint(x: center.x + (((app.fraction - 0.5) / -0.5) * (radius * 1.35)),
                                      y: center.y + (((app.fraction - 0.5) / -0.5) * radius)))
        return path
    }
    
    private static func firstQuarter(_ center: CGPoint, _ radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.addArc(center: center, radius: radius, startAngle: .pi / 2, endAngle: .pi / -2, clockwise: true)
        return path
    }
    
    private static func waxingGibbous(_ center: CGPoint, _ radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.addArc(center: center, radius: radius, startAngle: .pi / 2, endAngle: .pi / -2, clockwise: true)
        path.addLine(to: CGPoint(x: center.x, y: center.y - radius))
        path.addCurve(to: CGPoint(x: center.x, y: center.y + radius),
                    control1: CGPoint(x: center.x + (((app.fraction - 0.5) / -0.5) * (radius * 1.35)),
                                      y: center.y + (((app.fraction - 0.5) / -0.5) * radius)),
                    control2: CGPoint(x: center.x + (((app.fraction - 0.5) / -0.5) * (radius * 1.35)),
                                      y: center.y + (((app.fraction - 0.5) / 0.5) * radius)))
        return path
    }
    
    private static func full(_ center: CGPoint, _ radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        return path
    }
    
    private static func waningGibbous(_ center: CGPoint, _ radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.addArc(center: center, radius: radius, startAngle: .pi / -2, endAngle: .pi / 2, clockwise: true)
        path.addLine(to: CGPoint(x: center.x, y: center.y + radius))
        path.addCurve(to: CGPoint(x: center.x, y: center.y - radius),
                    control1: CGPoint(x: center.x + (((app.fraction - 0.5) / 0.5) * (radius * 1.35)),
                                      y: center.y + (((app.fraction - 0.5) / 0.5) * radius)),
                    control2: CGPoint(x: center.x + (((app.fraction - 0.5) / 0.5) * (radius * 1.35)),
                                      y: center.y + (((app.fraction - 0.5) / -0.5) * radius)))
        return path
    }
    
    private static func lastQuarter(_ center: CGPoint, _ radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.addArc(center: center, radius: radius, startAngle: .pi / -2, endAngle: .pi / 2, clockwise: true)
        return path
    }
    
    private static func waningCrescent(_ center: CGPoint, _ radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.addArc(center: center, radius: radius, startAngle: .pi / -2, endAngle: .pi / 2, clockwise: true)
        path.addLine(to: CGPoint(x: center.x, y: center.y + radius))
        path.addCurve(to: CGPoint(x: center.x, y: center.y - radius),
                    control1: CGPoint(x: center.x + (((app.fraction - 0.5) / 0.5) * (radius * 1.35)),
                                      y: center.y + (((app.fraction - 0.5) / -0.5) * radius)),
                    control2: CGPoint(x: center.x + (((app.fraction - 0.5) / 0.5) * (radius * 1.35)),
                                      y: center.y + (((app.fraction - 0.5) / 0.5) * radius)))
        return path
    }
    
    private static func craters(_ middle: CGFloat, _ radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.addPath({
            $0.addArc(center: CGPoint(x: middle + (radius / -3), y: middle + (radius / -3.5)), radius: radius / 2.2, startAngle: 0, endAngle: .pi * -2, clockwise: true)
            return $0
        } (CGMutablePath()))
        path.addPath({
            $0.addArc(center: CGPoint(x: middle + (radius / -3), y: middle + (radius / 2.25)), radius: radius / 4, startAngle: 0, endAngle: .pi * -2, clockwise: true)
            return $0
        } (CGMutablePath()))
        path.addPath({
            $0.addArc(center: CGPoint(x: middle + (radius / 2), y: middle + (radius / 3.5)), radius: radius / 4, startAngle: 0, endAngle: .pi * -2, clockwise: true)
            return $0
        } (CGMutablePath()))
        path.addPath({
            $0.addArc(center: CGPoint(x: middle + (radius / 6), y: middle + (radius / 1.5)), radius: radius / 5, startAngle: 0, endAngle: .pi * -2, clockwise: true)
            return $0
        } (CGMutablePath()))
        path.addPath({
            $0.addArc(center: CGPoint(x: middle + (radius / 4), y: middle + (radius / -1.5)), radius: radius / 6, startAngle: 0, endAngle: .pi * -2, clockwise: true)
            return $0
        } (CGMutablePath()))
        return path
    }
}
