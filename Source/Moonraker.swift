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
//        let _days = days(time)
        return (.new, 0, 0)
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
}

/*
 
 var dayMs = 1000 * 60 * 60 * 24,
     J1970 = 2440588,
     J2000 = 2451545;

 function toJulian(date) { return date.valueOf() / dayMs - 0.5 + J1970; }
 function fromJulian(j)  { return new Date((j + 0.5 - J1970) * dayMs); }
 function toDays(date)   { return toJulian(date) - J2000; }
 
 SunCalc.getMoonIllumination = function (date) {

     var d = toDays(date || new Date()),
         s = sunCoords(d),
         m = moonCoords(d),

         sdist = 149598000, // distance from Earth to Sun in km

         phi = acos(sin(s.dec) * sin(m.dec) + cos(s.dec) * cos(m.dec) * cos(s.ra - m.ra)),
         inc = atan(sdist * sin(phi), m.dist - sdist * cos(phi)),
         angle = atan(cos(s.dec) * sin(s.ra - m.ra), sin(s.dec) * cos(m.dec) -
                 cos(s.dec) * sin(m.dec) * cos(s.ra - m.ra));

     return {
         fraction: (1 + cos(inc)) / 2,
         phase: 0.5 + 0.5 * inc * (angle < 0 ? -1 : 1) / Math.PI,
         angle: angle
     };
 };
 
 */
