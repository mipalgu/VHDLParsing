// GenericTypeDeclaration.swift
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

/// Test class for ``GenericTypeDeclaration``.
final class GenericTypeDeclarationTests: XCTestCase {

    /// A variable `x`.
    let x = VariableName(text: "x")

    /// The `std_logic` type.
    let type = SignalType.stdLogic

    /// A `std_logic` value of `'0'`.
    let value = Expression.literal(value: .logic(value: .low))

    /// A generic under test.
    lazy var generic = GenericTypeDeclaration(name: x, type: type, defaultValue: value)

    /// Initialise the unit under test before every test function.
    override func setUp() {
        generic = GenericTypeDeclaration(name: x, type: type, defaultValue: value)
    }

    /// Test stored property initialiser sets values correctly.
    func testPropertyInit() {
        XCTAssertEqual(generic.name, x)
        XCTAssertEqual(generic.type, type)
        XCTAssertEqual(generic.defaultValue, value)
        let generic2 = GenericTypeDeclaration(name: x, type: type)
        XCTAssertEqual(generic2.name, x)
        XCTAssertEqual(generic2.type, type)
        XCTAssertNil(generic2.defaultValue)
    }

    /// Test raw value.
    func testRawValue() {
        XCTAssertEqual(generic.rawValue, "x: std_logic := '0';")
        let generic2 = GenericTypeDeclaration(name: x, type: type)
        XCTAssertEqual(generic2.rawValue, "x: std_logic;")
    }

    /// Test `init(rawValue:)`.
    func testRawValueInit() {
        XCTAssertEqual(GenericTypeDeclaration(rawValue: "x: std_logic := '0';"), generic)
        XCTAssertEqual(GenericTypeDeclaration(rawValue: "x: std_logic := '0'"), generic)
        XCTAssertEqual(GenericTypeDeclaration(rawValue: "x\n:    std_logic     :=     '0'   ;"), generic)
        generic = GenericTypeDeclaration(name: x, type: type)
        XCTAssertEqual(GenericTypeDeclaration(rawValue: "x: std_logic;"), generic)
        XCTAssertEqual(GenericTypeDeclaration(rawValue: "x: std_logic"), generic)
        XCTAssertEqual(GenericTypeDeclaration(rawValue: "x\n:    std_logic     ;"), generic)
        XCTAssertEqual(GenericTypeDeclaration(rawValue: "x    :    std_logic     ;     "), generic)
        let complexGeneric = GenericTypeDeclaration(
            name: x,
            type: .ranged(type: .stdLogicVector(size: .downto(
                upper: .literal(value: .integer(value: 7)), lower: .literal(value: .integer(value: 0))
            ))),
            defaultValue: .literal(value: .vector(value: .indexed(values: IndexedVector(
                values: [IndexedValue(index: .others, value: .logic(value: .low))]
            ))))
        )
        XCTAssertEqual(
            GenericTypeDeclaration(rawValue: "x: std_logic_vector(7 downto 0) := (others => '0');"),
            complexGeneric
        )
        XCTAssertEqual(
            GenericTypeDeclaration(rawValue: "x : std_logic_vector(7 downto 0) := (others => '0');"),
            complexGeneric
        )
        XCTAssertNil(GenericTypeDeclaration(rawValue: "x: in std_logic;"))
        XCTAssertNil(GenericTypeDeclaration(rawValue: "x: in std_logic := '0';"))
        XCTAssertNil(GenericTypeDeclaration(rawValue: "x := '0';"))
        XCTAssertNil(GenericTypeDeclaration(rawValue: ""))
        XCTAssertNil(GenericTypeDeclaration(rawValue: String(repeating: "x", count: 256) + ": std_logic;"))
        XCTAssertNil(GenericTypeDeclaration(rawValue: "x: std_logic := '0' := '1';"))
        XCTAssertNil(GenericTypeDeclaration(rawValue: "x:std_logic := '0';"))
        XCTAssertNil(GenericTypeDeclaration(rawValue: "x : := '0';"))
    }

}
