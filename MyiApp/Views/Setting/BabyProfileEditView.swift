//
//  BabyProfileEditView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/22/25.
//

import SwiftUI

struct BabyProfileEditView: View {
    @StateObject var viewModel: BabyProfileViewModel
    
    var body: some View {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text("이름")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary.opacity(0.8))
                        .padding()
                        .padding(.top, 10)
                    
                    TextField("이름을 입력하세요", text: $viewModel.baby.name)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary.opacity(0.6))
                        .font(.system(size: 17))
                        .padding()
                        .padding(.vertical, 8)
                        .background(
                            VStack {
                                Spacer()
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.black.opacity(0.8))
                            }
                                .padding()
                        )
                }
                .background(Color(UIColor.tertiarySystemBackground))
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("생년월일")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding()
                        
                        Spacer()
                        
                        DatePicker("", selection: $viewModel.baby.birthDate, displayedComponents: [.date])
                            .labelsHidden()
                            .padding()
                    }
                }
                .background(Color(UIColor.tertiarySystemBackground))
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("출생시간")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding()
                        
                        Spacer()
                        
                        DatePicker("", selection: $viewModel.baby.birthDate, displayedComponents: [.hourAndMinute])
                            .labelsHidden()
                            .padding()
                    }
                }
                .background(Color(UIColor.tertiarySystemBackground))
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("성별")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding()
                        
                        Spacer()
                        
                        Picker("", selection: $viewModel.baby.gender) {
                            Text("남").tag(Gender.male)
                            Text("여").tag(Gender.female)
                        }
                        .multilineTextAlignment(.trailing)
                        .pickerStyle(MenuPickerStyle())
                        .foregroundColor(.primary.opacity(0.6))
                    }
                }
                .background(Color(UIColor.tertiarySystemBackground))
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("키")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary.opacity(0.8))
                        .padding()
                    
                    TextField("키", value: $viewModel.baby.height, formatter: NumberFormatter())
                        .multilineTextAlignment(.leading)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.primary.opacity(0.6))
                        .font(.system(size: 17))
                        .background(Color(UIColor.tertiarySystemBackground))
                        .padding()
                        .padding(.bottom, 10)
                        .background(
                            VStack {
                                Spacer()
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.black.opacity(0.8))
                            }
                                .padding()
                        )
                }
                .background(Color(UIColor.tertiarySystemBackground))
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("몸무게")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary.opacity(0.8))
                        .padding()
                        .padding(.top, 10)
                    
                    TextField("몸무게", value: $viewModel.baby.weight, formatter: NumberFormatter())
                        .multilineTextAlignment(.leading)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.primary.opacity(0.6))
                        .font(.system(size: 17))
                        .background(Color(UIColor.tertiarySystemBackground))
                        .padding()
                        .padding(.bottom, 10)
                        .background(
                            VStack {
                                Spacer()
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.black.opacity(0.8))
                            }
                                .padding()
                        )
                }
                .background(Color(UIColor.tertiarySystemBackground))
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("혈액형")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding()
                        
                        Spacer()
                        
                        Picker("", selection: $viewModel.baby.bloodType) {
                            Text(BloodType.A.rawValue).tag(BloodType.A)
                            Text(BloodType.B.rawValue).tag(BloodType.B)
                            Text(BloodType.AB.rawValue).tag(BloodType.AB)
                            Text(BloodType.O.rawValue).tag(BloodType.O)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                .background(Color(UIColor.tertiarySystemBackground))
            }
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
    return BabyProfileEditView(viewModel: BabyProfileViewModel(baby: sampleBaby))
}
