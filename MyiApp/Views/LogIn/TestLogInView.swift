//
//  TestLogInView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-09.
//

import SwiftUI

struct TestLogInView: View {
    @StateObject var viewModel: TestLogInViewModel = .init()
    
    var body: some View {
        VStack(spacing: 20) {
            // 로고 또는 앱 이름
            Text("MyiApp")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 30)
            
            // 이메일 입력 필드
            TextField("이메일", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // 비밀번호 입력 필드
            SecureField("비밀번호", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // 로그인 버튼
            Button { viewModel.signIn() } label: {
                Text("로그인")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // 회원가입
            Button { viewModel.signUp() } label: {
                Text("회원가입")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button { viewModel.signInWithGoogle() } label: {
                Text("구글 로그인")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            if let errorMessage = viewModel.error {
                Text(errorMessage)
            }
                
        }
        .padding(.horizontal)
    }
}


#Preview {
    TestLogInView()
}
