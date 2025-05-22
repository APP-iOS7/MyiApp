//
//  NewSettingsView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/19/25.
//

import SwiftUI

struct SettingsView: View {
//    @StateObject private var viewModel = AccountSettingsViewModel.shared
    @StateObject var caregiverManager = CaregiverManager.shared
    @State private var showingAlert = false
    @State private var topExpanded: Bool = false
    
    // 앱 버전 표시
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return "\(version).\(build)"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                        VStack(alignment: .leading) {
                            Text("이민서")
                                .font(.headline)
                                .foregroundColor(.primary.opacity(0.8))
                            Text("")
                        }
                        .padding(.leading, 10)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.trailing, 18)
                    }
                    .padding()
                    .padding(.horizontal, 15)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("개인 설정")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding()
                            .padding(.top, 10)
                        
                        DisclosureGroup(isExpanded: $topExpanded) {
                            VStack(alignment: .leading, spacing: 10) {
                                if caregiverManager.babies.isEmpty {
                                    Text("아기 정보가 없습니다.")
                                        .foregroundColor(.primary.opacity(0.6))
                                        .padding()
                                } else {
                                    ForEach(caregiverManager.babies, id: \.id) { baby in
                                        NavigationLink(destination: NewBabyProfileView(baby: baby)) {
                                            Text(baby.name)
                                                .foregroundColor(.primary.opacity(0.6))
                                                .padding()
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
                            }
                            .contentShape(Rectangle())
                            .padding()
                            .padding(.top, 5)
                            .padding(.bottom, 5)
                        }
                        .accentColor(.clear)
                        
                        NavigationLink(destination: NotificationSettingsView()) {
                            HStack {
                                Image ("notificationIcon")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("알림 설정")
                                    .foregroundColor(.primary.opacity(0.6))
                                    .padding(.leading, 5)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.primary.opacity(0.6))
                                    .padding(.trailing, 18)
                            }
                            .padding()
                            .padding(.bottom, 10)
                        }
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
                                    .padding(.trailing, 18)
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
                                    .padding(.trailing, 18)
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
                                .padding(.trailing, 18)
                        }
                        .padding()
                        .padding(.bottom, 10)
                    }
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    VStack {
                        Button(role: .destructive) {
                            showingAlert = true
                        } label: {
                            Text("로그아웃")
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                    }
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
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
            .task {
                await caregiverManager.loadCaregiverInfo()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
