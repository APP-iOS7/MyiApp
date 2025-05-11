//
//  SettingView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        Text("설정 화면")
        Button("log out", action: AuthService.shared.signOut)
    }
}

#Preview {
    NavigationStack {
        SettingView()
    }
}
