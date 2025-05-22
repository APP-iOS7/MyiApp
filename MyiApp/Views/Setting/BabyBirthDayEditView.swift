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
    @FocusState private var isTextFieldFocused: Bool
    @State private var showBirthDatePicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("생년월일")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary.opacity(0.8))
                .padding()
                .padding(.top, 10)
            DatePicker(
                "생년월일",
                selection: $viewModel.baby.birthDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding()
            .foregroundColor(.primary.opacity(0.6))
            .background(
                VStack {
                    Spacer()
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.primary.opacity(0.8))
                }
                    .padding()
            )
            Spacer()
            VStack {
                Button(action: {
                    Task {
                        await viewModel.saveProfileEdits()
                        dismiss()
                    }
                }) {
                    Text("완료")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color("buttonColor"))
                        .cornerRadius(12)
                }
                .contentShape(Rectangle())
                .padding(.horizontal)
            }
        }
        .background(Color("customBackgroundColor"))
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
    return BabyBirthDayEditView(viewModel: BabyProfileViewModel(baby: sampleBaby))
}

