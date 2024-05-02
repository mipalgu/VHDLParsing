// EnumerationDefinitionTests.swift
// VHDLParsing
// 
// Created by Morgan McColl.
// Copyright © 2024 Morgan McColl. All rights reserved.
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

@testable import VHDLParsing
import XCTest

/// Test class for ``EnumerationDefinition``.
final class EnumerationDefinitionTests: XCTestCase {

    /// Some test data.
    let enumeration = EnumerationDefinition(
        name: VariableName(text: "xs"),
        values: [VariableName(text: "x0"), VariableName(text: "x1"), VariableName(text: "x2")]
    )

    /// Test property init.
    func testInit() {
        XCTAssertEqual(enumeration.name, VariableName(text: "xs"))
        XCTAssertEqual(
            enumeration.values,
            [VariableName(text: "x0"), VariableName(text: "x1"), VariableName(text: "x2")]
        )
    }

    /// Test the `rawValue` creates the correct `VHDL` code.
    func testRawValue() {
        XCTAssertEqual(enumeration.rawValue, "type xs is (x0, x1, x2);")
    }

    /// Test public property init.
    func testPropertyInit() {
        XCTAssertNil(EnumerationDefinition(name: VariableName(text: "xs"), nonEmptyValues: []))
        let enumeration2 = EnumerationDefinition(name: enumeration.name, nonEmptyValues: enumeration.values)
        XCTAssertEqual(enumeration2, enumeration)
        let enumeration3 = EnumerationDefinition(
            name: enumeration.name, nonEmptyValues: [VariableName(text: "x0")]
        )
        XCTAssertEqual(
            enumeration3, EnumerationDefinition(name: enumeration.name, values: [VariableName(text: "x0")])
        )
    }

    /// Tests that `init(rawValue:)` parses `VHDL` code correctly.
    func testRawValueInit() {
        let raw0 = "type xs is (x0, x1, x2);"
        XCTAssertEqual(EnumerationDefinition(rawValue: raw0), enumeration)
        let rawNewlines = """
        type
         xs
          is
           (
             x0
             ,
                x1,
                    x2
           )
        ;
        """
        XCTAssertEqual(EnumerationDefinition(rawValue: rawNewlines), enumeration)
        XCTAssertEqual(
            EnumerationDefinition(rawValue: "type xs is (x0);"),
            EnumerationDefinition(name: VariableName(text: "xs"), values: [VariableName(text: "x0")])
        )
        XCTAssertEqual(EnumerationDefinition(rawValue: "type xs is (x0,x1,x2);"), enumeration)
        XCTAssertNil(EnumerationDefinition(rawValue: String(raw0.dropLast())))
        XCTAssertNil(EnumerationDefinition(rawValue: String(raw0.dropFirst(4))))
        XCTAssertNil(EnumerationDefinition(rawValue: "type \(String(repeating: "x", count: 4096)) is (x0);"))
        XCTAssertNil(EnumerationDefinition(rawValue: "type x!s is (x0, x1, x2);"))
        XCTAssertNil(EnumerationDefinition(rawValue: "type xs is (x0, x1, x2;"))
        XCTAssertNil(EnumerationDefinition(rawValue: "type xs (x0, x1, x2);"))
        XCTAssertNil(EnumerationDefinition(rawValue: "type xs iss (x0, x1, x2);"))
        XCTAssertNil(EnumerationDefinition(rawValue: "type xs is x0, x1, x2);"))
        XCTAssertNil(EnumerationDefinition(rawValue: "type xs is (x0, x1, x!2);"))
        XCTAssertNil(EnumerationDefinition(rawValue: "type xs is (x0, x!1, x2);"))
        XCTAssertNil(EnumerationDefinition(rawValue: "type xs is (x!0, x1, x2);"))
        XCTAssertNil(EnumerationDefinition(rawValue: "type xs is (x!0);"))
        XCTAssertNil(EnumerationDefinition(rawValue: "type xs is ();"))
        XCTAssertNil(EnumerationDefinition(rawValue: "type xs is (x0,,x2);"))
    }

}
