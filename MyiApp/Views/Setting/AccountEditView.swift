//
//  AccountSettingsView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/13/25.
//

import SwiftUI
import PhotosUI

struct AccountEditView: View {
    @ObservedObject private var viewModel = AccountSettingsViewModel.shared
    @State private var showPhotoActionSheet = false
    @State private var showPhotoPicker = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var selectedName: String
    private var isButtonEnabled: Bool {
        selectedName.trimmingCharacters(in: .whitespaces).isEmpty == false
    }
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    
    init(viewModel: AccountSettingsViewModel) {
        self.viewModel = viewModel
        self._selectedName = State(wrappedValue: viewModel.name)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("사용자 이름을 입력하세요")
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
                        viewModel.name = selectedName
                        Task {
                            await viewModel.saveProfile()
                            if viewModel.isProfileSaved {
                                dismiss()
                            }
                        }
                    }
                
                if !selectedName.isEmpty {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedName = ""
                            isTextFieldFocused = true
                        }
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
        .background(Color(UIColor.tertiarySystemBackground))
        .navigationTitle("사용자 프로필")
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
        .safeAreaInset(edge: .bottom) {
            if keyboardHeight > 0 {
                VStack {
                    Button(action: {
                        viewModel.name = selectedName
                        Task {
                            await viewModel.saveProfile()
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
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .task {
            await viewModel.loadProfile()
        }
        
    }
}

