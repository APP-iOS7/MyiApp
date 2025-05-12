//
//  LogInView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-07.
//

import SwiftUI
import GoogleSignInSwift
import AuthenticationServices

struct LogInView: View {
    @StateObject var viewModel: LogInViewModel = .init()
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView()
                .padding()
        }
        VStack {
            Text("My i")
                .font(.largeTitle)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .padding()
            
            Text("쉽고 편한 육아 기록 앱")
                .font(.title2)
                .fontWeight(.medium)
                .padding(.bottom, 30)
            
            Image("sharkToddler")
                .resizable()
                .frame(width: 150, height: 150)
                .padding(.bottom, 80)
            
            
            // Google 로그인 버튼
            Button(action: {
                Task {
                    do {
                        try await viewModel.signInWithGoogle()
                    } catch {
                        viewModel.error = error.localizedDescription
                    }
                }
            }) {
                HStack(alignment: .center) {
                    // Google 로고 (Asset에서 추가한 이미지 사용)
                    Image("google-logo-icon") // Assets.xcassets에 google_logo 추가
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.leading, 50)
                    
                    Text("Sign in with Google")
                        .font(.system(size: 23, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.trailing , 50)
                }
                .padding()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .frame(height: 45)
            .frame(maxWidth: .infinity)
            .padding()
            
            // 애플 로그인 버튼
            SignInWithAppleButton(.signIn) { request in
                viewModel.configureAppleSignInRequest(request)
            } onCompletion: { result in
                Task {
                    do {
                        switch result {
                        case .success(let authorization):
                            try await viewModel.signInWithApple(authorization)
                        case .failure(let error):
                            viewModel.error = error.localizedDescription
                        }
                    } catch {
                        viewModel.error = error.localizedDescription
                    }
                }
            }
            .frame(height: 60)
            .padding(.horizontal)
        }
    }
}

#Preview {
    LogInView()
}
