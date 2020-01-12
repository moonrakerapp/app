import Moonraker
import SwiftUI

final class Main: WKHostingController<MainContent> {
    override var body: MainContent { .init(model: Model()) }
}

struct MainContent: View {
    @ObservedObject var model: Model
    
    var body: some View {
        GeometryReader {
            if self.model.info != nil {
                Sky(viewModel: .init(self.model.info!, size: $0.size, zoom: false))
            }
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}

private struct Sky: View {
    @State private var ratio = CGFloat()
    let viewModel: ViewModel
    
    var body: some View {
        Group {
            Horizon(ratio: ratio, viewModel: viewModel)
                .stroke(Color("shade"), style: .init(lineWidth: 3, lineCap: .round))
            Dash(ratio: ratio, viewModel: viewModel)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [1, 3]))
                .foregroundColor(Color("shade"))
            Moon(viewModel: viewModel)
                .rotationEffect(.radians((.pi / -2) + viewModel.angle), anchor: .topLeading)
                .offset(x: viewModel.center.x, y: viewModel.center.y)
                .animation(.easeInOut(duration: 1))
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 1)) {
                    self.ratio = 1
                }
            }
        }
    }
}

private struct Moon: View {
    let viewModel: ViewModel
    
    var body: some View {
        Group {
            Outer(viewModel: viewModel)
                .fill(Color.black)
                .shadow(color: Color("haze"), radius: viewModel.radius,
                        x: viewModel.radius, y: viewModel.radius)
            Outer(viewModel: viewModel)
                .stroke(Color("shade"), style: .init(lineWidth: 2, lineCap: .round))
            Face(viewModel: viewModel)
                .fill(Color("haze"))
            Surface(viewModel: viewModel)
                .fill(Color(.sRGB, white: 0, opacity: 0.1))
        }
    }
}

private struct Horizon: Shape {
    var ratio: CGFloat
    let viewModel: ViewModel
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: viewModel.start)
        path.addLines(.init(viewModel.points.prefix(.init(.init(viewModel.points.count) * ratio))))
        return path
    }
    
    var animatableData: CGFloat {
        get { ratio }
        set { ratio = newValue }
    }
}

private struct Dash: Shape {
    var ratio: CGFloat
    let viewModel: ViewModel
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .init(x: viewModel.middle.x - (viewModel.amplitude * ratio), y: viewModel.middle.y))
        path.addLine(to: .init(x: viewModel.middle.x + (viewModel.amplitude * ratio), y: viewModel.middle.y))
        return path
    }
    
    var animatableData: CGFloat {
        get { ratio }
        set { ratio = newValue }
    }
}

private struct Outer: Shape {
    let viewModel: ViewModel
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: viewModel.radius + 1, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
        return path
    }
}

private struct Face: Shape {
    let viewModel: ViewModel
    
    func path(in rect: CGRect) -> Path {
        switch viewModel.phase {
        case .new: return new()
        case .waxingCrescent: return waxingCrescent()
        case .firstQuarter: return firstQuarter()
        case .waxingGibbous: return waxingGibbous()
        case .full: return full()
        case .waningGibbous: return waningGibbous()
        case .lastQuarter: return lastQuarter()
        case .waningCrescent: return waningCrescent()
        }
    }
    
    private func new() -> Path {
        .init()
    }
    
    private func waxingCrescent() -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: viewModel.radius, startAngle: .radians(.pi / 2), endAngle: .radians(.pi / -2), clockwise: true)
        path.addLine(to: .init(x: 0, y: -viewModel.radius))
        path.addCurve(to: .init(x: 0, y: viewModel.radius),
                      control1: .init(x: ((viewModel.fraction - 0.5) / -0.5) * (viewModel.radius * 1.35), y: ((viewModel.fraction - 0.5) / 0.5) * viewModel.radius),
                      control2: .init(x: ((viewModel.fraction - 0.5) / -0.5) * (viewModel.radius * 1.35), y: ((viewModel.fraction - 0.5) / -0.5) * viewModel.radius))
        return path
    }
    
    private func firstQuarter() -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: viewModel.radius, startAngle: .radians(.pi / 2), endAngle: .radians(.pi / -2), clockwise: true)
        return path
    }
    
    private func waxingGibbous() -> Path {
        var path = Path()
        path.addArc(center: viewModel.center, radius: viewModel.radius, startAngle: .radians(.pi / 2), endAngle: .radians(.pi / -2), clockwise: true)
        path.addLine(to: .init(x: 0, y: -viewModel.radius))
        path.addCurve(to: .init(x: 0, y: viewModel.radius),
                      control1: .init(x: ((viewModel.fraction - 0.5) / -0.5) * (viewModel.radius * 1.35), y: ((viewModel.fraction - 0.5) / -0.5) * viewModel.radius),
                      control2: .init(x: ((viewModel.fraction - 0.5) / -0.5) * (viewModel.radius * 1.35), y: ((viewModel.fraction - 0.5) / 0.5) * viewModel.radius))
        return path
    }
    
    private func full() -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: viewModel.radius, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
        return path
    }
    
    private func waningGibbous() -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: viewModel.radius, startAngle: .radians(.pi / -2), endAngle: .radians(.pi / 2), clockwise: true)
        path.addLine(to: .init(x: 0, y: viewModel.radius))
        path.addCurve(to: .init(x: 0, y: -viewModel.radius),
                      control1: .init(x: ((viewModel.fraction - 0.5) / 0.5) * (viewModel.radius * 1.35),
                                      y: ((viewModel.fraction - 0.5) / 0.5) * viewModel.radius),
                      control2: .init(x: ((viewModel.fraction - 0.5) / 0.5) * (viewModel.radius * 1.35),
                                      y: ((viewModel.fraction - 0.5) / -0.5) * viewModel.radius))
        return path
    }
    
    private func lastQuarter() -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: viewModel.radius, startAngle: .radians(.pi / -2), endAngle: .radians(.pi / 2), clockwise: true)
        return path
    }
    
    private func waningCrescent() -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: viewModel.radius, startAngle: .radians(.pi / -2), endAngle: .radians(.pi / 2), clockwise: true)
        path.addLine(to: .init(x: 0, y: viewModel.radius))
        path.addCurve(to: .init(x: 0, y: -viewModel.radius),
                      control1: .init(x: ((viewModel.fraction - 0.5) / 0.5) * (viewModel.radius * 1.35), y: ((viewModel.fraction - 0.5) / -0.5) * viewModel.radius),
                      control2: .init(x: ((viewModel.fraction - 0.5) / 0.5) * (viewModel.radius * 1.35), y: ((viewModel.fraction - 0.5) / 0.5) * viewModel.radius))
        return path
    }
}

private struct Surface: Shape {
    let viewModel: ViewModel
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addPath({
            var path = Path()
            path.addArc(center: .init(x: viewModel.radius / -3, y: viewModel.radius / -3.5),
                        radius: viewModel.radius / 2.2, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        path.addPath({
            var path = Path()
            path.addArc(center: .init(x: viewModel.radius / -3, y: viewModel.radius / 2.25),
                        radius: viewModel.radius / 4, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        path.addPath({
            var path = Path()
            path.addArc(center: .init(x: viewModel.radius / 2, y: viewModel.radius / 3.5),
                        radius: viewModel.radius / 4, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        path.addPath({
            var path = Path()
            path.addArc(center: .init(x: viewModel.radius / 6, y: viewModel.radius / 1.5),
                        radius: viewModel.radius / 5, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        path.addPath({
            var path = Path()
            path.addArc(center: .init(x: viewModel.radius / 4, y: viewModel.radius / -1.5),
                        radius: viewModel.radius / 6, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        return path
    }
}
