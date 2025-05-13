//
//  EqualizerView.swift
//  MyiApp
//
//  Created by 조영민 on 5/12/25.
//

import SwiftUI

struct EqualizerView: View {
    let numberOfBars = 8
    @State private var heights: [CGFloat] = Array(repeating: 10, count: 8)
    
    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            ForEach(0..<numberOfBars, id: \.self) { index in
                Capsule()
                    .fill(Color.blue)
                    .frame(width: 8, height: heights[index])
            }
        }
        .frame(height: 100)
        .onAppear {
            startAnimation()
        }
    }

    func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                heights = (0..<numberOfBars).map { index in
                    
                    let center = CGFloat(numberOfBars - 1) / 2
                    let distance = abs(CGFloat(index) - center)
                    let falloff = cos(distance * .pi / CGFloat(numberOfBars))
                    let base = 20 + 20 * falloff
                    return CGFloat.random(in: base...(base + 60))
                }
            }
        }
    }
}

#Preview {
    CryAnalysisProcessingView()
}
