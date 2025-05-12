//
//  TimelineRow.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-12.
//

import SwiftUI

struct TimelineRow: View {
    let record: Record
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(record.createdAt.to24HourTimeString())
                .font(.system(size: 16))
                .frame(width: 50, alignment: .leading)
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 1, height: 20)
                Circle()
                    .fill(Color.pink)
                    .frame(width: 10, height: 10)
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 1, height: 20)
            }

            HStack(spacing: 8) {
                Image(.colorBabyFood)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.pink)
                VStack(alignment: .leading, spacing: 2) {
                    Text(record.title.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("subtitle")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }
}


#Preview {
    TimelineRow(record: Record.mockRecords[0])
}
