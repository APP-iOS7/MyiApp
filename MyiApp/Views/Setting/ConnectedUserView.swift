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
                            }) {
                                Image(systemName: "person.fill.xmark")
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
