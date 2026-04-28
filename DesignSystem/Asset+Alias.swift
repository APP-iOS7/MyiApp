import SwiftUI

/// Tuist가 자동 생성한 `DesignSystemAsset`의 짧은 alias.
public typealias Asset = DesignSystemAsset

public extension Image {
    /// `Image(Asset.Records.Color.bath)` 같이 SwiftUI 관용구로 바로 사용.
    init(_ asset: DesignSystemImages) {
        self.init(asset: asset)
    }
}

public extension Color {
    /// `Color(Asset.Tokens.blue500)` 같이 SwiftUI 관용구로 바로 사용.
    init(_ asset: DesignSystemColors) {
        self.init(asset: asset)
    }
}
