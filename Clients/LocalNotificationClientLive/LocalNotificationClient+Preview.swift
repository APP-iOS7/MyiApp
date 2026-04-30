import ComposableArchitecture
import Domain
import Foundation

extension LocalNotificationClient {
    public static let previewValue = Self(
        requestPermission: { true },
        schedule: { _ in },
        cancel: { _ in }
    )
}
