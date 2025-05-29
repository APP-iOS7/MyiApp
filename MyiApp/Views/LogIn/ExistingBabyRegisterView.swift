//
//  RegisterExistingBabyView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/28/25.
//

import SwiftUI

struct ExistingBabyRegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("공유 코드를 입력하세요")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary.opacity(0.8))
                .padding()
                .padding(.top, 10)
        }
        
        Spacer()
    }
}

#Preview {
    ExistingBabyRegisterView()
}
