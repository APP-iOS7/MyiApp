import CoreFoundation

public enum Spacing {
    public static let xs: CGFloat = 4
    public static let s: CGFloat = 8
    public static let m: CGFloat = 16
    public static let l: CGFloat = 24
    public static let xl: CGFloat = 32
}

public enum Radius {
    public static let s: CGFloat = 5
    public static let m: CGFloat = 8
    public static let l: CGFloat = 12
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
    /// 배경 링 투명도
    public static let backgroundRingOpacity: Double = 0.2
    /// 점 이벤트(수면 외)를 호로 표현할 길이 (분)
    public static let pointEventDurationMinutes: Int = 30
}

public enum WeeklyChartLayout {
    /// 일별 컬럼 너비 대비 이벤트 막대 너비 비율
    public static let barWidthRatio: CGFloat = 0.6
    /// 그리드 선 투명도
    public static let gridLineOpacity: Double = 0.2
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
}
