import Moonraker
import SwiftUI

final class Main: WKHostingController<MainContent> {
    override var body: MainContent { .init(model: Model()) }
}

struct MainContent: View {
    @ObservedObject var model: Model
    @State private var ratio = CGFloat()
    
    var body: some View {
        GeometryReader {
            if self.model.info != nil {
                Moon(viewModel: .init(self.model.info!, size: $0.size, ratio: self.ratio, zoom: false))
            }
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
    var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            Horizon(viewModel: viewModel)
                .stroke(Color("shade"), style: .init(lineWidth: 3, lineCap: .round))
            Outer(viewModel: viewModel)
                .fill(Color.black)
                .shadow(color: Color("haze"), radius: viewModel.radius,
                        x: viewModel.radius - viewModel.center.x, y: viewModel.radius - viewModel.center.y)
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
    var viewModel: ViewModel
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: viewModel.start)
        path.addLines(viewModel.points)
        return path
    }
    
    var animatableData: ViewModel {
        get { viewModel }
        set { viewModel = newValue }
    }
}

private struct Outer: Shape {
    var viewModel: ViewModel
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: viewModel.center, radius: viewModel.radius + 1, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
        return path
    }
    
    var animatableData: ViewModel {
        get { viewModel }
        set { viewModel = newValue }
    }
}

private struct Face: Shape {
    var viewModel: ViewModel
    
    func path(in rect: CGRect) -> Path {
        switch viewModel.phase {
        case .new: return new()
//        case .waxingCrescent: return waxingCrescent()
//        case .firstQuarter: return firstQuarter()
//        case .waxingGibbous: return waxingGibbous()
//        case .full: return full()
//        case .waningGibbous: return waningGibbous()
//        case .lastQuarter: return lastQuarter()
//        case .waningCrescent: return waningCrescent()
        default: return new()
        }
    }
    
    private func new() -> Path {
        .init()
    }
    /*
    private func waxingCrescent() -> Path {
        var path = Path()
        path.addArc(center: center, radius: animatable.radius, startAngle: .radians(.pi / 2), endAngle: .radians(.pi / -2), clockwise: true)
        path.addLine(to: .init(x: center.x, y: center.y - animatable.radius))
        path.addCurve(to: .init(x: center.x, y: center.y + animatable.radius),
                      control1: .init(x: ((animatable.fraction - 0.5) / -0.5) * (animatable.radius * 1.35), y: ((animatable.fraction - 0.5) / 0.5) * animatable.radius),
                      control2: .init(x: ((animatable.fraction - 0.5) / -0.5) * (animatable.radius * 1.35), y: ((animatable.fraction - 0.5) / -0.5) * animatable.radius))
        return path
    }
    
    private func firstQuarter() -> Path {
        var path = Path()
        path.addArc(center: center, radius: animatable.radius, startAngle: .radians(.pi / 2), endAngle: .radians(.pi / -2), clockwise: true)
        return path
    }
    
    private func waxingGibbous() -> Path {
        var path = Path()
        path.addArc(center: center, radius: animatable.radius, startAngle: .radians(.pi / 2), endAngle: .radians(.pi / -2), clockwise: true)
        path.addLine(to: .init(x: center.x, y: center.y - animatable.radius))
        path.addCurve(to: .init(x: center.x, y: center.y + animatable.radius),
                      control1: .init(x: ((animatable.fraction - 0.5) / -0.5) * (animatable.radius * 1.35), y: ((animatable.fraction - 0.5) / -0.5) * animatable.radius),
                      control2: .init(x: ((animatable.fraction - 0.5) / -0.5) * (animatable.radius * 1.35), y: ((animatable.fraction - 0.5) / 0.5) * animatable.radius))
        return path
    }
    
    private func full() -> Path {
        var path = Path()
        path.addArc(center: center, radius: animatable.radius, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
        return path
    }
    
    private func waningGibbous() -> Path {
        var path = Path()
        path.addArc(center: center, radius: animatable.radius, startAngle: .radians(.pi / -2), endAngle: .radians(.pi / 2), clockwise: true)
        path.addLine(to: .init(x: center.x, y: center.y + animatable.radius))
        path.addCurve(to: .init(x: center.x, y: center.y - animatable.radius),
                      control1: .init(x: center.x + (((animatable.fraction - 0.5) / 0.5) * (animatable.radius * 1.35)),
                                      y: center.y + ((animatable.fraction - 0.5) / 0.5) * animatable.radius),
                      control2: .init(x: center.x + ((animatable.fraction - 0.5) / 0.5) * (animatable.radius * 1.35),
                                      y: center.y + ((animatable.fraction - 0.5) / -0.5) * animatable.radius))
        return path
    }
    
    private func lastQuarter() -> Path {
        var path = Path()
        path.addArc(center: center, radius: animatable.radius, startAngle: .radians(.pi / -2), endAngle: .radians(.pi / 2), clockwise: true)
        return path
    }
    
    private func waningCrescent() -> Path {
        var path = Path()
        path.addArc(center: center, radius: animatable.radius, startAngle: .radians(.pi / -2), endAngle: .radians(.pi / 2), clockwise: true)
        path.addLine(to: .init(x: center.x, y: center.y + animatable.radius))
        path.addCurve(to: .init(x: center.x, y: center.y - animatable.radius),
                      control1: .init(x: ((animatable.fraction - 0.5) / 0.5) * (animatable.radius * 1.35), y: ((animatable.fraction - 0.5) / -0.5) * animatable.radius),
                      control2: .init(x: ((animatable.fraction - 0.5) / 0.5) * (animatable.radius * 1.35), y: ((animatable.fraction - 0.5) / 0.5) * animatable.radius))
        return path
    }*/
    
    var animatableData: ViewModel {
        get { viewModel }
        set { viewModel = newValue }
    }
}

private struct Surface: Shape {
    var viewModel: ViewModel
    
    func path(in rect: CGRect) -> Path {
        var path = Path()/*
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
        } ())*/
        return path
    }
    
    var animatableData: ViewModel {
        get { viewModel }
        set { viewModel = newValue }
    }
}

