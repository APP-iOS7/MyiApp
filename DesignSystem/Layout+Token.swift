import CoreFoundation

public enum Spacing {
    public static let xs: CGFloat = 4
    public static let s: CGFloat = 8
    public static let m: CGFloat = 16
    public static let l: CGFloat = 24
    public static let xl: CGFloat = 32
}

public enum Radius {
    public static let xs: CGFloat = 4
    public static let s: CGFloat = 8
    public static let m: CGFloat = 12
    public static let l: CGFloat = 16
    public static let xl: CGFloat = 20
}

public enum ButtonSize {
    public static let height: CGFloat = 50
}

public enum RowHeight {
    public static let timeline: CGFloat = 60
}

public enum DailyChartLayout {
    /// 캔버스 너비 대비 링 외곽 지름 비율
    public static let ringDiameterRatio: CGFloat = 0.6
    /// 링 지름 대비 stroke 두께 비율
    public static let ringThicknessRatio: CGFloat = 0.4
    /// 시간 마커가 링 바깥쪽에서 떨어지는 거리
    public static let markerOuterPadding: CGFloat = 10
    /// 점 이벤트(수면 외)를 호로 표현할 길이 (분)
    public static let pointEventDurationMinutes: Int = 30
}

public enum GrowthChartLayout {
    /// 차트 본체 높이
    public static let chartHeight: CGFloat = 220
    /// 데이터 부족 안내 영역 최소 높이
    public static let emptyMinHeight: CGFloat = 200
    /// 일반 데이터 포인트 심볼 크기
    public static let pointSize: CGFloat = 48
    /// 선택된 데이터 포인트 심볼 크기
    public static let selectedPointSize: CGFloat = 120
    /// X/Y 축 라벨 개수 힌트
    public static let axisDesiredCount: Int = 4
    /// 선택 토글 애니메이션 길이 (초)
    public static let selectionAnimationDuration: Double = 0.15
    /// 어노테이션 위치 결정 임계값 (0~1, 초과 시 topLeading)
    public static let trailingAnnotationThreshold: CGFloat = 0.7
}

public enum WeeklyChartLayout {
    /// 일별 컬럼 너비 대비 이벤트 막대 너비 비율
    public static let barWidthRatio: CGFloat = 0.6
    /// 그리드 선 두께
    public static let gridLineWidth: CGFloat = 0.5
    /// 시간 라벨 표시 간격 (3 = 매 3시간마다)
    public static let hourLabelInterval: Int = 3
    /// 시간 라벨 좌측 x 위치
    public static let timeLabelLeading: CGFloat = 20
    /// 점 이벤트(수면 외)를 막대로 표현할 길이 (분)
    public static let pointEventDurationMinutes: Int = 30
}

public enum IconSize {
    public static let s: CGFloat = 18
    public static let m: CGFloat = 24
    public static let l: CGFloat = 32
    public static let xl: CGFloat = 44
}

public enum Opacity {
    /// 배경 트랙/외곽 링 등 가장 옅은 표시
    public static let track: Double = 0.1
    /// 가벼운 하이라이트 (오늘 셀 배경, 선택 칩 배경)
    public static let highlight: Double = 0.15
    /// 가이드 라인, 차트 배경 링
    public static let guide: Double = 0.2
    /// 중간 강조 (VolumeMeter 중간 링 등)
    public static let soft: Double = 0.25
    /// 비활성 액션
    public static let disabled: Double = 0.3
    /// 약한 흐림 (out-of-month 등 보조 콘텐츠)
    public static let dimmed: Double = 0.35
    /// 모달 backdrop
    public static let scrim: Double = 0.5
    /// 버튼 눌림 dim
    public static let pressed: Double = 0.7
}

public enum ProgressBarLayout {
    public static let height: CGFloat = 4
    public static let markerWidth: CGFloat = 2
    public static let markerHeight: CGFloat = 8
}

public enum ConfidenceRingLayout {
    /// 트랙/진행 stroke 두께 — 사용 가능 공간 대비 비율
    public static let strokeRatio: CGFloat = 0.07
    /// 중앙 감정 아이콘 한 변 — 사용 가능 공간 대비 비율
    public static let iconRatio: CGFloat = 0.45
    /// 퍼센트 텍스트 폰트 크기 — 사용 가능 공간 대비 비율
    public static let percentTextRatio: CGFloat = 0.1
}

public enum CalendarLayout {
    public static let indicatorSize: CGFloat = 4
}

public enum VolumeMeterLayout {
    /// 기본 외곽 ring 지름 — 사용 가능 공간 대비 비율 (rest 상태)
    public static let baseRatio: CGFloat = 0.5
    /// 중간 ring 지름 — base 대비
    public static let midRingRatio: CGFloat = 0.8
    /// 코어 원 지름 — base 대비
    public static let coreRatio: CGFloat = 0.6
    /// 마이크 아이콘 폰트 크기 — base 대비
    public static let iconRatio: CGFloat = 0.25

    /// 외곽 ring 펄스 — amp=1일 때 추가 scale 배수 (1 + boost)
    public static let outerPulseBoost: CGFloat = 1.0
    /// 중간 ring 펄스
    public static let midPulseBoost: CGFloat = 0.7
    /// 코어 원 펄스
    public static let corePulseBoost: CGFloat = 0.2
}
