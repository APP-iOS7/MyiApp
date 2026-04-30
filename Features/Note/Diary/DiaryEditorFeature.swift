import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct DiaryEditorFeature {
    @ObservableState
    public struct State: Equatable {
        public var title: String
        public var description: String
        public var date: Date
        public var photoCount: Int

        public init(
            date: Date = Date(),
            title: String = "",
            description: String = "",
            photoCount: Int = 0
        ) {
            self.date = date
            self.title = title
            self.description = description
            self.photoCount = photoCount
        }

        public var canSave: Bool { !title.isEmpty }

        public var navigationTitle: String {
            Calendar.current.isDateInToday(date) ? "오늘의 일지" : "지난 일지"
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case addPhotoButtonTapped
        case removePhotoButtonTapped
        case cancelButtonTapped
        case saveButtonTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case saved(Note)
            case cancelled
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addPhotoButtonTapped:
                state.photoCount += 1
                return .none

            case .removePhotoButtonTapped:
                state.photoCount = max(0, state.photoCount - 1)
                return .none

            case .cancelButtonTapped:
                return .send(.delegate(.cancelled))

            case .saveButtonTapped:
                // TODO: photoCount → 실제 업로드된 이미지 URL 배열로 교체 (현재는 placeholder)
                let placeholder = URL(string: "https://picsum.photos/200")
                let imageURLs = placeholder.map { Array(repeating: $0, count: state.photoCount) } ?? []
                let note = Note(
                    kind: .diary,
                    title: state.title,
                    description: state.description,
                    date: state.date,
                    imageURLs: imageURLs
                )
                return .send(.delegate(.saved(note)))

            case .binding, .delegate:
                return .none
            }
        }
    }
}
