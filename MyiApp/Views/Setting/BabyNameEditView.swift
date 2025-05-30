//
//  BabyNameEditView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/23/25.
//

import SwiftUI

struct BabyNameEditView: View {
    @StateObject var viewModel: BabyProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    @State private var selectedName: String
    private var isButtonEnabled: Bool {
        selectedName.trimmingCharacters(in: .whitespaces).isEmpty == false
    }
    
    init(viewModel: BabyProfileViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._selectedName = State(wrappedValue: viewModel.baby.name)
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("이름을 입력하세요")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary.opacity(0.8))
                    .padding()
                    .padding(.top, 10)
                ZStack(alignment: .trailing) {
                    TextField("이름을 입력하세요", text: $selectedName)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary.opacity(0.6))
                        .font(.title2)
                        .padding()
                        .padding(.vertical)
                        .padding(.trailing, 40)
                        .focused($isTextFieldFocused)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                        .background(
                            VStack {
                                Spacer()
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.primary.opacity(0.8))
                            }
                                .padding()
                        )
                        .submitLabel(.done)
                        .onSubmit {
                            viewModel.baby.name = selectedName
                            Task {
                                await viewModel.saveProfileEdits()
                                if viewModel.isProfileSaved {
                                    await CaregiverManager.shared.loadCaregiverInfo()
                                    dismiss()
                                }
                            }
                        }
                    
                    if !selectedName.isEmpty {
                        Button(action: {
                            selectedName = ""
                            isTextFieldFocused = true
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 20)
                        }
                    }
                }
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .padding(.leading, 18)
                }
                
                Spacer()
                
            }
            .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.tertiarySystemBackground))
                )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                if keyboardHeight > 0 {
                    VStack {
                        Button(action: {
                            viewModel.baby.name = selectedName
                            Task {
                                await viewModel.saveProfileEdits()
                                if viewModel.isProfileSaved {
                                    await CaregiverManager.shared.loadCaregiverInfo()
                                    dismiss()
                                }
                            }
                        }) {
                            Text("완료")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .font(.headline)
                                .background(isButtonEnabled ? Color("buttonColor") : Color.gray)
                        }
                        .contentShape(Rectangle())
                        .disabled(!isButtonEnabled)
                    }
                }
            }
            .animation(.easeInOut, value: keyboardHeight)
            .onAppear {
                // 키보드 높이 감지
                NotificationCenter.default.addObserver(
                    forName: UIResponder.keyboardWillShowNotification,
                    object: nil,
                    queue: .main
                ) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        keyboardHeight = keyboardFrame.height
                    }
                }
                NotificationCenter.default.addObserver(
                    forName: UIResponder.keyboardWillHideNotification,
                    object: nil,
                    queue: .main
                ) { _ in
                    keyboardHeight = 0
                }
            }
            .onDisappear {
                // 노티피케이션 제거
                NotificationCenter.default.removeObserver(self)
            }
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
    return BabyNameEditView(viewModel: BabyProfileViewModel(baby: sampleBaby))
}
