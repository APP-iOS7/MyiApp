//
//  StatisticView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import SwiftUI

struct StatisticView: View {
    @ObservedObject var viewModel = StatisticViewModel()
    @State private var selectedCategories: [String] = ["수유\n이유식", "기저귀", "배변", "수면", "목욕", "간식"]
    
    struct CareCategory: Equatable {
        let name: String
        let image: UIImage
    }
    
    var baby: Baby {
        viewModel.baby
    }
    
    var birthDate: Date {
        viewModel.baby.birthDate
    }
    
    var records: [Record] {
        viewModel.records
    }
    
    @State private var selectedDate = Date()
    @State private var selectedMode = "일"
    let modes = ["일", "주"]
    
    private var formattedDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        if selectedMode == "일" {
            if Calendar.current.isDateInToday(selectedDate) {
                formatter.dateFormat = "MM월 dd일 '(오늘)'"
            } else {
                formatter.dateFormat = "MM월 dd일 (E)"
            }
            return formatter.string(from: selectedDate)
        } else {
            let calendar = Calendar(identifier: .gregorian)
            var mondayStartCalendar = calendar
            mondayStartCalendar.firstWeekday = 2
            
            let startOfWeek = mondayStartCalendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
            let endOfWeek = mondayStartCalendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? selectedDate
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM월 dd일"
            formatter.locale = Locale(identifier: "ko_KR")
            
            let startString = formatter.string(from: startOfWeek)
            let endString = formatter.string(from: endOfWeek)
            
            return "\(startString) ~ \(endString)"
            
        }
    }
    
    var body: some View {
        ZStack {
            Color("customBackgroundColor")
                .ignoresSafeArea()
            VStack(spacing: 0) {
                SafeAreaPaddingView()
                    .frame(height: getTopSafeAreaHeight())
                ScrollView {
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("통계")
                                .font(.title)
                                .bold()
                            Spacer()
                            NavigationLink(destination: GrowthChartView(baby: baby, records: records)) {
                                Image(systemName: "chart.xyaxis.line")
                                    .foregroundColor(.primary)
                                    .font(.title2)
                            }
                            
                        }
                        .padding(.horizontal)
                        .padding(.trailing, 7)
                        VStack(spacing: 10) {
                            toggleMode
                                .padding(.vertical, 10)
                            
                            dateMove
                                .padding(.vertical, 10)
                            
                            
                            
                            iconGrid
                                .padding(.bottom, 20)
                            
                            chartView
                                .padding(.bottom, 20)
                            babyInfo
                        }
                        .padding()
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(12)
                        VStack(spacing: 15) {
                            
                            statisticList
                        }
                    }
                    .padding()
                }
            }
            
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    let horizontalAmount = value.translation.width
                    if horizontalAmount < -50 && selectedMode == "일" {
                        selectedMode = "주"
                    } else if horizontalAmount > 50 && selectedMode == "주" {
                        selectedMode = "일"
                    }
                }
        )
    }
    var iconGrid: some View {
        let categories = [
            ("수유\n이유식", UIImage.colorMeal, Color("food")),
            ("기저귀", UIImage.colorDiaper, Color("diaper")),
            ("배변", UIImage.colorPotty, Color("potty")),
            ("수면", UIImage.colorSleep, Color("sleep")),
            ("목욕", UIImage.colorBath, Color("bath")),
            ("간식", UIImage.colorSnack, Color("snack"))
        ]
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
            ForEach(categories, id: \.0) { category in
                let isSelected = selectedCategories.contains(category.0)
                
                Button(action: {
                    if isSelected {
                        selectedCategories.removeAll { $0 == category.0 }
                    } else {
                        selectedCategories.append(category.0)
                    }
                }) {
                    IconItem(
                        title: category.0,
                        image: category.1,
                        isSelected: isSelected,
                        selectedColor: category.2
                    )
                }
            }
        }
    }
    private var toggleMode: some View {
        Picker("모드 선택", selection: $selectedMode) {
            ForEach(modes, id: \.self) { mode in
                Text(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding()
        .frame(width: 200, height: 50)
    }
    private func getTopSafeAreaHeight() -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return 0
        }
        
        let height = window.safeAreaInsets.top
        return height * 0.1
    }
    private var dateMove: some View {
        ZStack {
            HStack {
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: selectedMode == "일" ? -1 : -7, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: "calendar")
                    .foregroundColor(.primary)
                
                Text(formattedDateString)
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: selectedMode == "일" ? 1 : 7, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary)
                }
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
    private var chartView: some View {
        Group {
            if selectedMode == "주" {
                WeeklyChartView(baby: baby, records: records,  selectedDate: selectedDate, selectedCategories: selectedCategories)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.trailing)
                    .padding(.vertical, 20)
                
            } else if selectedMode == "일" {
                GeometryReader { geometry in
                    DailyChartView(baby: baby, records: records,  selectedDate: selectedDate, selectedCategories: selectedCategories)
                        .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9)
                        .padding(.horizontal)
                        .padding(.vertical, 20)
                }
                .frame(height: UIScreen.main.bounds.width * 0.9)
                
            }
        }
        
    }
    private var babyInfo: some View {
        let genderText = baby.gender == .female ? "여" : "남"
        let ageComponents = Calendar.current.dateComponents([.year, .month, .day], from: baby.birthDate, to: Date())
        
        let months = Calendar.current.dateComponents([.month, .day], from: baby.birthDate, to: Date()).month ?? 0
        let days = (Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.date(byAdding: .month, value: months, to: baby.birthDate) ?? Date(),
            to: Date()
        ).day ?? 0) + 1
        
        let ageInYears = (ageComponents.year ?? 0) + 1
        let fullAge = getFullAge(from: baby.birthDate)
        
        return Text("\(genderText) · \(months)개월 \(days)일, \(ageInYears)살(만 \(fullAge)세)")
            .font(.subheadline)
            .foregroundColor(.gray)
            .padding(.horizontal)
    }
    private func getFullAge(from birthDate: Date) -> Int {
        let now = Date()
        let calendar = Calendar.current
        
        let birthYear = calendar.component(.year, from: birthDate)
        let birthMonth = calendar.component(.month, from: birthDate)
        let birthDay = calendar.component(.day, from: birthDate)
        
        let nowYear = calendar.component(.year, from: now)
        let nowMonth = calendar.component(.month, from: now)
        let nowDay = calendar.component(.day, from: now)
        
        var age = nowYear - birthYear
        
        if (nowMonth < birthMonth) || (nowMonth == birthMonth && nowDay < birthDay) {
            age -= 1
        }
        
        return age
    }
    
    private var statisticList: some View {
        Group {
            if selectedMode == "주" {
                WeeklyStatisticCardListView(baby: baby, records: records,  selectedDate: selectedDate)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if selectedMode == "일" {
                DailyStatisticCardListView(baby: baby, records: records,  selectedDate: selectedDate)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        
    }
}

struct IconItem: View {
    let title: String
    let image: UIImage
    let isSelected: Bool
    let selectedColor: Color
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill((Color(.tertiarySystemBackground)))
                    .frame(width: 30, height: 30)
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.leading, 10)
        .frame(height: 60)
        .background(isSelected ? selectedColor.opacity(0.5) : Color.gray.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? selectedColor : Color(.tertiarySystemBackground), lineWidth: 2)
        )
        
    }
}
extension TitleCategory {
    var displayName: String {
        switch self {
        case .formula, .babyFood, .pumpedMilk, .breastfeeding:
            return "수유\n이유식"
        case .diaper:
            return "기저귀"
        case .poop, .pee, .pottyAll:
            return "배변"
        case .sleep:
            return "수면"
        case .bath:
            return "목욕"
        case .snack:
            return "간식"
        default:
            return ""
        }
    }
}
