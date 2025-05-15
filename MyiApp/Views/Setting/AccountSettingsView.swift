//
//  AccountSettingsView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/13/25.
//

import SwiftUI
import PhotosUI

struct AccountSettingsView: View {
    @ObservedObject private var viewModel = AccountSettingsViewModel.shared
    @State private var showPhotoActionSheet = false
    @State private var showPhotoPicker = false
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: AccountSettingsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("프로필 사진") {
                    if let image = viewModel.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .frame(maxWidth: .infinity, alignment: .center)
                            .onTapGesture {
                                showPhotoActionSheet = true
                            }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .onTapGesture {
                                showPhotoActionSheet = true
                            }
                    }
                    
                    PhotosPicker("사진 변경", selection: $viewModel.selectedPhoto, matching: .images)
                }
                
                Section("사용자") {
                    TextField("이름", text: $viewModel.name)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
            .navigationTitle("사용자 프로필")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("저장") {
                        Task {
                            await viewModel.saveProfile()
                            if viewModel.isProfileSaved {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .task {
                await viewModel.loadProfile()
            }
            .onChange(of: viewModel.selectedPhoto) {
                Task { await viewModel.loadSelectedPhoto() }
            }
            .confirmationDialog("프로필 사진 변경", isPresented: $showPhotoActionSheet, titleVisibility: .visible) {
                Button("앨범에서 선택") {
                    showPhotoPicker = true
                }
                Button("프로필 사진 삭제", role: .destructive) {
                    Task {
                        viewModel.profileImage = nil
                        viewModel.selectedPhoto = nil
                        await viewModel.saveProfile()
                    }
                }
                Button("닫기", role: .cancel) {
                    showPhotoActionSheet = false
                }
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $viewModel.selectedPhoto, matching: .images)
        }
    }
}
