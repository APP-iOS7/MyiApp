import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                // 1. 수집하는 개인정보의 항목
                VStack(alignment: .leading, spacing: 10) {
                    Text("1. 수집하는 개인정보의 항목")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary.opacity(0.8))
                    VStack(alignment: .leading, spacing: 10) {
                        Text("MyiApp은 서비스 제공을 위해 다음과 같은 개인정보를 수집합니다")
                        Text("- 이름, 이메일 주소, 전화번호")
                        Text("- 아기 정보(이름, 생년월일, 성별, 키, 몸무게, 혈액형")
                        Text("- 기기 정보(IP 주소, 디바이스 ID, 사용 기록")
                    }
                    .foregroundColor(.primary.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                
                // 2. 개인정보의 수집 및 이용 목적
                VStack(alignment: .leading, spacing: 10) {
                    Text("2. 개인정보의 수집 및 이용 목적")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary.opacity(0.8))
                    VStack(alignment: .leading, spacing: 10) {
                        Text("수집한 개인정보는 다음의 목적으로 이용됩니다")
                        Text("- 서비스 제공 및 운영: 사용자 맞춤형 콘텐츠 제공")
                        Text("- 고객 지원: 문의 응대 및 불만 처리")
                        Text("- 서비스 개선: 사용 패턴 분석 및 기능 개선")
                    }
                    .foregroundColor(.primary.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                
                // 3. 개인정보의 보유 및 이용 기간
                VStack(alignment: .leading, spacing: 10) {
                    Text("3. 개인정보의 보유 및 이용 기간")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary.opacity(0.8))
                    VStack(alignment: .leading, spacing: 10) {
                        Text("MyiApp은 개인정보를 수집한 목적이 달성될 때까지 보유하며, 목적 달성 후에는 즉시 파기합니다. 단, 관련 법령에 따라 일정 기간 보관이 필요한 경우에는 해당 기간 동안 보관 후 파기합니다")
                        Text("- 계약 또는 청약철회 관련 기록: 5년")
                        Text("- 소비자 불만 또는 분쟁 처리 기록: 3년")
                    }
                    .foregroundColor(.primary.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                
                // 4. 개인정보의 제3자 제공
                VStack(alignment: .leading, spacing: 10) {
                    Text("4. 개인정보의 제3자 제공")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary.opacity(0.8))
                    Text("MyiApp은 사용자의 동의 없이 개인정보를 제3자에게 제공하지 않습니다. 다만, 법령에 의거하거나 사용자가 동의한 경우에는 예외적으로 제공될 수 있습니다.")
                        .foregroundColor(.primary.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                
                // 5. 이용자 권리
                VStack(alignment: .leading, spacing: 10) {
                    Text("5. 이용자 권리")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary.opacity(0.8))
                    Text("사용자는 언제든지 자신의 개인정보에 대해 열람, 정정, 삭제를 요청할 수 있습니다. 문의는 고객 지원팀(support@myiapp.com)으로 연락 주시기 바랍니다.")
                        .foregroundColor(.primary.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                
                Spacer()
                    .frame(height: 20)
            }
            .padding()
        }
        .background(Color("customBackgroundColor"))
        .navigationTitle("개인정보 처리 방침")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary.opacity(0.8))
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
