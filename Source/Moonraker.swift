import Foundation
import Combine

public final class Moonraker {
    public let visible = CurrentValueSubject<Double, Never>(0)
    private let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    private let J1970 = Double(2440588)
    private let J2000 = Double(2451545)
    private let radians = Double.pi / 180
    private let earthPerihelion = Double.pi / 180 * 102.9372
    private let earthObliquity = Double.pi / 180 * 23.4397
    
    public init() {
        
    }
    
    public func update(_ date: Date) {
        queue.async { [weak self] in
            self?.visible.send(self?.visible(date.timeIntervalSince1970) ?? 0)
        }
    }
    
    func visible(_ time: TimeInterval) -> Double {
        let _days = days(time)
        return 0
    }
    
    func days(_ time: TimeInterval) -> Double {
        (time / (60 * 60 * 24)) - 0.5 + J1970 - J2000
    }
    
    func sunCoords(_ days: Double) -> (Double, Double) {
        {
            (declination(0, $0), rightAscension(0, $0))
        } (eclipticLongitude(solarMeanAnomaly(days)))
    }
    
    func solarMeanAnomaly(_ days: Double) -> Double {
        radians * (357.5291 + 0.98560028 * days)
    }
    
    func eclipticLongitude(_ anomaly: Double) -> Double {
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
