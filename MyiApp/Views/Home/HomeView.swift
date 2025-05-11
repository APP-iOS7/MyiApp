//
//  HomeView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import SwiftUI

struct HomeView: View {
    
    @State var selectedDate = Date()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                babyInfoCard
                dateSection
                gridItems
                Divider()
                timeline
            }
            .padding()
        }
    }
    
    private var babyInfoCard: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(.colorBabyFood) // 임시 캐릭터
                .resizable()
                .frame(width: 90, height: 90)
                .padding(8)
                .background(
                    Circle()
                        .fill(Color.sharkPrimaryLight)
                        .stroke(Color.sharksSadowTone, lineWidth: 2)
                )
                .padding(.trailing)
            VStack(alignment: .leading, spacing: 4) {
                Text("김죠스")
                    .font(.system(size: 10))
                Text("여아")
                    .font(.system(size: 10))
                Text("2025.05.07")
                    .font(.system(size: 10))
                Text("1개월 9일")
                    .font(.system(size: 10))
                Text("39일")
                    .font(.system(size: 10))
            }
            Spacer()
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 24).fill(
                Color(
                    red: 246/255,
                    green: 244/255,
                    blue: 253/255,
                    opacity: 1
                )
            )
        )
    }
    
    private var dateSection: some View {
        ZStack {
            HStack(spacing: 6) {
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.left")
                        .font(.body)
                }
                .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "calendar")
                Text(selectedDate.formattedKoreanDateString())
                    .fontWeight(.medium)
                    .font(.body)
                Spacer()
                Button(action: {
                    // 하루 전으로 이동
                    selectedDate = Calendar.current.date(byAdding: .day, value: +1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.right")
                        .font(.body)
                }
                .foregroundStyle(.primary)
            }
            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .frame(width: 180, height: 30)
            .blendMode(.destinationOver)
        }
    }
    
    private var gridItems: some View {
        struct CareCategory: Equatable {
            let name: String
            let image: UIImage
        }
        let careItems: [CareCategory] = [
            .init(name: "수유/이유식", image: .colorBabyFood),
            .init(name: "기저귀", image: .colorBabyFood),
            .init(name: "배변", image: .colorBabyFood),
            .init(name: "수면", image: .colorBabyFood),
            .init(name: "키/몸무게", image: .colorBabyFood),
            .init(name: "목욕", image: .colorBabyFood),
            .init(name: "간식", image: .colorBabyFood),
            .init(name: "건강 관리", image: .colorBabyFood)
        ]
        let columns = Array(repeating: GridItem(.flexible()), count: 4)
        return LazyVGrid(columns: columns) {
            ForEach(careItems, id: \.name) { item in
                Button(action: {print(item)}) {
                    VStack(spacing: 0) {
                        Image(uiImage: item.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 70, height: 70)
                            )
                        Text(item.name)
                            .font(.system(size: 12))
                    }
                }
                
            }
        }
        .padding(.horizontal)
    }
    
    private var timeline: some View {
        VStack {
            
        }
    }
}

struct TimelineRow: View {
    let record: Record
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // 1. 시간
            Text(record.createdAt.formattedKoreanDateString())
                .font(.caption)
                .frame(width: 50, alignment: .leading)
            
            // 2. 타임라인 (위-원-아래)
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
            
            // 3. 아이콘 + 텍스트 그룹
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
    HomeView()
}
#Preview {
    TimelineRow(record: Record.mockRecords[0])
}
