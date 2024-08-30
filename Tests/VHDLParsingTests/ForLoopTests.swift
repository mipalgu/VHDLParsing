// ForLoopTests.swift
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

/// Test class for ``ForLoop``.
final class ForLoopTests: XCTestCase {

    /// A variable `x`.
    let x = VariableName(text: "x")

    /// A variable `y`.
    let y = VariableName(text: "y")

    /// A range from `0` to `7`.
    let range = VectorSize.to(
        lower: .literal(value: .integer(value: 0)),
        upper: .literal(value: .integer(value: 7))
    )

    /// The block of the for-loop.
    lazy var code = SynchronousBlock.statement(
        statement: .assignment(
            name: .variable(reference: .variable(name: y)),
            value: .reference(variable: .variable(reference: .variable(name: x)))
        )
    )

    /// The loop under test.
    lazy var loop = ForLoop(iterator: x, range: range, body: code)

    /// Initialise the test data.
    override func setUp() {
        code = SynchronousBlock.statement(
            statement: .assignment(
                name: .variable(reference: .variable(name: y)),
                value: .reference(variable: .variable(reference: .variable(name: x)))
            )
        )
        loop = ForLoop(iterator: x, range: range, body: code)
    }

    /// Test that the stored properties are set correctly.
    func testPropertyInit() {
        XCTAssertEqual(loop.iterator, x)
        XCTAssertEqual(loop.range, range)
        XCTAssertEqual(loop.body, code)
    }

    /// Test that the `rawValue` generates the correct code.
    func testRawValue() {
        let expected = """
            for x in 0 to 7 loop
                y <= x;
            end loop;
            """
        XCTAssertEqual(loop.rawValue, expected)
    }

    /// Test that `init(rawValue:)` parses the `VHDL` code correctly.
    func testRawValueInit() {
        let expected = """
            for x in 0 to 7 loop
                y <= x;
            end loop;
            """
        XCTAssertEqual(ForLoop(rawValue: expected), loop)
        let expected2 = """
            for x in 0 to 7 loop
                y <= x;
            end loop ;
            """
        XCTAssertEqual(ForLoop(rawValue: expected2), loop)
        XCTAssertNil(ForLoop(rawValue: ""))
        let raw = """
            for x in 0 to 7
                y <= x;
            end loop;
            """
        XCTAssertNil(ForLoop(rawValue: raw))
        let raw2 = "for x in 0 to 7 loop"
        XCTAssertNil(ForLoop(rawValue: raw2))
    }

    /// Test invalud `init(rawValue:)` cases.
    func testInvalidRawValueInit() {
        let raw = """
            for x in 0 to 7 loop
                y <= x;
            end loop
            """
        XCTAssertNil(ForLoop(rawValue: raw))
        let raw2 = """
            for x in 0 to 7 loop
                y <= x;
            end;
            """
        XCTAssertNil(ForLoop(rawValue: raw2))
        let raw3 = """
            for x in 0 to 7 loop
                y <= x;
            loop;
            """
        XCTAssertNil(ForLoop(rawValue: raw3))
        let raw4 = """
            for x in 0 to 7 loop
                y <= x;
            loop ;
            """
        XCTAssertNil(ForLoop(rawValue: raw4))
        let raw5 = """
            for x in 0 to 7 loop
                y <== x;
            end loop;
            """
        XCTAssertNil(ForLoop(rawValue: raw5))
        let raw6 = """
            for x in 0 too 7 loop
                y <= x;
            end loop;
            """
        XCTAssertNil(ForLoop(rawValue: raw6))
        let raw7 = """
            for 2x in 0 to 7 loop
                y <= x;
            end loop;
            """
        XCTAssertNil(ForLoop(rawValue: raw7))
    }

}
