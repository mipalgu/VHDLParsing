// IndexedVectorTests.swift
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

/// Test class for ``IndexedVector``.
final class IndexedVectorTests: XCTestCase {

    /// The values of the indexes.
    let values = [
        IndexedValue(index: .index(value: .literal(value: .integer(value: 3))), value: .bit(value: .high)),
        IndexedValue(index: .others, value: .bit(value: .low)),
    ]

    /// The literal under test.
    var literal: IndexedVector {
        IndexedVector(values: values)
    }

    /// Tests that the initialiser sets the stored properties correctly.
    func testInit() {
        XCTAssertEqual(literal.values, values)
    }

    /// Test that the `VHDL` code is generated correctly.
    func testRawValue() {
        XCTAssertEqual(literal.rawValue, "(3 => '1', others => '0')")
    }

    // swiftlint:disable function_body_length

    /// Test that `init(rawValue:)` parses the `VHDL` code correctly.
    func testRawValueInit() {
        XCTAssertEqual(IndexedVector(rawValue: "(3 => '1', others => '0')"), literal)
        XCTAssertEqual(IndexedVector(rawValue: " (3 => '1', others => '0')"), literal)
        XCTAssertEqual(IndexedVector(rawValue: "(3 => '1', others => '0') "), literal)
        XCTAssertEqual(IndexedVector(rawValue: " (3 => '1', others => '0') "), literal)
        XCTAssertNil(
            IndexedVector(
                rawValue: "(0 to 2047 => \"\(String(repeating: "1", count: 2048))\", others => '0')"
            )
        )
        XCTAssertEqual(
            IndexedVector(rawValue: "(others => '0')"),
            IndexedVector(values: [IndexedValue(index: .others, value: .bit(value: .low))])
        )
        XCTAssertEqual(
            IndexedVector(rawValue: "(3 downto 2 => '1', others => '0')"),
            IndexedVector(
                values: [
                    IndexedValue(
                        index: .range(
                            value: .downto(
                                upper: .literal(value: .integer(value: 3)),
                                lower: .literal(value: .integer(value: 2))
                            )
                        ),
                        value: .bit(value: .high)
                    ),
                    IndexedValue(index: .others, value: .bit(value: .low)),
                ]
            )
        )
        XCTAssertEqual(
            IndexedVector(rawValue: "(3 downto 2 => '1', others => 'U')"),
            IndexedVector(
                values: [
                    IndexedValue(
                        index: .range(
                            value: .downto(
                                upper: .literal(value: .integer(value: 3)),
                                lower: .literal(value: .integer(value: 2))
                            )
                        ),
                        value: .logic(value: .high)
                    ),
                    IndexedValue(index: .others, value: .logic(value: .uninitialized)),
                ]
            )
        )
        XCTAssertNil(IndexedVector(rawValue: "3 => '1', others => '0'"))
        XCTAssertNil(IndexedVector(rawValue: "(3 => '1', others => '0'"))
        XCTAssertNil(IndexedVector(rawValue: "3 => '1', others => '0')"))
        XCTAssertNil(IndexedVector(rawValue: "((3 => '1'), others => '0')"))
        XCTAssertNil(IndexedVector(rawValue: ""))
        XCTAssertNil(IndexedVector(rawValue: " "))
        XCTAssertNil(IndexedVector(rawValue: "\n"))
    }

    // swiftlint:enable function_body_length

    /// Test `init(rawValue:)` works for mixed types indexes.
    func testRawValueForMixedIndexes() {
        let raw = "(0 => a, 1 to 2 => \"UZ\", others => '0')"
        let expected = IndexedVector(values: [
            IndexedValue(
                index: .index(value: .literal(value: .integer(value: 0))),
                value: .reference(variable: .variable(reference: .variable(name: VariableName(text: "a"))))
            ),
            IndexedValue(
                index: .range(
                    value: .to(
                        lower: .literal(value: .integer(value: 1)),
                        upper: .literal(value: .integer(value: 2))
                    )
                ),
                value: .vector(value: .logics(value: LogicVector(values: [.uninitialized, .highImpedance])))
            ),
            IndexedValue(index: .others, value: .bit(value: .low)),
        ])
        let result = IndexedVector(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

}
