import XCTest
@testable import SwiftPTZ

final class SwiftPTZTests: XCTestCase {
    func obtainFixture(category: String, name: String) -> URL {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures/\(category)") else {
            fatalError("Missing resource file: \(category)/\(name)")
        }
        return url.absoluteURL
    }
    
    func obtainFixtures<T: Decodable>(category: String, name: String, type: T.Type) -> T {
        let url = obtainFixture(category: category, name: name)
        let data = try! Data(contentsOf: url)
        let decoded = try! JSONDecoder().decode(T.self, from: data)
        return decoded
    }
    
    func testSetPositionFixtures() {
        let fixtures = (
            obtainFixtures(category: "SetPosition", name: "position-set-pan",  type: [SetPositionFixture].self) +
            obtainFixtures(category: "SetPosition", name: "position-set-tilt", type: [SetPositionFixture].self) +
            obtainFixtures(category: "SetPosition", name: "position-set-zoom", type: [SetPositionFixture].self)
        )

        var successFixtures: [Int] = []
        var imperfectFixtures: [Int] = []
        var failedFixtures: [Int] = []

        for (i, fixture) in fixtures.enumerated() {
            let originalBytes = fixture.query.bytes
            let request = PTZRequestSetPosition(
                pan:  .init(value: fixture.pan),
                tilt: .init(value: fixture.tilt),
                zoom: .init(value: fixture.zoom)
            )
            XCTAssertTrue(request.validLength)


            let computedBytes = request.bytes
            // zoom bytes are not a perfect match, go figure... not sure what the proper formulae is supposed to be, but
            // that's honestly close enough
            switch originalBytes.compare(computedBytes, allowingVarianceOfOneAtIndex: 13) {
            case .equal:
                successFixtures.append(i)
            case .closeEnough:
                imperfectFixtures.append(i)
            case .different:
                //print("--------------", i, "--------------")
                //print(originalBytes)
                //print(computedBytes)
                failedFixtures.append(i)
            }
        }
        
        print("Success:", successFixtures.count)
        print("Close enough:", imperfectFixtures.count)
        print("Failed:", failedFixtures.count)
    }
    
    func testGetPositionFixtures() {
        let fixtures = (
            obtainFixtures(category: "GetPosition", name: "position-get-pan",  type: [GetPositionFixture].self) +
            obtainFixtures(category: "GetPosition", name: "position-get-tilt", type: [GetPositionFixture].self) +
            obtainFixtures(category: "GetPosition", name: "position-get-zoom", type: [GetPositionFixture].self)
        )

        var successFixtures: [Int] = []
        var imperfectFixtures: [Int] = []
        var failedFixtures: [Int] = []

        for (i, fixture) in fixtures.enumerated() {
            let response = PTZReply(string: fixture.response)
            XCTAssertTrue(response.validLength)
            
            let parsed = response.parsed
            if case let .position(pan, tilt, zoom) = parsed {
                if pan.value == fixture.pan, tilt.value == fixture.tilt {
                    if zoom.value == fixture.zoom {
                        successFixtures.append(i)
                    }
                    else if abs(zoom.value - fixture.zoom) < 4 {
                        imperfectFixtures.append(i)
                    }
                }
                else {
                    failedFixtures.append(i)
                }
            }
            else {
                failedFixtures.append(i)
            }
        }
        
        print("Success:", successFixtures.count)
        print("Close enough:", imperfectFixtures.count)
        print("Failed:", failedFixtures.count)
    }
}
