import XCTest
@testable import Achillea

private struct ProbeDTO: Decodable {
    var mass: LooseMass
}

private actor ScriptedReed: ReedChannel {
    private var results: [Result<(Data, URLResponse), Error>]
    private var requests: [URLRequest] = []

    init(results: [Result<(Data, URLResponse), Error>]) {
        self.results = results
    }

    func haul(_ request: URLRequest) async throws -> (Data, URLResponse) {
        requests.append(request)
        guard !results.isEmpty else { throw URLError(.cannotConnectToHost) }
        return try results.removeFirst().get()
    }

    func recordedRequests() -> [URLRequest] {
        requests
    }
}

final class AskCourierTests: XCTestCase {
    private let url = URL(string: "https://achillea-ask.pro/probe")!

    func test_setsUserAgentOnEveryRequest() async throws {
        let channel = ScriptedReed(results: [
            .success((Data("{\"mass\":1}".utf8), http(200))),
        ])
        let courier = AskCourier(channel: channel)
        _ = try await courier.decodeReed(ProbeDTO.self, from: url)
        let request = await channel.recordedRequests().first
        XCTAssertEqual(request?.value(forHTTPHeaderField: "User-Agent"), AskCourier.userAgent)
        XCTAssertEqual(request?.timeoutInterval, 15)
        XCTAssertEqual(AskCourier.userAgent, "Achillea/1.0 (iOS; +https://achillea-ask.pro)")
        XCTAssertEqual(AskCourier.contactURL.absoluteString, "https://achillea-ask.pro/contact-us")
    }

    func test_retriesTransientTransportOnce() async throws {
        let channel = ScriptedReed(results: [
            .failure(URLError(.timedOut)),
            .success((Data("{\"mass\":\"4.5\"}".utf8), http(200))),
        ])
        let courier = AskCourier(channel: channel)
        let dto = try await courier.decodeReed(ProbeDTO.self, from: url)
        XCTAssertEqual(dto.mass.mass, 4.5)
        let count = await channel.recordedRequests().count
        XCTAssertEqual(count, 2)
    }

    func test_doesNotRetry404() async {
        let channel = ScriptedReed(results: [
            .success((Data(), http(404))),
            .success((Data("{\"mass\":1}".utf8), http(200))),
        ])
        let courier = AskCourier(channel: channel)
        do {
            _ = try await courier.decodeReed(ProbeDTO.self, from: url)
            XCTFail("expected vacant")
        } catch {
            XCTAssertEqual(error as? ReedFault, .vacant)
        }
        let count = await channel.recordedRequests().count
        XCTAssertEqual(count, 1)
    }

    func test_malformedJSONIsUnreadable() async {
        let channel = ScriptedReed(results: [
            .success((Data("{".utf8), http(200))),
        ])
        let courier = AskCourier(channel: channel)
        do {
            _ = try await courier.decodeReed(ProbeDTO.self, from: url)
            XCTFail("expected unreadable")
        } catch {
            XCTAssertEqual(error as? ReedFault, .unreadable)
        }
    }

    func test_statusZeroMapsToVacant() async {
        let channel = ScriptedReed(results: [
            .success((Data("{\"status\":0}".utf8), http(200))),
        ])
        let courier = AskCourier(channel: channel)
        do {
            _ = try await courier.readStatus(from: url)
            XCTFail("expected vacant")
        } catch {
            XCTAssertEqual(error as? ReedFault, .vacant)
        }
    }

    func test_looseMassAcceptsNumberAndString() throws {
        let number = try JSONDecoder().decode(ProbeDTO.self, from: Data("{\"mass\":12.5}".utf8))
        let string = try JSONDecoder().decode(ProbeDTO.self, from: Data("{\"mass\":\"12.5\"}".utf8))
        let missing = try JSONDecoder().decode(ProbeDTO.self, from: Data("{\"mass\":null}".utf8))
        XCTAssertEqual(number.mass.mass, 12.5)
        XCTAssertEqual(string.mass.mass, 12.5)
        XCTAssertNil(missing.mass.mass)
    }

    private func http(_ status: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!
    }
}
