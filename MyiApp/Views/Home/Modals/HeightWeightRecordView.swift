//
//  HeightWeightRecordView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-12.
//

import SwiftUI

struct HeightWeightRecordView: View {
    @State var height: String = ""
    @State var weight: String = ""
    
    var body: some View {
        VStack(spacing: 10) {
            Button(action: {}) {
                VStack {
                    Image(.colorHeightWeight)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(7)
                        .background(
                            Circle()
                                .fill(Color.sharkPrimary)
                        )
                    Text("키/몸무게")
                        .font(.system(size: 14))
                        .tint(.primary)
                }
            }
            
            VStack(spacing: 9) {
                HStack(alignment: .center) {
                    Text("키")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 60, alignment: .leading)
                    TextField("키를 입력하세요", text: $height)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 20, weight: .medium))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.75, green: 0.85, blue: 1.0), lineWidth: 2)
                        )
                    Text("cm")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: 30)
                }
                
                HStack(alignment: .center) {
                    Text("몸무게")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 60, alignment: .leading)
                    TextField("몸무게를 입력하세요", text: $weight)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 20, weight: .medium))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.75, green: 0.85, blue: 1.0), lineWidth: 2)
                        )
                    Text("kg")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: 30)
                }
            }
        }
    }
}

#Preview {
    HeightWeightRecordView()
} 
