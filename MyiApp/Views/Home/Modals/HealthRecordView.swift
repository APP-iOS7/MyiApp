//
//  HealthRecordView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-13.
//

import SwiftUI

struct HealthRecordView: View {
    @Binding var record: Record
    @State private var isTMPPickerPresented: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 15) {
                Button(
                    action: {
                        record.title = .temperature
                        record.content = nil
                    }) {
                    VStack {
                        Image(.normalTemperature)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(record.title == .temperature ? .sharkPrimary : Color.gray)
                            )
                        Text("체온")
                            .font(.system(size: 14))
                            .tint(record.title == .temperature ? .primary : .secondary)
                    }
                }
                Button(
                    action: {
                        record.title = .medicine
                        record.content = nil
                    }) {
                    VStack {
                        Image(.normalMedicine)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(record.title == .medicine ? .sharkPrimary : Color.gray)
                            )
                        Text("투약")
                            .font(.system(size: 14))
                            .tint(record.title == .medicine ? .primary : .secondary)
                    }
                }
                Button(
                    action: {
                        record.title = .clinic
                        record.content = nil
                    }) {
                    VStack {
                        Image(.normalClinic)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(record.title == .clinic ? .sharkPrimary : Color.gray)
                            )
                        Text("병원")
                            .font(.system(size: 14))
                            .tint(record.title == .clinic ? .primary : .secondary)
                    }
                }
            }
            Group {
                if record.title == .temperature {
                    Button(action: { isTMPPickerPresented = true }) {
                        Text(String(format: "%.1f °C", record.temperature ?? 36.5))
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
                    TextField(
                        "간단한 메모를 남겨 기록하세요",
                        text: Binding(
                            get: { record.content ?? "" },
                            set: { record.content = $0 }
                        ),
                        axis: .vertical
                    )
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
            TMPPickerActionSheet(
                isPresented: $isTMPPickerPresented,
                selectedTemperature: Binding(
                    get: { record.temperature ?? 36.5 },
                    set: { record.temperature = $0 }
                )
            )
        }
    }
}

//#Preview {
//    HealthRecordView()
//}
