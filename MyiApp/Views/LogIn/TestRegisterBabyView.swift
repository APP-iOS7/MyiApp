//
//  TestRegisterBabyView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-10.
//

import SwiftUI

class TestRegisterBabyViewModel: ObservableObject {
    private let databaseService = DatabaseService.shared
    
    @Published var name: String = ""
    @Published var birthDate: Date = Date()
    @Published var gender: Gender? = nil
    @Published var height: String = ""
    @Published var weight: String = ""
    @Published var bloodType: BloodType? = nil
    
    // 등록 결과 메시지 등 필요시
    @Published var errorMessage: String? = nil
    
    func registerBaby() {
        guard let gender = gender, let bloodType = bloodType,
              let heightValue = Double(height), let weightValue = Double(weight) else {
            errorMessage = "모든 정보를 올바르게 입력해주세요."
            return
        }
        let baby = Baby(name: name, birthDate: birthDate, gender: gender, height: heightValue, weight: weightValue, bloodType: bloodType)
        Task {
            do {
                try await databaseService.saveBabyInfo(baby: baby)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct TestRegisterBabyView: View {
    @StateObject private var viewModel = TestRegisterBabyViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("아이 정보를\n등록해주세요")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            HStack(spacing: 16) {
                Button(action: { viewModel.gender = Gender.male }) {
                    Text("남아")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.gender == Gender.male ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                Button(action: { viewModel.gender = Gender.female }) {
                    Text("여아")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.gender == Gender.female ? Color.pink.opacity(0.2) : Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            }
            .font(.headline)
            .padding(.horizontal)
            TextField("이름", text: $viewModel.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            DatePicker("출생일", selection: $viewModel.birthDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding(.horizontal)
            HStack(spacing: 16) {
                TextField("키", text: $viewModel.height)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("몸무게", text: $viewModel.weight)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            // 혈액형 입력란 추가
            Picker("혈액형", selection: $viewModel.bloodType) {
                Text("혈액형 선택").tag(BloodType?.none)
                ForEach([BloodType.A, .B, .O, .AB], id: \.self) { type in
                    Text(type.rawValue).tag(type as BloodType?)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            Button(action: viewModel.registerBaby) {
                Text("등록하기")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.5))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    TestRegisterBabyView()
}
