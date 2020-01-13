import SwiftUI
import Combine

final class Stats: WKHostingController<StatsContent> {
    override var body: StatsContent { .init() }
}

struct StatsContent: View {
    @State private var ratio = CGFloat()
    @State private var crown = Double()
    @State private var zoom = false
    
    var body: some View {
        ZStack {
            Circle()
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}
