//
//  BabyProfileRegisterView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/28/25.
//

import SwiftUI

struct NewBabyRegisterView: View {
    @StateObject private var viewModel = RegisterBabyViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case name, birthDate, height, weight, submit
    }
    
    @State private var isNameEntered: Bool = false
    @State private var isGenderSelected: Bool = false
    @State private var isBirthDateSelected: Bool = false
    @State private var isHeightEntered: Bool = false
    @State private var isWeightEntered: Bool = false
    @State private var isBloodTypeSelected: Bool = false
    
    private var isButtonEnabled: Bool {
        !viewModel.name.isEmpty &&
        viewModel.gender != nil &&
        !viewModel.height.isEmpty &&
        !viewModel.weight.isEmpty &&
        viewModel.bloodType != nil &&
        viewModel.birthDate != nil
    }
    
    var body: some View {
        VStack {
            SafeAreaPaddingView()
                .frame(height: getTopSafeAreaHeight())
                .background(Color.customBackground)
            ScrollView {
                VStack(spacing: 15) {
                    if !viewModel.weight.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("혈액형")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary.opacity(0.8))
                                .padding()
                                .padding(.top, 8)
                            HStack {
                                Text("A 형")
                                    .foregroundColor(.primary.opacity(0.6))
                                Spacer()
                                
                                Image(systemName: viewModel.bloodType == .A ? "checkmark.circle.fill" : "checkmark.circle")
                                    .font(.title2)
                                    .foregroundColor(viewModel.bloodType == .A ? Color("buttonColor") : .primary.opacity(0.6))
                            }
                            .padding()
                            .padding(.top, 5)
                            .padding(.bottom, 5)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.bloodType = .A
                                dismissKeyboard()
                            }
                            
                            HStack {
                                Text("B 형")
                                    .foregroundColor(.primary.opacity(0.6))
                                
                                Spacer()
                                
                                Image(systemName: viewModel.bloodType == .B ? "checkmark.circle.fill" : "checkmark.circle")
                                    .font(.title2)
                                    .foregroundColor(viewModel.bloodType == .B ? Color("buttonColor") : .primary.opacity(0.6))
                            }
                            .padding()
                            .padding(.top, 5)
                            .padding(.bottom, 5)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.bloodType = .B
                                dismissKeyboard()
                            }
                            
                            HStack {
                                Text("O 형")
                                    .foregroundColor(.primary.opacity(0.6))
                                
                                Spacer()
                                
                                Image(systemName: viewModel.bloodType == .O ? "checkmark.circle.fill" : "checkmark.circle")
                                    .font(.title2)
                                    .foregroundColor(viewModel.bloodType == .O ? Color("buttonColor") : .primary.opacity(0.6))
                            }
                            .padding()
                            .padding(.top, 5)
                            .padding(.bottom, 5)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.bloodType = .O
                                dismissKeyboard()
                            }
                            
                            HStack {
                                Text("AB 형")
                                    .foregroundColor(.primary.opacity(0.6))
                                    .padding(.leading, 5)
                                
                                Spacer()
                                
                                Image(systemName: viewModel.bloodType == .AB ? "checkmark.circle.fill" : "checkmark.circle")
                                    .font(.title2)
                                    .foregroundColor(viewModel.bloodType == .AB ? Color("buttonColor") : .primary.opacity(0.6))
                            }
                            .padding()
                            .padding(.bottom, 8)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.bloodType = .AB
                                dismissKeyboard()
                            }
                            
                        }
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .onChange(of: viewModel.bloodType) {
                            if viewModel.bloodType != nil {
                                withAnimation {
                                    isBloodTypeSelected = true
                                    focusedField = .submit
                                    dismissKeyboard()
                                }
                            } else {
                                isBloodTypeSelected = false
                            }
                        }
                    }
                    
                    if !viewModel.height.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("몸무게")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary.opacity(0.8))
                                .padding()
                                .padding(.top, 8)
                            ZStack(alignment: .trailing) {
                                TextField("몸무게를 입력하세요", text: $viewModel.weight)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.primary.opacity(0.6))
                                    .font(.title2)
                                    .padding(.vertical)
                                    .padding(.trailing, 40)
                                    .disableAutocorrection(true)
                                    .textInputAutocapitalization(.never)
                                    .background(
                                        VStack {
                                            Spacer()
                                            Rectangle()
                                                .frame(height: 1)
                                                .foregroundColor(.primary.opacity(0.8))
                                        }
                                    )
                                    .focused($focusedField, equals: .weight)
                                if !viewModel.weight.isEmpty {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            viewModel.weight = ""
                                            focusedField = .weight
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 20)
                                    }
                                }
                            }
                            .padding()
                            .padding(.bottom, 8)
                        }
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    if isBirthDateSelected {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("키")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary.opacity(0.8))
                                .padding()
                                .padding(.top, 8)
                            ZStack(alignment: .trailing) {
                                TextField("키를 입력하세요", text: $viewModel.height)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.primary.opacity(0.6))
                                    .font(.title2)
                                    .padding(.vertical)
                                    .padding(.trailing, 40)
                                    .disableAutocorrection(true)
                                    .textInputAutocapitalization(.never)
                                    .background(
                                        VStack {
                                            Spacer()
                                            Rectangle()
                                                .frame(height: 1)
                                                .foregroundColor(.primary.opacity(0.8))
                                        }
                                    )
                                    .focused($focusedField, equals: .height)
                                if !viewModel.height.isEmpty {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            viewModel.height = ""
                                            focusedField = .height
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 20)
                                    }
                                }
                            }
                            .padding()
                            .padding(.bottom, 8)
                        }
                            .background(Color(UIColor.tertiarySystemBackground))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    if isNameEntered {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("출생일")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary.opacity(0.8))
                                .padding()
                                .padding(.top, 8)
                            HStack {
                                DatePicker(
                                    "날짜",
                                    selection: Binding(
                                        get: { viewModel.birthDate ?? Date() },
                                        set: {
                                            newValue in
                                            viewModel.birthDate = newValue
                                            isBirthDateSelected = true
                                        }
                                    ),
                                    displayedComponents: .date
                                )
                                .focused($focusedField, equals: .birthDate)
                            }
                            .padding()
                            .padding(.top, 5)
                            .padding(.bottom, 5)
                            .onChange(of: viewModel.birthDate) {
                                withAnimation {
                                    isBirthDateSelected = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        focusedField = .height
                                    }
                                }
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                Toggle("시간 입력", isOn: $viewModel.isTimeSelectionEnabled)
                                    .padding()
                                if viewModel.isTimeSelectionEnabled {
                                    HStack {
                                        DatePicker(
                                            "시간",
                                            selection: Binding(
                                                get: { viewModel.birthDate ?? Date() },
                                                set: { viewModel.birthDate = $0 }
                                            ),
                                            displayedComponents: .hourAndMinute
                                        )
                                        .focused($focusedField, equals: .birthDate)
                                    }
                                    .padding()
                                    .padding(.bottom, 8)
                                    .onChange(of: viewModel.birthDate) {
                                        withAnimation {
                                            isBirthDateSelected = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                focusedField = .height
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .onSubmit {
                            if !isHeightEntered {
                                withAnimation {
                                    isBirthDateSelected = true
                                    focusedField = .height
                                }
                            } else {
                                focusedField = nil
                            }
                        }
                    }
                    
                    if viewModel.gender != nil {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("이름")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary.opacity(0.8))
                                .padding()
                                .padding(.top, 8)
                            
                            ZStack(alignment: .trailing) {
                                TextField("이름을 입력하세요", text: $viewModel.name)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.primary.opacity(0.6))
                                    .font(.title2)
                                    .padding(.vertical)
                                    .padding(.trailing, 40)
                                    .disableAutocorrection(true)
                                    .textInputAutocapitalization(.never)
                                    .background(
                                        VStack {
                                            Spacer()
                                            Rectangle()
                                                .frame(height: 1)
                                                .foregroundColor(.primary.opacity(0.8))
                                        }
                                    )
                                    .submitLabel(.done)
                                    .focused($focusedField, equals: .name)
                                
                                if !viewModel.name.isEmpty {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            viewModel.name = ""
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 20)
                                    }
                                }
                            }
                            .padding()
                            .padding(.bottom, 8)
                        }
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .onChange(of: viewModel.name) { _, newValue in
                            isNameEntered = !newValue.isEmpty
                        }
                        .onSubmit {
                            if !viewModel.name.isEmpty {
                                withAnimation {
                                    isNameEntered = true
                                    focusedField = .birthDate
                                }
                            } else {
                                isNameEntered = false
                                focusedField = nil
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("성별")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding()
                            .padding(.top, 8)
                        HStack {
                            Text("남자 아이")
                                .foregroundColor(.primary.opacity(0.6))
                                .padding(.leading, 5)
                            
                            Spacer()
                            
                            Image(systemName: viewModel.gender == .male ? "checkmark.circle.fill" : "checkmark.circle")
                                .font(.title2)
                                .foregroundColor(viewModel.gender == .male ? Color("buttonColor") : .primary.opacity(0.6))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.gender = .male
                        }
                        .padding()
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        HStack {
                            Text("여자 아이")
                                .foregroundColor(.primary.opacity(0.6))
                                .padding(.leading, 5)
                            
                            Spacer()
                            
                            Image(systemName: viewModel.gender == .female ? "checkmark.circle.fill" : "checkmark.circle")
                                .font(.title2)
                                .foregroundColor(viewModel.gender == .female ? Color("buttonColor") : .primary.opacity(0.6))
                        }
                        .padding()
                        .padding(.bottom, 8)
                    }
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.gender = .female
                    }
                    .onChange(of: viewModel.gender) {
                        withAnimation {
                            isGenderSelected = viewModel.gender != nil
                            focusedField = .name
                        }
                    }
                    
                    Spacer()
                    
                }
            }
            Button(action: {
                dismissKeyboard()
                viewModel.registerBaby()
            }) {
                Text("완료")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .font(.headline)
                    .background(isButtonEnabled ? Color("buttonColor") : Color.gray)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            .disabled(!isButtonEnabled)
            .navigationTitle("아이 정보 등록")
            .background(Color("customBackgroundColor"))
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
        .onTapGesture {
            dismissKeyboard()
        }
        .background(Color("customBackgroundColor"))
    }
    
    
    private func dismissKeyboard() {
        focusedField = nil
    }
    
    private func getTopSafeAreaHeight() -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return 0
        }
        
        let height = window.safeAreaInsets.top
        return height * 0.1
    }
}

#Preview {
    NavigationStack {
        NewBabyRegisterView()
    }
}

