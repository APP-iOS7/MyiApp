//
//  PottyRecordView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-12.
//

import SwiftUI

struct PottyRecordView: View {
    @State private var selectedType: Int = 0
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 15) {
                Button(action: { selectedType = 0 }) {
                    VStack {
                        Image(.normalPee)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(selectedType == 0 ? Color.sharkPrimary : Color.gray)
                            )
                        Text("소변")
                            .font(.system(size: 14))
                            .tint(selectedType == 0 ? .primary : .secondary)
                    }
                }
                Button(action: { selectedType = 1 }) {
                    VStack {
                        Image(.normalPoop)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(selectedType == 1 ? Color.sharkPrimary : Color.gray)
                            )
                        Text("대변")
                            .font(.system(size: 14))
                            .tint(selectedType == 1 ? .primary : .secondary)
                    }
                }
                Button(action: { selectedType = 2 }) {
                    VStack {
                        Image(.normalPotty)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(selectedType == 2 ? Color.sharkPrimary : Color.gray)
                            )
                        Text("둘다")
                            .font(.system(size: 14))
                            .tint(selectedType == 2 ? .primary : .secondary)
                    }
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
    PottyRecordView()
}
