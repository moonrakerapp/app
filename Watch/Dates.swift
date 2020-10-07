import SwiftUI

final class Dates: WKHostingController<DatesContent> {
    override var body: DatesContent { .init(model: .init()) }
}

struct DatesContent: View {
    @ObservedObject var model: DatesModel
    
    var body: some View {
        HStack {
            VStack {
                Image("new")
                Text(model.newDate)
                    .font(.footnote)
                    .foregroundColor(Color("shade"))
                Text(model.newCounter)
                    .font(.footnote)
                    .foregroundColor(Color("haze"))
            }
            Spacer()
                .frame(width: 15)
            VStack {
                Image("full")
                Text(model.fullDate)
                    .font(.footnote)
                    .foregroundColor(Color("shade"))
                Text(model.fullCounter)
                    .font(.footnote)
                    .foregroundColor(Color("haze"))
            }
        }
    }
}
