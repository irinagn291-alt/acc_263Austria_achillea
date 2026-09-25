import Foundation

/// Role: Ask. Typed hop failures. This product has no remote catalog.
enum ReedFault: Error, Equatable, Sendable {
    case vacant
    case unreadable
    case lostReed
    case cutShort
    case notHTTP
}

/// Role: Ask. Injected hop so tests never leave the process.
protocol ReedChannel: Sendable {
    func haul(_ request: URLRequest) async throws -> (Data, URLResponse)
}

/// Role: Ask. URLSession hop with a 15 s timeout and the app User-Agent.
struct SessionReed: ReedChannel {
    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        configuration.httpAdditionalHeaders = ["User-Agent": AskCourier.userAgent]
        self.session = URLSession(configuration: configuration)
    }

    func haul(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

/// Role: Ask. Number or numeric string; missing stays nil. Never a domain field.
struct LooseMass: Sendable, Equatable, Decodable {
    var mass: Double?

    init(mass: Double?) {
        self.mass = mass
    }

    init(from decoder: Decoder) throws {
        let box = try decoder.singleValueContainer()
        if box.decodeNil() {
            mass = nil
            return
        }
        if let number = try? box.decode(Double.self) {
            mass = number
            return
        }
        if let whole = try? box.decode(Int.self) {
            mass = Double(whole)
            return
        }
        if let text = try? box.decode(String.self) {
            mass = Double(text)
            return
        }
        mass = nil
    }
}

struct StatusReed: Decodable, Sendable {
    var status: Int
}

/// Role: Ask. Owns the session. Contact URL is opened by Settings, not decoded here.
actor AskCourier {
    static let userAgent = "Achillea/1.0 (iOS; +https://achillea-ask.pro)"
    /// Literal contact URL. Failure here is a programmer error.
    static let contactURL = URL(string: "https://achillea-ask.pro/contact-us")!

    private let channel: any ReedChannel

    init(channel: any ReedChannel) {
        self.channel = channel
    }

    init() {
        self.channel = SessionReed()
    }

    func decodeReed<DTO: Decodable>(_ type: DTO.Type, from url: URL) async throws -> DTO {
        try Task.checkCancellation()
        let body = try await haul(ticket(for: url))
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            return try decoder.decode(DTO.self, from: body)
        } catch is CancellationError {
            throw ReedFault.cutShort
        } catch {
            throw ReedFault.unreadable
        }
    }

    func readStatus(from url: URL) async throws -> Int {
        let reed = try await decodeReed(StatusReed.self, from: url)
        if reed.status == 0 {
            throw ReedFault.vacant
        }
        return reed.status
    }

    private func ticket(for url: URL) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
        return request
    }

    private func haul(_ request: URLRequest) async throws -> Data {
        do {
            return try await send(request)
        } catch let fault as ReedFault {
            throw fault
        } catch is CancellationError {
            throw ReedFault.cutShort
        } catch {
            if Self.cutShort(error) {
                throw ReedFault.cutShort
            }
            guard Self.transient(error) else { throw ReedFault.lostReed }
            do {
                return try await send(request)
            } catch let fault as ReedFault {
                throw fault
            } catch is CancellationError {
                throw ReedFault.cutShort
            } catch {
                if Self.cutShort(error) { throw ReedFault.cutShort }
                throw ReedFault.lostReed
            }
        }
    }

    private func send(_ request: URLRequest) async throws -> Data {
        try Task.checkCancellation()
        let (body, reply) = try await channel.haul(request)
        guard let http = reply as? HTTPURLResponse else {
            throw ReedFault.notHTTP
        }
        if http.statusCode == 404 {
            throw ReedFault.vacant
        }
        guard (200 ..< 300).contains(http.statusCode) else {
            throw ReedFault.lostReed
        }
        return body
    }

    private static func transient(_ error: Error) -> Bool {
        guard let urlError = error as? URLError else { return false }
        switch urlError.code {
        case .timedOut, .networkConnectionLost, .notConnectedToInternet,
             .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
            return true
        default:
            return false
        }
    }

    private static func cutShort(_ error: Error) -> Bool {
        if error is CancellationError { return true }
        return (error as? URLError)?.code == .cancelled
    }
}
