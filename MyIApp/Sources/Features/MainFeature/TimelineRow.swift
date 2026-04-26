import SwiftUI

public struct TimelineRow: View {
    public let record: Record
    public let index: Int
    public let totalCount: Int

    public init(record: Record, index: Int, totalCount: Int) {
        self.record = record
        self.index = index
        self.totalCount = totalCount
    }

    private var showTopLine: Bool {
        if totalCount == 1 {
            return false
        }
        return index != 0
    }

    private var showBottomLine: Bool {
        if totalCount == 1 {
            return false
        }
        return index != totalCount - 1
    }

    private var icon: UIImage {
        switch record.title {
        case .formula: MyiAppAsset.ActivityIcons.icActivityNormalPowderedMilk.image
        case .babyFood: MyiAppAsset.ActivityIcons.icActivityNormalBabyMeal.image
        case .pumpedMilk: MyiAppAsset.ActivityIcons.icActivityNormalPumpedMilk.image
        case .breastfeeding: MyiAppAsset.ActivityIcons.icActivityNormalBreastFeeding.image
        case .diaper: MyiAppAsset.ActivityIcons.icActivityColorDiaper.image
        case .sleep: MyiAppAsset.ActivityIcons.icActivityColorSleep.image
        case .heightWeight: MyiAppAsset.ActivityIcons.icActivityColorHeightWeight.image
        case .bath: MyiAppAsset.ActivityIcons.icActivityColorBath.image
        case .snack: MyiAppAsset.ActivityIcons.icActivityColorSnack.image
        case .temperature: MyiAppAsset.ActivityIcons.icActivityNormalTemperature.image
        case .medicine: MyiAppAsset.ActivityIcons.icActivityNormalMedicine.image
        case .clinic: MyiAppAsset.ActivityIcons.icActivityColorChecklist.image
        case .poop: MyiAppAsset.ActivityIcons.icActivityNormalPoop.image
        case .pee: MyiAppAsset.ActivityIcons.icActivityNormalPee.image
        case .pottyAll: MyiAppAsset.ActivityIcons.icActivityNormalPotty.image
        }
    }

    private var title: String {
        switch record.title {
        case .formula: "분유"
        case .babyFood: "이유식"
        case .pumpedMilk: "유축수유"
        case .breastfeeding: "모유수유"
        case .diaper: "기저귀 교체"
        case .sleep: "수면"
        case .heightWeight: "키/몸무게"
        case .bath: "목욕"
        case .snack: "간식"
        case .temperature: "체온"
        case .medicine: "투약"
        case .clinic: "메모"
        case .poop: "대변"
        case .pee: "소변"
        case .pottyAll: "대소변"
        }
    }

    private var subtitle: String {
        switch record.title {
        case .formula, .pumpedMilk, .babyFood:
            return "\(record.mlAmount ?? 0)ml"

        case .breastfeeding:
            let left = record.breastfeedingLeftMinutes ?? 0
            let right = record.breastfeedingRightMinutes ?? 0
            return "왼쪽 \(left)분, 오른쪽 \(right)분"

        case .sleep:
            if let start = record.sleepStart, let end = record.sleepEnd {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd"
                let startDateStr = dateFormatter.string(from: start)
                let endDateStr = dateFormatter.string(from: end)
                let startTimeStr = start.to24HourTimeString()
                let endTimeStr = end.to24HourTimeString()
                return startDateStr == endDateStr ? "\(startDateStr) \(startTimeStr) - \(endTimeStr)" : "\(startDateStr) \(startTimeStr) - \(endDateStr) \(endTimeStr)"
            } else if let start = record.sleepStart {
                return "\(start.to24HourTimeString()) - (종료 기록 없음)"
            } else {
                return "기록 없음"
            }

        case .heightWeight:
            if let height = record.height, let weight = record.weight {
                return "키 \(String(format: "%.1f", height))cm, 몸무게 \(String(format: "%.1f", weight))kg"
            } else {
                return "미기록"
            }

        case .temperature:
            return record.temperature != nil ? "\(String(format: "%.1f", record.temperature!))°C" : "미기록"

        default:
            return record.content ?? "기록 완료"
        }
    }

    private var circleColor: Color {
        switch record.title {
        case .formula, .babyFood, .pumpedMilk, .breastfeeding: .food
        case .diaper, .clinic: .diaper
        case .sleep: .sleep
        case .heightWeight: .heightWeight
        case .bath: .bath
        case .snack: .snack
        case .temperature, .medicine: .health
        case .pottyAll, .poop, .pee: .potty
        }
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(record.createdAt.to24HourTimeString())
                .font(.subheadline)
                .frame(width: 50, alignment: .leading)

            VStack(spacing: 0) {
                Rectangle()
                    .fill(showTopLine ? Color.gray.opacity(0.4) : Color.clear)
                    .frame(width: 2, height: 25)
                Circle()
                    .fill(circleColor)
                    .frame(width: 10, height: 10)
                Rectangle()
                    .fill(showBottomLine ? Color.gray.opacity(0.4) : Color.clear)
                    .frame(width: 2, height: 25)
            }

            HStack(spacing: 8) {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .background(Color(UIColor.tertiarySystemBackground))
        .contentShape(Rectangle())
    }
}
