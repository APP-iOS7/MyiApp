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
                    NavigationLink(destination: BabyProfileView()) {
                        HStack(spacing: 12) {
                            Image("babyIcon")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("아기 정보")
                        }
                    }
                    NavigationLink(destination: NotificationSettingsView()) {
                        HStack(spacing: 12) {
                            Image("notificationIcon")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("알림 설정")
                        }
                    }
                }
                Section(header: Text("개인 정보")) {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        HStack(spacing: 12) {
                            Image("privacy")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("개인정보 처리 방침")
                        }
                    }
                    NavigationLink(destination: TermsOfServiceView()) {
                        HStack(spacing: 12) {
                            Image("agreementsLicense")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("이용 약관")
                        }
                    }
                }
                Section(header: Text("기타")) {
                    NavigationLink(destination: AppVersionView()) {
                        HStack(spacing: 12) {
                            Image("appVIcon")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("앱 버전")
                        }
                    }
                }
                Button(role: .destructive) {
                    showingAlert = true
                } label: {
                    HStack {
                        Image("logoutIcon")
                            .resizable()
                            .frame(width: 18, height: 18)
                        Text("로그아웃")
                    }
                }
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
