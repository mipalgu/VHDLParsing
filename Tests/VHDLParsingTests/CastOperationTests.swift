// CastOperationTests.swift
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

/// Test class for ``CastOperation``.
final class CastOperationTests: XCTestCase {

    /// A variable `x`.
    let x = Expression.variable(name: VariableName(text: "x"))

    /// Test the raw values generate the correct `VHDL` code.
    func testRawValue() {
        XCTAssertEqual(CastOperation.bit(expression: x).rawValue, "bit(x)")
        XCTAssertEqual(CastOperation.bitVector(expression: x).rawValue, "bit_vector(x)")
        XCTAssertEqual(CastOperation.boolean(expression: x).rawValue, "boolean(x)")
        XCTAssertEqual(CastOperation.integer(expression: x).rawValue, "integer(x)")
        XCTAssertEqual(CastOperation.natural(expression: x).rawValue, "natural(x)")
        XCTAssertEqual(CastOperation.positive(expression: x).rawValue, "positive(x)")
        XCTAssertEqual(CastOperation.real(expression: x).rawValue, "real(x)")
        XCTAssertEqual(CastOperation.signed(expression: x).rawValue, "signed(x)")
        XCTAssertEqual(CastOperation.stdLogic(expression: x).rawValue, "std_logic(x)")
        XCTAssertEqual(CastOperation.stdLogicVector(expression: x).rawValue, "std_logic_vector(x)")
        XCTAssertEqual(CastOperation.stdULogic(expression: x).rawValue, "std_ulogic(x)")
        XCTAssertEqual(CastOperation.stdULogicVector(expression: x).rawValue, "std_ulogic_vector(x)")
        XCTAssertEqual(CastOperation.unsigned(expression: x).rawValue, "unsigned(x)")
    }

    /// Test the `init(rawValue:)` for bit types.
    func testBitRawInit() {
        XCTAssertEqual(CastOperation(rawValue: "bit(x)"), CastOperation.bit(expression: x))
        XCTAssertEqual(CastOperation(rawValue: "BIT(x)"), CastOperation.bit(expression: x))
        XCTAssertEqual(CastOperation(rawValue: "bit (x)"), CastOperation.bit(expression: x))
        XCTAssertEqual(CastOperation(rawValue: "bit( x)"), CastOperation.bit(expression: x))
        XCTAssertEqual(CastOperation(rawValue: "bit ( x)"), CastOperation.bit(expression: x))
        XCTAssertEqual(CastOperation(rawValue: "bit(x )"), CastOperation.bit(expression: x))
        XCTAssertEqual(CastOperation(rawValue: "bit (x )"), CastOperation.bit(expression: x))
        XCTAssertEqual(CastOperation(rawValue: "bit( x )"), CastOperation.bit(expression: x))
        XCTAssertEqual(CastOperation(rawValue: "bit ( x )"), CastOperation.bit(expression: x))
        XCTAssertEqual(CastOperation(rawValue: " bit(x)"), CastOperation.bit(expression: x))
        XCTAssertEqual(CastOperation(rawValue: "bit(x) "), CastOperation.bit(expression: x))
        XCTAssertEqual(CastOperation(rawValue: " bit(x) "), CastOperation.bit(expression: x))
        XCTAssertEqual(CastOperation(rawValue: "bit(\n    x\n)"), CastOperation.bit(expression: x))
        XCTAssertEqual(
            CastOperation(rawValue: "bit((x))"), CastOperation.bit(expression: .precedence(value: x))
        )
        XCTAssertNil(CastOperation(rawValue: "bit((x)"))
        XCTAssertNil(CastOperation(rawValue: "bit((x)))"))
        XCTAssertNil(CastOperation(rawValue: "bit(\(String(repeating: "x", count: 256)))"))
        XCTAssertNil(CastOperation(rawValue: "bit(x) + y"))
        XCTAssertNil(CastOperation(rawValue: "bits(x)"))
        XCTAssertNil(CastOperation(rawValue: ""))
        XCTAssertNil(CastOperation(rawValue: "(bit(x))"))
        XCTAssertNil(CastOperation(rawValue: ";bit(x)"))
    }

    /// Test the `init(rawValue:)` for the remaining types.
    func testRemainingRawInit() {
        XCTAssertEqual(CastOperation(rawValue: "bit_vector(x)"), .bitVector(expression: x))
        XCTAssertNil(CastOperation(rawValue: "bit_vector(x))"))
        XCTAssertEqual(CastOperation(rawValue: "boolean(x)"), .boolean(expression: x))
        XCTAssertNil(CastOperation(rawValue: "boolean(x))"))
        XCTAssertEqual(CastOperation(rawValue: "integer(x)"), .integer(expression: x))
        XCTAssertNil(CastOperation(rawValue: "integer(x))"))
        XCTAssertEqual(CastOperation(rawValue: "natural(x)"), .natural(expression: x))
        XCTAssertNil(CastOperation(rawValue: "natural(x))"))
        XCTAssertEqual(CastOperation(rawValue: "positive(x)"), .positive(expression: x))
        XCTAssertNil(CastOperation(rawValue: "positive(x))"))
        XCTAssertEqual(CastOperation(rawValue: "real(x)"), .real(expression: x))
        XCTAssertNil(CastOperation(rawValue: "real(x))"))
        XCTAssertEqual(CastOperation(rawValue: "signed(x)"), .signed(expression: x))
        XCTAssertNil(CastOperation(rawValue: "signed(x))"))
        XCTAssertEqual(CastOperation(rawValue: "std_logic(x)"), .stdLogic(expression: x))
        XCTAssertNil(CastOperation(rawValue: "std_logic(x))"))
        XCTAssertEqual(CastOperation(rawValue: "std_logic_vector(x)"), .stdLogicVector(expression: x))
        XCTAssertNil(CastOperation(rawValue: "std_logic_vector(x))"))
        XCTAssertEqual(CastOperation(rawValue: "std_ulogic(x)"), .stdULogic(expression: x))
        XCTAssertNil(CastOperation(rawValue: "std_ulogic(x))"))
        XCTAssertEqual(CastOperation(rawValue: "std_ulogic_vector(x)"), .stdULogicVector(expression: x))
        XCTAssertNil(CastOperation(rawValue: "std_ulogic_vector(x))"))
        XCTAssertEqual(CastOperation(rawValue: "unsigned(x)"), .unsigned(expression: x))
        XCTAssertNil(CastOperation(rawValue: "unsigned(x))"))
    }

    /// Test that `init(firstWord:, expression:)` created the correct case.
    func testWordInit() {
        XCTAssertEqual(CastOperation(firstWord: "bit", expression: x), .bit(expression: x))
        XCTAssertEqual(CastOperation(firstWord: "bit_vector", expression: x), .bitVector(expression: x))
        XCTAssertEqual(CastOperation(firstWord: "boolean", expression: x), .boolean(expression: x))
        XCTAssertEqual(CastOperation(firstWord: "integer", expression: x), .integer(expression: x))
        XCTAssertEqual(CastOperation(firstWord: "natural", expression: x), .natural(expression: x))
        XCTAssertEqual(CastOperation(firstWord: "positive", expression: x), .positive(expression: x))
        XCTAssertEqual(CastOperation(firstWord: "real", expression: x), .real(expression: x))
        XCTAssertEqual(CastOperation(firstWord: "signed", expression: x), .signed(expression: x))
        XCTAssertEqual(CastOperation(firstWord: "std_logic", expression: x), .stdLogic(expression: x))
        XCTAssertEqual(
            CastOperation(firstWord: "std_logic_vector", expression: x),
            .stdLogicVector(expression: x)
        )
        XCTAssertEqual(CastOperation(firstWord: "std_ulogic", expression: x), .stdULogic(expression: x))
        XCTAssertEqual(
            CastOperation(firstWord: "std_ulogic_vector", expression: x),
            .stdULogicVector(expression: x)
        )
        XCTAssertEqual(CastOperation(firstWord: "unsigned", expression: x), .unsigned(expression: x))
        XCTAssertNil(CastOperation(firstWord: "bits", expression: x))
        XCTAssertNil(CastOperation(firstWord: "std_ulogic_vectors", expression: x))
    }

}
