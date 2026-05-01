import Foundation

public enum DurationFormatter {
    /// 분(Int)을 "N시간 M분" / "M분" 한국어 라벨로 포맷.
    public static func hourMinute(fromMinutes totalMinutes: Int) -> String {
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return hours > 0 ? "\(hours)시간 \(minutes)분" : "\(minutes)분"
    }
}
