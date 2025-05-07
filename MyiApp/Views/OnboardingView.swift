import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    @State private var selectedItem: OnBordingItem = onBordingItems.first! // 선택된 아이템을 가지는 변수, 기본값은 배열의 처음것.
    @State private var introItems: [OnBordingItem] = onBordingItems // 아이템 5개를 갖는 배열
    @State private var activateIndex: Int = 0 // ?
    var body: some View {
        VStack(spacing: 0) {
            Button {
                updateItem(isForward: false)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .foregroundStyle(.green.gradient)
                    .contentShape(.rect)
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(selectedItem.id == introItems.first?.id ? 0 : 1)
            
            ZStack {
                ForEach(introItems) { item in
                    AnimatedIconView(item)
                }
            }
            .frame(height: 250)
            .frame(maxHeight: .infinity)
            
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(introItems) { item in
                        Capsule()
                            .fill(selectedItem.id == item.id ? Color.primary : .gray)
                            .frame(width: selectedItem.id == item.id ? 25 : 4, height: 4)
                    }
                }
                .padding(.bottom, 15)
                
                Text(selectedItem.title)
                    .font(.title.bold())
                    .contentTransition(.numericText()) // 이친구 무슨기능하는지 확은 해 봐야함
                Text("우리조의 이름은 죠습니다")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                
                Button {
                    if selectedItem.id == introItems.last?.id {
                        hasSeenOnboarding = true
                    } else {
                        updateItem(isForward: true)
                    }
                } label: {
                    Text(selectedItem.id == introItems.last?.id ? "Continue" : "Next")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 250)
                        .padding(.vertical, 12)
                        .background(Color.green.gradient, in: .capsule)
                }
                .padding(.top, 25)
                
            }
            .multilineTextAlignment(.center) // 모든 정렬을 가운데로
            .frame(width: 300)
            .frame(maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    func AnimatedIconView(_ item: OnBordingItem) -> some View {
        let isSelected = selectedItem.id == item.id
        
        Image(systemName: item.image)
            .font(.system(size: 80))
            .foregroundStyle(.white.shadow(.drop(radius: 20)))
            .frame(width: 120, height: 120)
            .background(.green.gradient, in: .rect(cornerRadius: 32))
            .background {
                RoundedRectangle(cornerRadius: 35)
                    .fill(.background)
                    .shadow(color: .primary.opacity(0.2), radius: 1, x: 1, y: 1)
                    .shadow(color: .primary.opacity(0.2), radius: 1, x: -1, y: -1)
                    .padding(-3)
                    .opacity(selectedItem.id == item.id ? 1 : 0)
            }
            .rotationEffect(.degrees(item.rotation))
            .scaleEffect(isSelected ? 1.1 : item.scale, anchor: item.anchor)
            .offset(x: item.offset)
            .rotationEffect(.degrees(item.rotation))
            .zIndex(isSelected ? 2 : item.zIndex)
        
    }
    
    func updateItem(isForward: Bool) {
        guard isForward ? activateIndex != introItems.count - 1 : activateIndex != 0 else { return }
        
        var fromIndex: Int
        
        if isForward {
            activateIndex += 1
        } else {
            activateIndex -= 1
        }
        
        if isForward {
            fromIndex = activateIndex - 1
        }
        else {
            fromIndex = activateIndex + 1
        }
        for index in introItems.indices {
            introItems[index].zIndex = 0
        }
        Task {
            withAnimation(.bouncy(duration: 1.5)) {
                introItems[fromIndex].scale = introItems[activateIndex].scale
                introItems[fromIndex].rotation = introItems[activateIndex].rotation
                introItems[fromIndex].anchor = introItems[activateIndex].anchor
                introItems[fromIndex].offset = introItems[activateIndex].offset
                introItems[fromIndex].zIndex = 1
            }
            try? await Task.sleep(for: .seconds(0.1))
            withAnimation(.bouncy(duration: 0.9)) {
                introItems[activateIndex].scale = 1
                introItems[activateIndex].rotation = .zero
                introItems[activateIndex].anchor = .center
                introItems[activateIndex].offset = .zero
                
                selectedItem = introItems[activateIndex]
            }
        }
    }
}

#Preview {
    OnboardingView()
}
