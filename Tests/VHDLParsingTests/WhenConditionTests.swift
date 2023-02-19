// WhenConditionTests.swift
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

/// Test class for ``WhenCondition``.
final class WhenConditionTests: XCTestCase {

    /// Test `rawValue` generates `VHDL` code correctly.
    func testRawValues() {
        XCTAssertEqual(WhenCondition.others.rawValue, "others")
        XCTAssertEqual(
            WhenCondition.expression(expression: .literal(value: .bit(value: .high))).rawValue, "'1'"
        )
        XCTAssertEqual(
            WhenCondition.selection(expressions: [
                .literal(value: .integer(value: 1)),
                .literal(value: .integer(value: 2)),
                .literal(value: .integer(value: 3))
            ]).rawValue,
            "1|2|3"
        )
        XCTAssertEqual(
            WhenCondition.range(range: .downto(
                upper: .literal(value: .integer(value: 3)), lower: .literal(value: .integer(value: 0))
            )).rawValue,
            "3 downto 0"
        )
    }

    /// Test init for others case.
    func testOthersInit() {
        XCTAssertEqual(WhenCondition(rawValue: "others"), .others)
        XCTAssertEqual(WhenCondition(rawValue: "others "), .others)
        XCTAssertEqual(WhenCondition(rawValue: " others"), .others)
        XCTAssertEqual(WhenCondition(rawValue: " others "), .others)
    }

    /// Test init for selection case.
    func testSelectionInit() {
        let expected = WhenCondition.selection(expressions: [
            .literal(value: .integer(value: 1)),
            .literal(value: .integer(value: 2)),
            .literal(value: .integer(value: 3))
        ])
        XCTAssertEqual(WhenCondition(rawValue: "1|2|3"), expected)
        XCTAssertEqual(WhenCondition(rawValue: "1|2|3 "), expected)
        XCTAssertEqual(WhenCondition(rawValue: " 1|2|3"), expected)
        XCTAssertEqual(WhenCondition(rawValue: " 1|2|3 "), expected)
        XCTAssertEqual(WhenCondition(rawValue: " 1  |  2  |  3  "), expected)
        XCTAssertNil(WhenCondition(rawValue: "1|2|"))
        XCTAssertNil(WhenCondition(rawValue: "1||3"))
        XCTAssertNil(WhenCondition(rawValue: "|2|3"))
        XCTAssertNil(WhenCondition(rawValue: "1|2|3;"))
        XCTAssertNil(WhenCondition(rawValue: "1|2|\(String(repeating: "3", count: 256))"))
    }

    /// Test init for expression case.
    func testExpressionInit() {
        let expected = WhenCondition.expression(expression: .variable(name: VariableName(text: "x")))
        XCTAssertEqual(WhenCondition(rawValue: "x"), expected)
        XCTAssertEqual(WhenCondition(rawValue: "x "), expected)
        XCTAssertEqual(WhenCondition(rawValue: " x"), expected)
        XCTAssertEqual(WhenCondition(rawValue: " x "), expected)
        XCTAssertEqual(WhenCondition(rawValue: " x \n"), expected)
        XCTAssertEqual(WhenCondition(rawValue: " x \t"), expected)
        XCTAssertEqual(WhenCondition(rawValue: " x \r"), expected)
        XCTAssertNil(WhenCondition(rawValue: "x;"))
        XCTAssertNil(WhenCondition(rawValue: ""))
        XCTAssertNil(WhenCondition(rawValue: " "))
        XCTAssertNil(WhenCondition(rawValue: "\n"))
        XCTAssertNil(WhenCondition(rawValue: "\(String(repeating: "x", count: 256))"))
    }

    /// Test init for range case.
    func testRangeInit() {
        let expected = WhenCondition.range(range: .downto(
            upper: .literal(value: .integer(value: 3)), lower: .literal(value: .integer(value: 0))
        ))
        XCTAssertEqual(WhenCondition(rawValue: "3 downto 0"), expected)
        XCTAssertEqual(WhenCondition(rawValue: "3 downto 0 "), expected)
        XCTAssertEqual(WhenCondition(rawValue: " 3 downto 0"), expected)
        XCTAssertEqual(WhenCondition(rawValue: " 3 downto 0 "), expected)
        XCTAssertEqual(WhenCondition(rawValue: "3  downto  0"), expected)
        XCTAssertNil(WhenCondition(rawValue: "3 downto"))
        XCTAssertNil(WhenCondition(rawValue: "downto 0"))
        XCTAssertNil(WhenCondition(rawValue: "3 downt0 0"))
        XCTAssertNil(WhenCondition(rawValue: "3 downto 0;"))
    }

}
