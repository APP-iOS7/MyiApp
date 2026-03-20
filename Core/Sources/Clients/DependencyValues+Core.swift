import ComposableArchitecture
import Domain
import Foundation

// MARK: - AuthClient

extension AuthClient: @retroactive DependencyKey {
    public static var liveValue: Self {
        .live
    }

    public static var testValue: Self {
        Self(
            currentUser: { nil },
            login: { _ in fatalError("Unimplemented") },
            logout: {},
            deleteAccount: {}
        )
    }
}

extension DependencyValues {
    public var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

// MARK: - CaregiverClient

extension CaregiverClient: @retroactive DependencyKey {
    public static var liveValue: Self {
        .live
    }

    public static var testValue: Self {
        Self(
            fetchCaregiver: { _ in fatalError("Unimplemented") },
            registerCaregiver: { _ in fatalError("Unimplemented") },
            connectCaregiver: { _, _ in fatalError("Unimplemented") }
        )
    }
}

extension DependencyValues {
    public var caregiverClient: CaregiverClient {
        get { self[CaregiverClient.self] }
        set { self[CaregiverClient.self] = newValue }
    }
}

// MARK: - RecordClient

extension RecordClient: @retroactive DependencyKey {
    public static var liveValue: Self {
        .live
    }

    public static var testValue: Self {
        Self(
            fetchRecords: { _ in fatalError("Unimplemented") },
            saveRecord: { _ in fatalError("Unimplemented") },
            deleteRecord: { _ in fatalError("Unimplemented") }
        )
    }
}

extension DependencyValues {
    public var recordClient: RecordClient {
        get { self[RecordClient.self] }
        set { self[RecordClient.self] = newValue }
    }
}
