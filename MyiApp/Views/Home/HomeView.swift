//
//  HomeView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel = .init()

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
        .sheet(item: $viewModel.selectedCategory) { category in
            AddRecordView(category: category)
                .presentationDetents([.medium])
        }
    }
    
    private var babyInfoCard: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(.sharkChild)
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
            VStack(alignment: .leading) {
                Button(action: {}) {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .padding(8)
                        .foregroundStyle(.sharkPrimaryDark)
                }
                Spacer()
            }
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.sharkCardBackground))
    }
    private var dateSection: some View {
        ZStack {
            HStack(spacing: 6) {
                Button(action: {
                    viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: viewModel.selectedDate) ?? viewModel.selectedDate
                }) {
                    Image(systemName: "chevron.left")
                        .font(.body)
                }
                .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "calendar")
                Text(viewModel.selectedDate.formattedKoreanDateString())
                    .fontWeight(.medium)
                    .font(.body)
                Spacer()
                Button(action: {
                    viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: +1, to: viewModel.selectedDate) ?? viewModel.selectedDate
                }) {
                    Image(systemName: "chevron.right")
                        .font(.body)
                }
                .foregroundStyle(.primary)
            }
            DatePicker(
                "",
                selection: $viewModel.selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .frame(width: 180, height: 30)
            .blendMode(.destinationOver)
        }
        .padding()
    }
    private var gridItems: some View {
        let careItems: [CareCategory] = [
            .init(name: "수유/이유식", image: .colorBabyFood),
            .init(name: "기저귀", image: .colorDiaper),
            .init(name: "배변", image: .colorPotty),
            .init(name: "수면", image: .colorSleep),
            .init(name: "키/몸무게", image: .colorHeightWeight),
            .init(name: "목욕", image: .colorBath),
            .init(name: "간식", image: .colorSnack),
            .init(name: "건강 관리", image: .colorCheckList)
        ]
        let columns = Array(repeating: GridItem(.flexible()), count: 4)
        return LazyVGrid(columns: columns) {
            ForEach(careItems, id: \.name) { item in
                Button(action: {
                    viewModel.selectedCategory = item
                }) {
                    VStack(spacing: 0) {
                        Image(uiImage: item.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.sharkCardBackground)
                                    .frame(width: 70, height: 70)
                            )
                        Text(item.name)
                            .font(.system(size: 12))
                            .foregroundStyle(.foreground)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding([.horizontal, .bottom])
    }
    private var timeline: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.records) { record in
                TimelineRow(record: record)
            }
        }
    }
}

struct CareCategory: Identifiable {
    let id: UUID = UUID()
    let name: String
    let image: UIImage
}

#Preview {
    HomeView()
}
