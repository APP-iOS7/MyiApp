//
//  DiaperRecordView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-12.
//

import SwiftUI

struct DiaperRecordView: View {
    
    var body: some View {
        VStack(spacing: 24) {
            Button(action: {}) {
                VStack {
                    Image(.normalDiaper)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(7)
                        .background(
                            Circle()
                                .fill(Color.sharkPrimary)
                        )
                    Text("기저귀 교체")
                        .font(.system(size: 14))
                        .tint(.primary)
                }
            }
            
            Button(action: {}) {
                Text("1회")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.75, green: 0.85, blue: 1.0), lineWidth: 2)
                            .frame(height: 60)
                    )
            }
            .padding(.vertical)
        }
        .padding(.vertical)
    }
}

#Preview {
    DiaperRecordView()
}
