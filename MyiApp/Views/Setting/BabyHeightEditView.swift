//
//  BabyHeightEditView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/23/25.
//

import SwiftUI

struct BabyHeightEditView: View {
    @StateObject var viewModel: BabyProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    @State private var selectedHeight: Double?
    
    private var isButtonEnabled: Bool {
        selectedHeight != nil && selectedHeight! > 0
    }
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.minimum = 0
        formatter.maximum = 200
        formatter.allowsFloats = true
        return formatter
    }()
    
    init(viewModel: BabyProfileViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._selectedHeight = State(wrappedValue: viewModel.baby.height)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("키를 입력하세요")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary.opacity(0.8))
                .padding()
                .padding(.top, 10)
            ZStack(alignment: .trailing) {
                TextField("키를 입력하세요", value: $selectedHeight, formatter: numberFormatter)
                    .multilineTextAlignment(.leading)
                    .keyboardType(.decimalPad)
                    .foregroundColor(.primary.opacity(0.6))
                    .font(.title2)
                    .padding()
                    .padding(.vertical)
                    .padding(.trailing, 70)
                    .background(
                        VStack {
                            Spacer()
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.primary.opacity(0.8))
                        }
                            .padding()
                    )
                    .focused($isTextFieldFocused)
                
                if selectedHeight != nil {
                    HStack(spacing: 15) {
                        Text("cm")
                            .foregroundColor(.primary.opacity(0.6))
                            .font(.title2)
                        Button(action: {
                            selectedHeight = nil
                            isTextFieldFocused = true
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.trailing, 20)
                }
            }
            Spacer()
            
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
        .safeAreaInset(edge: .bottom) {
            if keyboardHeight > 0 {
                VStack {
                    Button(action: {
                        if let height = selectedHeight, height > 0 {
                            viewModel.baby.height = height
                            Task {
                                await viewModel.saveProfileEdits()
                                dismiss()
                            }
                        }
                    }) {
                        Text("완료")
                            .foregroundColor(isButtonEnabled ? .white : .primary)
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
    return BabyHeightEditView(viewModel: BabyProfileViewModel(baby: sampleBaby))
}

