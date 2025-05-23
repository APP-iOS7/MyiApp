//
//  BabyGenderEditView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/23/25.
//

import SwiftUI

struct BabyGenderEditView: View {
    @StateObject var viewModel: BabyProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGender: Gender
    
    init(viewModel: BabyProfileViewModel) {
            self._viewModel = StateObject(wrappedValue: viewModel)
            self._selectedGender = State(wrappedValue: viewModel.baby.gender)
        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("성별")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary.opacity(0.8))
                .padding()
                .padding(.top, 10)
            
//            HStack {
//                Picker("성별", selection: $selectedGender) {
//                    Text("남").tag(Gender.male)
//                    Text("여").tag(Gender.female)
//                }
//                .pickerStyle(.segmented)
//                .padding()
//            }
//            .padding()
//            .foregroundColor(.primary.opacity(0.6))
            
            VStack {
                HStack {
                    Text("남자 아이")
                        .font(.title3)
                    
                    Spacer()
                    
                    Image(systemName: selectedGender == .male ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(selectedGender == .male ? Color("buttonColor") : .primary.opacity(0.6))
                }
                .padding()
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedGender = .male
                }
                
                HStack {
                    Text("여자 아이")
                        .font(.title3)
                    
                    Spacer()
                    Image(systemName: selectedGender == .female ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(selectedGender == .female ? Color("buttonColor") : .primary.opacity(0.6))
            }
            .padding()
            .contentShape(Rectangle())
            .onTapGesture {
                selectedGender = .  female
            }
        }
            
            Spacer()
            
            VStack {
                Button(action: {
                    viewModel.baby.gender = selectedGender
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
    BabyGenderEditView(viewModel: BabyProfileViewModel(baby: sampleBaby))
}
