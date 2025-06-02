//
//  BabyBirthTimeEditView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/23/25.
//

import SwiftUI

struct BabyBirthTimeEditView: View {
    @StateObject var viewModel: BabyProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showBirthDatePicker = false
    @State private var selectedTime: Date
    
    init(viewModel: BabyProfileViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._selectedTime = State(wrappedValue: viewModel.baby.birthDate)
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("출생 시간")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary.opacity(0.8))
                    .padding()
                    .padding(.top, 10)
                HStack {
                    DatePicker("출생 시간", selection: $selectedTime, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .tint(Color("buttonColor"))
                        .padding()
                        .foregroundColor(.primary.opacity(0.6))
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()                
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.tertiarySystemBackground))
            )
            
            Spacer()
            
            Button(action: {
                viewModel.baby.birthDate = selectedTime
                Task {
                    await viewModel.saveProfileEdits()
                    dismiss()
                }
            }) {
                Text("완료")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .font(.headline)
                    .background(Color("buttonColor"))
                    .cornerRadius(12)
            }
            
            .contentShape(Rectangle())
            .navigationTitle(Text("출생 시간"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .padding(.horizontal)
        .background(Color("customBackgroundColor"))
    }
}

#Preview {
    let sampleBaby = Baby(
        name: "아기",
        birthDate: Date(),
        gender: .male,
        height: 50.5,
        weight: 3.5,
        bloodType: .A
    )
    return BabyBirthTimeEditView(viewModel: BabyProfileViewModel(baby: sampleBaby))
}
