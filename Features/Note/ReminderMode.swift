import ComposableArchitecture
import Domain
import Foundation

public enum ReminderMode: Equatable, Sendable {
    case none
    case minutesBefore(Int)
    case custom(Date)

    public static let presets: [(label: String, mode: ReminderMode)] = [
        ("없음", .none),
        ("정시", .minutesBefore(0)),
        ("10분 전", .minutesBefore(10)),
        ("1시간 전", .minutesBefore(60)),
        ("1일 전", .minutesBefore(1440)),
        ("1주일 전", .minutesBefore(10080)),
    ]
}
