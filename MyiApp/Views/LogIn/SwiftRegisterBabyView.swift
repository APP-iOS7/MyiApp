// SwiftRegisterBabyView.swift
import SwiftUI

struct SwiftRegisterBabyView: View {
    @StateObject private var viewModel = RegisterBabyViewModel()
    @State private var birthDateText: String = ""
    @State private var heightText: String = ""
    @State private var weightText: String = ""
    
    // 단계 완료 상태
    @State private var isNameEntered: Bool = false
    @State private var isGenderSelected: Bool = false
    @State private var isBirthDateSelected: Bool = false
    @State private var isHeightEntered: Bool = false
    @State private var isWeightEntered: Bool = false
    @State private var isBloodTypeSelected: Bool = false
    
    // 포커스 상태
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case name, birthDate, height, weight, submit
    }
    
    // 날짜 포맷터
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }
    
    // 입력용 날짜 포맷터
    private var inputDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
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
        NavigationStack {
            ScrollView {
                VStack {
                    // 헤더
                    Text("아이 정보를\n입력해주세요")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Color.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 80)
                    
                    // 혈액형
                    if !viewModel.weight.isEmpty {
                        Picker("혈액형", selection: $viewModel.bloodType) {
                            Text("혈액형").tag(BloodType?.none)
                            ForEach([BloodType.A, .B, .O, .AB], id: \.self) { type in
                                Text(type.rawValue).tag(type as BloodType?)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(Color("buttonColor"))
                        .onChange(of: viewModel.bloodType) {
                            if viewModel.bloodType != nil {
                                withAnimation {
                                    isBloodTypeSelected = true
                                    focusedField = .submit
                                    dismissKeyboard()
                                }
                            }
                        }
                    }
                    
                    // 몸무게
                    if !viewModel.height.isEmpty {
                        HStack {
                            TextField("몸무게", text: Binding(
                                get: { viewModel.weight },
                                set: { newValue in
                                    // 숫자와 . 만 허용
                                    let filtered = newValue.filter { $0.isNumber || $0 == "." }
                                    viewModel.weight = filtered
                                }
                            ))
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .weight)
                            .submitLabel(.done)
                            .onSubmit {
                                if !viewModel.weight.isEmpty {
                                    withAnimation {
                                        focusedField = nil
                                    }
                                }
                            }

                            Text("kg")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    // 키
                    if viewModel.birthDate != nil {
                        HStack {
                            TextField("키", text: Binding(
                                get: { viewModel.height },
                                set: { newValue in
                                    // 숫자와 .만 허용
                                    let filtered = newValue.filter { $0.isNumber || $0 == "." }
                                    viewModel.height = filtered
                                }
                            ))
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .height)
                            .submitLabel(.next)
                            .onSubmit {
                                if !viewModel.height.isEmpty {
                                    withAnimation {
                                        focusedField = .weight
                                    }
                                } else {
                                    focusedField = nil
                                }
                            }
                            Text("cm")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    // 출생일
                    if isNameEntered {
                        
                        TextField("출생일 (YYYY/MM/DD)", text: Binding(
                            get: { viewModel.formattedBirthDateText },
                            set: { newValue in
                                viewModel.updateBirthDateText(from: newValue)
                                if let _ = viewModel.birthDate, viewModel.birthDateRawText.count == 8 {
                                    isBirthDateSelected = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        focusedField = .height
                                    }
                                } else {
                                    isBirthDateSelected = false
                                }
                            }
                        ))
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .keyboardType(.numberPad)
                        .foregroundColor(viewModel.birthDate == nil ? .gray : .primary)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .birthDate)
                    }
                    
                    // 아기 이름
                    if viewModel.gender != nil {
                        TextField("이름, 별명", text: $viewModel.name)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                            .submitLabel(.next)
                            .focused($focusedField, equals: .name)
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
                            .onChange(of: viewModel.name) { _, newValue in
                                isNameEntered = !newValue.isEmpty
                            }
                    }
                    
                    // 성별 선택
                    Picker("성별", selection: $viewModel.gender) {
                        Text("남아").tag(Gender.male as Gender?)
                        Text("여아").tag(Gender.female as Gender?)
                    }
                    .pickerStyle(.segmented)
                    .tint(Color("buttonColor"))
                    .onChange(of: viewModel.gender) {
                        withAnimation {
                            focusedField = .name
                        }
                    }
                    // 등록하기 버튼
                    if isBloodTypeSelected {
                        Button(action: {
                            dismissKeyboard()
                            viewModel.registerBaby()
                        }) {
                            Text("등록하기")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .foregroundStyle(.white)
                                .background(isButtonEnabled ? Color("buttonColor") : Color.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(!isButtonEnabled)
                        .padding(.top, 20)
                        .focused($focusedField, equals: .submit)
                    }
                    
                    // 에러 메시지
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .onTapGesture {
                dismissKeyboard()
            }
        }
    }
    
    // 키보드 내리는 함수
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    SwiftRegisterBabyView()
}
