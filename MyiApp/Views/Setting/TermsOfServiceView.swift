import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) { // 섹션 간 간격을 30으로 조정
                // 1. 목적
                VStack(alignment: .leading, spacing: 0) { // 제목과 내용 붙이기
                    Text("1. 목적")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)
                    Text("""
                    본 이용약관은 MyiApp(이하 "앱")의 서비스 이용과 관련하여 이용자와 앱 간의 권리, 의무 및 책임사항을 규정합니다. 모든 이용자는 본 약관을 준수해야 합니다.
                    """)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                // 2. 서비스 이용 계약의 성립
                VStack(alignment: .leading, spacing: 0) {
                    Text("2. 서비스 이용 계약의 성립")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)
                    Text("""
                    서비스 이용 계약은 이용자가 본 약관에 동의하고 앱에 가입함으로써 성립됩니다. 가입 시 제공한 정보는 정확해야 하며, 허위 정보 제공 시 서비스 이용이 제한될 수 있습니다.
                    """)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                // 3. 서비스 이용 제한
                VStack(alignment: .leading, spacing: 0) {
                    Text("3. 서비스 이용 제한")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)
                    Text("""
                    다음 사항에 해당하는 경우, 앱은 이용자의 서비스 이용을 제한하거나 계약을 해지할 수 있습니다:
                    - 부정 사용 또는 불법 행위
                    - 타인의 개인정보를 도용한 경우
                    - 기타 앱 운영에 현저한 지장을 초래하는 행위
                    """)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                // 4. 책임과 의무
                VStack(alignment: .leading, spacing: 0) {
                    Text("4. 책임과 의무")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)
                    Text("""
                    - 앱은 지속적이고 안정적인 서비스 제공을 위해 최선을 다합니다.
                    - 이용자는 자신의 계정과 비밀번호를 관리할 책임이 있으며, 이를 소홀히 한 경우 발생하는 손해는 이용자가 부담합니다.
                    """)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                // 5. 분쟁 해결
                VStack(alignment: .leading, spacing: 0) {
                    Text("5. 분쟁 해결")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)
                    Text("""
                    이용자와 앱 간의 분쟁이 발생할 경우, 양측은 성실히 협의하여 해결합니다. 협의가 어려울 경우, 대한민국 법을 적용하며 서울중앙지방법원을 전속 관할 법원으로 합니다.
                    """)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                    .frame(height: 20)
            }
            .padding()
        }
        .navigationTitle("이용약관")
    }
}

#Preview {
    NavigationStack {
        TermsOfServiceView()
    }
}
