//
//  OnBordingItems.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-07.
//

import Foundation
import SwiftUICore

struct OnBordingItem: Identifiable {
    var id: String = UUID().uuidString
    var image: String
    var title: String
    
    var scale: CGFloat = 1
    var anchor: UnitPoint = .center
    var offset: CGFloat = 0
    var rotation: CGFloat = 0
    var zIndex: CGFloat = 0
}

let onBordingItems: [OnBordingItem] = [
    OnBordingItem(image: "figure.walk.circle.fill", title: "이건 ", scale: 1),
    OnBordingItem(image: "figure.run.circle.fill", title: "인트로 넣는건.", scale: 0.6, anchor: .topLeading, offset: -70, rotation: 30),
    OnBordingItem(image: "figure.badminton.circle.fill", title: "어떤가요?", scale: 0.5, anchor: .topLeading, offset: -60, rotation: -50),
    OnBordingItem(image: "figure.climbing.circle.fill", title: "전에 그냥 따라 쳐본", scale: 0.4, anchor: .topLeading, offset: -50, rotation: 110),
    OnBordingItem(image: "figure.cooldown.circle.fill", title: "코드입니다만", scale: 0.35, anchor: .topLeading, offset: -50, rotation: 200),
]
