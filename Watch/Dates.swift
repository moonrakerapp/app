import SwiftUI
import Combine

final class Dates: WKHostingController<DatesContent> {
    override var body: DatesContent { .init() }
}

struct DatesContent: View {
    @State private var ratio = CGFloat()
    @State private var crown = Double()
    @State private var zoom = false
    
    var body: some View {
        VStack {
            HStack {
                Item(image: "rise", date: "b", time: "a")
                Item(image: "set", date: "b", time: "a")
            }
            HStack {
                Item(image: "new", date: "b", time: "a")
                Item(image: "full", date: "b", time: "a")
            }
        }
    }
}

private struct Item: View {
    let image: String
    let date: String
    let time: String
    
    var body: some View {
        VStack {
            Image(image)
            Text(date)
                .font(.footnote)
                .foregroundColor(Color("shade"))
            Text(time)
                .font(.footnote)
                .foregroundColor(Color("shade"))
        }
    }
}
