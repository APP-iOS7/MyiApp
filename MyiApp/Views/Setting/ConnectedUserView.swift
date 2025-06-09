//
//  ConnectedUserView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 6/8/25.
//

import SwiftUI
import FirebaseFirestore

struct ConnectedUserView: View {
    let baby: Baby
    @State private var caregivers: [Caregiver] = []
    @State private var selectedCaregiver: Caregiver?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Form {
            if caregivers.isEmpty {
                ProgressView()
            } else {
                ForEach(caregivers, id: \.id) { caregiver in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(caregiver.name ?? "이름 없음")
                                .font(.headline)
                            if let email = caregiver.email {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        if caregiver.id == baby.mainCaregiver {
                            Text("(메인 보호자)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        } else if CaregiverManager.shared.caregiver?.id == baby.mainCaregiver {
                            Button(action: {
                                selectedCaregiver = caregiver
                                showingDeleteAlert = true
                            }) {
                                Image(systemName: "person.fill.badge.minus")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("연결된 사용자")
        .onAppear {
            loadCaregivers()
        }
        .alert("보호자 삭제", isPresented: $showingDeleteAlert) {
                    Button("삭제", role: .destructive) {
                        if let caregiver = selectedCaregiver {
                            Task {
                                    try await CaregiverManager.shared.removeCaregiver(baby: baby, caregiverId: caregiver.id)
                                    caregivers.removeAll { $0.id == caregiver.id }
                                    selectedCaregiver = nil
                            }
                        }
                    }
                    Button("취소", role: .cancel) {
                        selectedCaregiver = nil
                    }
                } message: {
                    Text("'\(selectedCaregiver?.name ?? "알 수 없음")' 님을 보호자 목록에서 삭제하시겠습니까?")
                }
    }
    
    private func loadCaregivers() {
        for ref in baby.caregivers {
            ref.getDocument { document, error in
                if let document = document,
                   document.exists,
                   let caregiver = try? document.data(as: Caregiver.self) {
                    DispatchQueue.main.async {
                        caregivers.append(caregiver)
                    }
                }
            }
        }
    }
}
