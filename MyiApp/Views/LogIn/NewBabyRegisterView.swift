//
//  BabyProfileRegisterView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/28/25.
//

import SwiftUI

struct NewBabyRegisterView: View {
    @StateObject private var viewModel = RegisterBabyViewModel()
    
    private var isButtonEnabled: Bool {
        !viewModel.name.isEmpty &&
        viewModel.gender != nil &&
        !viewModel.height.isEmpty &&
        !viewModel.weight.isEmpty &&
        viewModel.bloodType != nil &&
        viewModel.birthDate != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("이름")) {
                    TextField("이름을 입력하세요", text: $viewModel.name)
                        .onSubmit {
                            dismissKeyboard()
                        }
                        .submitLabel(.done)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                }
                
                Section(header: Text("출생")) {
                    DatePicker(
                        "날짜",
                        selection: Binding(
                            get: { viewModel.birthDate ?? Date() },
                            set: { viewModel.birthDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    Toggle("시간 입력", isOn: $viewModel.isTimeSelectionEnabled)
                    if viewModel.isTimeSelectionEnabled {
                        DatePicker(
                            "시간",
                            selection: Binding(
                                get: { viewModel.birthDate ?? Date() },
                                set: { viewModel.birthDate = $0 }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
                
                Section(header: Text("카테고리")) {
                    Picker("성별", selection: $viewModel.gender) {
                        Text("선택").tag(nil as Gender?)
                        Text("남").tag(Gender.male as Gender?)
                        Text("여").tag(Gender.female as Gender?)
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("키/몸무게")) {
                    TextField("키를 입력하세요", text: $viewModel.height)
                        .keyboardType(.decimalPad)
                        .onSubmit {
                            dismissKeyboard()
                        }
                        .submitLabel(.done)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                    
                    TextField("몸무게를 입력하세요", text: $viewModel.weight)
                        .keyboardType(.decimalPad)
                        .onSubmit {
                            dismissKeyboard()
                        }
                        .submitLabel(.done)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                }
                
                Section(header: Text("혈액형")) {
                    Picker("혈액형", selection: $viewModel.bloodType) {
                        Text("선택").tag(nil as BloodType?)
                        Text("A").tag(BloodType.A as BloodType?)
                        Text("B").tag(BloodType.B as BloodType?)
                        Text("O").tag(BloodType.O as BloodType?)
                        Text("AB").tag(BloodType.AB as BloodType?)
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("아이 정보 등록")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("저장") {
                        dismissKeyboard()
                        viewModel.registerBaby()
                    }
                    .disabled(!isButtonEnabled)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                dismissKeyboard()
            }
        }
    }
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

#Preview {
    NavigationStack {
        NewBabyRegisterView()
    }
}

