import ComposableArchitecture
import Domain
import Foundation
import Shared

extension CareRecordClient: @retroactive TestDependencyKey {}
extension CareRecordClient: @retroactive DependencyKey {
    public static let liveValue = Self(
        loadRecords: { @Sendable babyID, range async throws(CareRecordError) -> [CareRecord] in
            do {
                let query: [String: String] = [
                    "from": ISO8601.fractional.string(from: range.lowerBound),
                    "to":   ISO8601.fractional.string(from: range.upperBound)
                ]
                let dtos: [CareRecordResponseDTO] = try await APIClient.shared.get(
                    "/babies/\(babyID.uuidString)/care-records",
                    query: query
                )
                return dtos.compactMap { $0.toCareRecord() }
            } catch let api as APIError {
                throw mapCareError(api)
            } catch {
                throw .unexpected
            }
        },
        lastEvent: { @Sendable babyID, category async throws(CareRecordError) -> CareEvent? in
            do {
                let dtos: [CareRecordResponseDTO] = try await APIClient.shared.get(
                    "/babies/\(babyID.uuidString)/care-records"
                )
                for dto in dtos {
                    if let event = dto.event.toCareEvent(), event.category == category {
                        return event
                    }
                }
                return nil
            } catch let api as APIError {
                throw mapCareError(api)
            } catch {
                throw .unexpected
            }
        },
        addRecord: { @Sendable babyID, record async throws(CareRecordError) in
            do {
                let req = CreateCareRecordRequestDTO(
                    event: CareEventDTO(record.event),
                    content: record.content,
                    occurredAt: record.createdAt
                )
                let _: CareRecordResponseDTO = try await APIClient.shared.postJSON(
                    "/babies/\(babyID.uuidString)/care-records",
                    body: req
                )
            } catch let api as APIError {
                throw mapCareError(api)
            } catch {
                throw .unexpected
            }
        },
        updateRecord: { @Sendable babyID, record async throws(CareRecordError) in
            do {
                let req = UpdateCareRecordRequestDTO(
                    event: CareEventDTO(record.event),
                    content: record.content,
                    occurredAt: record.createdAt
                )
                let _: CareRecordResponseDTO = try await APIClient.shared.patch(
                    "/babies/\(babyID.uuidString)/care-records/\(record.id.uuidString)",
                    body: req
                )
            } catch let api as APIError {
                throw mapCareError(api)
            } catch {
                throw .unexpected
            }
        },
        deleteRecord: { @Sendable babyID, recordID async throws(CareRecordError) in
            do {
                try await APIClient.shared.deleteEmpty(
                    "/babies/\(babyID.uuidString)/care-records/\(recordID.uuidString)"
                )
            } catch let api as APIError {
                throw mapCareError(api)
            } catch {
                throw .unexpected
            }
        }
    )
}

extension DependencyValues {
    public var careRecordClient: CareRecordClient {
        get { self[CareRecordClient.self] }
        set { self[CareRecordClient.self] = newValue }
    }
}

// MARK: - DTOs

struct CareRecordResponseDTO: Decodable, Sendable {
    let id: UUID
    let babyId: UUID
    let creatorId: String
    let event: CareEventDTO
    let content: String?
    let occurredAt: Date
    let createdAt: Date

    func toCareRecord() -> CareRecord? {
        guard let event = event.toCareEvent() else { return nil }
        return CareRecord(
            id: id,
            createdAt: occurredAt,   // Domain treats `createdAt` as event time.
            event: event,
            content: content
        )
    }
}

struct CreateCareRecordRequestDTO: Encodable, Sendable {
    let event: CareEventDTO
    let content: String?
    let occurredAt: Date
}

struct UpdateCareRecordRequestDTO: Encodable, Sendable {
    let event: CareEventDTO?
    let content: String?
    let occurredAt: Date?
}

/// Tagged-union representation of `Domain.CareEvent` for JSON exchange with the
/// backend. Single flat struct (all variant fields optional) keeps the wire
/// format simple and Jackson-friendly on the server side.
struct CareEventDTO: Codable, Sendable {
    let type: String
    let ml: Int?
    let leftMinutes: Int?
    let rightMinutes: Int?
    let start: Date?
    let end: Date?
    let celsius: Double?
    let heightCm: Double?
    let weightKg: Double?

    init(
        type: String,
        ml: Int? = nil,
        leftMinutes: Int? = nil,
        rightMinutes: Int? = nil,
        start: Date? = nil,
        end: Date? = nil,
        celsius: Double? = nil,
        heightCm: Double? = nil,
        weightKg: Double? = nil
    ) {
        self.type = type
        self.ml = ml
        self.leftMinutes = leftMinutes
        self.rightMinutes = rightMinutes
        self.start = start
        self.end = end
        self.celsius = celsius
        self.heightCm = heightCm
        self.weightKg = weightKg
    }

    init(_ event: CareEvent) {
        switch event {
        case let .formula(ml):          self.init(type: "formula",       ml: ml)
        case let .babyFood(ml):         self.init(type: "babyFood",      ml: ml)
        case let .pumpedMilk(ml):       self.init(type: "pumpedMilk",    ml: ml)
        case let .breastfeeding(l, r):  self.init(type: "breastfeeding", leftMinutes: l, rightMinutes: r)
        case .pee:                      self.init(type: "pee")
        case .poop:                     self.init(type: "poop")
        case .pottyAll:                 self.init(type: "pottyAll")
        case let .sleep(s, e):          self.init(type: "sleep", start: s, end: e)
        case .bath:                     self.init(type: "bath")
        case .snack:                    self.init(type: "snack")
        case let .temperature(c):       self.init(type: "temperature", celsius: c)
        case .medicine:                 self.init(type: "medicine")
        case .clinic:                   self.init(type: "clinic")
        case let .heightWeight(h, w):   self.init(type: "heightWeight", heightCm: h, weightKg: w)
        }
    }

    func toCareEvent() -> CareEvent? {
        switch type {
        case "formula":         return ml.map { .formula(ml: $0) }
        case "babyFood":        return ml.map { .babyFood(ml: $0) }
        case "pumpedMilk":      return ml.map { .pumpedMilk(ml: $0) }
        case "breastfeeding":
            guard let l = leftMinutes, let r = rightMinutes else { return nil }
            return .breastfeeding(leftMinutes: l, rightMinutes: r)
        case "pee":             return .pee
        case "poop":            return .poop
        case "pottyAll":        return .pottyAll
        case "sleep":
            guard let s = start else { return nil }
            return .sleep(start: s, end: end)
        case "bath":            return .bath
        case "snack":           return .snack
        case "temperature":     return celsius.map { .temperature(celsius: $0) }
        case "medicine":        return .medicine
        case "clinic":          return .clinic
        case "heightWeight":    return .heightWeight(heightCm: heightCm, weightKg: weightKg)
        default:                return nil
        }
    }
}

private func mapCareError(_ error: APIError) -> CareRecordError {
    switch error {
    case .unauthorized: return .unauthorized
    case .forbidden:    return .unauthorized
    case .notFound:     return .notFound
    default:            return .unexpected
    }
}
