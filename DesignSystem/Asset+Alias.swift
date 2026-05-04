import SwiftUI

public typealias Asset = DesignSystemAsset

public extension Image {
    init(_ asset: DesignSystemImages) {
        self.init(asset: asset)
    }
}

public extension Color {
    init(_ asset: DesignSystemColors) {
        self.init(asset: asset)
    }
}
