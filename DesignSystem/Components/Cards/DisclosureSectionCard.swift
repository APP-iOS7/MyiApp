import SwiftUI

public struct DisclosureSectionCard: View {
    private let title: String
    private let content: String

    public init(title: String, content: String) {
        self.title = title
        self.content = content
    }

    public var body: some View {
        SectionCard(spacing: 0) {
            DisclosureGroup {
                Text(content)
                    .foregroundColor(.Semantic.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } label: {
                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(.Semantic.sectionHeading)
            }
            .disclosureGroupStyle(PlainDisclosureGroupStyle())
        }
    }
}
