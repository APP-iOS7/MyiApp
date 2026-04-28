import DesignSystem
import Domain
import SwiftUI

struct DailyChartView: View {
    let baby: Baby
    let records: [CareRecord]
    let selectedDate: Date
    let selectedCategories: Set<CareEvent.Category>

    private var timedRecords: [TimedRecord] { records.compactMap(timedRecord(for:)) }

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let diameter = size.width * DailyChartLayout.ringDiameterRatio
            let lineWidth = diameter * DailyChartLayout.ringThicknessRatio
            let ringRect = CGRect(
                x: center.x - diameter / 2,
                y: center.y - diameter / 2,
                width: diameter,
                height: diameter
            )

            // 배경 링
            context.stroke(
                Circle().path(in: ringRect),
                with: .color(.gray.opacity(DailyChartLayout.backgroundRingOpacity)),
                lineWidth: lineWidth
            )

            // 이벤트 호
            for record in timedRecords {
                context.stroke(
                    arcPath(in: ringRect, startHour: record.startHour, endHour: record.endHour),
                    with: .color(record.color),
                    lineWidth: lineWidth
                )
            }

            // 시간 표기 (짝수만 숫자, 홀수는 점)
            let markerRadius = diameter / 2 + lineWidth / 2 + DailyChartLayout.markerOuterPadding
            for hour in 0 ..< 24 {
                let angle = Angle(degrees: Double(hour) / 24 * 360 - 90)
                let position = CGPoint(
                    x: center.x + cos(angle.radians) * markerRadius,
                    y: center.y + sin(angle.radians) * markerRadius
                )
                context.draw(
                    Text(hour % 2 == 0 ? "\(hour)" : "·")
                        .font(.caption2)
                        .foregroundColor(.Semantic.secondaryText),
                    at: position
                )
            }

            // 가운데 나이 라벨
            context.draw(
                Text(baby.ageText(at: selectedDate))
                    .font(.headline)
                    .foregroundColor(.Semantic.secondaryText),
                at: center
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func timedRecord(for record: CareRecord) -> TimedRecord? {
        let category = record.event.category
        guard category.hasChartFootprint, selectedCategories.contains(category) else { return nil }
        guard let span = chartSpan(for: record) else { return nil }

        return TimedRecord(
            id: record.id,
            startHour: span.start,
            endHour: span.end,
            color: category.tintColor
        )
    }

    private func chartSpan(for record: CareRecord) -> (start: Double, end: Double)? {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: selectedDate)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return nil }

        if case let .sleep(start, end) = record.event, let end {
            let overlapStart = max(start, dayStart)
            let overlapEnd = min(end, dayEnd)
            guard overlapStart < overlapEnd else { return nil }

            return (overlapStart.hourDecimal, overlapEnd.hourDecimal)
        }

        guard calendar.isDate(record.createdAt, inSameDayAs: selectedDate) else { return nil }

        let arcEnd = calendar.date(
            byAdding: .minute,
            value: DailyChartLayout.pointEventDurationMinutes,
            to: record.createdAt
        ) ?? record.createdAt
        return (record.createdAt.hourDecimal, arcEnd.hourDecimal)
    }

    private func arcPath(in rect: CGRect, startHour: Double, endHour: Double) -> Path {
        let correctedEnd = endHour >= startHour ? endHour : endHour + 24
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: Angle(degrees: (startHour / 24) * 360 - 90),
            endAngle: Angle(degrees: (correctedEnd / 24) * 360 - 90),
            clockwise: false
        )
        return path
    }
}

private struct TimedRecord: Identifiable {
    let id: UUID
    let startHour: Double
    let endHour: Double
    let color: Color
}

#if DEBUG
    private func chartPreview(
        records: [CareRecord] = CareRecord.mocks,
        categories: Set<CareEvent.Category> = Set(CareEvent.Category.allCases)
    )
        -> some View
    {
        DailyChartView(
            baby: Baby(
                name: "꼬미",
                birthDate: Calendar.current.date(byAdding: .day, value: -100, to: Date())!,
                gender: .female,
                bloodType: .a,
                mainCaregiverID: "user-123"
            ),
            records: records,
            selectedDate: Date(),
            selectedCategories: categories
        )
        .padding()
    }

    #Preview("기록 있음") { chartPreview() }
    #Preview("기록 없음") { chartPreview(records: []) }
    #Preview("필터 일부") { chartPreview(categories: [.feeding, .sleep]) }
#endif
