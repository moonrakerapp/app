import Foundation
import Combine

public final class Moonraker {
    public let phase = CurrentValueSubject<Phase, Never>(.new)
    public let fraction = CurrentValueSubject<Double, Never>(0)
    public let angle = CurrentValueSubject<Double, Never>(0)
    private let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    private let J1970 = Double(2440588)
    private let J2000 = Double(2451545)
    private let radians = Double.pi / 180
    private let earthPerihelion = Double.pi / 180 * 102.9372
    private let earthObliquity = Double.pi / 180 * 23.4397
    private let sunDistanceKm = Double(149598000)
    
    public init() {
        
    }
    
    public func update(_ date: Date) {
        queue.async { [weak self] in
            guard let illumination = self?.illumination(date.timeIntervalSince1970) else { return }
            self?.phase.send(illumination.0)
            self?.fraction.send(illumination.1)
            self?.angle.send(illumination.2)
        }
    }
    
    func illumination(_ time: TimeInterval) -> (Phase, Double, Double) {
        {
            {
                {
                    (phase($0, $1), fraction($0), $1)
                } (inclination(phi($0, $1), $1.2), angle($0, $1))
            } (sunCoords($0), moonCoords($0))
        } (days(time))
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
    
    private func phase(_ inclination: Double, _ angle: Double) -> Phase {
        switch 0.5 + ((0.5 * inclination) * (angle < 0 ? -1 : 1) / .pi) {
        case 0: return .new
        case let phase where phase < 0.25: return .waxingCrescent
        case 0.25: return .firstQuarter
        case let phase where phase > 0.25 && phase < 0.5: return .waxingGibbous
        case 0.5: return .full
        case let phase where phase > 5 && phase < 0.75: return .waningGibbous
        case 0.75: return .lastQuarter
        default: return .waningCrescent
        }
    }
}
