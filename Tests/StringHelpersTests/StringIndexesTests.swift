// StringIndexesTests.swift
// VHDLParsing
//
// Created by Morgan McColl.
// Copyright © 2023 Morgan McColl. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above
//    copyright notice, this list of conditions and the following
//    disclaimer in the documentation and/or other materials
//    provided with the distribution.
//
// 3. All advertising materials mentioning features or use of this
//    software must display the following acknowledgement:
//
//    This product includes software developed by Morgan McColl.
//
// 4. Neither the name of the author nor the names of contributors
//    may be used to endorse or promote products derived from this
//    software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// -----------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the above terms or under the terms of the GNU
// General Public License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.
//

@testable import StringHelpers
import XCTest

/// Test class for `indexes(for: )` method in `String` extension.
final class StringIndexesTests: XCTestCase {

    /// Test indexes grab substring correctly when the data is a sentence.
    func testIndexesForSentence() {
        let data = "ABC DEF ABE ABF DEA"
        let sentence = ["ABE", "ABF"]
        let result = data.indexes(for: sentence)
        let sentenceLower = sentence.map { $0.lowercased() }
        let resultLowercased = data.indexes(for: sentenceLower)
        let resultCaseInsensitive = data.indexes(for: sentenceLower, isCaseSensitive: false)
        XCTAssertTrue(resultLowercased.isEmpty)
        guard result.count == 1 else {
            XCTFail("Incorrect indexes returned \(result.count).")
            return
        }
        XCTAssertEqual(result[0].0, data.index(data.startIndex, offsetBy: 8))
        XCTAssertEqual(data[result[0].0..<result[0].1], "ABE ABF")
        XCTAssertEqual(result[0].1, data.index(data.startIndex, offsetBy: 15))
        XCTAssertEqual(resultCaseInsensitive[0].0, data.index(data.startIndex, offsetBy: 8))
        XCTAssertEqual(data[resultCaseInsensitive[0].0..<resultCaseInsensitive[0].1], "ABE ABF")
        XCTAssertEqual(resultCaseInsensitive[0].1, data.index(data.startIndex, offsetBy: 15))
        XCTAssertEqual(resultCaseInsensitive.count, 1)
        let data2 = "ABC DEF ABEABF DEA"
        XCTAssertTrue(data2.indexes(for: sentence).isEmpty)
        let data3 = "ABC DEF ABE ABF"
        let result3 = data3.indexes(for: sentence)
        guard result3.count == 1 else {
            XCTFail("Incorrect indexes returned \(result3.count).")
            return
        }
        XCTAssertEqual(result3[0].0, data3.index(data3.startIndex, offsetBy: 8))
        XCTAssertEqual(data3[result3[0].0..<result3[0].1], "ABE ABF")
        XCTAssertEqual(result3[0].1, data3.index(data3.startIndex, offsetBy: 15))
        let data4 = "ABC ABE ABE ABF"
        let result4 = data4.indexes(for: sentence)
        guard result4.count == 1 else {
            XCTFail("Incorrect indexes returned \(result3.count).")
            return
        }
        XCTAssertEqual(result4[0].0, data4.index(data4.startIndex, offsetBy: 8))
        XCTAssertEqual(data4[result4[0].0..<result4[0].1], "ABE ABF")
        XCTAssertEqual(result4[0].1, data4.index(data4.startIndex, offsetBy: 15))
        let data5 = "ABC DEF ABE ABF DEA ABC DEF ABE ABF DEA"
        let result5 = data5.indexes(for: sentence)
        guard result5.count == 2 else {
            XCTFail("Incorrect indexes returned \(result.count).")
            return
        }
        XCTAssertEqual(result5[0].0, data5.index(data5.startIndex, offsetBy: 8))
        XCTAssertEqual(data5[result5[0].0..<result5[0].1], "ABE ABF")
        XCTAssertEqual(result5[0].1, data5.index(data5.startIndex, offsetBy: 15))
        XCTAssertEqual(result5[1].0, data5.index(data5.startIndex, offsetBy: 28))
        XCTAssertEqual(data5[result5[1].0..<result5[1].1], "ABE ABF")
        XCTAssertEqual(result5[1].1, data5.index(data5.startIndex, offsetBy: 35))
    }

    /// Test indexes for block with words previously found in string.
    func testIndexWordsBigText() {
        // swiftlint:disable:next line_length
        let raw =
            "process (clk)\nbegin\nif (rising_edge(clk)) then\nx <= y;\nend if;\nend process;\nx <= y;\nx <= y;"
        let data = ["end", "process;"]
        let result = raw.indexes(for: data)
        guard result.count == 1 else {
            XCTFail("Incorrect indexes returned \(result.count).")
            return
        }
        XCTAssertEqual(result[0].0, raw.index(raw.startIndex, offsetBy: 63))
        XCTAssertEqual(raw[result[0].0..<result[0].1], "end process;")
        XCTAssertEqual(result[0].1, raw.index(raw.startIndex, offsetBy: 75))
    }

    /// Test indexes method null cases.
    func testNullCases() {
        let data = "ABC DEF AB E ABF DEA"
        let sentence = ["ABE", "ABF"]
        XCTAssertTrue(data.indexes(for: sentence).isEmpty)
        let data2 = "ABC DEF ABE AB F DEA"
        XCTAssertTrue(data2.indexes(for: sentence).isEmpty)
        let data3 = "ABC DEF ABE ABF DE A"
        let sentence2 = ["ABE", "ABF", "DEA"]
        XCTAssertTrue(data3.indexes(for: sentence2).isEmpty)
        let data4 = "ABC DEF ABE ABF DE A ABE"
        XCTAssertTrue(data4.indexes(for: sentence2).isEmpty)
        XCTAssertTrue("".indexes(for: sentence).isEmpty)
        XCTAssertTrue("A".indexes(for: sentence).isEmpty)
        XCTAssertTrue(data.indexes(for: ["ABC", " "]).isEmpty)
    }

    /// Test `nextWord` function.
    func testNextWord() {
        let data = "ABC DEF ABE ABF DEA"
        let index = data.index(after: data.startIndex)
        XCTAssertEqual(data.nextWord(after: index), data.index(data.startIndex, offsetBy: 4))
        XCTAssertNil(data.nextWord(after: data.endIndex))
        let emptyString = ""
        XCTAssertNil(emptyString.nextWord(after: emptyString.startIndex))
    }

}
