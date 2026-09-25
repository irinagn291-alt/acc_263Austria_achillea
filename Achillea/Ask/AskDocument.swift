import Foundation

/// Role: Ask. Codable envelope for UserDefaults ach.ask.v1. Fold is stored as the ADT.
struct AskDocument: Codable, Equatable, Sendable {
    var schemaVersion: Int
    var names: [NameRecord]
    var fold: AskFold
    var gageMark: GageMarkRecord?
    var slips: [SlipRecord]
    var records: [FiledRecord]
    var dispute: Bool
    var onboardingComplete: Bool

    static func envelope(from ask: Ask) -> AskDocument {
        AskDocument(
            schemaVersion: AskCodec.currentSchema,
            names: ask.names.map { NameRecord(id: $0.id, text: $0.text, mass: $0.stalk.mass) },
            fold: ask.fold,
            gageMark: ask.gageMark.map { mark in
                GageMarkRecord(
                    id: mark.id,
                    dayKey: mark.dayKey,
                    stampedEpoch: mark.stampedAt.timeIntervalSince1970,
                    nameIDs: mark.nameIDs
                )
            },
            slips: ask.slips.map { slip in
                SlipRecord(
                    id: slip.id,
                    nameID: slip.nameID,
                    nameText: slip.nameText,
                    mass: slip.mass,
                    dayKey: slip.dayKey,
                    filedEpoch: slip.filedAt.timeIntervalSince1970
                )
            },
            records: ask.records.map { record in
                FiledRecord(
                    id: record.id,
                    slipID: record.slipID,
                    nameID: record.nameID,
                    nameText: record.nameText,
                    dayKey: record.dayKey,
                    filedEpoch: record.filedAt.timeIntervalSince1970
                )
            },
            dispute: ask.dispute,
            onboardingComplete: ask.onboardingComplete
        )
    }

    func asAsk() -> Ask {
        Ask(
            names: names.map { Name(id: $0.id, text: $0.text, stalk: Stalk(mass: $0.mass)) },
            fold: fold,
            gageMark: gageMark.map { mark in
                GageMark(
                    id: mark.id,
                    dayKey: mark.dayKey,
                    stampedAt: Date(timeIntervalSince1970: mark.stampedEpoch),
                    nameIDs: mark.nameIDs
                )
            },
            slips: slips.map { slip in
                Slip(
                    id: slip.id,
                    nameID: slip.nameID,
                    nameText: slip.nameText,
                    mass: slip.mass,
                    dayKey: slip.dayKey,
                    filedAt: Date(timeIntervalSince1970: slip.filedEpoch)
                )
            },
            records: records.map { record in
                DecisionRecord(
                    id: record.id,
                    slipID: record.slipID,
                    nameID: record.nameID,
                    nameText: record.nameText,
                    dayKey: record.dayKey,
                    filedAt: Date(timeIntervalSince1970: record.filedEpoch)
                )
            },
            dispute: dispute,
            onboardingComplete: onboardingComplete
        )
    }
}

struct NameRecord: Codable, Equatable, Sendable {
    var id: UUID
    var text: String
    var mass: Double
}

struct GageMarkRecord: Codable, Equatable, Sendable {
    var id: UUID
    var dayKey: Int
    var stampedEpoch: TimeInterval
    var nameIDs: [UUID]
}

struct SlipRecord: Codable, Equatable, Sendable {
    var id: UUID
    var nameID: UUID
    var nameText: String
    var mass: Double
    var dayKey: Int
    var filedEpoch: TimeInterval
}

struct FiledRecord: Codable, Equatable, Sendable {
    var id: UUID
    var slipID: UUID
    var nameID: UUID
    var nameText: String
    var dayKey: Int
    var filedEpoch: TimeInterval
}

/// Role: Ask. Schema switch. Domain types never decode this JSON themselves.
enum AskCodec {
    static let currentSchema = 1

    enum Failure: Error, Equatable {
        case unsupportedSchema(Int)
        case corrupt
    }

    static func encode(_ document: AskDocument) throws -> Data {
        var copy = document
        copy.schemaVersion = currentSchema
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(copy)
    }

    static func decode(_ data: Data) throws -> AskDocument {
        let decoder = JSONDecoder()
        let probe: SchemaProbe
        do {
            probe = try decoder.decode(SchemaProbe.self, from: data)
        } catch {
            throw Failure.corrupt
        }
        switch probe.schemaVersion {
        case 1:
            do {
                var document = try decoder.decode(AskDocument.self, from: data)
                document.schemaVersion = currentSchema
                return document
            } catch {
                throw Failure.corrupt
            }
        default:
            throw Failure.unsupportedSchema(probe.schemaVersion)
        }
    }
}

private struct SchemaProbe: Decodable {
    var schemaVersion: Int
}
