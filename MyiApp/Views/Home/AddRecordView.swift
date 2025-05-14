//
//  AddRecordView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-12.
//

import SwiftUI
import Combine

class AddRecordViewModel: ObservableObject {
    private let caregiverManager = CaregiverManager.shared
    @Published var record: Record
    @Published var showActionSheet = false
    @Published var isSaveDisabled = true
    private var cancellables: Set<AnyCancellable> = []
    
    init(record: Record) {
        self.record = record
        setupBinding()
    }
    
    func setupBinding() {
        // 버튼의 Enable & Disable 유무를 결정.
        $record
            .map { record -> Bool in
                switch record.title {
                    case .formula, .babyFood, .pumpedMilk:
                        return !(record.mlAmount != nil && record.mlAmount! > 0)
                        
                    case .breastfeeding:
                        return !((record.breastfeedingLeftMinutes != nil && record.breastfeedingLeftMinutes! > 0) ||
                                 (record.breastfeedingRightMinutes != nil && record.breastfeedingRightMinutes! > 0))
                        
                    case .sleep:
                        // 시작과 종료 시간이 모두 있으면 저장 가능
                        return !(record.sleepStart != nil && record.sleepEnd != nil)
                        
                    case .heightWeight:
                        // 키나 몸무게 중 하나라도 있으면 저장 가능
                        return !(record.height != nil || record.weight != nil)
                        
                    case .temperature:
                        // 온도가 있으면 저장 가능
                        return !(record.temperature != nil)
                        
                    case .snack, .medicine, .clinic:
                        // 내용이 있으면 저장 가능
                        return !(record.content != nil && !record.content!.isEmpty)
                        
                    case .diaper, .bath, .poop, .pee, .pottyAll:
                        // 추가 입력이 필요없는 경우 항상 저장 가능
                        return false
                }
            }
            .assign(to: \.isSaveDisabled, on: self)
            .store(in: &cancellables)
    }
    
    func saveRecord() {
        caregiverManager.saveRecord(record: record)
    }
}

struct AddRecordView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: AddRecordViewModel
    
    init(careCategory: GridItemCategory) {
        let newRecord = Record(title: careCategory.category)
        self._viewModel = StateObject(wrappedValue: AddRecordViewModel(record: newRecord))
    }
    
    var body: some View {
        VStack {
            headerView
            datePicker
            content
            buttonView
        }
        .padding(30)
    }
    
    private var headerView: some View {
        var title: String {
            switch viewModel.record.title {
                case .formula, .babyFood, .pumpedMilk, .breastfeeding: return "수유/이유식 기록"
                case .diaper: return "기저귀 기록"
                case .sleep: return "수면 기록"
                case .heightWeight: return "키/몸무게 기록"
                case .bath: return "목욕 기록"
                case .snack: return "간식 기록"
                case .temperature, .medicine, .clinic: return "건강 관리 기록"
                case .poop, .pee, .pottyAll: return "배변 기록"
            }
        }
        var titleImage: ImageResource {
            switch viewModel.record.title {
                case .formula, .babyFood, .pumpedMilk, .breastfeeding: return .colorMeal
                case .diaper: return .colorDiaper
                case .sleep: return .colorSleep
                case .heightWeight: return .colorHeightWeight
                case .bath: return .colorBath
                case .snack: return .colorSnack
                case .temperature, .medicine, .clinic: return .colorCheckList
                case .poop, .pee, .pottyAll: return .colorPotty
            }
        }
        var backgoundColor: Color {
            switch viewModel.record.title {
                case .formula, .babyFood, .pumpedMilk, .breastfeeding: return .pink
                case .diaper: return .purple
                case .sleep: return .gray
                case .heightWeight: return .green
                case .bath: return .blue
                case .snack: return .orange
                case .temperature, .medicine, .clinic: return .yellow
                case .poop, .pee, .pottyAll: return .brown
            }
        }
        
        return HStack {
            Image(titleImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48)
                .background(
                    Circle().fill(backgoundColor)
                )
            Text(title)
                .font(.system(size: 25, weight: .medium))
            Spacer()
            Button(action: {}) {
                Image(systemName: "trash")
                    .foregroundStyle(.foreground)
                    .font(.system(size: 20))
            }
            
        }
    }
    
    private var datePicker: some View {
        HStack {
            Button(action: { viewModel.showActionSheet = true }) {
                HStack {
                    Image(systemName: "calendar")
                    Text(viewModel.record.createdAt.formattedKoreanDateString() + " " + viewModel.record.createdAt.to24HourTimeString())
                    Image(systemName: "chevron.down")
                }
                .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .background(
            UIDatePickerActionSheet(isPresented: $viewModel.showActionSheet, selectedDate: $viewModel.record.createdAt)
        )
        .padding(3)
    }
    
    private var content: some View {
        VStack {
            switch viewModel.record.title {
                case .breastfeeding, .babyFood, .formula, .pumpedMilk:
                    FeedingRecordView(record: $viewModel.record)
                case .diaper:
                    DiaperRecordView()
                case .pee, .poop, .pottyAll:
                    PottyRecordView(record: $viewModel.record)
                case .sleep:
                    SleepRecordView(record: $viewModel.record)
                case .heightWeight:
                    HeightWeightRecordView(record: $viewModel.record)
                case .bath:
                    BathRecordView()
                case .snack:
                    SnackRecordView(record: $viewModel.record)
                case .temperature, .medicine, .clinic:
                    HealthRecordView(record: $viewModel.record)
            }
        }
    }
    
    private var buttonView: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Text("취소")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 32)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
            }
            Button(
                action: {
                    viewModel.saveRecord()
                    dismiss()
                }) {
                Text("저장")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 32)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.75, green: 0.85, blue: 1.0))
                    )
            }
            .disabled(viewModel.isSaveDisabled)
        }
    }
}

#Preview {
    AddRecordView(careCategory: .init(name: "수면", category: .babyFood, image: .colorBabyFood))
}
