// IndexedValue.swift
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

/// Test class for ``IndexedValue``.
final class IndexedValueTests: XCTestCase {

    /// A value under test.
    let value = IndexedValue(index: .others, value: .bit(value: .high))

    /// Test initialiser sets stored properties correctly.
    func testInit() {
        XCTAssertEqual(value.index, .others)
        XCTAssertEqual(value.value, .literal(value: .bit(value: .high)))
    }

    /// Test the expression initialiser.
    func testExpressionInit() {
        let value = IndexedValue(index: .others, value: .literal(value: .bit(value: .high)))
        XCTAssertEqual(value.index, .others)
        XCTAssertEqual(value.value, .literal(value: .bit(value: .high)))
    }

    /// Test `rawValue` creates `VHDL` code correctly.
    func testRawValue() {
        XCTAssertEqual(value.rawValue, "others => '1'")
        XCTAssertEqual(
            IndexedValue(
                index: .index(value: .literal(value: .integer(value: 1))), value: .bit(value: .low)
            ).rawValue,
            "1 => '0'"
        )
        XCTAssertEqual(
            IndexedValue(
                index: .range(value: .downto(
                    upper: .literal(value: .integer(value: 2)), lower: .literal(value: .integer(value: 0))
                )),
                value: .bit(value: .low)
            ).rawValue,
            "2 downto 0 => '0'"
        )
    }

    /// Test `init(rawValue:)` parses `VHDL` code correctly.
    func testRawValueInit() {
        XCTAssertEqual(IndexedValue(rawValue: "others => '1'"), value)
        XCTAssertEqual(IndexedValue(rawValue: "others => '1' "), value)
        XCTAssertEqual(IndexedValue(rawValue: " others => '1'"), value)
        XCTAssertEqual(IndexedValue(rawValue: " others => '1' "), value)
        XCTAssertEqual(IndexedValue(rawValue: "others => '1',"), value)
        XCTAssertEqual(IndexedValue(rawValue: "others => '1', "), value)
        XCTAssertEqual(IndexedValue(rawValue: " others => '1',"), value)
        XCTAssertEqual(IndexedValue(rawValue: " others => '1', "), value)
        XCTAssertEqual(
            IndexedValue(rawValue: "3 downto 0 => '1',"),
            IndexedValue(
                index: .range(value: .downto(
                    upper: .literal(value: .integer(value: 3)), lower: .literal(value: .integer(value: 0))
                )),
                value: .bit(value: .high)
            )
        )
        XCTAssertEqual(
            IndexedValue(rawValue: "1 => '1'"),
            IndexedValue(index: .index(value: .literal(value: .integer(value: 1))), value: .bit(value: .high))
        )
        XCTAssertEqual(
            IndexedValue(rawValue: "others => 'U'"),
            IndexedValue(index: .others, value: .logic(value: .uninitialized))
        )
        XCTAssertNil(IndexedValue(rawValue: "others => '1' => '0'"))
        XCTAssertNil(IndexedValue(rawValue: "2 => '1', others => '0'"))
        XCTAssertNil(IndexedValue(rawValue: ""))
        XCTAssertNil(IndexedValue(rawValue: " "))
        XCTAssertNil(IndexedValue(rawValue: "\n"))
        XCTAssertNil(IndexedValue(rawValue: "\(String(repeating: "1", count: 256)) => '1'"))
        XCTAssertEqual(
            IndexedValue(rawValue: "abx => '1'"),
            IndexedValue(
                index: .index(value: .reference(variable: .variable(name: VariableName(text: "abx")))),
                value: .bit(value: .high)
            )
        )
        XCTAssertNil(IndexedValue(rawValue: "signal x: std_logic_vector(3 downto 0) := (others => '1');"))
        XCTAssertNil(IndexedValue(rawValue: "others => \"1\""))
        XCTAssertNil(IndexedValue(rawValue: "others => 1"))
    }

}
