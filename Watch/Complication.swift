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
    
    private func circularSmall() -> CLKComplicationTemplateCircularSmallSimpleImage {
        let template = CLKComplicationTemplateCircularSmallSimpleImage()
        template.imageProvider = .init(onePieceImage: .make(24))
        template.tintColor = UIColor(named: "haze")
        return template
    }
    
    private func extraLarge() -> CLKComplicationTemplateExtraLargeSimpleImage {
        let template = CLKComplicationTemplateExtraLargeSimpleImage()
        template.imageProvider = .init(onePieceImage: .make(112))
        template.tintColor = UIColor(named: "haze")
        return template
    }
    
    private func modularSmall() -> CLKComplicationTemplateModularSmallSimpleImage {
        let template = CLKComplicationTemplateModularSmallSimpleImage()
        template.imageProvider = .init(onePieceImage: .make(32))
        template.tintColor = UIColor(named: "haze")
        return template
    }
    
    private func modularLarge() -> CLKComplicationTemplateModularLargeStandardBody {
        let template = CLKComplicationTemplateModularLargeStandardBody()
        template.headerImageProvider = .init(onePieceImage: .make(42))
        template.tintColor = UIColor(named: "haze")
        return template
    }
    
    private func utilitarianSmall() -> CLKComplicationTemplateUtilitarianSmallSquare {
        let template = CLKComplicationTemplateUtilitarianSmallSquare()
        template.imageProvider = .init(onePieceImage: .make(50))
        template.tintColor = UIColor(named: "haze")
        return template
    }
    
    private func utilitarianSmallFlat() -> CLKComplicationTemplateUtilitarianSmallFlat {
        let template = CLKComplicationTemplateUtilitarianSmallFlat()
        template.imageProvider = .init(onePieceImage: .make(22))
        template.tintColor = UIColor(named: "haze")
        return template
    }
    
    private func utilitarianFlat() -> CLKComplicationTemplateUtilitarianLargeFlat {
        let template = CLKComplicationTemplateUtilitarianLargeFlat()
        template.imageProvider = .init(onePieceImage: .make(22))
        template.tintColor = UIColor(named: "haze")
        return template
    }
    
    private func graphicCorner() -> CLKComplicationTemplateGraphicCornerCircularImage {
        let template = CLKComplicationTemplateGraphicCornerCircularImage()
        template.imageProvider = .init(fullColorImage: .make(36))
        return template
    }
    
    private func graphicBezel() -> CLKComplicationTemplateGraphicBezelCircularText {
        let template = CLKComplicationTemplateGraphicBezelCircularText()
        
        let circular = CLKComplicationTemplateGraphicCircularImage()
        circular.imageProvider = .init(fullColorImage: .make(47))
        template.circularTemplate = circular

        return template
    }
    
    private func graphicRectangular() -> CLKComplicationTemplateGraphicRectangularLargeImage {
        .init()
    }
    
    private func graphicCircular() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateGraphicCircularImage()
        template.imageProvider = .init(fullColorImage: .make(47))
        return template
    }
}
