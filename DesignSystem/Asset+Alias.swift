import SwiftUI

public typealias Asset = DesignSystemAsset

extension Image {
    public init(_ asset: DesignSystemImages) {
        self.init(asset: asset)
    }
}

extension Color {
    public init(_ asset: DesignSystemColors) {
        self.init(asset: asset)
    }
}
