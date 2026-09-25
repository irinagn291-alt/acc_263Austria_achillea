import XCTest
@testable import Achillea

final class AchilleaTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: AchilleaApp.self), "AchilleaApp")
    }
}
