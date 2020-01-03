import Foundation

public enum Clock {
    case
    up,
    down,
    rise(time: Date),
    set(time: Date),
    both(rise: Date, set: Date)
}
