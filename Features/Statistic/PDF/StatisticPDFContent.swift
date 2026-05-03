import DesignSystem
import Domain
import Shared
import SwiftUI

public struct StatisticPDFContent: View {
    let baby: Baby
    let records: [CareRecord]
    let date: Date

    public init(baby: Baby, records: [CareRecord], date: Date) {
        self.baby = baby
        self.records = records
        self.date = date
    }

    private var todayRecords: [CareRecord] { records.filtered(on: date) }
    private var yesterdayRecords: [CareRecord] {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
        return records.filtered(on: yesterday)
    }

    public var body: some View {
        VStack(spacing: Spacing.l) {
            header
            feedingCard
            pottyCard
            sleepCard
            bathCard
            snackCard
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity)
        .background(Color.Semantic.screenBackground)
    }

    private var header: some View {
        VStack(alignment: .center, spacing: Spacing.xs) {
            Text(date.formatted(.dateTime.year().month().day()))
                .font(.subheadline)
                .foregroundStyle(Color.Semantic.secondaryText)
            Text("\(baby.name)의 기록 분석")
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
    }

    private var feedingCard: some View {
        let count = todayRecords.count(of: .feeding)
        let prevCount = yesterdayRecords.count(of: .feeding)
        let ml = todayRecords.totalMl
        let prevMl = yesterdayRecords.totalMl
        let minutes = todayRecords.totalBreastfeedingMinutes
        let prevMinutes = yesterdayRecords.totalBreastfeedingMinutes
        return StatisticCard(
            title: "수유/이유식 기록 분석",
            image: Image(Asset.Records.Color.meal),
            tintColor: .Semantic.feeding,
            metrics: [
                StatisticMetric(currentText: "횟수 \(count)회", previousText: "어제 \(prevCount)회", current: count, previous: prevCount),
                StatisticMetric(currentText: "용량 \(ml)ml", previousText: "어제 \(prevMl)ml", current: ml, previous: prevMl),
                StatisticMetric(
                    currentText: "시간 \(DurationFormatter.hourMinute(fromMinutes: minutes))",
                    previousText: "어제 \(DurationFormatter.hourMinute(fromMinutes: prevMinutes))",
                    current: minutes,
                    previous: prevMinutes
                )
            ]
        )
    }

    private var pottyCard: some View {
        let today = todayRecords.pottyCount
        let yesterday = yesterdayRecords.pottyCount
        return StatisticCard(
            title: "배변 기록 분석",
            image: Image(Asset.Records.Color.potty),
            tintColor: .Semantic.potty,
            metrics: [
                StatisticMetric(currentText: "소변 \(today.pee)회", previousText: "어제 \(yesterday.pee)회", current: today.pee, previous: yesterday.pee),
                StatisticMetric(currentText: "대변 \(today.poop)회", previousText: "어제 \(yesterday.poop)회", current: today.poop, previous: yesterday.poop)
            ]
        )
    }

    private var sleepCard: some View {
        let count = todayRecords.count(of: .sleep)
        let prevCount = yesterdayRecords.count(of: .sleep)
        let minutes = records.totalSleepMinutes(on: date)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
        let prevMinutes = records.totalSleepMinutes(on: yesterday)
        return StatisticCard(
            title: "수면 기록 분석",
            image: Image(Asset.Records.Color.sleep),
            tintColor: .Semantic.sleep,
            metrics: [
                StatisticMetric(currentText: "횟수 \(count)회", previousText: "어제 \(prevCount)회", current: count, previous: prevCount),
                StatisticMetric(
                    currentText: "시간 \(DurationFormatter.hourMinute(fromMinutes: minutes))",
                    previousText: "어제 \(DurationFormatter.hourMinute(fromMinutes: prevMinutes))",
                    current: minutes,
                    previous: prevMinutes
                )
            ]
        )
    }

    private var bathCard: some View {
        let count = todayRecords.count(of: .bath)
        let prevCount = yesterdayRecords.count(of: .bath)
        return StatisticCard(
            title: "목욕 기록 분석",
            image: Image(Asset.Records.Color.bath),
            tintColor: .Semantic.bath,
            metrics: [
                StatisticMetric(currentText: "횟수 \(count)회", previousText: "어제 \(prevCount)회", current: count, previous: prevCount)
            ]
        )
    }

    private var snackCard: some View {
        let count = todayRecords.count(of: .snack)
        let prevCount = yesterdayRecords.count(of: .snack)
        return StatisticCard(
            title: "간식 기록 분석",
            image: Image(Asset.Records.Color.snack),
            tintColor: .Semantic.snack,
            metrics: [
                StatisticMetric(currentText: "횟수 \(count)회", previousText: "어제 \(prevCount)회", current: count, previous: prevCount)
            ]
        )
    }
}

#if DEBUG
    #Preview {
        ScrollView {
            StatisticPDFContent(
                baby: Baby(
                    name: "꼬미",
                    birthDate: Calendar.current.date(byAdding: .day, value: -100, to: Date()) ?? Date(),
                    gender: .female,
                    bloodType: .a,
                    mainCaregiverID: "preview"
                ),
                records: CareRecord.mocks,
                date: Date()
            )
        }
    }
#endif
