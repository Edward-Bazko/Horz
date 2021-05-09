import XCTest
@testable import Horz

class HorzTests: XCTestCase {
    func testExample() {
        let ud = UrbanDictionary()
        let e = expectation(description: "ud")
        ud.fetchManyRandomWords(count: 5) { result in
            print(">>" + String(describing: result))
            e.fulfill()
        }
        wait(for: [e], timeout: 10)
    }
}
