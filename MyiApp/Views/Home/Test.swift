//
//  Test.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-21.
//

import SwiftUI

import SwiftUI

struct MenuExampleView: View {
    @State private var selectedOption: String = "선택하세요"

    var body: some View {
        VStack(spacing: 20) {
            Text("선택된 옵션: \(selectedOption)")
                .font(.headline)

            Menu("옵션 선택") {
                Button("사과 🍎") { selectedOption = "사과" }
                Button("바나나 🍌") { selectedOption = "바나나" }
                Button("수박 🍉") { selectedOption = "수박" }
            }
            .font(.title2)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
    }
}

#Preview {
    MenuExampleView()
}
