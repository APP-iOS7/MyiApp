//
//  EditRecordView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-20.
//

import SwiftUI

struct EditRecordView: View {
    @State var record: Record
    @State var isLeftMinutesPickerActionSheetPresent = false
    @State var isRightMinutesPickerActionSheetPresent = false
    @State var isMLPickerActionSheetPresent = false
    @State var isTMPickerActionSheetPresent = false
    var body: some View {
        NavigationView {
            Form {
                content(record: record)
                recordTimeSection
                deleteSection
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소", role: .cancel, action: {})
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장", action: {})
                }
            }
            .background {
                MinutesPickerActionSheet(isPresented: $isRightMinutesPickerActionSheetPresent, selectedAmount: $record.breastfeedingRightMinutes)
                MinutesPickerActionSheet(isPresented: $isLeftMinutesPickerActionSheetPresent, selectedAmount: $record.breastfeedingLeftMinutes)
                MLPickerActionSheet(isPresented: $isMLPickerActionSheetPresent, selectedAmount: $record.mlAmount)
                TMPPickerActionSheet(isPresented: $isTMPickerActionSheetPresent, selectedTemperature: Binding(
                    get: { record.temperature ?? 36.5 },
                    set: { record.temperature = $0 }
                ))
            }
        }
        
    }
    
    private var navigationTitle: String {
        switch record.title {
            case .formula, .babyFood, .pumpedMilk, .breastfeeding:
                "수유/이유식 기록"
            case .diaper:
                "기저귀 기록"
            case .sleep:
                "수면 기록"
            case .heightWeight:
                "키/몸무게 기록"
            case .bath:
                "목욕 기록"
            case .snack:
                "간식 기록"
            case .temperature, .medicine, .clinic:
                "건강 관리 기록"
            case .poop, .pee, .pottyAll:
                "배변 기록"
        }
    }
    private var recordTimeSection: some View {
        Section {
            DatePicker("기록 시간", selection: $record.createdAt, displayedComponents: [.date, .hourAndMinute])
        }
    }
    private var deleteSection: some View {
        Section {
            Button("기록 삭제", role: .destructive, action: {})
        }
    }
    @ViewBuilder func content(record: Record) -> some View {
        switch record.title {
            case .formula, .babyFood, .pumpedMilk, .breastfeeding:
                Section {
                    HStack {
                        Image(systemName: record.title == .breastfeeding ? "circle.inset.filled" : "circle")
                        Image(.normalBreastFeeding)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .padding(.horizontal)
                        Text("모유수유")
                    }
                    .onTapGesture {
                        self.record.title = .breastfeeding
                        if record.title != .breastfeeding {
                            self.record.mlAmount = 0
                            self.record.breastfeedingLeftMinutes = 0
                            self.record.breastfeedingRightMinutes = 0
                        }
                    }
                    HStack {
                        Image(systemName: record.title == .pumpedMilk ? "circle.inset.filled" : "circle")
                        Image(.normalPumpedMilk)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .padding(.horizontal)
                        Text("유축수유")
                    }
                    .onTapGesture {
                        self.record.title = .pumpedMilk
                        if record.title != .pumpedMilk {
                            self.record.mlAmount = 0
                            self.record.breastfeedingLeftMinutes = 0
                            self.record.breastfeedingRightMinutes = 0
                        }
                    }
                    HStack {
                        Image(systemName: record.title == .formula ? "circle.inset.filled" : "circle")
                        Image(.normalPowderedMilk)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .padding(.horizontal)
                        Text("분유")
                    }
                    .onTapGesture {
                        self.record.title = .formula
                        if record.title != .formula {
                            self.record.mlAmount = 0
                            self.record.breastfeedingLeftMinutes = 0
                            self.record.breastfeedingRightMinutes = 0
                        }
                    }
                    HStack {
                        Image(systemName: record.title == .babyFood ? "circle.inset.filled" : "circle")
                        Image(.normalBabyMeal)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .padding(.horizontal)
                        Text("이유식")
                    }
                    .onTapGesture {
                        self.record.title = .babyFood
                        if record.title != .babyFood {
                            self.record.mlAmount = 0
                            self.record.breastfeedingLeftMinutes = 0
                            self.record.breastfeedingRightMinutes = 0
                        }
                    }
                } header: { Text("카테고리") }
                    .listRowSeparator(.hidden)
                if record.title == .breastfeeding {
                    Section {
                        HStack {
                            Text("왼쪽")
                            Spacer()
                            Button {
                                isLeftMinutesPickerActionSheetPresent = true
                            } label: {
                                Text("\(self.record.breastfeedingLeftMinutes ?? 0) 분")
                                    .foregroundStyle(Color.primary)
                            }
                            .buttonStyle(.bordered)
                        }
                        .buttonStyle(.plain)
                        HStack {
                            Text("오른쪽")
                            Spacer()
                            Button {
                                isRightMinutesPickerActionSheetPresent = true
                            } label: {
                                Text("\(self.record.breastfeedingRightMinutes ?? 0) 분")
                                    .foregroundStyle(Color.primary)
                            }
                            .buttonStyle(.bordered)
                        }
                        .buttonStyle(.plain)
                    } header: {
                        Text("수유 시간")
                    }
                } else {
                    Section {
                        HStack {
                            Text("오른쪽")
                            Spacer()
                            Button {
                                isMLPickerActionSheetPresent = true
                            } label: {
                                Text("\(self.record.mlAmount ?? 0) ml")
                                    .foregroundStyle(Color.primary)
                            }
                            .buttonStyle(.bordered)
                        }
                        .buttonStyle(.plain)
                    } header: {
                        Text("용량")
                    }
                }
            case .sleep:
                Section {
                    DatePicker("시작", selection: Binding(
                        get: {
                            self.record.sleepStart ?? Date()
                        },
                        set: { self.record.sleepStart = $0 })
                    )
                    DatePicker("종료", selection: Binding(
                        get: {
                            self.record.sleepEnd ?? Date()
                        },
                        set: { self.record.sleepEnd = $0 }))
                } header: {
                    Text("수면 시간")
                }
            case .heightWeight:
                Section {
                    TextField(
                        "키를 입력해 주세요",
                        text: Binding(
                            get: { record.height.map { String(format: "%.1f", $0) } ?? "" },
                            set: { self.record.height = Double($0) }
                        )
                    )
                    .keyboardType(.decimalPad)
                    .overlay(
                        HStack {
                            Spacer()
                            Text("cm")
                                .foregroundColor(.secondary)
                                .padding(.trailing, 8)
                        }
                    )
                    TextField(
                        "몸무게를 입력해 주세요",
                        text: Binding(
                            get: { record.weight.map { String(format: "%.1f", $0) } ?? "" },
                            set: { self.record.weight = Double($0) }
                        )
                    )
                    .keyboardType(.decimalPad)
                    .overlay(
                        HStack {
                            Spacer()
                            Text("kg")
                                .foregroundColor(.secondary)
                                .padding(.trailing, 8)
                        }
                    )
                } header: {
                    Text("키/몸무게")
                }
            case .snack:
                Section {
                    TextField("간식을 입력해 주세요",
                              text: Binding(
                                get: { self.record.content ?? "" },
                                set: { self.record.content = $0 }
                              )
                    )
                } header: {
                    Text("내용")
                }
            case .temperature, .medicine, .clinic:
                Section {
                    HStack {
                        Image(systemName: record.title == .temperature ? "circle.inset.filled" : "circle")
                        Image(.normalTemperature)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .padding(.horizontal)
                        Text("체온")
                    }
                    .onTapGesture {
                        self.record.title = .temperature
                        if record.title != .temperature {
                            self.record.content = nil
                        }
                    }
                    HStack {
                        Image(systemName: record.title == .medicine ? "circle.inset.filled" : "circle")
                        Image(.normalMedicine)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .padding(.horizontal)
                        Text("투약")
                    }
                    .onTapGesture {
                        self.record.title = .medicine
                        self.record.content = nil
                        self.record.temperature = nil
                    }
                    HStack {
                        Image(systemName: record.title == .clinic ? "circle.inset.filled" : "circle")
                        Image(.normalClinic)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .padding(.horizontal)
                        Text("기타")
                    }
                    .onTapGesture {
                        self.record.title = .clinic
                        self.record.content = nil
                        self.record.temperature = nil
                    }
                } header: {
                    Text("카테고리")
                }
                .listRowSeparator(.hidden)
                if record.title == .temperature {
                    Section {
                        HStack {
                            Text("체온")
                            Spacer()
                            Button {
                                isTMPickerActionSheetPresent = true
                            } label: {
                                Text(String(format: "%.1f °C", record.temperature ?? 36.5))
                                    .foregroundColor(.primary)
                            }
                            .buttonStyle(.bordered)
                        }
                    } header: {
                        Text("현재 체온")
                    }
                } else {
                    Section {
                        TextField("내용을 입력해 주세요",
                                  text: Binding(
                                    get: { self.record.content ?? "" },
                                    set: { self.record.content = $0 }
                                  )
                        )
                    } header: {
                        Text("내용을 입력해 주세요")
                    }
                }
            case .poop, .pee, .pottyAll:
                Section {
                    HStack {
                        Image(systemName: record.title == .pee ? "circle.inset.filled" : "circle")
                        Image(.normalPee)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .padding(.horizontal)
                        Text("소변")
                    }
                    .onTapGesture {
                        self.record.title = .pee
                    }
                    HStack {
                        Image(systemName: record.title == .poop ? "circle.inset.filled" : "circle")
                        Image(.normalPoop)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .padding(.horizontal)
                        Text("대변")
                    }
                    .onTapGesture {
                        self.record.title = .poop
                    }
                    HStack {
                        Image(systemName: record.title == .pottyAll ? "circle.inset.filled" : "circle")
                        Image(.normalPotty)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .padding(.horizontal)
                        Text("둘다")
                    }
                    .onTapGesture {
                        self.record.title = .pottyAll
                    }
                }
                .listRowSeparator(.hidden)
            case .diaper, .bath:
                EmptyView()
        }
    }
}

#Preview {
    let record = Record.mockRecords[30]
    EditRecordView(record: record)
    Text(record.title.rawValue)
}
