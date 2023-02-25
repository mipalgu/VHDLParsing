// ArrayDefinitionTests.swift
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

/// Test class for ``ArrayDefinition``.
final class ArrayDefinitionTests: XCTestCase {

    /// A variable `xs`.
    let xs = VariableName(text: "xs")

    /// The size of a 4x2 array.
    let ranges = [
        VectorSize.downto(
            upper: .literal(value: .integer(value: 3)), lower: .literal(value: .integer(value: 0))
        ),
        VectorSize.downto(
            upper: .literal(value: .integer(value: 1)), lower: .literal(value: .integer(value: 0))
        )
    ]

    /// The types of the elements.
    let elementType = Type.signal(type: .integer)

    /// The array under test.
    lazy var array = ArrayDefinition(name: xs, size: ranges, elementType: elementType)

    /// Initiaizes the array under test.
    override func setUp() {
        array = ArrayDefinition(name: xs, size: ranges, elementType: elementType)
    }

    /// Test that the stored properties are set correctly.
    func testInit() {
        XCTAssertEqual(array.name, xs)
        XCTAssertEqual(array.size, ranges)
        XCTAssertEqual(array.elementType, elementType)
    }

    /// Test that the `VHDL` code is generated correctly.
    func testRawValue() {
        XCTAssertEqual(array.rawValue, "type xs is array (3 downto 0, 1 downto 0) of integer;")
        let array2 = ArrayDefinition(name: xs, size: [ranges[0]], elementType: elementType)
        XCTAssertEqual(array2.rawValue, "type xs is array (3 downto 0) of integer;")
    }

    /// Test `init(rawValue:)` parses `VHDL` code correctly.
    func testRawValueInit() {
        let raw = "type xs is array (3 downto 0, 1 downto 0) of integer;"
        XCTAssertEqual(ArrayDefinition(rawValue: raw), array)
        XCTAssertEqual(
            ArrayDefinition(rawValue: "TYPE xs IS ARRAY (3 DOWNTO 0, 1 DOWNTO 0) of INTEGER;"), array
        )
        let raw2 = "type xs is array (3 downto 0) of integer;"
        let array2 = ArrayDefinition(name: xs, size: [ranges[0]], elementType: elementType)
        XCTAssertEqual(ArrayDefinition(rawValue: raw2), array2)
        XCTAssertNil(ArrayDefinition(rawValue: ""))
        XCTAssertNil(ArrayDefinition(rawValue: "type xs is array () of integer;"))
        XCTAssertNil(ArrayDefinition(rawValue: "type xs is array (3 downto 0, 1 downto 0) of integer"))
        XCTAssertNil(ArrayDefinition(rawValue: "type xs is array (3 downto 0, 1 downto 0) ofs integer;"))
        XCTAssertNil(ArrayDefinition(rawValue: "type xs is arrays (3 downto 0, 1 downto 0) of integer;"))
        XCTAssertNil(ArrayDefinition(rawValue: "type xs iss array (3 downto 0, 1 downto 0) of integer;"))
        XCTAssertNil(ArrayDefinition(rawValue: "types xs is array (3 downto 0, 1 downto 0) of integer;"))
        XCTAssertNil(ArrayDefinition(rawValue: "type 2xs is array (3 downto 0, 1 downto 0) of integer;"))
        XCTAssertNil(ArrayDefinition(rawValue: "type xs is array (3s downto 0, 1 downto 0) of integer;"))
        XCTAssertNil(ArrayDefinition(rawValue: "type xs is array (3 downto 0, 1s downto 0) of integer;"))
        XCTAssertNil(ArrayDefinition(rawValue: "type xs is array (3 downtos 0, 1 downto 0) of integer;"))
        XCTAssertNil(ArrayDefinition(rawValue: "type xs is array (3 downto 0, 1 downto 0) of integer;;"))
        XCTAssertNil(ArrayDefinition(rawValue: "type xs is array 3 downto 0 of integer;"))
        XCTAssertNil(ArrayDefinition(rawValue: "type xs is array (3 downto 0, 1 downto 0 of integer;"))
        XCTAssertNil(ArrayDefinition(rawValue: "type xs is array (3 downto 0, 1 downto 0)) of integer;"))
    }

}
