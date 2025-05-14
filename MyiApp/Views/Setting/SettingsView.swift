//
//  SettingView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import SwiftUI

struct SettingsView: View {
    @State private var profileImage: Image = Image(systemName: "person.circle.fill")
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // 프로필 섹션
                Section(header: Text("사용자 프로필")) {
                    HStack {
                        profileImage
                            .resizable()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                            .foregroundColor(Color("sharkPrimaryColor"))
                            .font(.headline)
                        
                        NavigationLink(destination: AccountSettingsView()){
                            Text("김죠스 엄마")
                        }
                        Spacer()
                    }
                }
                Section(header: Text("계정 설정")) {
                    NavigationLink(destination: BabyProfileView()) {
                        Text("아기 정보")
                    }
                    NavigationLink(destination: NotificationSettingsView()) {
                        Text("알림 설정")
                    }
                }
                Section(header: Text("개인 정보")) {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Text("개인정보 처리 방침")
                    }
                    NavigationLink(destination: TermsOfServiceView()) {
                        Text("이용약관")
                    }
                }
                Section(header: Text("기타")) {
                    NavigationLink(destination: AppVersionView()) {
                        Text("앱 버전")
                    }
                }
                Button("로그아웃", action: { showingAlert = true })
                    .foregroundStyle(Color.red)
            }
            .navigationTitle(Text("설정"))
            .alert("로그아웃", isPresented: $showingAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    AuthService.shared.signOut()
                }
            } message: {
                Text("정말 로그아웃 하시겠습니까?")
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
