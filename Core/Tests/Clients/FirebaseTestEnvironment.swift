import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation

/// 테스트 환경에서 Firebase를 안전하게(Thread-safe) 한 번만 초기화하기 위한 클래스입니다.
public final class FirebaseTestEnvironment: @unchecked Sendable {
    public static let shared = FirebaseTestEnvironment()

    private init() {
        if FirebaseApp.app() == nil {
            let options = FirebaseOptions(
                googleAppID: "1:1234567890:ios:321abc456def7890",
                gcmSenderID: "1234567890"
            )
            options.projectID = "demo-myiapp"
            options.apiKey = "AIzaSyDummyKey123456789"
            FirebaseApp.configure(options: options)

            // Firestore 에뮬레이터 설정
            let db = Firestore.firestore()
            let settings = db.settings
            settings.host = "127.0.0.1:8080"
            settings.cacheSettings = MemoryCacheSettings()
            settings.isSSLEnabled = false
            db.settings = settings

            // Auth 에뮬레이터 설정
            let auth = Auth.auth()
            auth.useEmulator(withHost: "127.0.0.1", port: 9099)
            auth.settings?.isAppVerificationDisabledForTesting = true

            print("✅ FirebaseTestEnvironment: FirebaseApp and Emulators configured for testing.")
        }
    }

    /// Firebase 초기화를 보장합니다.
    public func setup() {
        // 싱글톤 인스턴스에 접근하는 것만으로 init()이 한 번 실행됩니다.
    }
}
