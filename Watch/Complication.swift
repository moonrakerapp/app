import ClockKit

final class Complication: NSObject, CLKComplicationDataSource {
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        withHandler(.init(date: .init(), complicationTemplate: {
            switch $0 {
            case .circularSmall: return circularSmall()
            case .extraLarge: return extraLarge()
            case .modularSmall: return modularSmall()
            case .modularLarge: return modularLarge()
            case .utilitarianSmall: return utilitarianSmall()
            case .utilitarianSmallFlat: return utilitarianSmallFlat()
            case .utilitarianLarge: return utilitarianFlat()
            case .graphicCorner: return graphicCorner()
            case .graphicCircular: return graphicCircular()
            case .graphicBezel: return graphicBezel()
            case .graphicRectangular: return .init()
            @unknown default: return .init() }
        } (complication.family)))
    }
    
    func getSupportedTimeTravelDirections(for: CLKComplication, withHandler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        withHandler([])
    }
    
    func getTimelineStartDate(for: CLKComplication, withHandler: @escaping (Date?) -> Void) {
        withHandler(nil)
    }
    
    func getTimelineEndDate(for: CLKComplication, withHandler: @escaping (Date?) -> Void) {
        withHandler(nil)
    }
    
    func getPrivacyBehavior(for: CLKComplication, withHandler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        withHandler(.showOnLockScreen)
    }
    
    func getTimelineEntries(for: CLKComplication, before: Date, limit: Int, withHandler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        withHandler(nil)
    }
    
    func getTimelineEntries(for: CLKComplication, after: Date, limit: Int, withHandler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        withHandler(nil)
    }
    
    func getLocalizableSampleTemplate(for: CLKComplication, withHandler: @escaping (CLKComplicationTemplate?) -> Void) {
        withHandler(nil)
    }
    
    private func circularSmall() -> CLKComplicationTemplateCircularSmallStackImage {
//        let template = CLKComplicationTemplateCircularSmallStackImage()
//        template.line1ImageProvider = CLKImageProvider(onePieceImage: image(18))
//        template.line2TextProvider = CLKSimpleTextProvider(text: "as", shortText: "d")
//        template.tintColor = UIColor(named: "haze")
//        return template
        
        .init()
    }
    
    private func extraLarge() -> CLKComplicationTemplateExtraLargeSimpleImage {
        .init()
    }
    
    private func modularSmall() -> CLKComplicationTemplateModularSmallSimpleImage {
        .init()
    }
    
    private func modularLarge() -> CLKComplicationTemplateModularLargeStandardBody {
        .init()
    }
    
    private func utilitarianSmall() -> CLKComplicationTemplateUtilitarianSmallRingImage {
        .init()
    }
    
    private func utilitarianSmallFlat() -> CLKComplicationTemplateUtilitarianSmallFlat {
        .init()
    }
    
    private func utilitarianFlat() -> CLKComplicationTemplateUtilitarianLargeFlat {
        .init()
    }
    
    private func graphicCorner() -> CLKComplicationTemplateGraphicCornerCircularImage {
        let template = CLKComplicationTemplateGraphicCornerCircularImage()
        template.imageProvider = .init(fullColorImage: image(36))
        return template
    }
    
    private func graphicBezel() -> CLKComplicationTemplateGraphicBezelCircularText {
        let template = CLKComplicationTemplateGraphicBezelCircularText()
        
        let circular = CLKComplicationTemplateGraphicCircularImage()
        circular.imageProvider = .init(fullColorImage: image(47))
        template.circularTemplate = circular

        return template
    }
    
    private func graphicRectangular() -> CLKComplicationTemplateGraphicRectangularLargeImage {
        .init()
    }
    
    private func graphicCircular() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateGraphicCircularImage()
        template.imageProvider = .init(fullColorImage: image(47))
        return template
    }
    
    private func image(_ size: CGFloat) -> UIImage {
        let middle = size * 0.5
        let center = CGPoint(x: middle, y: middle)
        let radius = middle - 1
        
        UIGraphicsBeginImageContext(.init(width: size, height: size))
        let c = UIGraphicsGetCurrentContext()!
        c.addEllipse(in: .init(x: 1, y: 1, width: radius * 2, height: radius * 2))
        c.setFillColor(UIColor.black.cgColor)
        c.setStrokeColor(UIColor(named: "shade")!.cgColor)
        c.setLineWidth(1)
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
    
    private func waxingCrescent(_ center: CGPoint, _ radius: CGFloat) -> CGPath {
        {
            $0.addArc(center: center, radius: radius, startAngle: .pi / 2, endAngle: .pi / -2, clockwise: true)
            $0.addLine(to: .init(x: 0, y: -radius))
            $0.addCurve(to: CGPoint(x: 0, y: radius),
                        control1: CGPoint(x: ((app.fraction - 0.5) / -0.5) * (radius * 1.35), y: ((app.fraction - 0.5) / 0.5) * radius),
                        control2: CGPoint(x: ((app.fraction - 0.5) / -0.5) * (radius * 1.35), y: ((app.fraction - 0.5) / -0.5) * radius))
            return $0
        } (CGMutablePath())
    }
    
    private func firstQuarter(_ center: CGPoint, _ radius: CGFloat) -> CGPath {
        {
            $0.addArc(center: center, radius: radius, startAngle: .pi / 2, endAngle: .pi / -2, clockwise: true)
            return $0
        } (CGMutablePath())
    }
    
    private func waxingGibbous(_ center: CGPoint, _ radius: CGFloat) -> CGPath {
        {
            $0.addArc(center: center, radius: radius, startAngle: .pi / 2, endAngle: .pi / -2, clockwise: true)
            $0.addLine(to: .init(x: center.x, y: center.y - radius))
            $0.addCurve(to: CGPoint(x: center.x, y: center.y + radius),
                        control1: CGPoint(x: ((app.fraction - 0.5) / -0.5) * (radius * 1.35), y: ((app.fraction - 0.5) / -0.5) * radius),
                        control2: CGPoint(x: ((app.fraction - 0.5) / -0.5) * (radius * 1.35), y: ((app.fraction - 0.5) / 0.5) * radius))
            return $0
        } (CGMutablePath())
    }
    
    private func full(_ center: CGPoint, _ radius: CGFloat) -> CGPath {
        {
            $0.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath())
    }
    
    private func waningGibbous(_ center: CGPoint, _ radius: CGFloat) -> CGPath {
        {
            $0.addArc(center: center, radius: radius, startAngle: .pi / -2, endAngle: .pi / 2, clockwise: true)
            $0.addLine(to: .init(x: center.x, y: center.y + radius))
            $0.addCurve(to: CGPoint(x: center.x, y: center.y - radius),
                        control1: CGPoint(x: ((app.fraction - 0.5) / 0.5) * (radius * 1.35), y: ((app.fraction - 0.5) / 0.5) * radius),
                        control2: CGPoint(x: ((app.fraction - 0.5) / 0.5) * (radius * 1.35), y: ((app.fraction - 0.5) / -0.5) * radius))
            return $0
        } (CGMutablePath())
    }
    
    private func lastQuarter(_ center: CGPoint, _ radius: CGFloat) -> CGPath {
        {
            $0.addArc(center: center, radius: radius, startAngle: .pi / -2, endAngle: .pi / 2, clockwise: true)
            return $0
        } (CGMutablePath())
    }
    
    private func waningCrescent(_ center: CGPoint, _ radius: CGFloat) -> CGPath {
        {
            $0.addArc(center: center, radius: radius, startAngle: .pi / -2, endAngle: .pi / 2, clockwise: true)
            $0.addLine(to: .init(x: center.x, y: center.y + radius))
            $0.addCurve(to: CGPoint(x: center.x, y: center.y - radius),
                        control1: CGPoint(x: ((app.fraction - 0.5) / 0.5) * (radius * 1.35), y: ((app.fraction - 0.5) / -0.5) * radius),
                        control2: CGPoint(x: ((app.fraction - 0.5) / 0.5) * (radius * 1.35), y: ((app.fraction - 0.5) / 0.5) * radius))
            return $0
        } (CGMutablePath())
    }
    
    private func craters(_ middle: CGFloat, _ radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.addPath({
            $0.addArc(center: .init(x: middle + (radius / -3), y: middle + (radius / -3.5)), radius: radius / 2.2, startAngle: 0, endAngle: .pi * -2, clockwise: true)
            return $0
        } (CGMutablePath()))
        path.addPath({
            $0.addArc(center: .init(x: middle + (radius / -3), y: middle + (radius / 2.25)), radius: radius / 4, startAngle: 0, endAngle: .pi * -2, clockwise: true)
            return $0
        } (CGMutablePath()))
        path.addPath({
            $0.addArc(center: .init(x: middle + (radius / 2), y: middle + (radius / 3.5)), radius: radius / 4, startAngle: 0, endAngle: .pi * -2, clockwise: true)
            return $0
        } (CGMutablePath()))
        path.addPath({
            $0.addArc(center: .init(x: middle + (radius / 6), y: middle + (radius / 1.5)), radius: radius / 5, startAngle: 0, endAngle: .pi * -2, clockwise: true)
            return $0
        } (CGMutablePath()))
        path.addPath({
            $0.addArc(center: .init(x: middle + (radius / 4), y: middle + (radius / -1.5)), radius: radius / 6, startAngle: 0, endAngle: .pi * -2, clockwise: true)
            return $0
        } (CGMutablePath()))
        return path
    }
}
