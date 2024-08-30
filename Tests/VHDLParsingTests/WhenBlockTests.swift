// WhenBlockTests.swift
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

/// Test class for ``WhenBlock``.
final class WhenBlockTests: XCTestCase {

    /// A `when` statement.
    let when = WhenBlock.when(
        statement: WhenStatement(
            condition: .literal(value: .boolean(value: true)),
            value: .literal(value: .bit(value: .high))
        )
    )

    /// An `else` statement.
    let elseStatement = WhenBlock.whenElse(
        statement: WhenElseStatement(
            value: .literal(value: .bit(value: .high)),
            condition: .literal(value: .boolean(value: true)),
            elseBlock: .expression(value: .literal(value: .bit(value: .low)))
        )
    )

    /// Test `rawValue` generates the correct `VHDL` code.
    func testRawValue() {
        XCTAssertEqual(when.rawValue, "'1' when true")
        XCTAssertEqual(elseStatement.rawValue, "'1' when true else '0'")
    }

    /// Test the `VHDL` code is parsed correctly.
    func testRawValueInit() {
        XCTAssertEqual(WhenBlock(rawValue: "'1' when true"), when)
        XCTAssertEqual(WhenBlock(rawValue: "'1' when true else '0'"), elseStatement)
        XCTAssertNil(WhenBlock(rawValue: ""))
        XCTAssertNil(WhenBlock(rawValue: "'1' when \(String(repeating: "x", count: 2048)) = 1 else '0'"))
        XCTAssertNil(WhenBlock(rawValue: "'11' when true"))
        XCTAssertNil(WhenBlock(rawValue: "'1' when true else '00'"))
    }

}
