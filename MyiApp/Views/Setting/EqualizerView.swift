//
//  EqualizerView.swift
//  MyiApp
//
//  Created by 조영민 on 5/12/25.
//

import SwiftUI

struct EqualizerView: View {
    var levels: [Float] // 파형 막내 하나의 상대적인 높이
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(levels.indices, id: \.self) { i in
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: 6, height: CGFloat(levels[i]) * 100) // levels[i] 값을 100과 곱해서 비율로 설정
            }
        }
        .animation(.easeOut(duration: 0.1), value: levels)
    }
}

#Preview {
    EqualizerView(levels: (0..<12).map { _ in Float.random(in: 0.3...1.0) })
}
