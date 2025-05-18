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
            let newRecord = Record(title: category.category)
            AddRecordView(record: newRecord)
                .presentationDetents([.medium])
        }
    }
    
    private var babyInfoCard: some View {
        Group {
            if viewModel.isFlipped == false {
                VStack {
                    HStack(alignment: .center, spacing: 16) {
                        Image(.sharkChild)
                            .resizable()
                            .scaledToFit()
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.sharkPrimaryLight)
                                    .stroke(Color.sharksSadowTone, lineWidth: 2)
                            )
                            .padding(.trailing)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.displayName)
                                .font(.system(size: 10))
                            Text(viewModel.displayGender)
                                .font(.system(size: 10))
                            Text(viewModel.displayBirthDate)
                                .font(.system(size: 10))
                            Text(viewModel.displayMonthDay)
                                .font(.system(size: 10))
                            Text(viewModel.displayDayCount)
                                .font(.system(size: 10))
                        }
                        Spacer()
                        VStack() {
                            Button(action: { viewModel.isFlipped = true }) {
                                Image(systemName: "arrow.uturn.backward.circle.fill")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(.sharkPrimaryDark)
                            }
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .padding(16)
                
            } else {
                VStack {
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("성장단계")
                                .font(.headline)
                            Text("기수")
                                .font(.footnote)
                                .padding(.bottom, 6)
                            Text("이름")
                                .font(.headline)
                            Text("김죠")
                                .font(.footnote)
                                .padding(.bottom, 6)
                            Text("생년월일")
                                .font(.headline)
                            Text("2.25.05.04")
                                .font(.footnote)
                        }
                        
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("성별")
                                .font(.headline)
                            Text("여아")
                                .font(.footnote)
                                .padding(.bottom, 6)
                            Text("혈액형")
                                .font(.headline)
                            Text("A형")
                                .font(.footnote)
                                .padding(.bottom, 6)
                            Text("키")
                                .font(.headline)
                            Text("30")
                                .font(.footnote)
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("몸무게")
                                .font(.headline)
                            Text("4")
                                .font(.footnote)
                        }
                        VStack(alignment: .trailing) {
                            Button(action: { viewModel.isFlipped.toggle() }) {
                                Image(systemName: "arrow.uturn.backward.circle.fill")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(.sharkPrimaryDark)
                            }
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .padding(16)
            }
        }
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.sharkCardBackground))
        .frame(height: 180)
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
        let careItems: [GridItemCategory] = [
            .init(name: "수유/이유식", category: .breastfeeding, image: .colorBabyFood),
            .init(name: "기저귀", category: .diaper, image: .colorDiaper),
            .init(name: "배변", category: .pee, image: .colorPotty),
            .init(name: "수면", category: .sleep, image: .colorSleep),
            .init(name: "키/몸무게", category: .heightWeight, image: .colorHeightWeight),
            .init(name: "목욕", category: .bath, image: .colorBath),
            .init(name: "간식", category: .snack, image: .colorSnack),
            .init(name: "건강 관리", category: .temperature, image: .colorCheckList)
        ]
        let columns = Array(repeating: GridItem(.flexible()), count: 4)
        return LazyVGrid(columns: columns) {
            ForEach(careItems, id: \.name) { item in
                Button(action: { viewModel.selectedCategory = item } ) {
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
            if viewModel.filteredRecords.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("이 날짜에 기록이 없습니다")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 50)
            } else {
                ForEach(viewModel.filteredRecords) { record in
                    TimelineRow(record: record)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.recordToEdit = record
                        }
                }
                .sheet(item: $viewModel.recordToEdit) { record in
                    AddRecordView(record: record)
                        .presentationDetents([.medium])
                }
            }
        }
    }
}

struct GridItemCategory: Identifiable {
    let id: UUID = UUID()
    let name: String
    let category: TitleCategory
    let image: UIImage
}

#Preview {
    HomeView()
}
