//
//  NewSettingsView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/19/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = AccountEditViewModel.shared
    @StateObject var caregiverManager = CaregiverManager.shared
    @State private var showingAlert = false
    @State private var showingDeleteAlert = false
    @State private var topExpanded: Bool = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    // 앱 버전 표시
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        //        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return "\(version)"
    }
    
    // 사용자 표시 이름
    private var displayName: String {
        if let name = caregiverManager.userName {
            return name
        } else {
            return caregiverManager.email ?? ""
        }
    }
    
    // 로그인 제공자 표시
    private var providerText: String {
        guard let provider = caregiverManager.provider else {
            return ""
        }
        switch provider {
        case "apple.com":
            return "Apple로 로그인"
        case "google.com":
            return "Google로 로그인"
        default:
            return ""
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SafeAreaPaddingView()
                .frame(height: getTopSafeAreaHeight())
                .background(Color.customBackground)
            ScrollView {
                VStack(spacing: 15) {
                    NavigationLink(destination: AccountEditView(viewModel: viewModel)) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                            VStack(alignment: .leading) {
                                Text(displayName)
                                    .font(.headline)
                                    .foregroundColor(.primary.opacity(0.8))
                                Text(providerText)
                                    .font(.subheadline)
                                    .foregroundColor(.primary.opacity(0.6))
                            }
                            .padding(.leading, 10)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.primary.opacity(0.8))
                                .font(.system(size: 12))
                                .padding(.trailing, 8)
                        }
                        .padding()
                        .padding(.horizontal, 15)
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("개인 설정")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding()
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                        
                        DisclosureGroup(isExpanded: $topExpanded) {
                            VStack(alignment: .leading, spacing: 10) {
                                if caregiverManager.babies.isEmpty {
                                    Text("아기 정보가 없습니다.")
                                        .foregroundColor(.primary.opacity(0.6))
                                        .padding()
                                } else {
                                    ForEach(caregiverManager.babies, id: \.id) { baby in
                                        NavigationLink(destination: BabyProfileView(baby: baby)) {
                                            Text(baby.name)
                                                .foregroundColor(.primary.opacity(0.6))
                                                .padding()
                                                .padding(.leading, 44)
                                            
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 10)
                        } label: {
                            HStack {
                                Image("babyInfoIcon")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("아이 정보")
                                    .foregroundColor(.primary.opacity(0.6))
                                    .padding(.leading, 5)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .rotationEffect(.degrees(topExpanded ? 90 : 0))
                                    .animation(.easeInOut(duration: 0.2), value: topExpanded)
                                    .foregroundColor(.primary.opacity(0.6))
                                    .font(.system(size: 12))
                            }
                            .contentShape(Rectangle())
                            .padding(.leading, 16)
                            .padding(.trailing, 6)
                            .padding(.bottom, 20)
                        }
                        .tint(.clear)
                        
                        //                    NavigationLink(destination: NotificationSettingsView()) {
                        //                        HStack {
                        //                            Image ("notificationIcon")
                        //                                .resizable()
                        //                                .frame(width: 30, height: 30)
                        //                            Text("알림 설정")
                        //                                .foregroundColor(.primary.opacity(0.6))
                        //                                .padding(.leading, 5)
                        //                            Spacer()
                        //                            Image(systemName: "chevron.right")
                        //                                .foregroundColor(.primary.opacity(0.6))
                        //                                .font(.system(size: 12))
                        //                                .padding(.trailing, 8)
                        //                        }
                        //                        .padding()
                        //                        .padding(.bottom, 10)
                        //                    }
                    }
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("개인 정보")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding()
                            .padding(.top, 10)
                        
                        NavigationLink(destination: PrivacyPolicyView()) {
                            HStack {
                                Image ("privacyIcon")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("개인 정보 처리 방침")
                                    .foregroundColor(.primary.opacity(0.6))
                                    .padding(.leading, 5)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.primary.opacity(0.6))
                                    .font(.system(size: 12))
                                    .padding(.trailing, 8)
                            }
                            .padding()
                            .padding(.top, 5)
                            .padding(.bottom, 5)
                        }
                        
                        NavigationLink(destination: TermsOfServiceView()) {
                            HStack {
                                Image ("agreementIcon")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("이용 약관")
                                    .foregroundColor(.primary.opacity(0.6))
                                    .padding(.leading, 5)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.primary.opacity(0.6))
                                    .font(.system(size: 12))
                                    .padding(.trailing, 8)
                            }
                            .padding()
                            .padding(.bottom, 10)
                        }
                    }
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("기타")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding()
                            .padding(.top, 10)
                        
                        HStack {
                            Image ("appVIcon")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text("앱 버전")
                                .foregroundColor(.primary.opacity(0.6))
                                .padding(.leading, 5)
                            Spacer()
                            Text("\(appVersion)")
                                .foregroundColor(.primary.opacity(0.6))
                                .padding(.trailing, 8)
                        }
                        .padding()
                        .padding(.bottom, 10)
                    }
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    VStack(spacing: -10) {
                        Button(role: .destructive) {
                            showingAlert = true
                        } label: {
                            Text("로그아웃")
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.bottom)
                        
                        Spacer()
                        
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            Text("회원탈퇴")
                                .font(.caption2)
                                .foregroundColor(.blue)
                                .padding(.vertical, 20)
                                .underline()
                        }
                    }
                }
            }
            .background(Color("customBackgroundColor"))
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("로그아웃"),
                    message: Text("정말 로그아웃하시겠습니까?"),
                    primaryButton: .destructive(Text("로그아웃")) {
                        AuthService.shared.signOut()
                    },
                    secondaryButton: .cancel(Text("취소"))
                )
            }
            .alert("회원탈퇴", isPresented: $showingDeleteAlert) {
                Button("삭제", role: .destructive) {
                    Task {
                        defer { isLoading = false }
                        isLoading = true
                        do {
                            try await AuthService.shared.deleteAccount()
                            print("Account deletion successful")
                        } catch {
                            errorMessage = "회원탈퇴 실패: \(error.localizedDescription)"
                            showingErrorAlert = true
                            print("Account deletion failed: \(error.localizedDescription)")
                        }
                        isLoading = false
                    }
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("계정을 삭제하려면 재인증이 필요합니다. 계속하시겠습니까?")
            }
            .alert("오류", isPresented: $showingErrorAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .overlay(
                isLoading ? ProgressView().progressViewStyle(CircularProgressViewStyle()) : nil
            )
            .task {
                await caregiverManager.loadCaregiverInfo()
            }
        }
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
