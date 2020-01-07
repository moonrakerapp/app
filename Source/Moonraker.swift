import Foundation
import Combine

public final class Moonraker {
    public var coords = (Double(), Double()) {
        didSet {
            makeInfo()
            makeTimes()
            makePhases()
        }
    }
    
    public var date = Date() {
        didSet {
            makeInfo()
            makeTimes()
            makePhases()
        }
    }
    
    public var offset = TimeInterval() {
        didSet {
            makeInfo()
        }
    }
    
    public let info = CurrentValueSubject<Info, Never>(.init())
    public let times = CurrentValueSubject<Times, Never>(.down)
    public let phases = CurrentValueSubject<(Date, Date), Never>((.init(), .init()))
    private let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    private let J1970 = Double(2440588)
    private let J2000 = Double(2451545)
    private let cycle = TimeInterval(60 * 60 * 24 * 29.53)
    private let radians = Double.pi / 180
    private let earthPerihelion = Double.pi / 180 * 102.9372
    private let earthObliquity = Double.pi / 180 * 23.4397
    private let sunDistanceKm = Double(149598000)
    
    public init() {
        
    }
    
    func info(_ time: TimeInterval, _ latitude: Double, _ longitude: Double) -> Info {
        let _days = days(time)
        let _sunCoords = sunCoords(_days)
        let _moonCoords = moonCoords(_days)
        let _inclination = inclination(phi(_sunCoords, _moonCoords), _moonCoords.2)
        let _angle = angle(_sunCoords, _moonCoords)
        let _lw = radians * -longitude
        let _phi = radians * latitude
        let _h = siderealTime(_days, _lw) - _moonCoords.0
        let _altitude = altitude(_h, _phi, _moonCoords.1)
        let _parallacticeAngle = atan2(sin(_h), tan(_phi) * cos(_moonCoords.1) - sin(_moonCoords.1) * cos(_h))
        
        var info = Info()
        info.phase = phase(phase(_inclination, _angle))
        info.fraction = fraction(_inclination)
        info.angle = _angle - _parallacticeAngle
        info.azimuth = azimuth(_h, _phi, _moonCoords.1)
        info.altitude = _altitude + astroRefraction(_altitude)
        return info
    }
    
    func times(_ date: Date, _ latitude: Double, _ longitude: Double) -> Times {
        let _start = date.timeIntervalSince1970
        let _hc = 0.133 * radians
        var _h0 = position(_start, latitude, longitude).1 - _hc
        var _ye = Double()
        var _rise: Double?
        var _set: Double?
        
        for i in stride(from: Double(1), through: 48, by: 2) {
            let _h1 = position(_start + (i * 3600), latitude, longitude).1 - _hc
            let _h2 = position(_start + ((i + 1) * 3600), latitude, longitude).1 - _hc
            let _a = (_h0 + _h2) / 2 - _h1
            let _b = (_h2 - _h0) / 2
            let _xe = -_b / (2 * _a)
            let _d = _b * _b - 4 * _a * _h1;
            var _roots = 0
            var _dx = Double()
            var _x1 = Double()
            var _x2 = Double()
            _ye = (_a * _xe + _b) * _xe + _h1
            
            if _d >= 0 {
                _dx = sqrt(_d) / (abs(_a) * 2);
                _x1 = _xe - _dx
                _x2 = _xe + _dx
                
                if abs(_x1) <= 1 {
                    _roots += 1
                }
                
                if abs(_x2) <= 1 {
                    _roots += 1
                }
                
                if _x1 < -1 {
                    _x1 = _x2
                }
            }

            if _roots == 1 {
                if _h0 < 0 {
                    _rise = i + _x1
                } else {
                    _set = i + _x1
                }
            } else if _roots == 2 {
                _rise = i + (_ye < 0 ? _x2 : _x1)
                _set = i + (_ye < 0 ? _x1 : _x2)
            }
            
            if _rise != nil && _set != nil {
                break
            }
            
            _h0 = _h2
        }
        
        if let _rise = _rise {
            if let _set = _set {
                return .both(rise: .init(timeIntervalSince1970: _start + (_rise * 3600)), set: .init(timeIntervalSince1970: _start + (_set * 3600)))
            } else {
                return .rise(time: .init(timeIntervalSince1970: _start + (_rise * 3600)))
            }
        } else if let _set = _set {
            return .set(time: .init(timeIntervalSince1970: _start + (_set * 3600)))
        }
        
        return _ye > 0 ? .up : .down
    }
    
    func illumination(_ time: TimeInterval) -> (Phase, Double, Double) {
        {
            {
                {
                    (phase(phase($0, $1)), fraction($0), $1)
                } (inclination(phi($0, $1), $1.2), angle($0, $1))
            } (sunCoords($0), moonCoords($0))
        } (days(time))
    }
    
    func position(_ time: TimeInterval, _ latitude: Double, _ longitude: Double) -> (Double, Double, Double, Double) {
        {
            {
                {
                    {
                        (azimuth($2, $0, $1.1), $3 + astroRefraction($3), $1.2, atan2(sin($2), tan($0) * cos($1.1) - sin($1.1) * cos($2)))
                    } ($0, $1, $2, altitude($2, $0, $1.1))
                } ($1, $3, siderealTime($2, $0) - $3.0)
            } ($0, $1, $2, moonCoords($2))
        } (radians * -longitude, radians * latitude, days(time))
    }
    
    func days(_ time: TimeInterval) -> Double {
        (time / (60 * 60 * 24)) - 0.5 + J1970 - J2000
    }
    
    func sunCoords(_ days: Double) -> (Double, Double) {
        {
            (declination(0, $0), rightAscension(0, $0))
        } (sunEclipticLongitude(solarMeanAnomaly(days)))
    }
    
    func moonCoords(_ days: Double) -> (Double, Double, Double) {
        {
            {
               (rightAscension($1, $2), declination($1, $2), moonDistanceKm($0))
            } ($0, moonLatitude(moonMeanDistance(days)), moonLongitude(moonEclipticLongitude(days), $0))
        } (moonMeanAnomaly(days))
    }
    
    func solarMeanAnomaly(_ days: Double) -> Double {
        radians * (357.5291 + 0.98560028 * days)
    }
    
    func sunEclipticLongitude(_ anomaly: Double) -> Double {
        anomaly + equationOfCenter(anomaly) + earthPerihelion + .pi
    }
    
    func declination(_ latitude: Double, _ longitude: Double) -> Double {
        asin(sin(latitude) * cos(earthObliquity) + cos(latitude) * sin(earthObliquity) * sin(longitude))
    }
    
    func rightAscension(_ latitude: Double, _ longitude: Double) -> Double {
        atan2(sin(longitude) * cos(earthObliquity) - tan(latitude) * sin(earthObliquity), cos(longitude))
    }
    
    func siderealTime(_ days: Double, _ lw: Double) -> Double {
        radians * (280.16 + 360.9856235 * days) - lw
    }
    
    func altitude(_ h: Double, _ phi: Double, _ declination: Double) -> Double {
        asin(sin(phi) * sin(declination) + cos(phi) * cos(declination) * cos(h))
    }
    
    func azimuth(_ h: Double, _ phi: Double, _ declination: Double) -> Double {
        atan2(sin(h), cos(h) * sin(phi) - tan(declination) * cos(phi))
    }
    
    func astroRefraction(_ altitude: Double) -> Double {
        let altitude = altitude >= 0 ? altitude : 0
        return 0.0002967 / tan(altitude + 0.00312536 / (altitude + 0.08901179))
    }
    
    func phases(_ time: TimeInterval) -> (Date, Date) {
        let _days = days(time)
        let _sunCoords = sunCoords(_days)
        let _moonCoords = moonCoords(_days)
        let _inclination = inclination(phi(_sunCoords, _moonCoords), _moonCoords.2)
        let _angle = angle(_sunCoords, _moonCoords)
        let _phase = phase(_inclination, _angle)
        let _middle = 0.5 - _phase
        let _new = (1 - _phase) * cycle
        let _full = (_middle < 0 ? 1 + _middle : _middle) * cycle
        return (.init(timeIntervalSince1970: _new + time), .init(timeIntervalSince1970: _full + time))
    }
    
    private func makeInfo() {
        queue.async {
            self.info.value = self.info(self.date.timeIntervalSince1970 + self.offset, self.coords.0, self.coords.1)
        }
    }
    
    private func makeTimes() {
        queue.async {
            self.times.value = self.times(self.date, self.coords.0, self.coords.1)
        }
    }
    
    private func makePhases() {
        queue.async {
            self.phases.value = self.phases(self.date.timeIntervalSince1970)
        }
    }
    
    private func equationOfCenter(_ anomaly: Double) -> Double {
        radians * (1.9148 * sin(anomaly) + 0.02 * sin(2 * anomaly) + 0.0003 * sin(3 * anomaly))
    }
    
    private func moonEclipticLongitude(_ days: Double) -> Double {
        radians * (218.316 + 13.176396 * days)
    }
    
    private func moonMeanAnomaly(_ days: Double) -> Double {
        radians * (134.963 + 13.064993 * days)
    }
    
    private func moonMeanDistance(_ days: Double) -> Double {
        radians * (93.272 + 13.229350 * days)
    }
    
    private func moonLatitude(_ distance: Double) -> Double {
        radians * 5.128 * sin(distance)
    }
    
    private func moonLongitude(_ eclipticLongitude: Double, _ anomaly: Double) -> Double {
        eclipticLongitude + (radians * 6.289 * sin(anomaly))
    }
    
    private func moonDistanceKm(_ anomaly: Double) -> Double {
        385001 - (20905 * cos(anomaly))
    }
    
    private func fraction(_ inclination: Double) -> Double {
        (1 + cos(inclination)) / 2
    }
    
    private func angle(_ sunCoords: (Double, Double), _ moonCoords: (Double, Double, Double)) -> Double {
        atan2(cos(sunCoords.0) * sin(sunCoords.1 - moonCoords.0),
              sin(sunCoords.0) * cos(moonCoords.1) - cos(sunCoords.0) * sin(moonCoords.1) * cos(sunCoords.1 - moonCoords.0))
    }
    
    private func phi(_ sunCoords: (Double, Double), _ moonCoords: (Double, Double, Double)) -> Double {
        acos(sin(sunCoords.0) * sin(moonCoords.1) + cos(sunCoords.0) * cos(moonCoords.1) * cos(sunCoords.1 - moonCoords.0))
    }
    
    private func inclination(_ phi: Double, _ moonDistanceKm: Double) -> Double {
        atan2(sunDistanceKm * sin(phi), moonDistanceKm - sunDistanceKm * cos(phi))
    }
    
    private func phase(_ inclination: Double, _ angle: Double) -> Double {
        0.5 + ((0.5 * inclination) * (angle < 0 ? -1 : 1) / .pi)
    }
    
    private func phase(_ phase: Double) -> Phase {
        switch phase {
        case 0: return .new
        case let phase where phase < 0.25: return .waxingCrescent
        case 0.25: return .firstQuarter
        case let phase where phase > 0.25 && phase < 0.5: return .waxingGibbous
        case 0.5: return .full
        case let phase where phase > 0.5 && phase < 0.75: return .waningGibbous
        case 0.75: return .lastQuarter
        default: return .waningCrescent
        }
    }
}
