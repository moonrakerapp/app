import SwiftUI

final class Times: WKHostingController<TimesContent> {
    private let model = TimesModel()
    
    override var body: TimesContent { .init(model: model) }
    
    override func didAppear() {
        super.didAppear()
        model.timer.schedule(deadline: .now(), repeating: 1)
    }
    
    override func willDisappear() {
        super.willDisappear()
        model.timer.schedule(deadline: .distantFuture)
    }
}

struct TimesContent: View {
    @ObservedObject var model: TimesModel
    
    var body: some View {
        HStack {
            VStack {
                Image("rise")
                Text(model.riseDate)
                    .font(.footnote)
                    .foregroundColor(Color("shade"))
                Text(model.riseCounter)
                    .font(.footnote)
                    .foregroundColor(Color("haze"))
            }
            VStack {
                Image("set")
                Text(model.setDate)
                    .font(.footnote)
                    .foregroundColor(Color("shade"))
                Text(model.setCounter)
                    .font(.footnote)
                    .foregroundColor(Color("haze"))
            }
        }
    }
}
