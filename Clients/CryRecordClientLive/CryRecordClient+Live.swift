import ComposableArchitecture
import Domain
import Foundation
import Shared

extension CryRecordClient: @retroactive TestDependencyKey {}
extension CryRecordClient: @retroactive DependencyKey {
    public static let liveValue = Self(
        loadRecords: { @Sendable babyID, range async throws(CryRecordError) -> [CryAnalysisRecord] in
            do {
                let dtos: [CryRecordResponseDTO] = try await APIClient.shared.get(
                    "/babies/\(babyID.uuidString)/cry-records"
                )
                return dtos
                    .filter { range.contains($0.createdAt) }
                    .map { $0.toCryAnalysisRecord() }
            } catch let api as APIError {
                throw mapCryError(api)
            } catch {
                throw .unexpected
            }
        },
        addRecord: { @Sendable babyID, record async throws(CryRecordError) in
            do {
                let req = CreateCryRecordRequestDTO(
                    windows: record.windows,
                    audioURL: nil
                )
                let _: CryRecordResponseDTO = try await APIClient.shared.postJSON(
                    "/babies/\(babyID.uuidString)/cry-records",
                    body: req
                )
            } catch let api as APIError {
                throw mapCryError(api)
            } catch {
                throw .unexpected
            }
        },
        deleteRecord: { @Sendable babyID, recordID async throws(CryRecordError) in
            do {
                try await APIClient.shared.deleteEmpty(
                    "/babies/\(babyID.uuidString)/cry-records/\(recordID.uuidString)"
                )
            } catch let api as APIError {
                throw mapCryError(api)
            } catch {
                throw .unexpected
            }
        }
    )
}

extension DependencyValues {
    public var cryRecordClient: CryRecordClient {
        get { self[CryRecordClient.self] }
        set { self[CryRecordClient.self] = newValue }
    }
}

// MARK: - DTOs

struct CryRecordResponseDTO: Decodable, Sendable {
    let id: UUID
    let babyId: UUID
    let creatorId: String
    let windows: [[EmotionScore]]
    let audioURL: String?
    let createdAt: Date

    func toCryAnalysisRecord() -> CryAnalysisRecord {
        CryAnalysisRecord(id: id, createdAt: createdAt, windows: windows)
    }
}

struct CreateCryRecordRequestDTO: Encodable, Sendable {
    let windows: [[EmotionScore]]
    let audioURL: String?
}

private func mapCryError(_ error: APIError) -> CryRecordError {
    switch error {
    case .unauthorized: return .unauthorized
    case .forbidden:    return .unauthorized
    case .notFound:     return .notFound
    default:            return .unexpected
    }
}
