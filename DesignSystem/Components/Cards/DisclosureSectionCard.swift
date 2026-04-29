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

#Preview {
    ScrollView {
        VStack(spacing: Spacing.m) {
            DisclosureSectionCard(
                title: "제1조 (목적)",
                content: "본 약관은 서비스 이용에 관한 사항을 규정합니다."
            )
            DisclosureSectionCard(
                title: "수집 항목",
                content: """
                필수
                - 이메일
                - 이름
                """
            )
        }
        .padding()
    }
}
