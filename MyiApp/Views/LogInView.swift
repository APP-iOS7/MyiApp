//
//  LogInView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-07.
//

import SwiftUI

struct LogInView: View {
    @StateObject var viewModel: LogInViewModel = .init()
    
    var body: some View {
        Button("Apple", action: viewModel.appleLogin)
            .buttonStyle(.borderedProminent)
        Button("Google", action: viewModel.googleLogin)
            .buttonStyle(.borderedProminent)
    }
}

#Preview {
    LogInView()
}
