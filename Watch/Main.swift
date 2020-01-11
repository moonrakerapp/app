import SwiftUI

final class Main: WKHostingController<MainContent> {
    override var body: MainContent { .init() }
}

struct MainContent: View {
    @State private var ratio = CGFloat()
    
    var body: some View {
        GeometryReader {
            Horizon(ratio: self.ratio)
                .stroke(Color("shade"), style: .init(lineWidth: 3, lineCap: .round))
            Moon(animatable: .init(radius: min($0.size.width, $0.size.height) / 10, x: $0.size.width / 2, y: $0.size.height / 2))
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    self.ratio = 1
                }
            }
    }
}

private struct Moon: View {
    var animatable: Animatable
    
    var body: some View {
        Group {
            Outer(animatable: animatable)
                .fill(Color.black)
                .shadow(color: Color("haze"), radius: animatable.radius, x: animatable.radius - animatable.x, y: animatable.radius - animatable.y)
            Outer(animatable: animatable)
                .stroke(Color("shade"), style: .init(lineWidth: 2, lineCap: .round))
            Face(animatable: animatable)
                .fill(Color("haze"))
            Surface(animatable: animatable)
                .fill(Color(.sRGB, white: 0, opacity: 0.1))
        }
    }
}

private struct Horizon: Shape {
    var ratio: CGFloat
    private let period = CGFloat(360)
    
    func path(in rect: CGRect) -> Path {
        let radius = (min(rect.width, rect.height) * 0.5) - 2
        let amplitude = radius / 3
        
        var path = Path()
        path.move(to: .init(x: rect.midX - radius, y: rect.midY + (amplitude * ratio)))
        stride(from: 2, through: period, by: 2).forEach {
            path.addLine(to:
                CGPoint(x: rect.midX - radius + ($0 / period * (radius * 2)), y: rect.midY + (cos($0 / 180 * .pi) * (amplitude * ratio))))
        }
        return path
    }
    
    var animatableData: CGFloat {
        get { ratio }
        set { ratio = newValue }
    }
}

private struct Outer: Shape {
    var animatable: Animatable
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: .init(x: animatable.x, y: animatable.y), radius: animatable.radius + 1, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
        return path
    }
    
    var animatableData: Animatable {
        get { animatable }
        set { animatable = newValue }
    }
}

private struct Face: Shape {
    var animatable: Animatable
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: .init(x: animatable.x, y: animatable.y), radius: animatable.radius, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
        return path
    }
    
    var animatableData: Animatable {
        get { animatable }
        set { animatable = newValue }
    }
}

private struct Surface: Shape {
    var animatable: Animatable
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addPath({
            var path = Path()
            path.addArc(center:
                .init(x: animatable.x + (animatable.radius / -3), y: animatable.y + (animatable.radius / -3.5)),
                        radius: animatable.radius / 2.2, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        path.addPath({
            var path = Path()
            path.addArc(center:
                .init(x: animatable.x + (animatable.radius / -3), y: animatable.y + (animatable.radius / 2.25)),
                        radius: animatable.radius / 4, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        path.addPath({
            var path = Path()
            path.addArc(center:
                .init(x: animatable.x + (animatable.radius / 2), y: animatable.y + (animatable.radius / 3.5)),
                        radius: animatable.radius / 4, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        path.addPath({
            var path = Path()
            path.addArc(center:
                .init(x: animatable.x + (animatable.radius / 6), y: animatable.y + (animatable.radius / 1.5)),
                        radius: animatable.radius / 5, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        path.addPath({
            var path = Path()
            path.addArc(center:
                .init(x: animatable.x + (animatable.radius / 4), y: animatable.y + (animatable.radius / -1.5)),
                        radius: animatable.radius / 6, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        return path
    }
    
    var animatableData: Animatable {
        get { animatable }
        set { animatable = newValue }
    }
}

private struct Animatable {
    var radius: CGFloat
    var x: CGFloat
    var y: CGFloat
}
