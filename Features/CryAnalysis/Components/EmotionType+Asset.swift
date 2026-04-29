import DesignSystem
import Domain

extension EmotionType {
    public var iconAsset: DesignSystemImages {
        switch self {
        case .bellyPain:  Asset.Analysis.bellyPain
        case .burping:    Asset.Analysis.burping
        case .coldHot:    Asset.Analysis.coldHot
        case .discomfort: Asset.Analysis.unknown
        case .hungry:     Asset.Analysis.hungry
        case .lonely:     Asset.Analysis.lonely
        case .scared:     Asset.Analysis.scared
        case .tired:      Asset.Analysis.tired
        case .unknown:    Asset.Analysis.unknown
        }
    }
}
