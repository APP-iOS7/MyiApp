import DesignSystem
import Domain
import Shared
import SwiftUI

struct WeeklyChartView: View {
    let baby: Baby
    let records: [CareRecord]
    let selectedDate: Date
    let selectedCategories: Set<CareEvent.Category>

    private var weekDates: [Date] {
        guard let start = Calendar.current.dateInterval(of: .weekOfYear, for: selectedDate)?.start else { return [] }
        return (0 ..< 7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: start) }
    }

    private var weeklyTimedRecords: [WeeklyTimedRecord] {
        records.flatMap(weeklyTimedRecord(for:))
    }

    var body: some View {
        Canvas { context, size in
            let dayWidth = size.width / 8
            let hourHeight = size.height / 25
            drawGrid(in: &context, dayWidth: dayWidth, hourHeight: hourHeight, canvasSize: size)
            drawTimeLabels(in: &context, hourHeight: hourHeight)
            drawDateLabels(in: &context, dayWidth: dayWidth, hourHeight: hourHeight, canvasHeight: size.height)
            drawEventBars(in: &context, dayWidth: dayWidth, hourHeight: hourHeight)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func drawGrid(in context: inout GraphicsContext, dayWidth: CGFloat, hourHeight: CGFloat, canvasSize: CGSize) {
        var path = Path()
        for column in 1 ... 7 {
            let x = CGFloat(column) * dayWidth
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: canvasSize.height - hourHeight))
        }
        for row in 0 ... 24 {
            let y = CGFloat(row) * hourHeight
            path.move(to: CGPoint(x: dayWidth, y: y))
            path.addLine(to: CGPoint(x: canvasSize.width, y: y))
        }
        context.stroke(
            path,
            with: .color(.gray.opacity(Opacity.guide)),
            lineWidth: WeeklyChartLayout.gridLineWidth
        )
    }

    private func drawTimeLabels(in context: inout GraphicsContext, hourHeight: CGFloat) {
        for hour in 0 ... 24 where hour % WeeklyChartLayout.hourLabelInterval == 0 {
            context.draw(
                Text("\(hour)")
                    .font(.caption2)
                    .foregroundColor(.Semantic.secondaryText),
                at: CGPoint(x: WeeklyChartLayout.timeLabelLeading, y: CGFloat(hour) * hourHeight)
            )
        }
    }

    private func drawDateLabels(in context: inout GraphicsContext, dayWidth: CGFloat, hourHeight: CGFloat, canvasHeight: CGFloat) {
        for (index, date) in weekDates.enumerated() {
            let day = Calendar.current.component(.day, from: date)
            let columnCenter = CGFloat(index + 1) * dayWidth + dayWidth / 2
            let bottomRow = canvasHeight - hourHeight / 2
            context.draw(
                Text("\(day)일")
                    .font(.caption2)
                    .foregroundColor(.Semantic.secondaryText),
                at: CGPoint(x: columnCenter, y: bottomRow)
            )
        }
    }

    private func drawEventBars(in context: inout GraphicsContext, dayWidth: CGFloat, hourHeight: CGFloat) {
        let barWidth = dayWidth * WeeklyChartLayout.barWidthRatio
        for record in weeklyTimedRecords {
            let columnX = CGFloat(record.dayIndex + 1) * dayWidth
            let barX = columnX + (dayWidth - barWidth) / 2
            let barY = CGFloat(record.startHour) * hourHeight
            let barHeight = max(CGFloat(record.endHour - record.startHour) * hourHeight, 0.5)
            let rect = CGRect(x: barX, y: barY, width: barWidth, height: barHeight)
            context.fill(Path(rect), with: .color(record.color))
        }
    }

    private func weeklyTimedRecord(for record: CareRecord) -> [WeeklyTimedRecord] {
        let category = record.event.category
        guard category.hasChartFootprint, selectedCategories.contains(category) else { return [] }

        if case let .sleep(start, end) = record.event, let end {
            return sleepTimedRecords(start: start, end: end, color: category.tintColor)
        }

        return pointTimedRecord(for: record, color: category.tintColor)
    }

    private func sleepTimedRecords(start: Date, end: Date, color: Color) -> [WeeklyTimedRecord] {
        let calendar = Calendar.current
        return weekDates.enumerated().compactMap { index, day -> WeeklyTimedRecord? in
            let dayStart = calendar.startOfDay(for: day)
            guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return nil }

            let overlapStart = max(start, dayStart)
            let overlapEnd = min(end, dayEnd)
            guard overlapStart < overlapEnd else { return nil }

            let endHour = calendar.isDate(overlapEnd, equalTo: dayEnd, toGranularity: .minute) ? 24.0 : overlapEnd.hourDecimal

            return WeeklyTimedRecord(
                id: UUID(),
                dayIndex: index,
                startHour: overlapStart.hourDecimal,
                endHour: endHour,
                color: color
            )
        }
    }

    private func pointTimedRecord(for record: CareRecord, color: Color) -> [WeeklyTimedRecord] {
        let calendar = Calendar.current
        guard let dayIndex = weekDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: record.createdAt) })
        else { return [] }

        let pointEventEnd = calendar.date(
            byAdding: .minute,
            value: WeeklyChartLayout.pointEventDurationMinutes,
            to: record.createdAt
        ) ?? record.createdAt

        return [WeeklyTimedRecord(
            id: record.id,
            dayIndex: dayIndex,
            startHour: record.createdAt.hourDecimal,
            endHour: pointEventEnd.hourDecimal,
            color: color
        )]
    }
}

private struct WeeklyTimedRecord: Identifiable {
    let id: UUID
    let dayIndex: Int
    let startHour: Double
    let endHour: Double
    let color: Color
}

#if DEBUG
    private func weeklyChartPreview(
        records: [CareRecord] = CareRecord.mocks,
        categories: Set<CareEvent.Category> = Set(CareEvent.Category.allCases)
    ) -> some View {
        WeeklyChartView(
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

    #Preview("기록 있음") { weeklyChartPreview() }
    #Preview("기록 없음") { weeklyChartPreview(records: []) }
    #Preview("필터 일부") { weeklyChartPreview(categories: [.feeding, .sleep]) }
#endif
