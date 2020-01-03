import Foundation

public enum Times {
    case
    up,
    down,
    rise(time: Date),
    set(time: Date),
    both(rise: Date, set: Date)
}
