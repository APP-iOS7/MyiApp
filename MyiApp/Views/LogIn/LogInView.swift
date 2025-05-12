//
//  LogInView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-07.
//

import SwiftUI
import GoogleSignInSwift

struct LogInView: View {
    @StateObject var viewModel: LogInViewModel = .init()
    
    var body: some View {
        VStack {
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
            Button {
                Task {
                    do {
                        try await viewModel.signIn()
                    } catch {
                        viewModel.error = error.localizedDescription
                    }
                }
            } label: {
                Text("로그인")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // 회원가입
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                    } catch {
                        viewModel.error = error.localizedDescription
                    }
                }
            }  label: {
                Text("회원가입")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // 구글 로그인 버튼
            GoogleSignInButton(action: {
                Task {
                    do {
                        try await viewModel.signInWithGoogle()
                    } catch {
                        viewModel.error = error.localizedDescription
                    }
                }
            })
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}

#Preview {
    LogInView()
}
