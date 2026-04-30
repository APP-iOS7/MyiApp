import ComposableArchitecture
import Domain
import Foundation

extension LocalNotificationClient {
    public static let previewValue = Self(
        authorizationStatus: { .authorized },
        requestPermission: { true },
        schedule: { _ in },
        cancel: { _ in }
    )
}
