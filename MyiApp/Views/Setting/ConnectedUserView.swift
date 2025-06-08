//
//  ConnectedUserView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 6/8/25.
//

import SwiftUI

struct ConnectedUserView: View {
    let baby: Baby
    
    var body: some View {
        Form {
            ForEach (baby.caregivers, id: \.self) { id in
                Text(id.documentID)
            }
        }
        .navigationTitle(Text("연결 된 사용자"))
    }
}
