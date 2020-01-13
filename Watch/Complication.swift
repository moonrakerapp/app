import ClockKit

final class Complication: NSObject, CLKComplicationDataSource {
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler: @escaping (CLKComplicationTimelineEntry?) -> Void) {


            
    //        let template = CLKComplicationTemplateModularSmallStackImage()
            
    //        UIGraphicsBeginImageContext(.init(width: Argonaut.tile * 2, height: Argonaut.tile * 2))
    //        UIGraphicsGetCurrentContext()!.translateBy(x: 0, y: .init(Argonaut.tile) * 2)
    //        UIGraphicsGetCurrentContext()!.scaleBy(x: 1, y: -1)
    //        UIGraphicsGetCurrentContext()!.draw(cgImage!, in:
    //            .init(x: Argonaut.tile * 2 * -.init(x), y: (Argonaut.tile * 2 * .init(y + 1)) - .init(cgImage!.height), width: .init(cgImage!.width), height: .init(cgImage!.height)))
    //
    //        split.data = UIImage(cgImage: UIGraphicsGetCurrentContext()!.makeImage()!).pngData()!
    //        UIGraphicsEndImageContext()
            
            // Set the data providers.
    //        template.line1ImageProvider = CLKImageProvider(onePieceImage: UIGraphicsEndImageContext())
        withHandler(.init(date: .init(), complicationTemplate: {
            switch $0 {
            case .circularSmall: return circularSmall()
            case .extraLarge: return .init()
            case .modularSmall: return .init()
            case .modularLarge: return .init()
            case .utilitarianSmall: return .init()
            case .utilitarianSmallFlat: return .init()
            case .utilitarianLarge: return .init()
            case .graphicCorner: return .init()
            case .graphicCircular: return graphicCircular()
            case .graphicBezel: return .init()
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
    
    private func circularSmall() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateCircularSmallStackImage()
        template.line1ImageProvider = CLKImageProvider(onePieceImage: UIImage(named: "new")!)
        template.line2TextProvider = CLKSimpleTextProvider(text: "as",
                                                           shortText: "d")
        
        return template
        
        
    }
    
    private func graphicCircular() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateGraphicCircularImage()
        template.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "new")!)
        return template
    }
}
