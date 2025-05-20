//
//  NewSettingsView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/19/25.
//

import SwiftUI

struct NewSettingsView: View {
    @StateObject private var viewModel = AccountSettingsViewModel.shared
    @State private var showingAlert = false
    
    // 앱 버전 표시
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return "\(version).\(build)"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
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
                    }
                    .padding()
                    .padding(.horizontal, 15)
                    
                    // 개인 설정 섹션
                    VStack(alignment: .leading, spacing: 0) {
                        Text("개인 설정")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding()
                            .padding(.top, 15)
                        
                        NavigationLink(destination: BabyProfileView()) {
                            HStack {
                                Image ("appVIcon")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("아이 정보")
                                    .foregroundColor(.primary.opacity(0.6))
                                    .padding(.leading, 5)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.primary.opacity(0.6))
                            }
                            .padding()
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                        }
                        
                        NavigationLink(destination: NotificationSettingsView()) {
                            HStack {
                                Image ("appVIcon")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("알림 설정")
                                    .foregroundColor(.primary.opacity(0.6))
                                    .padding(.leading, 5)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.primary.opacity(0.6))
                            }
                            .padding()
                            .padding(.bottom, 15)
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
                            .padding(.top, 15)
                        
                        NavigationLink(destination: PrivacyPolicyView()) {
                            HStack {
                                Image ("appVIcon")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("개인 정보 처리 방침")
                                    .foregroundColor(.primary.opacity(0.6))
                                    .padding(.leading, 5)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.primary.opacity(0.6))
                            }
                            .padding()
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                        }
                        
                        NavigationLink(destination: TermsOfServiceView()) {
                            HStack {
                                Image ("appVIcon")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("이용 약관")
                                    .foregroundColor(.primary.opacity(0.6))
                                    .padding(.leading, 5)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.primary.opacity(0.6))
                            }
                            .padding()
                            .padding(.bottom, 15)
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
                            .padding(.top, 15)
                        
                        HStack {
                            Image ("appVIcon")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("앱 버전")
                                .foregroundColor(.primary.opacity(0.6))
                                .padding(.leading, 5)
                            Spacer()
                            Text("\(appVersion)")
                                .foregroundColor(.primary.opacity(0.6))
                        }
                        .padding()
                        .padding(.bottom, 15)
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
                    },
                    secondaryButton: .cancel(Text("취소"))
                )
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NewSettingsView()
    }
}
