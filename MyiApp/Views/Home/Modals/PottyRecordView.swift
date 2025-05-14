//
//  PottyRecordView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-12.
//

import SwiftUI

struct PottyRecordView: View {
    @Binding var record: Record
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 15) {
                Button(action: { record.title = .pee }) {
                    VStack {
                        Image(.normalPee)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(record.title == .pee ? Color.sharkPrimary : Color.gray)
                            )
                        Text("소변")
                            .font(.system(size: 14))
                            .tint(record.title == .pee ? .primary : .secondary)
                    }
                }
                Button(action: { record.title = .poop }) {
                    VStack {
                        Image(.normalPoop)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(record.title == .poop ? Color.sharkPrimary : Color.gray)
                            )
                        Text("대변")
                            .font(.system(size: 14))
                            .tint(record.title == .poop ? .primary : .secondary)
                    }
                }
                Button(action: { record.title = .pottyAll }) {
                    VStack {
                        Image(.normalPotty)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(record.title == .pottyAll ? Color.sharkPrimary : Color.gray)
                            )
                        Text("둘다")
                            .font(.system(size: 14))
                            .tint(record.title == .pottyAll ? .primary : .secondary)
                    }
                }
            }
            Button(action: {}) {
                Text("1회")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
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

//#Preview {
//
//    PottyRecordView(record: $)
//}
