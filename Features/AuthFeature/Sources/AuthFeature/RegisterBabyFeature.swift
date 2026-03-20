import ComposableArchitecture
import Domain
import Foundation
import SwiftUI

@Reducer
public struct RegisterBabyFeature {
    @ObservableState
    public struct State: Equatable {
        public var name: String = ""
        public var birthDate: Date = Date()
        public var gender: Gender = .unknown
        public var isLoading: Bool = false
        public var error: String?

        public init() {}
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case registerButtonTapped
        case registrationResponse(Result<Void, CaregiverError>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case registered
        }
    }

    @Dependency(\.caregiverClient) var caregiverClient
    @Dependency(\.authClient) var authClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .registerButtonTapped:
                guard !state.name.isEmpty else {
                    state.error = "아기 이름을 입력해주세요."
                    return .none
                }
                state.isLoading = true
                state.error = nil

                let babyName = state.name
                let babyBirthDate = state.birthDate
                let babyGender = state.gender

                return .run { send in
                    do {
                        guard let user = try await self.authClient.currentUser() else {
                            await send(.registrationResponse(.failure(.unauthorized)))
                            return
                        }

                        let baby = Baby(
                            id: UUID().uuidString,
                            name: babyName,
                            birthDate: babyBirthDate,
                            gender: babyGender
                        )

                        try await self.caregiverClient.registerBaby(user.id, baby)
                        await send(.registrationResponse(.success(())))
                    } catch {
                        let caregiverError = (error as? CaregiverError) ?? .internalError(error)
                        await send(.registrationResponse(.failure(caregiverError)))
                    }
                }

            case .registrationResponse(.success):
                state.isLoading = false
                return .send(.delegate(.registered))

            case let .registrationResponse(.failure(error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

public struct RegisterBabyView: View {
    @Bindable var store: StoreOf<RegisterBabyFeature>

    public init(store: StoreOf<RegisterBabyFeature>) {
        self.store = store
    }

    public var body: some View {
        Form {
            Section(header: Text("아기 정보")) {
                TextField("이름", text: $store.name)
                DatePicker("생년월일", selection: $store.birthDate, displayedComponents: .date)
                Picker("성별", selection: $store.gender) {
                    Text("선택 안함").tag(Gender.unknown)
                    Text("남아").tag(Gender.male)
                    Text("여아").tag(Gender.female)
                }
            }

            Section {
                Button {
                    store.send(.registerButtonTapped)
                } label: {
                    if store.isLoading {
                        ProgressView()
                    } else {
                        Text("등록하기")
                    }
                }
                .disabled(store.name.isEmpty || store.isLoading)
            }

            if let error = store.error {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("아기 등록")
    }
}
