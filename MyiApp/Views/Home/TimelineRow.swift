//
//  TimelineRow.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-12.
//

import SwiftUI

struct TimelineRow: View {
    let record: Record
    
    private var iconName: UIImage {
        switch record.title {
            case .formula: return .normalPowderedMilk
            case .babyFood: return .normalBabyMeal
            case .pumpedMilk: return .normalPumpedMilk
            case .breastfeeding: return .normalBreastFeeding
            case .diaper: return .normalDiaper
            case .sleep: return .normalSleep
            case .heightWeight: return .normalHeightWeight
            case .bath: return .normalBath
            case .snack: return .normalSnack
            case .temperature: return .normalTemperature
            case .medicine: return .normalMedicine
            case .clinic: return .normalClinic
            case .poop: return .normalPoop
            case .pee: return .normalPee
            case .pottyAll: return .normalPotty
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
                return "\(start.to24HourTimeString()) - \(end.to24HourTimeString())"
            }
            return "시간 미기록"
        case .heightWeight:
            if let height = record.height, let weight = record.weight {
                return "키 \(String(format: "%.1f", height))cm, 몸무게 \(String(format: "%.1f", weight))kg"
            }
            return "미기록"
        case .temperature:
            if let temp = record.temperature {
                return "\(String(format: "%.1f", temp))°C"
            }
            return "미기록"
        case .medicine, .clinic, .snack:
            return record.content ?? "메모 없음"
        case .poop, .pee, .pottyAll, .diaper, .bath:
            return record.content ?? "기록 완료"
        }
    }
    
//    private var circleColor: Color {
//        switch record.title {
//            case .formula:
//                <#code#>
//            case .babyFood:
//                <#code#>
//            case .pumpedMilk:
//                <#code#>
//            case .breastfeeding:
//                <#code#>
//            case .diaper:
//                <#code#>
//            case .sleep:
//                <#code#>
//            case .heightWeight:
//                <#code#>
//            case .bath:
//                <#code#>
//            case .snack:
//                <#code#>
//            case .temperature:
//                <#code#>
//            case .medicine:
//                <#code#>
//            case .clinic:
//                <#code#>
//            case .poop:
//                <#code#>
//            case .pee:
//                <#code#>
//            case .pottyAll:
//                <#code#>
//        }
//    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(record.createdAt.to24HourTimeString())
                .font(.system(size: 16))
                .frame(width: 50, alignment: .leading)
            
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 1, height: 20)
                Circle()
                    .fill(Color.pink)
                    .frame(width: 10, height: 10)
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 1, height: 20)
            }

            HStack(spacing: 8) {
                Image(uiImage: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(record.title.rawValue)
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
        .padding(.horizontal, 5)
    }
}


#Preview {
    TimelineRow(record: Record.mockRecords[0])
}
