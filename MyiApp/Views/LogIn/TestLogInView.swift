//
//  TestLogInView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-09.
//

import SwiftUI

struct TestLogInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isShowingAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            // 로고 또는 앱 이름
            Text("MyiApp")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 30)
            
            // 이메일 입력 필드
            TextField("이메일", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // 비밀번호 입력 필드
            SecureField("비밀번호", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // 로그인 버튼
            Button(action: {
                // 로그인 로직 구현
                isShowingAlert = true
            }) {
                Text("로그인")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // 회원가입 링크
            Button(action: {
                // 로그인 로직 구현
                isShowingAlert = true
            }) {
                Text("로그인")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .alert("로그인", isPresented: $isShowingAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("로그인 기능이 구현되었습니다.")
        }
    }
}

#Preview {
    TestLogInView()
}
