#  Todo

추가 모달에서 다른 버튼을 눌렀을 때 기존 기록 삭제.
기저귀 아이콘 살짝 아래료 하기. // 병합 이후 진행.
버튼 활성화 색 물어보기.
온도 기본값
타임라인 컬러 지정
수정모드 추가모드 분기.

class BabyManager: ObservableObject {
    @Published var baby: Baby
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init(baby: Baby) {
        self.baby = baby
        setupBinding()
    }
    
    private func setupBinding() {
        // 아기의 정보를 실시간으로 가져옴
        let babyRef = db.collection("babies").document(baby.id.uuidString)
        babyRef
            .snapshotPublisher()
            .receive(on: RunLoop.main)
            .tryMap { try $0.data(as: Baby.self) }
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("아기 정보를 가져오는데 실패했습니다: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] baby in
                self?.baby = baby
            })
            .store(in: &cancellables)
        
        // baby 프로퍼티의 변경을 감지하여 자동 업로드
        $baby
            .dropFirst()
            .flatMap { babyRef.setData(from: $0) }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("아기 정보 업로드에 실패했습니다: \(error.localizedDescription)")
                }
            }, receiveValue: { _ in
                print("아기 정보가 성공적으로 업로드되었습니다")
            })
            .store(in: &cancellables)
    }
}
