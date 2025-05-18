import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) { // 섹션 간 간격을 30으로 조정
                // 1. 수집하는 개인정보의 항목
                VStack(alignment: .leading, spacing: 0) { // 제목과 내용 붙이기
                    Text("1. 수집하는 개인정보의 항목")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)
                    Text("""
                    MyiApp은 서비스 제공을 위해 다음과 같은 개인정보를 수집합니다:
                    - 이름, 이메일 주소, 전화번호
                    - 아기 정보(이름, 생년월일, 성별, 키, 몸무게, 혈액형)
                    - 기기 정보(IP 주소, 디바이스 ID, 사용 기록)
                    """)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                // 2. 개인정보의 수집 및 이용 목적
                VStack(alignment: .leading, spacing: 0) {
                    Text("2. 개인정보의 수집 및 이용 목적")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)
                    Text("""
                    수집한 개인정보는 다음의 목적으로 이용됩니다:
                    - 서비스 제공 및 운영: 사용자 맞춤형 콘텐츠 제공
                    - 고객 지원: 문의 응대 및 불만 처리
                    - 서비스 개선: 사용 패턴 분석 및 기능 개선
                    """)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                // 3. 개인정보의 보유 및 이용 기간
                VStack(alignment: .leading, spacing: 0) {
                    Text("3. 개인정보의 보유 및 이용 기간")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)
                    Text("""
                    MyiApp은 개인정보를 수집한 목적이 달성될 때까지 보유하며, 목적 달성 후에는 즉시 파기합니다. 단, 관련 법령에 따라 일정 기간 보관이 필요한 경우에는 해당 기간 동안 보관 후 파기합니다:
                    - 계약 또는 청약철회 관련 기록: 5년
                    - 소비자 불만 또는 분쟁 처리 기록: 3년
                    """)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                // 4. 개인정보의 제3자 제공
                VStack(alignment: .leading, spacing: 0) {
                    Text("4. 개인정보의 제3자 제공")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)
                    Text("""
                    MyiApp은 사용자의 동의 없이 개인정보를 제3자에게 제공하지 않습니다. 다만, 법령에 의거하거나 사용자가 동의한 경우에는 예외적으로 제공될 수 있습니다.
                    """)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                // 5. 이용자 권리
                VStack(alignment: .leading, spacing: 0) {
                    Text("5. 이용자 권리")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)
                    Text("""
                    사용자는 언제든지 자신의 개인정보에 대해 열람, 정정, 삭제를 요청할 수 있습니다. 문의는 고객 지원팀(support@myiapp.com)으로 연락 주시기 바랍니다.
                    """)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                    .frame(height: 20)
            }
            .padding()
        }
        .navigationTitle("개인정보 처리 방침")
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
