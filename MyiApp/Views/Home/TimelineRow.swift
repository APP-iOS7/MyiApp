//
//  TimelineRow.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-12.
//

import SwiftUI
import FirebaseFirestore

struct TimelineRow: View {
    let record: Record
    let index: Int
    let totalCount: Int
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    @State private var showingDeleteAlert = false
    @GestureState private var isDragging = false
    private let deleteWidth: CGFloat = -70
    
    var showTopLine: Bool {
        if totalCount == 1 { return false }
        return index != 0
    }
    
    var showBottomLine: Bool {
        if totalCount == 1 { return false }
        return index != totalCount - 1
    }
    
    private var iconName: UIImage {
        switch record.title {
            case .formula: return .normalPowderedMilk
            case .babyFood: return .normalBabyMeal
            case .pumpedMilk: return .normalPumpedMilk
            case .breastfeeding: return .normalBreastFeeding
            case .diaper: return .colorDiaper
            case .sleep: return .colorSleep
            case .heightWeight: return .colorHeightWeight
            case .bath: return .colorBath
            case .snack: return .colorSnack
            case .temperature: return .normalTemperature
            case .medicine: return .normalMedicine
            case .clinic: return .normalClinic
            case .poop: return .normalPoop
            case .pee: return .normalPee
            case .pottyAll: return .normalPotty
        }
    }
    private var title: String {
        switch record.title {
            case .formula:
                "분유"
            case .babyFood:
                "이유식"
            case .pumpedMilk:
                "유축수유"
            case .breastfeeding:
                "모유수유"
            case .diaper:
                "기저귀 교체"
            case .sleep:
                "수면"
            case .heightWeight:
                "키/몸무게"
            case .bath:
                "목욕"
            case .snack:
                "간식"
            case .temperature:
                "체온"
            case .medicine:
                "투약"
            case .clinic:
                "병운"
            case .poop:
                "대변"
            case .pee:
                "소변"
            case .pottyAll:
                "대소변"
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
                } else if let start = record.sleepStart {
                    return "\(start.to24HourTimeString()) - (종료 시간 없음)"
                } else if let end = record.sleepEnd {
                    return "(시작 시간 없음) - \(end.to24HourTimeString())"
                } else {
                    return "시간 미기록"
                }
            case .heightWeight:
                if let height = record.height, let weight = record.weight {
                    return "키 \(String(format: "%.1f", height))cm, 몸무게 \(String(format: "%.1f", weight))kg"
                } else if let height = record.height {
                    return "키 \(String(format: "%.1f", height))cm"
                } else if let weight = record.weight {
                    return "몸무게 \(String(format: "%.1f", weight))kg"
                } else {
                    return "미기록"
                }
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
    
    private var circleColor: Color {
        switch record.title {
            case .formula, .babyFood, .pumpedMilk, .breastfeeding: return .food
            case .diaper: return .diaper
            case .sleep: return .sleep
            case .heightWeight: return .heightWeight
            case .bath: return .bath
            case .snack: return .snack
            case .temperature, .medicine, .clinic: return .health
            case .pottyAll, .poop, .pee: return .potty
        }
    }
    
    var body: some View {
        ZStack {
            // 삭제 버튼 배경
            HStack(spacing: 0) {
                Spacer()
                
                Button {
                    showingDeleteAlert = true
                } label: {
                    VStack {
                        Image(systemName: "trash")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .frame(width: 50, height: 50)
                    .background(Color.red.opacity(0.7))
                }
                .cornerRadius(20)
            }
            .opacity(offset < -10 ? 1 : 0)
            
            // 기존 타임라인 로우 내용
            HStack(alignment: .center, spacing: 12) {
                Text(record.createdAt.to24HourTimeString())
                    .font(.system(size: 16))
                    .frame(width: 50, alignment: .leading)
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(showTopLine ? Color.gray.opacity(0.4) : Color(uiColor: .tertiarySystemBackground))
                        .frame(width: 2, height: 25)
                    Circle()
                        .fill(circleColor)
                        .frame(width: 10, height: 10)
                    Rectangle()
                        .fill(showBottomLine ? Color.gray.opacity(0.4) : Color(uiColor: .tertiarySystemBackground))
                        .frame(width: 2, height: 25)
                }
                HStack(spacing: 8) {
                    Image(uiImage: iconName)
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
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(10)
            .contentShape(Rectangle())
            .offset(x: offset)
            .gesture(
                DragGesture(minimumDistance: 15, coordinateSpace: .local)
                    .updating($isDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = max(value.translation.width, deleteWidth)
                        }
                    }
                    .onEnded { value in
                        if value.translation.width < deleteWidth/2 {
                            withAnimation(.easeOut(duration: 0.2)) {
                                offset = deleteWidth
                                isSwiped = true
                            }
                        } else {
                            withAnimation(.easeOut(duration: 0.2)) {
                                offset = 0
                                isSwiped = false
                            }
                        }
                    }
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        if isSwiped {
                            withAnimation(.spring()) {
                                offset = 0
                                isSwiped = false
                            }
                        }
                    }
            )
        }
        .alert("삭제 확인", isPresented: $showingDeleteAlert) {
            Button("취소", role: .cancel) {
                withAnimation(.spring()) {
                    offset = 0
                    isSwiped = false
                }
            }
            Button("삭제", role: .destructive) {
                deleteRecord()
                offset = 0
                isSwiped = false
            }
        } message: {
            Text("이 기록을 삭제하시겠습니까?")
        }
        .padding(.horizontal)
        .onAppear {
            offset = 0
            isSwiped = false
        }
        .onDisappear {
            offset = 0
            isSwiped = false
        }
    }
    
    private func deleteRecord() {
        let babyId = CaregiverManager.shared.selectedBaby?.id.uuidString ?? ""
        let _ = Firestore.firestore().collection("babies").document(babyId).collection("records").document(record.id.uuidString).delete { error in
            print(error ?? "")
        }
    }
}

#Preview {
    //    TimelineRow(record: Record.mockRecords[0])
}
