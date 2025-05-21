//
//  HomeView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel = .init()
    @State private var isPresented = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 10) {
                    babyInfoCard
                    VStack {
                        dateSection
                        gridItems
                        Divider()
                            .padding(.horizontal)
                        timeline
                    }
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .tertiarySystemBackground)))
                }
                .padding()
                
            }
            .background(Color.customBackground)
            .blur(radius: isPresented ? 10 : 0)
            .id(isPresented ? "blurred" : "normal")
            if isPresented { babyFullScreenCard }
        }
    }
    
    private var babyInfoCard: some View {
        HStack {
            Image(.sharkChild)
                .resizable()
                .scaledToFit()
                .padding(8)
                .background(
                    Circle()
                        .fill(Color.sharkPrimaryLight)
                        .stroke(Color.sharksSadowTone, lineWidth: 2)
                )
                .padding(8)
                .padding(.leading)
            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.displayName)
                    .font(.headline)
                HStack(spacing: 0) {
                    Image(.homeCalendar)
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text(viewModel.displayDayCount)
                }
            }
            Spacer()
            Button(action: {isPresented = true}) {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .padding(5)
                    .background(Circle().fill(Color.sharkPrimaryDark))
                    .tint(.white)
            }
            .padding(.trailing)
        }
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .tertiarySystemBackground)))
        .frame(height: 80)
    }
    private var babyFullScreenCard: some View {
        Group {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "square.and.pencil")
                }
                .padding([.top, .trailing])
                Image(.sharkChild)
                    .resizable()
                    .frame(width: 130, height: 130)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color.sharkPrimaryLight)
                            .stroke(Color.sharksSadowTone, lineWidth: 2)
                    )
                VStack {
                    HStack {
                        Text(viewModel.displayName)
                            .font(.title)
                            .bold()
                        Spacer()
                    }
                    HStack {
                        Text(viewModel.displayBirthDate)
                            .font(.body)
                        Spacer()
                    }
                }
                .padding()
                .padding(.leading)
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("성별")
                            .fontWeight(.semibold)
                        Text(viewModel.displayGender)
                            .font(.footnote)
                            .padding(.bottom)
                        Text("성장 단계")
                            .fontWeight(.semibold)
                        Text(viewModel.displayDevelopmentalStage)
                            .font(.footnote)

                    }
                    .padding(.leading)
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("키 / 몸무게")
                            .fontWeight(.semibold)
                        Text(viewModel.displayHeightWeight)
                            .font(.footnote)
                            .padding(.bottom)
                        Text("혈액형")
                            .fontWeight(.semibold)
                        Text(viewModel.displayBloodType)
                            .font(.footnote)
                    }
                    Spacer()
                }
                .padding([.leading, .bottom])
            }
            .frame(width: 300, height: 430)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(uiColor: .tertiarySystemBackground))
            )
        }
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
                .padding(.horizontal)
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
                .padding(.horizontal)
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
        .padding(.vertical, 7)
    }
    private var gridItems: some View {
        let careItems: [GridItemCategory] = [
            .init(name: "수유/이유식", category: .breastfeeding, image: .colorMeal),
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
                Button {
                    switch item.category {
                        case .breastfeeding:
                            if let recentMeal = viewModel.recentMeal {
                                let newRecord = Record(
                                    id: UUID(),
                                    createdAt: Date(),
                                    title: recentMeal.title,
                                    mlAmount: recentMeal.mlAmount,
                                    breastfeedingLeftMinutes: recentMeal.breastfeedingLeftMinutes,
                                    breastfeedingRightMinutes: recentMeal.breastfeedingRightMinutes
                                )
                                viewModel.saveRecord(record: newRecord)
                            } else {
                                viewModel.saveRecord(record: Record(title: .breastfeeding))
                            }
                        case .diaper: return
                            viewModel.saveRecord(record: Record(title: .diaper))
                        case .pee:
                            if let recentPotty = viewModel.recentPotty {
                                let newRecord = Record(
                                    id: UUID(),
                                    createdAt: Date(),
                                    title: recentPotty.title
                                )
                                viewModel.saveRecord(record: newRecord)
                            } else {
                                viewModel.saveRecord(record: Record(title: .pee))
                            }
                        case .sleep: return
                            viewModel.saveRecord(record: Record(title: .sleep))
                        case .heightWeight:
                            if let recentHeightWeight = viewModel.recentHeightWeight {
                                let newRecord = Record(
                                    id: UUID(),
                                    createdAt: Date(),
                                    title: recentHeightWeight.title,
                                    height: recentHeightWeight.height,
                                    weight: recentHeightWeight.weight
                                )
                                viewModel.saveRecord(record: newRecord)
                            } else {
                                viewModel.saveRecord(record: Record(title: .heightWeight))
                            }
                        case .bath: return
                            viewModel.saveRecord(record: Record(title: .bath))
                        case .snack:
                            if let recentSnack = viewModel.recentSnack {
                                let newRecord = Record(
                                    id: UUID(),
                                    createdAt: Date(),
                                    title: recentSnack.title,
                                    content: recentSnack.content
                                )
                                viewModel.saveRecord(record: newRecord)
                            } else {
                                viewModel.saveRecord(record: Record(title: .snack))
                            }
                        case .temperature:
                            if let recentHealth = viewModel.recentHealth {
                                let newRecord = Record(
                                    id: UUID(),
                                    createdAt: Date(),
                                    title: recentHealth.title,
                                    temperature: recentHealth.temperature,
                                    content: recentHealth.content
                                )
                                viewModel.saveRecord(record: newRecord)
                            } else {
                                viewModel.saveRecord(record: Record(title: .temperature, temperature: 36.5))
                            }
                        default:
                            print(item.category)
                    }
                } label: {
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
                    EditRecordView(record: record)
                }
            }
        }
        .padding(.horizontal)
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
