//
//  SnackRecordView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-13.
//

import SwiftUI

struct SnackRecordView: View {
    @Binding var record: Record
    
    var body: some View {
        VStack(spacing: 24) {
            Button(action: {}) {
                VStack {
                    Image(.normalSnack)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(7)
                        .background(
                            Circle()
                                .fill(Color.sharkPrimary)
                        )
                    Text("간식")
                        .font(.system(size: 14))
                        .tint(.primary)
                }
            }
            
            TextField(
                "간식을 입력해 주세요",
                text: Binding(
                    get: { record.content ?? "" },
                    set: { record.content = $0 }
                ),
                axis: .vertical
            )
                .padding()
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.75, green: 0.85, blue: 1.0), lineWidth: 2)
                        .frame(height: 60)
                )
        }
        .padding(.vertical)
    }
}

//#Preview {
//    SnackRecordView()
//}
