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
        ZStack {
            // 배경색
            Color("launchScreen")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                Text("My i")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .fontDesign(.rounded)
                    .padding()
                
                Text("쉽고 편한 육아 기록 앱")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    
                Spacer()
                
                Image("launchIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 256, height: 256)
                    .padding(.bottom, 75)
                
                Spacer()
                
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
                    HStack {
                        // Google 로고 (Asset에서 추가한 이미지 사용)
                        Image("google-logo-icon") // Assets.xcassets에 google_logo 추가
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .padding(.leading)
                        
                        Text("Sign in with Google")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal)
                        .padding(.vertical, 13)
                }
                .background(Color(UIColor { trait in
                    trait.userInterfaceStyle == .dark ? .systemGray5 : .white
                }))
                .clipShape(RoundedRectangle(cornerRadius: 8))                
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 50)
                
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
                .frame(height: 50)
                .padding(.horizontal, 50)
                
                Spacer()
            }
            
            // 로그인 로딩 화면
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .padding()
                }
                .opacity(viewModel.isLoading ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
            }
        }
    }
}

#Preview {
    LogInView()
}
