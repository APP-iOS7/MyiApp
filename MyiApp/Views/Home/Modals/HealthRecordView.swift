//
//  HealthRecordView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-13.
//

import SwiftUI

struct HealthRecordView: View {
    @State private var selectedType: Int = 0
    @State private var text: String = ""
    @State private var temperature: Double = 36.5
    @State private var isTMPPickerPresented: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 15) {
                Button(action: { selectedType = 0 }) {
                    VStack {
                        Image(.normalTemperature)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(selectedType == 0 ? .sharkPrimary : Color.gray)
                            )
                        Text("체온")
                            .font(.system(size: 14))
                            .tint(selectedType == 0 ? .primary : .secondary)
                    }
                }
                Button(action: { selectedType = 1 }) {
                    VStack {
                        Image(.normalMedicine)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(selectedType == 1 ? .sharkPrimary : Color.gray)
                            )
                        Text("투약")
                            .font(.system(size: 14))
                            .tint(selectedType == 1 ? .primary : .secondary)
                    }
                }
                Button(action: { selectedType = 2 }) {
                    VStack {
                        Image(.normalClinic)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(selectedType == 2 ? .sharkPrimary : Color.gray)
                            )
                        Text("병원")
                            .font(.system(size: 14))
                            .tint(selectedType == 2 ? .primary : .secondary)
                    }
                }
            }
            Group {
                if selectedType == 0 {
                    Button(action: { isTMPPickerPresented = true }) {
                        Text(String(format: "%.1f °C", temperature))
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
                } else {
                    TextField("간단한 메모를 남겨 기록하세요", text: $text, axis: .vertical)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.75, green: 0.85, blue: 1.0), lineWidth: 2)
                                .frame(height: 60)
                        )
                }
            }
            .frame(height: 60)
        }
        .padding(.vertical)
        .background() {
            TMPPickerActionSheet(isPresented: $isTMPPickerPresented, selectedTemperature: $temperature)
        }
    }
}

#Preview {
    HealthRecordView()
}
