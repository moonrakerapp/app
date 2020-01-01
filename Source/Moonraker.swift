import Foundation
import Combine

public final class Moonraker {
    public let visible = CurrentValueSubject<Double, Never>(0)
    private let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    
    public init() {
        
    }
    
    public func update(_ date: Date) {
        queue.async { [weak self] in
            self?.visible.send(self?.visible(date.timeIntervalSince1970) ?? 0)
        }
    }
    
    func visible(_ timestamp: TimeInterval) -> Double {
        return 0
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
