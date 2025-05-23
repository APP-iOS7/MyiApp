//
//  BabyBloodEditView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/23/25.
//

import SwiftUI

struct BabyBloodEditView: View {
    @StateObject var viewModel: BabyProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedBloodType: BloodType
    
    init(viewModel: BabyProfileViewModel) {
            self._viewModel = StateObject(wrappedValue: viewModel)
            self._selectedBloodType = State(wrappedValue: viewModel.baby.bloodType)
        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("혈액형")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary.opacity(0.8))
                .padding()
                .padding(.top, 10)
            
//            HStack {
//                Picker("", selection: $selectedBloodType) {
//                    Text(BloodType.A.rawValue).tag(BloodType.A)
//                    Text(BloodType.B.rawValue).tag(BloodType.B)
//                    Text(BloodType.AB.rawValue).tag(BloodType.AB)
//                    Text(BloodType.O.rawValue).tag(BloodType.O)
//                }
//                .pickerStyle(.segmented)
//                .padding()
//            }
//            .padding()
//            .foregroundColor(.primary.opacity(0.6))
            VStack {
                HStack {
                    Text("A 형")
                        .font(.title3)
                    
                    Spacer()
                    
                    Image(systemName: selectedBloodType == .A ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(selectedBloodType == .A ? Color("buttonColor") : .primary.opacity(0.6))
                }
                .padding()
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedBloodType = .A
                }
                
                HStack {
                    Text("B 형")
                        .font(.title3)
                    
                    Spacer()
                    
                    Image(systemName: selectedBloodType == .B ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(selectedBloodType == .B ? Color("buttonColor") : .primary.opacity(0.6))
                }
                .padding()
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedBloodType = .B
                }
                
                HStack {
                    Text("O 형")
                        .font(.title3)
                    
                    Spacer()
                    
                    Image(systemName: selectedBloodType == .O ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(selectedBloodType == .O ? Color("buttonColor") : .primary.opacity(0.6))
                }
                .padding()
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedBloodType = .O
                }
                
                HStack {
                    Text("AB 형")
                        .font(.title3)
                    
                    Spacer()
                    
                    Image(systemName: selectedBloodType == .AB ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(selectedBloodType == .AB ? Color("buttonColor") : .primary.opacity(0.6))
                }
                .padding()
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedBloodType = .AB
                }
                
        }
            
            Spacer()
            
            VStack {
                Button(action: {
                    viewModel.baby.bloodType = selectedBloodType
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
    BabyBloodEditView(viewModel: BabyProfileViewModel(baby: sampleBaby))
}
