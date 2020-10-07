import Moonraker
import SwiftUI
import Combine

final class Main: WKHostingController<AnyView> {
    override var body: AnyView { .init(Content().environmentObject(MainModel())) }
}

private struct Content: View {
    @EnvironmentObject var model: MainModel
    @State private var ratio = CGFloat()
    @State private var crown = Double()
    
    var body: some View {
        ZStack {
            Sky(ratio: $ratio)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                HStack {
                    Text(model.percent)
                        .font(Font.body.bold())
                        .foregroundColor(Color("haze"))
                        .padding(.trailing, -7)
                    Text("%")
                        .font(.footnote)
                        .foregroundColor(Color("shade"))
                }
                Text(model.name)
                    .font(Font.caption.bold())
                    .foregroundColor(Color("haze"))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                model.zoom.toggle()
                withAnimation(.easeOut(duration: 0.6)) {
                    ratio = model.zoom ? 0 : 1
                }
            }
            if !model.date.isEmpty {
                VStack {
                    Button(action: {
                        crown = 0
                    }) {
                        Image("now")
                            .font(.title)
                            .foregroundColor(Color("haze"))
                            .frame(width: 50, height: 50)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Rectangle())
                    Spacer()
                }
            }
        }
        .navigationBarTitle(model.date)
        .focusable()
        .digitalCrownRotation($crown)
        .onReceive(Just(crown)) {
            let offset = TimeInterval($0 * 500)
            if app.moonraker.offset != offset {
                app.moonraker.offset = offset
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 2)) {
                ratio = 1
            }
        }
    }
}

private struct Sky: View {
    @EnvironmentObject var model: MainModel
    @Binding var ratio: CGFloat
    
    var body: some View {
        ZStack {
            Horizon(ratio: ratio, points: model.points, start: model.start)
                .stroke(Color("shade"), style: .init(lineWidth: 3, lineCap: .round))
            Dash(ratio: ratio, middle: model.middle, amplitude: model.amplitude)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [1, 3]))
                .foregroundColor(Color("shade"))
            Moon()
                .rotationEffect(.radians((.pi / -2) + model.angle), anchor: .topLeading)
                .offset(x: model.center.x, y: model.center.y)
                .animation(.easeInOut(duration: 0.6))
        }
    }
}

private struct Moon: View {
    @EnvironmentObject var model: MainModel
    
    var body: some View {
        ZStack {
            Outer(radius: model.radius)
                .fill(Color.black)
                .shadow(color: Color("haze"), radius: model.radius)
            Outer(radius: model.radius)
                .stroke(Color("shade"), style: .init(lineWidth: 2, lineCap: .round))
            Face(radius: model.radius, fraction: model.fraction, phase: model.phase)
                .fill(Color("haze"))
            Surface(radius: model.radius)
                .fill(Color(.sRGB, white: 0, opacity: 0.1))
        }
    }
}

private struct Horizon: Shape {
    var ratio: CGFloat
    let points: [CGPoint]
    let start: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: start)
        path.addLines(.init(points.prefix(.init(.init(points.count) * ratio))))
        return path
    }
    
    var animatableData: CGFloat {
        get { ratio }
        set { ratio = newValue }
    }
}

private struct Dash: Shape {
    var ratio: CGFloat
    let middle: CGPoint
    let amplitude: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .init(x: middle.x - (amplitude * ratio), y: middle.y))
        path.addLine(to: .init(x: middle.x + (amplitude * ratio), y: middle.y))
        return path
    }
    
    var animatableData: CGFloat {
        get { ratio }
        set { ratio = newValue }
    }
}

private struct Outer: Shape {
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: radius + 1, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
        return path
    }
    
    var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }
}

private struct Face: Shape {
    var radius: CGFloat
    let fraction: CGFloat
    let phase: Phase
    
    func path(in rect: CGRect) -> Path {
        switch phase {
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
        path.addArc(center: .zero, radius: radius, startAngle: .radians(.pi / 2), endAngle: .radians(.pi / -2), clockwise: true)
        path.addLine(to: .init(x: 0, y: -radius))
        path.addCurve(to: .init(x: 0, y: radius),
                      control1: .init(x: ((fraction - 0.5) / -0.5) * (radius * 1.35), y: ((fraction - 0.5) / 0.5) * radius),
                      control2: .init(x: ((fraction - 0.5) / -0.5) * (radius * 1.35), y: ((fraction - 0.5) / -0.5) * radius))
        return path
    }
    
    private func firstQuarter() -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: radius, startAngle: .radians(.pi / 2), endAngle: .radians(.pi / -2), clockwise: true)
        return path
    }
    
    private func waxingGibbous() -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: radius, startAngle: .radians(.pi / 2), endAngle: .radians(.pi / -2), clockwise: true)
        path.addLine(to: .init(x: 0, y: -radius))
        path.addCurve(to: .init(x: 0, y: radius),
                      control1: .init(x: ((fraction - 0.5) / -0.5) * (radius * 1.35),
                                      y: ((fraction - 0.5) / -0.5) * radius),
                      control2: .init(x: ((fraction - 0.5) / -0.5) * (radius * 1.35),
                                      y: ((fraction - 0.5) / 0.5) * radius))
        return path
    }
    
    private func full() -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: radius, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
        return path
    }
    
    private func waningGibbous() -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: radius, startAngle: .radians(.pi / -2), endAngle: .radians(.pi / 2), clockwise: true)
        path.addLine(to: .init(x: 0, y: radius))
        path.addCurve(to: .init(x: 0, y: -radius),
                      control1: .init(x: ((fraction - 0.5) / 0.5) * (radius * 1.35),
                                      y: ((fraction - 0.5) / 0.5) * radius),
                      control2: .init(x: ((fraction - 0.5) / 0.5) * (radius * 1.35),
                                      y: ((fraction - 0.5) / -0.5) * radius))
        return path
    }
    
    private func lastQuarter() -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: radius, startAngle: .radians(.pi / -2), endAngle: .radians(.pi / 2), clockwise: true)
        return path
    }
    
    private func waningCrescent() -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: radius, startAngle: .radians(.pi / -2), endAngle: .radians(.pi / 2), clockwise: true)
        path.addLine(to: .init(x: 0, y: radius))
        path.addCurve(to: .init(x: 0, y: -radius),
                      control1: .init(x: ((fraction - 0.5) / 0.5) * (radius * 1.35), y: ((fraction - 0.5) / -0.5) * radius),
                      control2: .init(x: ((fraction - 0.5) / 0.5) * (radius * 1.35), y: ((fraction - 0.5) / 0.5) * radius))
        return path
    }
    
    var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }
}

private struct Surface: Shape {
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addPath({
            var path = Path()
            path.addArc(center: .init(x: radius / -3, y: radius / -3.5),
                        radius: radius / 2.2, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        path.addPath({
            var path = Path()
            path.addArc(center: .init(x: radius / -3, y: radius / 2.25),
                        radius: radius / 4, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        path.addPath({
            var path = Path()
            path.addArc(center: .init(x: radius / 2, y: radius / 3.5),
                        radius: radius / 4, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        path.addPath({
            var path = Path()
            path.addArc(center: .init(x: radius / 6, y: radius / 1.5),
                        radius: radius / 5, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        path.addPath({
            var path = Path()
            path.addArc(center: .init(x: radius / 4, y: radius / -1.5),
                        radius: radius / 6, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        return path
    }
    
    var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }
}
