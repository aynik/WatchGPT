import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
  func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
    handler([
      CLKComplicationDescriptor(
        identifier: "complication",
        displayName: "WatchGPT",
        supportedFamilies: [CLKComplicationFamily.modularSmall])
    ])
  }
  
  private func getComplicationTemplate(for complication: CLKComplication) -> CLKComplicationTemplate? {
    let template: CLKComplicationTemplate
    switch complication.family {
    case .modularSmall:
      template = CLKComplicationTemplateModularSmallSimpleImage(imageProvider: CLKImageProvider(onePieceImage: UIImage(named: "Complication/Modular")!))
    default:
      return nil
    }
    return template
  }
  
  private func getTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
    if let template = getComplicationTemplate(for: complication) {
      handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
    }
  }
  
  func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
    if let template = getComplicationTemplate(for: complication) {
      handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
    }
  }
}
