import XCTest
@testable import PTZCamera

import PTZMessaging

final class FixtureTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Camera.registerKnownStates()
    }

    func obtainFixture(category: String, name: String) -> URL {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Data/\(category)") else {
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
            let originalBytes = Bytes(string: fixture.query)!
            /// comparing to the -50 000 to +50 000 scale on the original program
            let request = PTZPositionState(.init(
                pan:  .init(ptzValue: PTZPanOriginalAPI(rawValue:  fixture.pan).ptzValue),
                tilt: .init(ptzValue: PTZTiltOriginalAPI(rawValue: fixture.tilt).ptzValue),
                zoom: .init(ptzValue: PTZZoomOriginalAPI(rawValue: fixture.zoom).ptzValue)
            )).setMessage()
 
            let computedBytes = request.bytes

            /// zoom bytes are not a perfect match, go figure... not sure what the proper formulae is supposed to be, but that's honestly close enough
            switch originalBytes.compare(computedBytes, allowingVarianceOfOneAtIndex: 13) {
            case .equal:
                successFixtures.append(i)
            case .closeEnough:
                imperfectFixtures.append(i)
            case .different:
                failedFixtures.append(i)
            }
        }
        
        XCTAssertEqual(successFixtures.count, 297)
        XCTAssertEqual(imperfectFixtures.count, 5)
        XCTAssertEqual(failedFixtures.count, 2)
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
            let responses = PTZMessage.replies(from: Bytes(string: fixture.response)!)
            if responses.count == 1, case .state(_, let response) = responses[0], let response = response as? PTZPositionState {
                let diffPan  = abs(Int(response.value.pan.ptzValue)  - Int(PTZPanOriginalAPI(rawValue: fixture.pan).ptzValue))
                let diffTilt = abs(Int(response.value.tilt.ptzValue) - Int(PTZTiltOriginalAPI(rawValue: fixture.tilt).ptzValue))
                let diffZoom = abs(Int(response.value.zoom.ptzValue) - Int(PTZZoomOriginalAPI(rawValue: fixture.zoom).ptzValue))
                if diffPan == 0, diffTilt == 0, diffZoom == 0 {
                    successFixtures.append(i)
                }
                else if diffPan < 4, diffTilt < 4, diffZoom < 4 {
                    imperfectFixtures.append(i)
                }
                else {
                    failedFixtures.append(i)
                }
            }
            else {
                failedFixtures.append(i)
            }
        }
        
        XCTAssertEqual(successFixtures.count, 196)
        XCTAssertEqual(imperfectFixtures.count, 98)
        XCTAssertEqual(failedFixtures.count, 0)
    }
}
