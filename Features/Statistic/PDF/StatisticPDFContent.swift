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
            feedingSection
            pottySection
            sleepSection
            bathSection
            snackSection
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

    // MARK: - Feeding

    private var feedingSection: some View {
        VStack(spacing: Spacing.m) {
            feedingCard
            feedingTrends
        }
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

    private var feedingTrends: some View {
        SectionCard(spacing: Spacing.m) {
            ForEach(FoodDetailFeature.FeedingType.allCases, id: \.self) { type in
                trendBlock(label: type.rawValue, unit: type.unit, tintColor: .Semantic.feeding) { range in
                    type.amount(in: records.filtered(in: range))
                }
            }
        }
    }

    // MARK: - Potty

    private var pottySection: some View {
        VStack(spacing: Spacing.m) {
            pottyCard
            SectionCard(spacing: Spacing.m) {
                trendBlock(label: "소변", unit: "회", tintColor: .Semantic.potty) { range in
                    records.filtered(in: range).pottyCount.pee
                }
                trendBlock(label: "대변", unit: "회", tintColor: .Semantic.potty) { range in
                    records.filtered(in: range).pottyCount.poop
                }
            }
        }
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

    // MARK: - Sleep

    private var sleepSection: some View {
        VStack(spacing: Spacing.m) {
            sleepCard
            SectionCard(spacing: Spacing.m) {
                trendBlock(label: "횟수", unit: "회", tintColor: .Semantic.sleep) { range in
                    records.filtered(in: range).count(of: .sleep)
                }
                trendBlock(label: "시간", unit: "분", tintColor: .Semantic.sleep) { range in
                    records.totalSleepMinutes(in: range)
                }
            }
        }
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

    // MARK: - Bath

    private var bathSection: some View {
        VStack(spacing: Spacing.m) {
            bathCard
            SectionCard(spacing: Spacing.m) {
                trendBlock(label: "횟수", unit: "회", tintColor: .Semantic.bath) { range in
                    records.filtered(in: range).count(of: .bath)
                }
            }
        }
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

    // MARK: - Snack

    private var snackSection: some View {
        VStack(spacing: Spacing.m) {
            snackCard
            SectionCard(spacing: Spacing.m) {
                trendBlock(label: "횟수", unit: "회", tintColor: .Semantic.snack) { range in
                    records.filtered(in: range).count(of: .snack)
                }
            }
        }
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

    // MARK: - Trend helpers

    @ViewBuilder
    private func trendBlock(
        label: String,
        unit: String,
        tintColor: Color,
        value: (Range<Date>) -> Int
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.Semantic.secondaryText)
            TrendBarChart(
                entries: trendEntries(value: value),
                unit: unit,
                tintColor: tintColor
            )
        }
    }

    private func trendEntries(value: (Range<Date>) -> Int) -> [TrendBarChart.Entry] {
        DetailMode.daily.trailingPeriodStarts(from: date, count: 7).map { start in
            let range = DetailMode.daily.currentRange(of: start)
            return TrendBarChart.Entry(
                id: start,
                label: DetailMode.daily.axisLabel(for: start),
                value: Double(value(range))
            )
        }
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
