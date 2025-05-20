//
//  StatisticView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import SwiftUI

struct StatisticView: View {
    
    @ObservedObject var caregiverManager = CaregiverManager.shared
    
    struct CareCategory: Equatable {
        let name: String
        let image: UIImage
    }
    
    var baby: Baby {
        caregiverManager.selectedBaby ?? Baby(name: "", birthDate: Date(), birthTime: Date(), gender: .male, height: 0, weight: 0, bloodType: .A)
    }
    
    var birthDate: Date {
        baby.birthDate
    }
    
    var records: [Record] {
        CaregiverManager.shared.records
    }
    
    @State private var selectedDate = Date()
    @State private var selectedMode = "일"
    let modes = ["일", "주"]
    
    private var formattedDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        if selectedMode == "일" {
            formatter.dateFormat = "MM월 dd일"
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
            mainScrollView
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
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 20) {
            IconItem(title: "밥", image: .colorMeal)
            IconItem(title: "기저귀", image: .colorDiaper)
            IconItem(title: "배변", image: .colorPotty)
            IconItem(title: "수면", image: .colorSleep)
            IconItem(title: "목욕", image: .colorBath)
            IconItem(title: "간식", image: .colorSnack)
        }
    }
    var mainScrollView: some View {
        ScrollView {
            VStack(spacing: 20) {
                heightWeightButton
                
                VStack(spacing: 10) {
                    toggleMode
                    .padding(.vertical, 10)
                    
                    dateMove
                        .padding(.vertical, 10)
                    
                    
                    
                    iconGrid
                        .padding(.bottom, 20)
                    
                    chartView
                    babyInfo
                }
                .padding()
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(12)
                
                statisticList
            }
            .padding()
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
    private var heightWeightButton: some View {
        NavigationLink(destination: GrowthChartView(baby: baby)) {
                HStack {
                    Text("성장곡선")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(12)
            }
    }
    private var chartView: some View {
        Group {
            if selectedMode == "주" {
                WeeklyChartView(baby: baby,  selectedDate: selectedDate)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                
            } else if selectedMode == "일" {
                Spacer()
                DailyChartView(baby: baby,  selectedDate: selectedDate)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                Spacer()
                
            }
        }
        
    }
    private var babyInfo: some View {
        let genderText = baby.gender == .female ? "여" : "남"
        let ageComponents = Calendar.current.dateComponents([.year, .month, .day], from: baby.birthDate, to: Date())
        
        let months = Calendar.current.dateComponents([.month, .day], from: baby.birthDate, to: Date()).month ?? 0
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.date(byAdding: .month, value: months, to: baby.birthDate) ?? Date(), to: Date()).day ?? 0
        
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
                WeeklyStatisticCardListView(baby: baby,  selectedDate: selectedDate)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if selectedMode == "일" {
                DailyStatisticCardListView(baby: baby,  selectedDate: selectedDate)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        
    }
    
    private var gridItems: some View {
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
}

struct IconItem: View {
    let title: String
    let image: UIImage
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color("customBackgroundColor"))
                    .frame(width: 40, height: 40)
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
    }
}
