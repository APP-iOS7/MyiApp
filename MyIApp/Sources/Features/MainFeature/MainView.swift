import ComposableArchitecture
import SwiftUI

public struct MainView: View {
    public let store: StoreOf<MainFeature>

    public init(store: StoreOf<MainFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                babyInfoCard

                VStack(spacing: 0) {
                    dateSection
                    gridItems

                    Divider()
                        .padding(.horizontal)

                    timeline
                }
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.tertiarySystemBackground)))
            }
            .padding()
        }
        .background(Color.customBackground.ignoresSafeArea())
        .onAppear { store.send(.onAppear) }
        .navigationTitle("")
        .navigationBarHidden(true)
    }

    // MARK: - Subviews

    private var babyInfoCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // Baby Profile Image
                AsyncImage(url: URL(string: store.baby.photoURL ?? "")) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    sharkPlaceholderImage
                }
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .background(Circle().fill(Color.sharkPrimaryLight))
                .overlay(Circle().stroke(Color.sharksSadowTone, lineWidth: 2))
                .padding(.trailing, 16)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(store.baby.name)
                            .foregroundColor(.primary)
                            .font(.title3)
                            .bold()

                        Image(uiImage: store.baby.gender == .male ? MyiAppAsset.ActivityIcons.icActivityBabyMale
                            .image : MyiAppAsset.ActivityIcons.icActivityBabyFemale.image)
                            .resizable()
                            .frame(width: 20, height: 20)

                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundStyle(Color.primary)
                    }

                    HStack {
                        Text(developmentalStage(for: store.baby.birthDate))
                            .font(.subheadline)
                            .foregroundStyle(Color.button)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("태어난지")
                            .fontWeight(.semibold)
                        Text("\(dayCount(since: store.baby.birthDate))일")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.button)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Divider()
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

            HStack {
                infoItem(title: "생년월일", value: formattedBirthDate(store.baby.birthDate))
                Spacer()
                infoItem(
                    title: "키/몸무게",
                    value: "\(String(format: "%.1f", store.baby.height))cm / \(String(format: "%.1f", store.baby.weight))kg"
                )
                Spacer()
                infoItem(title: "혈액형", value: "\(store.baby.bloodType.rawValue.uppercased()) 형")
            }
            .padding([.bottom, .horizontal])
        }
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(UIColor.tertiarySystemBackground)))
    }

    private var dateSection: some View {
        HStack {
            Button(action: { store.send(.previousDayButtonTapped) }) {
                Image(systemName: "chevron.left")
            }
            .foregroundStyle(.primary)
            .padding(.horizontal)

            Spacer()

            Image(systemName: "calendar")
            Text(store.selectedDate.formattedKoreanDateString())
                .fontWeight(.medium)

            Spacer()

            Button(action: { store.send(.nextDayButtonTapped) }) {
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(.primary)
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
    }

    private var gridItems: some View {
        let careItems: [(String, TitleCategory, UIImage)] = [
            ("수유/이유식", .breastfeeding, MyiAppAsset.ActivityIcons.icActivityColorMeal.image),
            ("배변", .pee, MyiAppAsset.ActivityIcons.icActivityColorPotty.image),
            ("수면", .sleep, MyiAppAsset.ActivityIcons.icActivityColorSleep.image),
            ("키/몸무게", .heightWeight, MyiAppAsset.ActivityIcons.icActivityColorHeightWeight.image),
            ("목욕", .bath, MyiAppAsset.ActivityIcons.icActivityColorBath.image),
            ("간식", .snack, MyiAppAsset.ActivityIcons.icActivityColorSnack.image),
            ("건강 관리", .temperature, MyiAppAsset.ActivityIcons.icActivityNormalClinic.image),
            ("메모", .clinic, MyiAppAsset.ActivityIcons.icActivityColorChecklist.image)
        ]

        let columns = Array(repeating: GridItem(.flexible()), count: 4)

        return LazyVGrid(columns: columns, spacing: 15) {
            ForEach(careItems, id: \.0) { item in
                VStack(spacing: 8) {
                    Image(uiImage: item.2)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.customBackground)
                                .frame(width: 64, height: 64)
                        )
                    Text(item.0)
                        .font(.footnote)
                        .foregroundStyle(.foreground)
                }
                .frame(height: 90)
            }
        }
        .padding([.horizontal, .bottom])
    }

    private var timeline: some View {
        VStack(spacing: 0) {
            if store.records.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("이 날짜에 기록이 없습니다")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 50)
            } else {
                ForEach(store.records.indices, id: \.self) { index in
                    TimelineRow(
                        record: store.records[index],
                        index: index,
                        totalCount: store.records.count
                    )
                }
                .padding(.bottom, 16)
            }
        }
    }

    // MARK: - Helpers

    private func infoItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
    }

    private var sharkPlaceholderImage: some View {
        Image(uiImage: MyiAppAsset.StatusIcons.icStatusSharkNewborn.image)
            .resizable()
            .scaledToFit()
            .padding(10)
    }

    private func developmentalStage(for birthDate: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.month, .day], from: birthDate, to: now)
        let months = components.month ?? 0
        let days = components.day ?? 0

        if months == 0, days < 30 {
            return "신생아기"
        } else if months < 12 {
            return "영아기"
        } else if months < 36 {
            return "유아기"
        } else {
            return "아동기"
        }
    }

    private func dayCount(since birthDate: Date) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: birthDate)
        let end = calendar.startOfDay(for: Date())
        let days = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        return days + 1
    }

    private func formattedBirthDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}
