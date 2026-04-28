import DesignSystem
import Domain
import SwiftUI

struct CategoryFilterGrid: View {
    @Binding var selectedCategories: Set<CareEvent.Category>

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: Spacing.s) {
            ForEach(CareEvent.Category.statisticFilterCases, id: \.self) { category in
                let isSelected = selectedCategories.contains(category)
                Button {
                    if isSelected {
                        selectedCategories.remove(category)
                    } else {
                        selectedCategories.insert(category)
                    }
                } label: {
                    CategoryIcon(
                        category: category,
                        isSelected: isSelected
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct CategoryIcon: View {
    let category: CareEvent.Category
    let isSelected: Bool

    var body: some View {
        VStack(spacing: Spacing.xs) {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .padding(Spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: Radius.l)
                        .fill(isSelected ? tintColor.opacity(0.15) : Color.gray.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.l)
                        .stroke(isSelected ? tintColor : .clear, lineWidth: 2)
                )

            Text(category.label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
    }

    private var image: Image {
        switch category {
        case .feeding: Image(Asset.Records.Color.meal)
        case .potty: Image(Asset.Records.Color.potty)
        case .sleep: Image(Asset.Records.Color.sleep)
        case .bath: Image(Asset.Records.Color.bath)
        case .snack: Image(Asset.Records.Color.snack)
        case .growth, .medical, .vital: Image(systemName: "questionmark")
        }
    }

    private var tintColor: Color {
        switch category {
        case .feeding: .Semantic.feeding
        case .potty: .Semantic.potty
        case .sleep: .Semantic.sleep
        case .bath: .Semantic.bath
        case .snack: .Semantic.snack
        case .growth, .medical, .vital: .gray
        }
    }
}

#Preview {
    CategoryFilterGrid(selectedCategories: .constant(Set(CareEvent.Category.statisticFilterCases)))
        .padding()
}
