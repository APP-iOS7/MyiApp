import ComposableArchitecture
import Domain
import Foundation
import Shared

extension BabyClient: @retroactive TestDependencyKey {}
extension BabyClient: @retroactive DependencyKey {
    public static let liveValue = Self(
        currentBabies: { @Sendable () async throws(BabyError) -> [Baby] in
            do {
                let dtos: [BabyResponseDTO] = try await APIClient.shared.get("/babies")
                return dtos.map { $0.toBaby() }
            } catch let api as APIError {
                throw mapBabyError(api)
            } catch {
                throw .unexpected
            }
        },
        streamBabies: { @Sendable () -> AsyncStream<[Baby]> in
            BabyListStream.make()
        },
        streamBaby: { @Sendable id -> AsyncStream<Baby> in
            BabyDetailStream.make(babyID: id)
        },
        registerNewBaby: { @Sendable baby async throws(BabyError) in
            do {
                let req = CreateBabyRequestDTO(
                    name: baby.name,
                    birthDate: baby.birthDate,
                    gender: baby.gender,
                    bloodType: baby.bloodType,
                    profileImageURL: baby.profileImageURL?.absoluteString
                )
                let _: BabyResponseDTO = try await APIClient.shared.postJSON("/babies", body: req)
            } catch let api as APIError {
                throw mapBabyError(api)
            } catch {
                throw .unexpected
            }
        },
        registerExistingBaby: { @Sendable inviteCode async throws(BabyError) in
            do {
                let _: BabyResponseDTO = try await APIClient.shared.postEmpty(
                    "/babies/\(inviteCode.uuidString)/join"
                )
            } catch let api as APIError where api == APIError.notFound {
                throw .invalidInviteCode
            } catch let api as APIError {
                throw mapBabyError(api)
            } catch {
                throw .unexpected
            }
        },
        updateBaby: { @Sendable baby async throws(BabyError) in
            do {
                let req = UpdateBabyRequestDTO(
                    name: baby.name,
                    birthDate: baby.birthDate,
                    gender: baby.gender,
                    bloodType: baby.bloodType,
                    profileImageURL: baby.profileImageURL?.absoluteString
                )
                let _: BabyResponseDTO = try await APIClient.shared.patch(
                    "/babies/\(baby.id.uuidString)",
                    body: req
                )
            } catch let api as APIError {
                throw mapBabyError(api)
            } catch {
                throw .unexpected
            }
        },
        removeCaregiver: { @Sendable babyID, caregiverID async throws(BabyError) in
            do {
                try await APIClient.shared.deleteEmpty(
                    "/babies/\(babyID.uuidString)/caregivers/\(caregiverID)"
                )
            } catch let api as APIError {
                throw mapBabyError(api)
            } catch {
                throw .unexpected
            }
        }
    )
}

extension DependencyValues {
    public var babyClient: BabyClient {
        get { self[BabyClient.self] }
        set { self[BabyClient.self] = newValue }
    }
}

// MARK: - DTOs

struct BabyResponseDTO: Decodable, Sendable {
    let id: UUID
    let name: String
    let birthDate: Date
    let gender: Gender
    let bloodType: BloodType
    let profileImageURL: String?
    let mainCaregiverID: String
    let caregiverIDs: [String]

    func toBaby() -> Baby {
        Baby(
            id: id,
            name: name,
            birthDate: birthDate,
            gender: gender,
            bloodType: bloodType,
            profileImageURL: profileImageURL.flatMap(URL.init(string:)),
            mainCaregiverID: mainCaregiverID,
            caregiverIDs: caregiverIDs
        )
    }
}

struct CreateBabyRequestDTO: Encodable, Sendable {
    let name: String
    let birthDate: Date
    let gender: Gender
    let bloodType: BloodType
    let profileImageURL: String?

    enum CodingKeys: String, CodingKey {
        case name, birthDate, gender, bloodType, profileImageURL
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        // birthDate is a date-only on backend (LocalDate). Format as yyyy-MM-dd.
        try c.encode(DateOnly.formatter.string(from: birthDate), forKey: .birthDate)
        try c.encode(gender, forKey: .gender)
        try c.encode(bloodType, forKey: .bloodType)
        try c.encodeIfPresent(profileImageURL, forKey: .profileImageURL)
    }
}

struct UpdateBabyRequestDTO: Encodable, Sendable {
    let name: String?
    let birthDate: Date?
    let gender: Gender?
    let bloodType: BloodType?
    let profileImageURL: String?

    enum CodingKeys: String, CodingKey {
        case name, birthDate, gender, bloodType, profileImageURL
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(name, forKey: .name)
        if let birthDate { try c.encode(DateOnly.formatter.string(from: birthDate), forKey: .birthDate) }
        try c.encodeIfPresent(gender, forKey: .gender)
        try c.encodeIfPresent(bloodType, forKey: .bloodType)
        try c.encodeIfPresent(profileImageURL, forKey: .profileImageURL)
    }
}

private func mapBabyError(_ error: APIError) -> BabyError {
    switch error {
    case .unauthorized: return .unauthorized
    case .forbidden:    return .unauthorized
    case .notFound:     return .invalidInviteCode
    default:            return .unexpected
    }
}

extension APIError: Equatable {
    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.notFound, .notFound),
             (.conflict, .conflict): return true
        default: return false
        }
    }
}

// MARK: - SSE-driven streams

/// Streams the caller's full baby list. Whenever an event arrives on any baby
/// the user is a member of, we re-fetch GET /babies to get the latest list.
/// This is simpler than partial diffing and matches the Firestore listener UX.
enum BabyListStream {
    static func make() -> AsyncStream<[Baby]> {
        AsyncStream { continuation in
            let task = Task {
                guard AuthState.shared.snapshot() != nil else {
                    continuation.finish()
                    return
                }
                // Initial snapshot.
                if let initial = try? await fetchList() {
                    continuation.yield(initial)
                }
                // We don't have a global baby-list stream endpoint. Fall back to
                // periodic refresh when no per-baby SSE is opened. For now we
                // simply re-fetch on a 30s interval.
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 30 * 1_000_000_000)
                    if Task.isCancelled { break }
                    if let next = try? await fetchList() {
                        continuation.yield(next)
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private static func fetchList() async throws -> [Baby] {
        let dtos: [BabyResponseDTO] = try await APIClient.shared.get("/babies")
        return dtos.map { $0.toBaby() }
    }
}

/// Streams a single baby — backed by SSE on `/babies/{id}/stream`. We listen
/// for `baby.updated` events and re-fetch on receipt to get the canonical state.
enum BabyDetailStream {
    static func make(babyID: UUID) -> AsyncStream<Baby> {
        AsyncStream { continuation in
            let task = Task {
                guard AuthState.shared.snapshot() != nil else {
                    continuation.finish()
                    return
                }
                if let initial = try? await fetchOne(id: babyID) {
                    continuation.yield(initial)
                }
                let sse = SSEClient()
                let stream = sse.events(path: "/babies/\(babyID.uuidString)/stream")
                do {
                    for try await event in stream {
                        try Task.checkCancellation()
                        if event.name == "update", event.data.contains("\"baby.updated\"") {
                            if let updated = try? await fetchOne(id: babyID) {
                                continuation.yield(updated)
                            }
                        }
                    }
                } catch {
                    AppLogger.debug("BabyDetailStream sse ended: \(error)")
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private static func fetchOne(id: UUID) async throws -> Baby {
        let dto: BabyResponseDTO = try await APIClient.shared.get("/babies/\(id.uuidString)")
        return dto.toBaby()
    }
}
