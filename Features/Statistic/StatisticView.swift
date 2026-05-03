import ComposableArchitecture
import DesignSystem
import Domain
import Shared
import SwiftUI

public struct StatisticView: View {
    @Bindable var store: StoreOf<StatisticFeature>

    public init(store: StoreOf<StatisticFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ScrollView {
                VStack(spacing: Spacing.m) {
                    ScreenTitle("기록 분석") {
                        HStack(spacing: Spacing.m) {
                            Button("성장 차트", systemImage: "chart.xyaxis.line") { store.send(.growthChartButtonTapped) }
                            Button("PDF 공유", systemImage: "square.and.arrow.up") { store.send(.shareButtonTapped) }
                        }
                        .labelStyle(.iconOnly)
                    }
                    overviewCard
                    statisticCards
                }
                .padding(Spacing.m)
            }
            .scrollIndicators(.hidden)
            .background(Color.Semantic.screenBackground.ignoresSafeArea())
            .task { await store.send(.task).finish() }
            .sheet(isPresented: $store.isShowingPDFPreview) {
                pdfPreviewSheet
            }
        } destination: { store in
            switch store.case {
            case let .growthChart(store):
                GrowthChartView(store: store)
            case let .snackDetail(store):
                SnackDetailView(store: store)
            case let .bathDetail(store):
                BathDetailView(store: store)
            case let .pottyDetail(store):
                PottyDetailView(store: store)
            case let .sleepDetail(store):
                SleepDetailView(store: store)
            case let .foodDetail(store):
                FoodDetailView(store: store)
            }
        }
    }
}

// MARK: - Overview

extension StatisticView {
    private var overviewCard: some View {
        SectionCard(spacing: Spacing.m) {
            Picker("모드 선택", selection: $store.mode) {
                ForEach(StatisticFeature.Mode.allCases, id: \.self) { mode in
                    Text(mode.rawValue)
                }
            }
            .pickerStyle(.segmented)

            DateNavigator(
                selectedDate: $store.selectedDate,
                step: .days(store.mode.stepDays),
                labelText: dateLabel(for:)
            )

            CategoryFilterGrid(selectedCategories: $store.selectedCategories)

            switch store.mode {
            case .daily:
                DailyChartView(
                    baby: store.baby,
                    records: store.records,
                    selectedDate: store.selectedDate,
                    selectedCategories: store.selectedCategories
                )

            case .weekly:
                WeeklyChartView(
                    baby: store.baby,
                    records: store.records,
                    selectedDate: store.selectedDate,
                    selectedCategories: store.selectedCategories
                )
            }

            Text(store.babySummaryText)
                .font(.subheadline)
                .foregroundColor(.Semantic.secondaryText)
                .frame(maxWidth: .infinity)
        }
    }

    private func dateLabel(for date: Date) -> String {
        switch store.mode {
        case .daily:
            date.shortDateWithDayLabel()
        case .weekly:
            date.weekRangeLabel()
        }
    }
}

// MARK: - Statistic Cards

extension StatisticView {
    private var statisticCards: some View {
        VStack(spacing: Spacing.m) {
            NavigationLink(state: StatisticFeature.Path.State.foodDetail(
                FoodDetailFeature.State(
                    baby: store.baby,
                    selectedDate: store.selectedDate,
                    mode: DetailMode(from: store.mode)
                )
            )) {
                StatisticCard(
                    title: "수유/이유식 기록 분석",
                    image: Image(Asset.Records.Color.meal),
                    tintColor: .Semantic.feeding,
                    metrics: [
                        countMetric(title: "횟수", current: store.feedingCount, previous: store.previousFeedingCount),
                        valueMetric(title: "용량", current: store.totalMl, previous: store.previousTotalMl, unit: "ml"),
                        minutesMetric(
                            title: "시간",
                            current: store.breastfeedingMinutes,
                            previous: store.previousBreastfeedingMinutes
                        )
                    ],
                    showsChevron: true
                )
            }
            .buttonStyle(NoHighlightButtonStyle())

            NavigationLink(state: StatisticFeature.Path.State.pottyDetail(
                PottyDetailFeature.State(
                    baby: store.baby,
                    selectedDate: store.selectedDate,
                    mode: DetailMode(from: store.mode)
                )
            )) {
                StatisticCard(
                    title: "배변 기록 분석",
                    image: Image(Asset.Records.Color.potty),
                    tintColor: .Semantic.potty,
                    metrics: [
                        countMetric(title: "소변", current: store.potty.pee, previous: store.previousPotty.pee),
                        countMetric(title: "대변", current: store.potty.poop, previous: store.previousPotty.poop)
                    ],
                    showsChevron: true
                )
            }
            .buttonStyle(NoHighlightButtonStyle())

            NavigationLink(state: StatisticFeature.Path.State.sleepDetail(
                SleepDetailFeature.State(
                    baby: store.baby,
                    selectedDate: store.selectedDate,
                    mode: DetailMode(from: store.mode)
                )
            )) {
                StatisticCard(
                    title: "수면 기록 분석",
                    image: Image(Asset.Records.Color.sleep),
                    tintColor: .Semantic.sleep,
                    metrics: [
                        countMetric(title: "횟수", current: store.sleepCount, previous: store.previousSleepCount),
                        minutesMetric(title: "시간", current: store.sleepMinutes, previous: store.previousSleepMinutes)
                    ],
                    showsChevron: true
                )
            }
            .buttonStyle(NoHighlightButtonStyle())

            NavigationLink(state: StatisticFeature.Path.State.bathDetail(
                BathDetailFeature.State(
                    baby: store.baby,
                    selectedDate: store.selectedDate,
                    mode: DetailMode(from: store.mode)
                )
            )) {
                StatisticCard(
                    title: "목욕 기록 분석",
                    image: Image(Asset.Records.Color.bath),
                    tintColor: .Semantic.bath,
                    metrics: [
                        countMetric(title: "횟수", current: store.bathCount, previous: store.previousBathCount)
                    ],
                    showsChevron: true
                )
            }
            .buttonStyle(NoHighlightButtonStyle())

            NavigationLink(state: StatisticFeature.Path.State.snackDetail(
                SnackDetailFeature.State(
                    baby: store.baby,
                    selectedDate: store.selectedDate,
                    mode: DetailMode(from: store.mode)
                )
            )) {
                StatisticCard(
                    title: "간식 기록 분석",
                    image: Image(Asset.Records.Color.snack),
                    tintColor: .Semantic.snack,
                    metrics: [
                        countMetric(title: "횟수", current: store.snackCount, previous: store.previousSnackCount)
                    ],
                    showsChevron: true
                )
            }
            .buttonStyle(NoHighlightButtonStyle())
        }
    }

    private var previousLabel: String {
        switch store.mode {
        case .daily: "어제"
        case .weekly: "지난주"
        }
    }

    private func countMetric(title: String, current: Int, previous: Int) -> StatisticMetric {
        valueMetric(title: title, current: current, previous: previous, unit: "회")
    }

    private func valueMetric(title: String, current: Int, previous: Int, unit: String) -> StatisticMetric {
        StatisticMetric(
            currentText: "\(title) \(current)\(unit)",
            previousText: "\(previousLabel) \(previous)\(unit)",
            current: current,
            previous: previous
        )
    }

    private func minutesMetric(title: String, current: Int, previous: Int) -> StatisticMetric {
        StatisticMetric(
            currentText: "\(title) \(DurationFormatter.hourMinute(fromMinutes: current))",
            previousText: "\(previousLabel) \(DurationFormatter.hourMinute(fromMinutes: previous))",
            current: current,
            previous: previous
        )
    }
}

// MARK: - PDF Preview

extension StatisticView {
    @ViewBuilder
    var pdfPreviewSheet: some View {
        PDFPreviewSheet(
            baby: store.baby,
            records: store.records,
            date: store.selectedDate,
            onDismiss: { store.isShowingPDFPreview = false }
        )
    }
}

private struct PDFPreviewSheet: View {
    let baby: Baby
    let records: [CareRecord]
    let date: Date
    let onDismiss: () -> Void

    @State private var image: UIImage?
    @State private var fileName: String = ""
    @State private var sharing: ShareableURL?
    @FocusState private var isFileNameFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding(Spacing.m)
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 400)
                    }
                }

                VStack(spacing: Spacing.m) {
                    UnderlinedTextField(placeholder: "파일 이름", text: $fileName)
                        .focused($isFileNameFocused)

                    Button("PDF로 저장 및 공유", action: shareTapped)
                        .buttonStyle(.primary)
                        .disabled(image == nil || fileName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(Spacing.m)
                .background(Color.Semantic.screenBackground)
            }
            .background(Color.Semantic.screenBackground.ignoresSafeArea())
            .navigationTitle("PDF 미리보기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소", action: onDismiss)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("완료") { isFileNameFocused = false }
                }
            }
            .task {
                fileName = defaultFileName()
                renderImage()
            }
            .sheet(item: $sharing) { wrapped in
                ActivityView(url: wrapped.url)
            }
        }
    }

    private func shareTapped() {
        guard let url = generatePDF() else { return }
        sharing = ShareableURL(url: url)
    }

    @MainActor
    private func renderImage() {
        let renderer = ImageRenderer(content: StatisticPDFContent(baby: baby, records: records, date: date))
        renderer.scale = UIScreen.main.scale
        image = renderer.uiImage
    }

    @MainActor
    private func generatePDF() -> URL? {
        let trimmed = fileName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        let renderer = ImageRenderer(content: StatisticPDFContent(baby: baby, records: records, date: date))
        renderer.scale = UIScreen.main.scale

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(trimmed).pdf")
        var success = false
        renderer.render { size, draw in
            var mediaBox = CGRect(origin: .zero, size: size)
            guard let pdf = CGContext(url as CFURL, mediaBox: &mediaBox, nil) else { return }
            pdf.beginPDFPage(nil)
            draw(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
            success = true
        }
        return success ? url : nil
    }

    private func defaultFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return "\(formatter.string(from: date))_기록 분석"
    }
}

private struct ShareableURL: Identifiable {
    let url: URL
    var id: URL { url }
}

private struct ActivityView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}

private func previewBaby() -> Baby {
    Baby(
        id: UUID(),
        name: "꼬미",
        birthDate: Calendar.current.date(byAdding: .day, value: -100, to: Date())!,
        gender: .female,
        bloodType: .a,
        mainCaregiverID: "user-123"
    )
}

#Preview("기록 있음") {
    StatisticView(
        store: Store(
            initialState: StatisticFeature.State(
                baby: previewBaby(),
                records: CareRecord.mocks
            )
        ) {
            StatisticFeature()
        }
    )
}

#Preview("기록 없음") {
    StatisticView(
        store: Store(
            initialState: StatisticFeature.State(
                baby: previewBaby(),
                records: []
            )
        ) {
            StatisticFeature()
        }
    )
}
