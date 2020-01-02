import Foundation
import Combine

public final class Moonraker {
    public let illumination = CurrentValueSubject<(Phase, Double, Double), Never>((.new, 0, 0))
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
            guard let self = self else { return }
            self.illumination.send(self.illumination(date.timeIntervalSince1970))
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
    
    func position(_ time: TimeInterval, _ latitude: Double, _ longitude: Double) -> (Double, Double, Double, Double) {
        let lw = radians * -longitude
        let phi = radians * latitude
        let _days = days(time)
        let coords = moonCoords(_days)
        let h = siderealTime(_days, lw) - coords.0
        let _altitude = altitude(h, phi, coords.1)
        let parallacticeAngle = atan2(sin(h), tan(phi) * cos(coords.1) - sin(coords.1) * cos(h))
        let corrected = _altitude + astroRefraction(_altitude)
        let _azimuth = azimuth(h, phi, coords.1)
        return (_azimuth, corrected, coords.2, parallacticeAngle)
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
