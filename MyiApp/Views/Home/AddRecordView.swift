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
            .assign(to: &$isSaveDisabled)
    }
    
    func saveRecord() {
//        caregiverManager.saveRecord(record: record)
    }
    
    func removeRecord() {
//        caregiverManager.deleteRecord(record: record)
    }
}

struct AddRecordView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: AddRecordViewModel
    
    @State private var selectedCategory = "분유"
    @State private var amount = "50ml"
    @State private var date = Date()
    
    init(record: Record) {
        self._viewModel = StateObject(wrappedValue: AddRecordViewModel(record: record))
    }
    
    var body: some View {
        NavigationView {
                    Form {
                        Section(header: Text("카테고리")) {
                            Picker("카테고리", selection: $selectedCategory) {
                                Text("모유 수유").tag("모유 수유")
                                Text("유축 수유").tag("유축 수유")
                                Text("분유").tag("분유")
                                Text("이유식").tag("이유식")
                            }
                            .pickerStyle(.inline)
                        }

                        Section(header: Text("용량")) {
                            TextField("용량", text: $amount)
                                .keyboardType(.numberPad)
                        }

                        Section(header: Text("날짜 및 시간")) {
                            DatePicker("날짜", selection: $date, displayedComponents: .date)
                            DatePicker("시간", selection: $date, displayedComponents: .hourAndMinute)
                        }

                        Section {
                            Button(role: .destructive) {
                                // 삭제 로직
                            } label: {
                                Text("기록 삭제")
                            }
                        }
                    }
                    .navigationTitle("수유 기록")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("취소") {
                                dismiss()
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("저장") {
                                // 저장 로직
                                dismiss()
                            }
                        }
                    }
                }
        
        
//        NavigationStack {
//            VStack {
//                headerView
//                datePicker
//                content
//                buttonView
//            }
//            .padding(30)
//        }
//        .navigationTitle(<#T##title: Text##Text#>)
    }
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
    private var headerView: some View {
        
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
                case .formula, .babyFood, .pumpedMilk, .breastfeeding: return .food
                case .diaper: return .diaper
                case .sleep: return .sleep
                case .heightWeight: return .heightWeight
                case .bath: return .bath
                case .snack: return .snack
                case .temperature, .medicine, .clinic: return .health
                case .poop, .pee, .pottyAll: return .potty
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
            Button(
                action: {
                    viewModel.removeRecord(); dismiss()
                }) {
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
    AddRecordView(record: Record.mockRecords[1])
}
