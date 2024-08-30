// TypeDefinitionTests.swift
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

/// Test class for ``TypeDefinition``.
final class TypeDefinitionTests: XCTestCase {

    /// A record type.
    let record = Record(
        name: VariableName(text: "NewRecord"),
        types: [
            RecordTypeDeclaration(name: VariableName(text: "x"), type: .signal(type: .stdLogic)),
            RecordTypeDeclaration(name: VariableName(text: "y"), type: .signal(type: .stdLogic)),
        ]
    )

    /// An enumeration definition.
    let enumeration = EnumerationDefinition(
        name: VariableName(text: "xs"),
        values: [VariableName(text: "x0"), VariableName(text: "x1"), VariableName(text: "x2")]
    )

    /// Test `rawValue` generates `VHDL` code correctly.
    func testRawValue() {
        XCTAssertEqual(TypeDefinition.record(value: record).rawValue, record.rawValue)
        XCTAssertEqual(
            TypeDefinition.alias(name: VariableName(text: "x"), type: .stdLogic).rawValue,
            "type x is std_logic;"
        )
        XCTAssertEqual(
            TypeDefinition.array(
                value: ArrayDefinition(
                    name: VariableName(text: "xs"),
                    size: [
                        .downto(
                            upper: .literal(value: .integer(value: 3)),
                            lower: .literal(value: .integer(value: 0))
                        )
                    ],
                    elementType: .signal(type: .stdLogic)
                )
            )
            .rawValue,
            "type xs is array (3 downto 0) of std_logic;"
        )
        XCTAssertEqual(TypeDefinition.enumeration(value: enumeration).rawValue, enumeration.rawValue)
    }

    /// Test `init(rawValue:)` parses the `VHDL` code correctly.
    func testRawValueInit() {
        XCTAssertEqual(TypeDefinition(rawValue: record.rawValue), .record(value: record))
        XCTAssertEqual(
            TypeDefinition(rawValue: "type x is std_logic;"),
            .alias(name: VariableName(text: "x"), type: .stdLogic)
        )
        XCTAssertEqual(
            TypeDefinition(rawValue: "type xs is array (3 downto 0) of std_logic;"),
            .array(
                value: ArrayDefinition(
                    name: VariableName(text: "xs"),
                    size: [
                        .downto(
                            upper: .literal(value: .integer(value: 3)),
                            lower: .literal(value: .integer(value: 0))
                        )
                    ],
                    elementType: .signal(type: .stdLogic)
                )
            )
        )
        XCTAssertEqual(TypeDefinition(rawValue: "type xs is (x0, x1, x2);"), .enumeration(value: enumeration))
        XCTAssertNil(TypeDefinition(rawValue: "type x is std_logic"))
        XCTAssertNil(TypeDefinition(rawValue: ""))
        XCTAssertNil(TypeDefinition(rawValue: "type 2x is std_logic;"))
        XCTAssertNil(TypeDefinition(rawValue: "types x is std_logic;"))
        XCTAssertNil(TypeDefinition(rawValue: "type x iss std_logic;"))
        XCTAssertNil(TypeDefinition(rawValue: "type x is std_logics;"))
        XCTAssertNil(TypeDefinition(rawValue: "type x is std_logic;;"))
        XCTAssertNil(TypeDefinition(rawValue: "type x is;"))
    }

}
