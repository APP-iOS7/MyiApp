//
//  HomeView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import SwiftUI
import Kingfisher
/*
 헤더 사이즈 줄이기.
 */

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel = .init()
    @State private var isPresented = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                SafeAreaPaddingView()
                    .frame(height: getTopSafeAreaHeight())
                    .background(Color.customBackground)
                ScrollView {
                    VStack(spacing: 15) {
                        //                        header
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
            }
            .background(Color.customBackground)
            .blur(radius: isPresented ? 10 : 0)
            .id(isPresented ? "blurred" : "normal")
            if isPresented { babyFullScreenCard }
        }
    }
    
    
    private var header: some View {
        HStack {
            Menu {
                ForEach(viewModel.caregiverManager.babies) { baby in
                    Button {
                        viewModel.babyChangeButtonDidTap(baby: baby)
                    } label: {
                        Text(baby.name)
                            .foregroundStyle(.primary)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(viewModel.baby?.name ?? "아기 선택")
                        .font(.headline)
                    Image(systemName: "chevron.down")
                        .font(.subheadline)
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.15))
                )
            }
            
            Spacer()
            
            Button {
                // TODO: 알림 상황일 때.
            } label: {
                Image(systemName: "bell.fill")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(10)
            }
        }
        .padding(.horizontal)
    }
    private var babyInfoCard: some View {
        HStack {
            KFImage(URL(string: viewModel.baby?.photoURL ?? ""))
                .placeholder({
                    ProgressView()
                })
                .onFailureImage(viewModel.displaySharkImage)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(.circle)
                .background(
                    Circle()
                        .fill(Color.sharkPrimaryLight)
                        .stroke(Color.sharksSadowTone, lineWidth: 2)
                )
                .overlay(
                    Circle()
                        .stroke(Color.sharksSadowTone, lineWidth: 2)
                )
                .padding(10)
                .padding(.leading, 10)
            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.displayName)
                    .font(.headline)
                    .padding(.leading, 4)
                HStack(spacing: 0) {
                    Image(.homeCalendar)
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text(viewModel.displayDayCount)
                }
            }
            Spacer()
            Button(action: {isPresented = true}) {
                Image(systemName: "list.bullet.rectangle.portrait.fill")
                    .resizable()
                    .frame(width: 15, height: 20)
                    .padding(10)
                    .background(Circle().fill(Color.sharkPrimaryDark))
                    .tint(.white)
            }
            .padding(.trailing)
        }
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .tertiarySystemBackground)))
        .frame(height: 95)
    }
    
    private var babyFullScreenCard: some View {
        Group {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
            VStack {
                HStack {
                    Spacer()
                    NavigationLink(destination: BabyProfileView(baby: viewModel.baby ?? Baby(name: "", birthDate: Date(), gender: .female, height: 0, weight: 0, bloodType: .O))) {
                        Image(systemName: "square.and.pencil")
                            .tint(Color.primary)
                    }
                }
                .padding([.top, .trailing])
                
                KFImage(URL(string: viewModel.baby?.photoURL ?? ""))
                    .placeholder({
                        ProgressView()
                    })
                    .onFailureImage(viewModel.displaySharkImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 130, height: 130)
                    .clipShape(.circle)
                    .background(
                        Circle()
                            .fill(Color.sharkPrimaryLight)
                            .stroke(Color.sharksSadowTone, lineWidth: 2)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.sharksSadowTone, lineWidth: 2)
                    )
                    .padding(10)
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
                            .font(.title2)
                            .fontWeight(.medium)
                        Text(viewModel.displayGender)
                            .font(.body)
                            .padding(.bottom)
                        Text("성장 단계")
                            .font(.title2)
                            .fontWeight(.medium)
                        Text(viewModel.displayDevelopmentalStage)
                            .font(.body)
                        
                    }
                    .padding(.leading)
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("키 / 몸무게")
                            .font(.title2)
                            .fontWeight(.medium)
                        Text(viewModel.displayHeightWeight)
                            .font(.body)
                            .padding(.bottom)
                        Text("혈액형")
                            .font(.title2)
                            .fontWeight(.medium)
                        Text(viewModel.displayBloodType)
                            .font(.body)
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
                    viewModel.gridItemDidTap(title: item.category)
                } label: {
                    VStack(spacing: 0) {
                        Image(uiImage: item.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.customBackground)
                                    .frame(width: 70, height: 70)
                            )
                        Text(item.name)
                            .font(.system(size: 12))
                            .foregroundStyle(.foreground)
                    }
                    .frame(width: 90, height: 100)
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
                List {
                    ForEach(viewModel.filteredRecords.indices, id: \.self) { index in
                        let record = viewModel.filteredRecords[index]
                        TimelineRow(
                            record: record,
                            index: index,
                            totalCount: viewModel.filteredRecords.count
                        )
                        .padding(.horizontal)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.recordToEdit = record
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
//                                                viewModel.deleteRecord(record)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .frame(height: CGFloat(viewModel.filteredRecords.count * 60))
                .sheet(item: $viewModel.recordToEdit) { record in
                    let detents: Set<PresentationDetent> = {
                        switch record.title {
                            case .babyFood, .formula, .breastfeeding, .pumpedMilk, .clinic, .temperature, .medicine:
                                [.large]
                            default:
                                [.medium]
                        }
                    }()
                    EditRecordView(record: record)
                        .presentationDetents(detents)
                }
            }
        }
        .padding(.horizontal)
    }
    private func getTopSafeAreaHeight() -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return 0
        }
        
        let height = window.safeAreaInsets.top
        return height * 0.1
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
