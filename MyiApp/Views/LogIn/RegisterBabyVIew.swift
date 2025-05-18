//
//  RegisterBabyVIew.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/13/25.
//

import SwiftUI

struct RegisterBabyView: View {
    @StateObject private var viewModel = RegisterBabyViewModel()
    @State private var showDatePicker: Bool = false
    
    // 날짜 포맷터
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateStyle = .medium
        return formatter
    }
    
    // 등록하기 버튼 활성화 여부
    private var isButtonEnabled: Bool {
        !viewModel.name.isEmpty &&
        viewModel.birthDate != nil &&
        viewModel.gender != nil &&
        !viewModel.height.isEmpty &&
        !viewModel.weight.isEmpty &&
        viewModel.bloodType != nil
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Spacer()
                    .frame(height: 30)
                
                VStack {
                    Text("아이 정보를")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 40)
                    Text("등록해주세요")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 60)
                }
                
                Spacer()
                
                // 남 여 선택 버튼
                HStack(spacing: 16) {
                    Button(action: { viewModel.gender = Gender.male }) {
                        Text("남아")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.gender == Gender.male ? Color("boyColor") : Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundStyle(Color.primary)
                    }
                    Button(action: { viewModel.gender = Gender.female }) {
                        Text("여아")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.gender == Gender.female ? Color("girlColor") : Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundStyle(Color.primary)
                    }
                }
                .font(.headline)
                .padding(.horizontal)
                
                // 아기 이름 텍스트필드
                TextField("이름", text: $viewModel.name)
                    .padding(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("sharkPrimaryColor"), lineWidth: 2)
                    )
                    .padding(.horizontal)
                    .onSubmit { dismissKeyboard() }
                
                // 출생일 텍스트 필드
                HStack {
                    Text(viewModel.birthDate == nil ? "출생일" : dateFormatter.string(from: viewModel.birthDate!))
                        .foregroundColor(viewModel.birthDate == nil ? .gray.opacity(0.5) : .primary)
                        .padding(.vertical, 12)
                        .padding(.leading, 12)
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(Color("sharkPrimaryColor"))
                        .padding(.trailing, 12)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("sharkPrimaryColor"), lineWidth: 2)
                )
                .padding(.horizontal)
                .onTapGesture {
                    showDatePicker = true
                }
                
                // DatePicker 표시
                .sheet(isPresented: $showDatePicker) {
                    VStack {
                        DatePicker(
                            "출생일",
                            selection: Binding(get: { viewModel.birthDate ?? Date() }, set: { viewModel.birthDate = $0 }),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        Button("완료") {
                            showDatePicker = false
                        }
                        .padding()
                    }
                    .padding()
                    .cornerRadius(12)
                    .presentationDetents([.height(500)])
                    .presentationDragIndicator(.visible)
                }
                
                // 키, 몸무게 텍스트필드
                HStack(spacing: 16) {
                    TextField("키", text: $viewModel.height)
                        .keyboardType(.decimalPad)
                        .padding(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("sharkPrimaryColor"), lineWidth: 2)
                        )
                        .onSubmit { dismissKeyboard() }
                    
                    TextField("몸무게", text: $viewModel.weight)
                        .keyboardType(.decimalPad)
                        .padding(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("sharkPrimaryColor"), lineWidth: 2)
                        )
                        .onSubmit { dismissKeyboard() }
                }
                .padding(.horizontal)
                
                // 혈액형 입력
                Picker("혈액형", selection: $viewModel.bloodType) {
                    Text("혈액형 선택").tag(BloodType?.none)
                    ForEach([BloodType.A, .B, .O, .AB], id: \.self) { type in
                        Text(type.rawValue).tag(type as BloodType?)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: viewModel.bloodType) {
                    dismissKeyboard()
                }
                
                // 등록하기 버튼
                Button(action: {
                    dismissKeyboard()
                    viewModel.registerBaby()
                }) {
                    Text("등록하기")
                        .foregroundColor(isButtonEnabled ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isButtonEnabled ? Color("sharkPrimaryColor") : Color.gray.opacity(0.5))
                        .cornerRadius(10)
                }
                .disabled(!isButtonEnabled)
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
                Color.clear
                    .frame(height: 20)
                
            }
        }
        .onTapGesture {
            dismissKeyboard()
        }
    }
    
    // 키보드 내리는 함수
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    RegisterBabyView()
}
