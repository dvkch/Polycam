//
//  Foundation+PTZ.swift
//
//
//  Created by syan on 08/01/2024.
//

import Foundation

extension RandomAccessCollection where Self.Index == Int {
    func last(n: Int) -> [Element] {
        let firstIndex = Swift.max(0, count - n)
        let lastIndex = Swift.max(0, count)
        return Array(self[firstIndex..<lastIndex])
    }
}

extension Collection where Element : BinaryInteger {
    var isZero: Bool {
        guard !isEmpty else { return true }
        return filter { $0 == 0 }.count == self.count
    }
}

//17:28:11.039 DEBUG    SMan: hd[0]: CameraBase: In: Command: 3e8 fa 8b5 1f8
//17:28:11.039 INFO     SMan: hd[0]: CameraJCCP: Send 14 bytes: 8d 41 51 24 0 3 68 0 0 7a 3 2 8 35


/* Move right:  83 45 01 11, stop: 82 45 02
 
 < 83 45 01 11
 > 3E 5D DD 00
 > 3E 5D D9 00
 > 3E 5D D5 00

 < 82 45 02
 > 5F 5D 3F
 */


/** ZOOM +  =>  83 45 0C 00
 > 3E 5D BE 00
 > 3E 5D BE 00
 > 5F 5D 3C
 > 3E 5D BE 00
 */

/** Boot
 > 3F 7B FB 01
 > 3F 7B FB 01
 > 5F 7E 40
 > 5F 7E 40
 > 5F 7E 60
 > 5F 7E 60
 > 3E DF DF 00
 
 > 3F 7B FB 01
 > 3F 7B FB 01
 > 5F 7E 40
 > 5F 7E 40
 > 5F 7E 60
 > 5F 7E 60
 > 3E DF DF 00
 
 > 3F 7B FB 01
 > 3F 7B FB 01
 > 5F 7E 40
 > 5F 7E 40
 > 5F 7E 60
 > 5F 7E 60
 > 3E DF DF 00 5F 96 0E 5F 7E C4
 > 5F 96 0E 5F 7E C4
 
 
 > 3F 7B FB 01
 > 3F 7B FB 01
 > 5F 7E 40
 > 5F 7E 40
 > 5F 7E 60
 > 5F 7E 60
 > 3E DF DF 00 5F 96 0E 5F 7E C4
 > 5F 96 0E 5F 7E C4

 > 3F 7B FB 01
 > 3F 7B FB 01
 > 5F 7E 40
 > 5F 7E 40
 > 5F 7E 60
 > 5F 7E 60
 > 3E DF DF 00 5F 96 CE CD 11 00
 > 5F 96 0E 5F 7E C4

 > 3F 7B FB 01
 > 3F 7B FB 01
 > 5F 7E 40
 > 5F 7E 40
 > 5F 7E 60
 > 5F 7E 60
 > 3E DF DF 60 9D 69 F6 CD 11 00
 > 5F 96 0E 5F 7E C4
 
 */

/** Brightness: 10 =>  3E DF E6 40 */
/** Brightness: 13 =>  AF CB FD F6 00 */
