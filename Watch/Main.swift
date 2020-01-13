import Moonraker
import SwiftUI
import Combine

final class Main: WKHostingController<MainContent> {
    override var body: MainContent { .init(model: Model()) }
}

struct MainContent: View {
    @ObservedObject var model: Model
    @State private var ratio = CGFloat()
    @State private var crown = Double()
    @State private var zoom = false
    
    var body: some View {
        ZStack {
            if self.model.info != nil {
                GeometryReader { g in
                    Sky(ratio: self.$ratio, render: .init(self.model.info!, size: g.size, zoom: self.zoom))
                }.edgesIgnoringSafeArea(.all)
            }
            Button(action: {
                self.zoom.toggle()
                withAnimation(.easeOut(duration: 0.6)) {
                    self.ratio = self.zoom ? 0 : 1
                }
            }) {
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
                    Text(model.date)
                        .font(.footnote)
                        .foregroundColor(Color("shade"))
                }
            }.background(Color.clear)
                .accentColor(.clear)
                .focusable()
                .digitalCrownRotation($crown)
                .onReceive(Just(crown)) {
                    let offset = TimeInterval($0 * 500)
                    if moonraker.offset != offset {
                        moonraker.offset = offset
                    }
                }
            if !self.model.date.isEmpty {
                VStack {
                    Button(action: {
                        self.crown = 0
                    }) {
                        Image("now")
                    }.background(Color.clear)
                        .accentColor(.clear)
                        .foregroundColor(Color("haze"))
                        .padding(.top, 15)
                    Spacer()
                }
            }
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true).onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.easeOut(duration: 1)) {
                        self.ratio = 1
                    }
                }
        }
    }
}

private struct Sky: View {
    @Binding var ratio: CGFloat
    let render: Render
    
    var body: some View {
        Group {
            Horizon(ratio: ratio, render: render)
                .stroke(Color("shade"), style: .init(lineWidth: 3, lineCap: .round))
            Dash(ratio: ratio, render: render)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [1, 3]))
                .foregroundColor(Color("shade"))
            Moon(render: render)
                .rotationEffect(.radians((.pi / -2) + render.angle), anchor: .topLeading)
                .offset(x: render.center.x, y: render.center.y)
                .animation(.easeInOut(duration: 0.6))
        }
    }
}

private struct Moon: View {
    let render: Render
    
    var body: some View {
        Group {
            Outer(render: render)
                .fill(Color.black)
                .shadow(color: Color("haze"), radius: render.radius,
                        x: render.radius, y: render.radius)
            Outer(render: render)
                .stroke(Color("shade"), style: .init(lineWidth: 2, lineCap: .round))
            Face(render: render)
                .fill(Color("haze"))
            Surface(render: render)
                .fill(Color(.sRGB, white: 0, opacity: 0.1))
        }
    }
}

private struct Horizon: Shape {
    var ratio: CGFloat
    let render: Render
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: render.start)
        path.addLines(.init(render.points.prefix(.init(.init(render.points.count) * ratio))))
        return path
    }
    
    var animatableData: CGFloat {
        get { ratio }
        set { ratio = newValue }
    }
}

private struct Dash: Shape {
    var ratio: CGFloat
    let render: Render
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .init(x: render.middle.x - (render.amplitude * ratio), y: render.middle.y))
        path.addLine(to: .init(x: render.middle.x + (render.amplitude * ratio), y: render.middle.y))
        return path
    }
    
    var animatableData: CGFloat {
        get { ratio }
        set { ratio = newValue }
    }
}

private struct Outer: Shape {
    var render: Render
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: render.radius + 1, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
        return path
    }
    
    var animatableData: CGFloat {
        get { render.radius }
        set { render.radius = newValue }
    }
}

private struct Face: Shape {
    var render: Render
    
    func path(in rect: CGRect) -> Path {
        switch render.phase {
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
        path.addArc(center: .zero, radius: render.radius, startAngle: .radians(.pi / 2), endAngle: .radians(.pi / -2), clockwise: true)
        path.addLine(to: .init(x: 0, y: -render.radius))
        path.addCurve(to: .init(x: 0, y: render.radius),
                      control1: .init(x: ((render.fraction - 0.5) / -0.5) * (render.radius * 1.35), y: ((render.fraction - 0.5) / 0.5) * render.radius),
                      control2: .init(x: ((render.fraction - 0.5) / -0.5) * (render.radius * 1.35), y: ((render.fraction - 0.5) / -0.5) * render.radius))
        return path
    }
    
    private func firstQuarter() -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: render.radius, startAngle: .radians(.pi / 2), endAngle: .radians(.pi / -2), clockwise: true)
        return path
    }
    
    private func waxingGibbous() -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: render.radius, startAngle: .radians(.pi / 2), endAngle: .radians(.pi / -2), clockwise: true)
        path.addLine(to: .init(x: 0, y: -render.radius))
        path.addCurve(to: .init(x: 0, y: render.radius),
                      control1: .init(x: ((render.fraction - 0.5) / -0.5) * (render.radius * 1.35),
                                      y: ((render.fraction - 0.5) / -0.5) * render.radius),
                      control2: .init(x: ((render.fraction - 0.5) / -0.5) * (render.radius * 1.35),
                                      y: ((render.fraction - 0.5) / 0.5) * render.radius))
        return path
    }
    
    private func full() -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: render.radius, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
        return path
    }
    
    private func waningGibbous() -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: render.radius, startAngle: .radians(.pi / -2), endAngle: .radians(.pi / 2), clockwise: true)
        path.addLine(to: .init(x: 0, y: render.radius))
        path.addCurve(to: .init(x: 0, y: -render.radius),
                      control1: .init(x: ((render.fraction - 0.5) / 0.5) * (render.radius * 1.35),
                                      y: ((render.fraction - 0.5) / 0.5) * render.radius),
                      control2: .init(x: ((render.fraction - 0.5) / 0.5) * (render.radius * 1.35),
                                      y: ((render.fraction - 0.5) / -0.5) * render.radius))
        return path
    }
    
    private func lastQuarter() -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: render.radius, startAngle: .radians(.pi / -2), endAngle: .radians(.pi / 2), clockwise: true)
        return path
    }
    
    private func waningCrescent() -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: render.radius, startAngle: .radians(.pi / -2), endAngle: .radians(.pi / 2), clockwise: true)
        path.addLine(to: .init(x: 0, y: render.radius))
        path.addCurve(to: .init(x: 0, y: -render.radius),
                      control1: .init(x: ((render.fraction - 0.5) / 0.5) * (render.radius * 1.35), y: ((render.fraction - 0.5) / -0.5) * render.radius),
                      control2: .init(x: ((render.fraction - 0.5) / 0.5) * (render.radius * 1.35), y: ((render.fraction - 0.5) / 0.5) * render.radius))
        return path
    }
    
    var animatableData: CGFloat {
        get { render.radius }
        set { render.radius = newValue }
    }
}

private struct Surface: Shape {
    var render: Render
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addPath({
            var path = Path()
            path.addArc(center: .init(x: render.radius / -3, y: render.radius / -3.5),
                        radius: render.radius / 2.2, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        path.addPath({
            var path = Path()
            path.addArc(center: .init(x: render.radius / -3, y: render.radius / 2.25),
                        radius: render.radius / 4, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        path.addPath({
            var path = Path()
            path.addArc(center: .init(x: render.radius / 2, y: render.radius / 3.5),
                        radius: render.radius / 4, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        path.addPath({
            var path = Path()
            path.addArc(center: .init(x: render.radius / 6, y: render.radius / 1.5),
                        radius: render.radius / 5, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        path.addPath({
            var path = Path()
            path.addArc(center: .init(x: render.radius / 4, y: render.radius / -1.5),
                        radius: render.radius / 6, startAngle: .radians(0), endAngle: .radians(.pi * 2), clockwise: true)
            return path
        } ())
        return path
    }
    
    var animatableData: CGFloat {
        get { render.radius }
        set { render.radius = newValue }
    }
}
