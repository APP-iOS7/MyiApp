//
//  CustomNavigationHeader.swift
//  MyiApp
//
//  Created by Saebyeok Jang on 5/29/25.
//

import SwiftUI

struct CustomNavigationHeader: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 0) {
            SafeAreaPaddingView()
                .frame(height: getTopSafeAreaHeight())
                .background(Color("customBackgroundColor"))
            
            HStack {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            .background(Color("customBackgroundColor"))
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

extension View {
    func customNavigationHeader(title: String, showDivider: Bool = true) -> some View {
        VStack(spacing: 0) {
            CustomNavigationHeader(title: title)
            self
        }
    }
}
