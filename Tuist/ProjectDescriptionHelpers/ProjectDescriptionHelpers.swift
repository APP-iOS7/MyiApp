import ProjectDescription

// ProjectDescriptionHelpers: 매니페스트 간 공유 코드

public extension TargetScript {
    static var swiftFormat: TargetScript {
        .pre(
            tool: "swiftformat",
            arguments: ["$SRCROOT"],
            name: "SwiftFormat",
            basedOnDependencyAnalysis: false
        )
    }
}
