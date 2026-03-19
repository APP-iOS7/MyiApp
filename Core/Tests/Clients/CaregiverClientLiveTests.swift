import Domain
import FirebaseCore
import FirebaseFirestore
import XCTest
@testable import Core

final class CaregiverClientLiveTests: XCTestCase {
    var db: Firestore!
    var client: CaregiverClient!

    override class func setUp() {
        super.setUp()
        if FirebaseApp.app() == nil {
            let options = FirebaseOptions(
                googleAppID: "1:1234567890:ios:321abc456def7890",
                gcmSenderID: "1234567890"
            )
            options.projectID = "demo-myiapp"
            options.apiKey = "AIzaSyDummyKey123456789"
            FirebaseApp.configure(options: options)
        }
    }

    override func setUp() {
        super.setUp()
        self.db = Firestore.firestore()
        let settings = self.db.settings
        settings.host = "127.0.0.1:8080"
        settings.isPersistenceEnabled = false
        settings.isSSLEnabled = false
        self.db.settings = settings

        self.client = CaregiverClient.liveValue
    }

    func test_Given_보호자정보_When_registerCaregiver호출시_Then_성공적으로저장됨() async throws {
        // Given
        let caregiver = Caregiver(
            id: UUID().uuidString,
            name: "테스트 보호자",
            email: "test@example.com",
            role: "엄마"
        )

        // When
        try await self.client.registerCaregiver(caregiver)

        // Then
        let fetched = try await client.fetchCaregiver(caregiver.id)
        XCTAssertEqual(fetched.id, caregiver.id)
        XCTAssertEqual(fetched.name, caregiver.name)
        XCTAssertEqual(fetched.role, caregiver.role)
    }

    func test_Given_존재하지않는ID_When_fetchCaregiver호출시_Then_notFound에러반환() async throws {
        // Given
        let invalidID = "invalid_id"

        // When / Then
        do {
            _ = try await self.client.fetchCaregiver(invalidID)
            XCTFail("에러가 발생해야 합니다.")
        } catch let error as CaregiverError {
            XCTAssertEqual(error, .notFound)
        } catch {
            XCTFail("CaregiverError.notFound가 발생해야 합니다: \(error)")
        }
    }

    func test_Given_사용자와아기_When_connectCaregiver호출시_Then_상호연결됨() async throws {
        // Given
        let caregiverID = UUID().uuidString
        let babyID = UUID().uuidString

        let caregiver = Caregiver(id: caregiverID, name: "보호자", email: "p@e.com")
        try await client.registerCaregiver(caregiver)

        // 아기 문서는 명시적으로 먼저 생성 (legacy 방식 대비 간소화)
        try await self.db.collection("babies").document(babyID).setData([
            "id": babyID,
            "name": "아기",
            "caregivers": []
        ])

        // When
        try await self.client.connectCaregiver(caregiverID, babyID)

        // Then
        let userDoc = try await db.collection("users").document(caregiverID).getDocument()
        let babyRefs = userDoc.data()?["babies"] as? [DocumentReference]
        XCTAssertTrue(babyRefs?.contains(where: { $0.documentID == babyID }) ?? false)

        let babyDoc = try await db.collection("babies").document(babyID).getDocument()
        let caregiverRefs = babyDoc.data()?["caregivers"] as? [DocumentReference]
        XCTAssertTrue(caregiverRefs?.contains(where: { $0.documentID == caregiverID }) ?? false)
    }
}
