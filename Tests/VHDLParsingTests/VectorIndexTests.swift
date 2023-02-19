// VectorIndexTests.swift
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

@testable import VHDLParsing
import XCTest

/// Test class for ``VectorIndex``.
final class VectorIndexTests: XCTestCase {

    /// Test raw values are correct.
    func testRawValues() {
        XCTAssertEqual(VectorIndex.index(value: 4).rawValue, "4")
        XCTAssertEqual(VectorIndex.others.rawValue, "others")
        let range = VectorSize.downto(
            upper: .literal(value: .integer(value: 4)), lower: .literal(value: .integer(value: 1))
        )
        XCTAssertEqual(VectorIndex.range(value: range).rawValue, range.rawValue)
    }

    /// Test `init(rawValue:)` works correctly for index values.
    func testIndexRawValueInit() {
        XCTAssertEqual(VectorIndex(rawValue: "4"), .index(value: 4))
        XCTAssertEqual(VectorIndex(rawValue: "0"), .index(value: 0))
        XCTAssertEqual(VectorIndex(rawValue: " 1"), .index(value: 1))
        XCTAssertEqual(VectorIndex(rawValue: " 2 "), .index(value: 2))
        XCTAssertEqual(VectorIndex(rawValue: " 3  "), .index(value: 3))
        XCTAssertEqual(VectorIndex(rawValue: "4 "), .index(value: 4))
        XCTAssertEqual(VectorIndex(rawValue: "11"), .index(value: 11))
        XCTAssertNil(VectorIndex(rawValue: "A"))
        XCTAssertNil(VectorIndex(rawValue: "1 2"))
        XCTAssertNil(VectorIndex(rawValue: "-1"))
        XCTAssertNil(VectorIndex(rawValue: "1.0"))
        XCTAssertNil(VectorIndex(rawValue: "\(Int.min)1"))
        XCTAssertNil(VectorIndex(rawValue: "\(Int.max)1"))
        XCTAssertNil(VectorIndex(rawValue: ""))
        XCTAssertNil(VectorIndex(rawValue: " "))
        XCTAssertNil(VectorIndex(rawValue: String(repeating: "1", count: 256)))
    }

    /// Test `init(rawValue:)` works correctly for others values.
    func testOthersRawValueInit() {
        XCTAssertEqual(VectorIndex(rawValue: "others"), .others)
        XCTAssertEqual(VectorIndex(rawValue: " others"), .others)
        XCTAssertEqual(VectorIndex(rawValue: "others "), .others)
        XCTAssertEqual(VectorIndex(rawValue: " others "), .others)
        XCTAssertEqual(VectorIndex(rawValue: "OTHERS"), .others)
        XCTAssertEqual(VectorIndex(rawValue: "OtHErS"), .others)
        XCTAssertNil(VectorIndex(rawValue: "otherss"))
        XCTAssertNil(VectorIndex(rawValue: "other"))
    }

    /// Test `init(rawValue:)` works correctly for range values.
    func testRangeRawValueInit() {
        XCTAssertEqual(VectorIndex(rawValue: "4 downto 0"), .range(value: .downto(
            upper: .literal(value: .integer(value: 4)), lower: .literal(value: .integer(value: 0))
        )))
        XCTAssertEqual(VectorIndex(rawValue: "4 downto 0 "), .range(value: .downto(
            upper: .literal(value: .integer(value: 4)), lower: .literal(value: .integer(value: 0))
        )))
        XCTAssertEqual(VectorIndex(rawValue: " 4 downto 0"), .range(value: .downto(
            upper: .literal(value: .integer(value: 4)), lower: .literal(value: .integer(value: 0))
        )))
        XCTAssertEqual(VectorIndex(rawValue: " 4 downto 0 "), .range(value: .downto(
            upper: .literal(value: .integer(value: 4)), lower: .literal(value: .integer(value: 0))
        )))
        XCTAssertEqual(VectorIndex(rawValue: "0 to 4"), .range(value: .to(
            lower: .literal(value: .integer(value: 0)), upper: .literal(value: .integer(value: 4))
        )))
        XCTAssertNil(VectorIndex(rawValue: "\(String(repeating: "1", count: 256)) downto 0"))
    }

}
