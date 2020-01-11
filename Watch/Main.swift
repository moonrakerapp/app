import SwiftUI

final class Main: WKHostingController<MainContent> {
    override var body: MainContent { .init() }
}

struct MainContent: View {
    @State private var ratio = CGFloat()
    
    var body: some View {
        ZStack {
            Horizon(ratio: ratio)
                .stroke(Color("shade"), style: .init(lineWidth: 3, lineCap: .round))
        }.onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                self.ratio = 1
            }
        }
    }
}

private struct Horizon: Shape {
    var ratio: CGFloat
    private let period = CGFloat(360)
    
    func path(in rect: CGRect) -> Path {
        let radius = (min(rect.width, rect.height) * 0.5) - 2
        let amplitude = radius / 2
        
        var path = Path()
        path.move(to: .init(x: rect.midX - radius, y: rect.midY + (amplitude * ratio)))
        stride(from: 2, through: period, by: 2).forEach {
            path.addLine(to: CGPoint(x: rect.midX - radius + ($0 / period * (radius * 2)), y: rect.midY + (cos($0 / 180 * .pi) * (amplitude * ratio))))
        }
        return path
    }
    
    var animatableData: CGFloat {
        get { ratio }
        set { ratio = newValue }
    }
}
