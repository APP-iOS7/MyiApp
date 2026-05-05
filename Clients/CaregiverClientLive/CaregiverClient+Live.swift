import ComposableArchitecture
import Domain
import Foundation
import Shared

extension CaregiverClient: @retroactive TestDependencyKey {}
extension CaregiverClient: @retroactive DependencyKey {
    public static let liveValue = Self(
        currentCaregiver: { @Sendable () async throws(CaregiverError) -> Caregiver? in
            do {
                let me: MeResponseDTO = try await APIClient.shared.get("/me")
                return Caregiver(
                    id: me.id,
                    displayName: me.displayName,
                    photoURL: nil,
                    fcmToken: nil,
                    createdAt: me.createdAt ?? Date()
                )
            } catch APIError.unauthorized {
                throw .unauthorized
            } catch let api as APIError where api == APIError.notFound {
                return nil
            } catch {
                throw .unexpected
            }
        },
        streamCaregiver: { @Sendable () -> AsyncStream<Caregiver?> in
            // We don't have a per-user stream endpoint. Emit once and finish;
            // callers re-call when needed (e.g., after profile edits).
            AsyncStream { continuation in
                Task {
                    let me: MeResponseDTO? = try? await APIClient.shared.get("/me")
                    if let me {
                        continuation.yield(Caregiver(
                            id: me.id,
                            displayName: me.displayName,
                            photoURL: nil,
                            fcmToken: nil,
                            createdAt: me.createdAt ?? Date()
                        ))
                    } else {
                        continuation.yield(nil)
                    }
                    continuation.finish()
                }
            }
        },
        streamCaregivers: { @Sendable ids -> AsyncStream<[Caregiver]> in
            AsyncStream { continuation in
                Task {
                    var caregivers: [Caregiver] = []
                    for id in ids {
                        if let pub: PublicUserResponseDTO = try? await APIClient.shared.get("/users/\(id)") {
                            caregivers.append(Caregiver(
                                id: pub.id,
                                displayName: pub.displayName,
                                photoURL: nil,
                                fcmToken: nil,
                                createdAt: pub.createdAt
                            ))
                        }
                    }
                    continuation.yield(caregivers)
                    continuation.finish()
                }
            }
        },
        provisionCaregiver: { @Sendable () async throws(CaregiverError) in
            // The /auth/login/* endpoints already upsert a user row, so
            // provisioning is implicit. Verify reachability with GET /me.
            do {
                let _: MeResponseDTO = try await APIClient.shared.get("/me")
            } catch APIError.unauthorized {
                throw .unauthorized
            } catch {
                throw .unexpected
            }
        },
        updateDisplayName: { @Sendable name async throws(CaregiverError) in
            do {
                let req = UpdateMeRequestDTO(displayName: name)
                let _: MeResponseDTO = try await APIClient.shared.patch("/me", body: req)
            } catch APIError.unauthorized {
                throw .unauthorized
            } catch {
                throw .unexpected
            }
        }
    )
}

extension DependencyValues {
    public var caregiverClient: CaregiverClient {
        get { self[CaregiverClient.self] }
        set { self[CaregiverClient.self] = newValue }
    }
}

// MARK: - DTOs (extending the foundation MeResponseDTO with createdAt)

struct PublicUserResponseDTO: Decodable, Sendable {
    let id: String
    let displayName: String?
    let createdAt: Date
}

struct UpdateMeRequestDTO: Encodable, Sendable {
    let displayName: String?
}
