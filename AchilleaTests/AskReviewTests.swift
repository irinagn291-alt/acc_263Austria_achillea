import XCTest
@testable import Achillea

final class AskReviewTests: XCTestCase {
    func test_readsTodayLogGoalsOnceAfterOnboarding() {
        var consumed = false
        XCTAssertEqual(
            AskReview.consume(
                arguments: ["-ReviewScreen", "today"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .today
        )
        XCTAssertTrue(consumed)
        XCTAssertNil(
            AskReview.consume(
                arguments: ["-ReviewScreen", "log"],
                onboardingComplete: true,
                consumed: &consumed
            )
        )

        consumed = false
        XCTAssertEqual(
            AskReview.consume(
                arguments: ["-ReviewScreen", "log"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .log
        )

        consumed = false
        XCTAssertEqual(
            AskReview.consume(
                arguments: ["-ReviewScreen", "goals"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .goals
        )
    }

    func test_skipsWhenOnboardingIncomplete() {
        var consumed = false
        XCTAssertNil(
            AskReview.consume(
                arguments: ["-ReviewScreen", "today"],
                onboardingComplete: false,
                consumed: &consumed
            )
        )
        XCTAssertFalse(consumed)
    }

    func test_missingOrUnknownIsNil() {
        var consumed = false
        XCTAssertNil(
            AskReview.consume(arguments: [], onboardingComplete: true, consumed: &consumed)
        )
        consumed = false
        XCTAssertNil(
            AskReview.consume(
                arguments: ["-ReviewScreen"],
                onboardingComplete: true,
                consumed: &consumed
            )
        )
        consumed = false
        XCTAssertNil(
            AskReview.consume(
                arguments: ["-ReviewScreen", "charts"],
                onboardingComplete: true,
                consumed: &consumed
            )
        )
        XCTAssertEqual(AskReview(slug: "today"), .today)
        XCTAssertEqual(AskReview(slug: "log"), .log)
        XCTAssertEqual(AskReview(slug: "goals"), .goals)
        XCTAssertNil(AskReview(slug: "history"))
    }

    func test_extraCoverSlugsMapOntoSheets() {
        XCTAssertTrue(AskReview.isHomeSlug("today"))
        XCTAssertTrue(AskReview.isHomeSlug("ask"))
        XCTAssertFalse(AskReview.isHomeSlug("history"))
        XCTAssertEqual(AskReview.sheet(forSlug: "history"), .history)
        XCTAssertEqual(AskReview.sheet(forSlug: "log"), .history)
        XCTAssertEqual(AskReview.sheet(forSlug: "settings"), .settings)
        XCTAssertEqual(AskReview.sheet(forSlug: "settingsview"), .settings)
        XCTAssertEqual(AskReview.sheet(forSlug: "goals"), .settings)
        XCTAssertEqual(AskReview.sheet(forSlug: "twist"), .twist)
        XCTAssertEqual(AskReview.sheet(forSlug: "gageguide"), .twist)
        XCTAssertNil(AskReview.sheet(forSlug: "charts"))
    }

    func test_massDraftRejectsNegativeAndJunk() {
        XCTAssertTrue(AskFigures.allowsMassDraft(""))
        XCTAssertTrue(AskFigures.allowsMassDraft("1"))
        XCTAssertEqual(try XCTUnwrap(AskFigures.parseMass("1.5")), 1.5, accuracy: 1e-9)
        XCTAssertFalse(AskFigures.allowsMassDraft("-1"))
        XCTAssertFalse(AskFigures.allowsMassDraft("+2"))
        XCTAssertFalse(AskFigures.allowsMassDraft("nope"))
        XCTAssertNil(AskFigures.parseMass("-3"))
    }
}
