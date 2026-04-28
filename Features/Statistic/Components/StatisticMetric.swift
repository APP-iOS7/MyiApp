import DesignSystem
import Domain
import SwiftUI

struct StatisticMetric: Identifiable {
    let id = UUID()
    let currentText: String
    let previousText: String
    let current: Int
    let previous: Int

    var currentRatio: CGFloat {
        let base = max(CGFloat(current), CGFloat(previous), 1)
        return CGFloat(current) / base
    }

    var previousRatio: CGFloat {
        let base = max(CGFloat(current), CGFloat(previous), 1)
        return CGFloat(previous) / base
    }
}
