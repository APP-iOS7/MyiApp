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
    
    
}


#Preview {
    TestLogInView()
}
