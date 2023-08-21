// StatementTests.swift
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

/// Test class for ``Statement``.
final class StatementTests: XCTestCase {

    /// A variable called `x`.
    let varX = VariableName(text: "x")

    /// Test `rawValue` generates `VHDL` code correctly.
    func testRawValue() {
        XCTAssertEqual(
            Statement.assignment(
                name: .variable(reference: .variable(name: varX)), value: .literal(value: .bit(value: .high))
            ).rawValue,
            "x <= '1';"
        )
        let comment = Comment(text: "signal x.")
        XCTAssertEqual(Statement.comment(value: comment).rawValue, comment.rawValue)
        XCTAssertEqual(Statement.null.rawValue, "null;")
        XCTAssertEqual(Statement.returns(value: .literal(value: .integer(value: 5))).rawValue, "return 5;")
    }

    /// Test `init(rawValue:)` parses `VHDL` code correctly for comments.
    func testCommentRawValueInit() {
        let comment = Comment(text: "signal x.")
        XCTAssertEqual(Statement(rawValue: "-- signal x."), Statement.comment(value: comment))
        XCTAssertEqual(Statement(rawValue: " -- signal x."), Statement.comment(value: comment))
        XCTAssertEqual(Statement(rawValue: "-- signal x. "), Statement.comment(value: comment))
        XCTAssertEqual(Statement(rawValue: " -- signal x. "), Statement.comment(value: comment))
        XCTAssertEqual(Statement(rawValue: "-- signal x.\n"), Statement.comment(value: comment))
        XCTAssertEqual(Statement(rawValue: "-- signal x.\n "), Statement.comment(value: comment))
        XCTAssertEqual(Statement(rawValue: " -- signal x.\n"), Statement.comment(value: comment))
        XCTAssertEqual(Statement(rawValue: " -- signal x.\n "), Statement.comment(value: comment))
        XCTAssertEqual(Statement(rawValue: "-- signal x.\n\n"), Statement.comment(value: comment))
        XCTAssertEqual(Statement(rawValue: "-- signal x.\n\n "), Statement.comment(value: comment))
        XCTAssertEqual(Statement(rawValue: "-- signal x.\n\n\n"), Statement.comment(value: comment))
        XCTAssertEqual(Statement(rawValue: "-- signal x.\n\n\n "), Statement.comment(value: comment))
        XCTAssertEqual(
            Statement(rawValue: "-- signal x.--"), Statement.comment(value: Comment(text: "signal x.--"))
        )
        XCTAssertEqual(Statement(rawValue: "--signal x."), Statement.comment(value: comment))
        XCTAssertNil(Statement(rawValue: "-- signal x.\n--"))
        XCTAssertNil(Statement(rawValue: "-- signal x.\n\n--"))
        XCTAssertNil(Statement(rawValue: "-- signal x.\n\n\n--\n"))
        XCTAssertNil(Statement(rawValue: "-- signal x;\n -- signal y."))
    }

    /// Test `init(rawValue:)` parses `VHDL` code correctly for assignments.
    func testAssignmentRawValueInit() {
        let value = Expression.literal(value: .bit(value: .high))
        XCTAssertEqual(
            Statement(rawValue: "x <= '1';"),
            .assignment(name: .variable(reference: .variable(name: varX)), value: value)
        )
        XCTAssertEqual(
            Statement(rawValue: "x <= '1'; "),
            .assignment(name: .variable(reference: .variable(name: varX)), value: value)
        )
        XCTAssertEqual(
            Statement(rawValue: " x <= '1';"),
            .assignment(name: .variable(reference: .variable(name: varX)), value: value)
        )
        XCTAssertEqual(
            Statement(rawValue: " x <= '1'; "),
            .assignment(name: .variable(reference: .variable(name: varX)), value: value)
        )
        XCTAssertEqual(
            Statement(rawValue: "x <= '1';\n"),
            .assignment(name: .variable(reference: .variable(name: varX)), value: value)
        )
        XCTAssertEqual(
            Statement(rawValue: "x <= '1';\n "),
            .assignment(name: .variable(reference: .variable(name: varX)), value: value)
        )
        XCTAssertEqual(
            Statement(rawValue: "x   <=    '1' ; "),
            .assignment(name: .variable(reference: .variable(name: varX)), value: value)
        )
        XCTAssertNil(Statement(rawValue: "x <= '1' <= '0';"))
        XCTAssertNil(Statement(rawValue: "x <= '2';"))
        XCTAssertNil(Statement(rawValue: "x <= '1'"))
        XCTAssertNil(Statement(rawValue: "2x <= '1';"))
        XCTAssertNil(Statement(rawValue: "\(String(repeating: "A", count: 2048)) <= '1';"))
    }

    /// Test null raw value init.
    func testNullRawValueInit() {
        XCTAssertEqual(Statement(rawValue: "null;"), .null)
        XCTAssertEqual(Statement(rawValue: "null; "), .null)
        XCTAssertEqual(Statement(rawValue: " null;"), .null)
        XCTAssertEqual(Statement(rawValue: " null; "), .null)
        XCTAssertEqual(Statement(rawValue: "null;\n"), .null)
        XCTAssertEqual(Statement(rawValue: "null;\n "), .null)
        XCTAssertEqual(Statement(rawValue: "NULL;"), .null)
        XCTAssertNil(Statement(rawValue: "null"))
    }

    /// Test return raw value init.
    func testReturnsRawValueInit() {
        XCTAssertEqual(Statement(rawValue: "return 5;"), .returns(value: .literal(value: .integer(value: 5))))
        XCTAssertNil(Statement(rawValue: "return 5"))
        XCTAssertNil(Statement(rawValue: "returns 5;"))
        XCTAssertNil(Statement(rawValue: "return 5 +;"))
    }

}
