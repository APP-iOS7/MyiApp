//
//  BabyProfileView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/13/25.
//

//
//  BabyProfileView.swift
//  MyiApp
//
//  Created by [Your Name] on 5/20/25.
//

import SwiftUI

struct BabyProfileView: View {
    let baby: Baby
    
    var body: some View {
            VStack {
                VStack(spacing: 40) {
                // 아기 사진
                if let photoURL = baby.photoURL, let url = URL(string: photoURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }
                
                // 아기 정보
                    HStack {
                        Text("이름")
                            .foregroundColor(.primary.opacity(0.6))
                            .padding(.leading, 5)
                        
                        Spacer()
                        
                        Text("\(baby.name)")
                            .foregroundColor(.primary.opacity(0.6))
                            .padding(.trailing, 5)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.6))
                    }
                    HStack {
                        Text("생년월일")
                            .foregroundColor(.primary.opacity(0.6))
                            .padding(.leading, 5)
                        Spacer()
                        Text("\(formattedDate(baby.birthDate))")
                            .foregroundColor(.primary.opacity(0.6))
                            .padding(.trailing, 5)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.6))
                    }
                    if let birthTime = baby.birthTime {
                        HStack {
                            Text("출생 시간")
                                .foregroundColor(.primary.opacity(0.6))
                                .padding(.leading, 5)
                            Spacer()
                            Text("\(formattedTime(birthTime))")
                                .foregroundColor(.primary.opacity(0.6))
                                .padding(.trailing, 5)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.primary.opacity(0.6))
                        }
                    }
                    HStack {
                        Text("성별")
                            .foregroundColor(.primary.opacity(0.6))
                            .padding(.leading, 5)
                        Spacer()
                        Text("\(baby.gender == .male ? "남" : "여")")
                            .foregroundColor(.primary.opacity(0.6))
                            .padding(.trailing, 5)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.6))
                    }
                    HStack {
                        Text("키")
                            .foregroundColor(.primary.opacity(0.6))
                            .padding(.leading, 5)
                        Spacer()
                        Text("\(String(format: "%.1f", baby.height)) cm")
                            .foregroundColor(.primary.opacity(0.6))
                            .padding(.trailing, 5)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.6))
                    }
                    HStack {
                        Text("몸무게")
                            .foregroundColor(.primary.opacity(0.6))
                            .padding(.leading, 5)
                        Spacer()
                        Text("\(String(format: "%.1f", baby.weight)) kg")
                            .foregroundColor(.primary.opacity(0.6))
                            .padding(.trailing, 5)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.6))
                    }
                    HStack {
                        Text("혈액형")
                            .foregroundColor(.primary.opacity(0.6))
                            .padding(.leading, 5)
                        Spacer()
                        Text("\(baby.bloodType.rawValue)")
                            .foregroundColor(.primary.opacity(0.6))
                            .padding(.trailing, 5)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.6))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 30)
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                
                Spacer()
            
        }
        .background(Color("customBackgroundColor"))
        .navigationTitle("\(baby.name)님의 정보")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top, 20)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct BabyProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleBaby = Baby(
            name: "민서",
            birthDate: Date(),
            birthTime: Date(),
            gender: .female,
            height: 50.5,
            weight: 3.2,
            bloodType: .A
        )
        BabyProfileView(baby: sampleBaby)
    }
}
