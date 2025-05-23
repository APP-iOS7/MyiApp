//
//  BabyBirthEditView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/23/25.
//

import SwiftUI

struct BabyBirthDayEditView: View {
    @StateObject var viewModel: BabyProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showBirthDatePicker = false
    @State private var selectedDate: Date
    
    init(viewModel: BabyProfileViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._selectedDate = State(wrappedValue: viewModel.baby.birthDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("출생일")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary.opacity(0.8))
                .padding()
                .padding(.top, 10)
            DatePicker(
                "출생일",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding()
            .foregroundColor(.primary.opacity(0.6))
            
            Spacer()

            VStack {
                Button(action: {
                    viewModel.baby.birthDate = selectedDate
                    Task {
                        await viewModel.saveProfileEdits()
                        dismiss()
                    }
                }) {
                    Text("완료")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .frame(height: 50)
                        .background(Color("buttonColor"))
                        .cornerRadius(12)
                }
                .contentShape(Rectangle())
                .padding(.horizontal)
            }
        }
        .background(Color(UIColor.tertiarySystemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary.opacity(0.8))
                }
            }
        }
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
    BabyBirthDayEditView(viewModel: BabyProfileViewModel(baby: sampleBaby))
}

