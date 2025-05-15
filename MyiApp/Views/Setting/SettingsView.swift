//
//  SettingView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = AccountSettingsViewModel.shared
    @State private var showingAlert = false
    @State private var showSnackbar = false
    @State private var snackbarMessage = ""
    
    
    var body: some View {
        NavigationStack {
            Form {
                // 프로필 섹션
                Section(header: Text("사용자 프로필")) {
                    HStack {
                        if let profileImage = viewModel.profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundStyle(.gray)
                        }
                        
                        NavigationLink(destination: AccountSettingsView(viewModel: viewModel)) {
                            Text(viewModel.name.isEmpty ? "이름 없음" : viewModel.name)
                                .padding(.leading, 16)
                                .font(.system(size: 20))
                        }
                        
                        Spacer()
                    }
                }
                Section(header: Text("계정 설정")) {
                    NavigationLink("아기 정보", destination: BabyProfileView())
                    NavigationLink("알림 설정", destination: NotificationSettingsView())
                }
                Section(header: Text("개인 정보")) {
                    NavigationLink("개인정보 처리 방침", destination: PrivacyPolicyView())
                    NavigationLink("이용약관", destination: TermsOfServiceView())
                }
                Section(header: Text("기타")) {
                    NavigationLink("앱 버전", destination: AppVersionView())
                }
                Button("로그아웃", role: .destructive) { showingAlert = true }
            }
            .navigationTitle("설정")
            .alert("로그아웃", isPresented: $showingAlert) {
                Button("취소", role: .cancel) {}
                Button("로그아웃", role: .destructive) {
                    AuthService.shared.signOut()
                }
            } message: {
                Text("로그아웃 됩니다")
            }
            .overlay {
                if showSnackbar {
                    SnackbarView(message: snackbarMessage)
                        .transition(.move(edge: .bottom))
                }
            }
            .onChange(of: viewModel.isProfileSaved) { _, newValue in
                if newValue {
                    snackbarMessage = "프로필이 변경되었습니다"
                    showSnackbar = true
                    Task {
                        try await Task.sleep(for: .seconds(2))
                        withAnimation {
                            showSnackbar = false
                            viewModel.isProfileSaved = false
                        }
                    }
                }
            }
        }
    }
}

// 스낵바 뷰
struct SnackbarView: View {
    let message: String
    
    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
        }
        .animation(.easeInOut, value: UUID())
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
