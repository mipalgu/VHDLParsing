// BlocksTests.swift
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

/// Test class for ``SynchronousBlock``.
final class SynchronousBlockTests: XCTestCase {

    /// A variable called x.
    let x = VariableName(text: "x")

    /// A variable called y.
    let y = VariableName(text: "y")

    /// Test raw values are correct.
    func testRawValues() {
        let statement = SynchronousBlock.statement(
            statement: Statement.assignment(
                name: .variable(reference: .variable(name: x)),
                value: .literal(value: .bit(value: .high))
            )
        )
        XCTAssertEqual(statement.rawValue, "x <= '1';")
        let ifStatement = SynchronousBlock.ifStatement(
            block: .ifStatement(
                condition: .conditional(
                    condition: .comparison(
                        value: .equality(
                            lhs: .reference(variable: .variable(reference: .variable(name: x))),
                            rhs: .reference(variable: .variable(reference: .variable(name: y)))
                        )
                    )
                ),
                ifBlock: SynchronousBlock.statement(
                    statement: Statement.assignment(
                        name: .variable(reference: .variable(name: x)),
                        value: .reference(variable: .variable(reference: .variable(name: y)))
                    )
                )
            )
        )
        let expected = """
            if (x = y) then
                x <= y;
            end if;
            """
        XCTAssertEqual(ifStatement.rawValue, expected)
        let blocks = SynchronousBlock.blocks(blocks: [statement, statement])
        XCTAssertEqual(blocks.rawValue, "x <= '1';\nx <= '1';")
        let bigBlocks = SynchronousBlock.blocks(blocks: [statement, ifStatement, statement])
        let expected2 = """
            x <= '1';
            if (x = y) then
                x <= y;
            end if;
            x <= '1';
            """
        XCTAssertEqual(bigBlocks.rawValue, expected2)
    }

    /// Test raw value for caseStatement case.
    func testCaseRawValue() {
        let expected3 = """
            case x is
                when '1' =>
                    y <= '1';
                when '0' =>
                    y <= '0';
            end case;
            """
        let caseStatement = SynchronousBlock.caseStatement(
            block: CaseStatement(
                condition: .reference(variable: .variable(reference: .variable(name: x))),
                cases: [
                    WhenCase(
                        condition: .expression(expression: .literal(value: .bit(value: .high))),
                        code: .statement(
                            statement: .assignment(
                                name: .variable(reference: .variable(name: y)),
                                value: .literal(value: .bit(value: .high))
                            )
                        )
                    ),
                    WhenCase(
                        condition: .expression(expression: .literal(value: .bit(value: .low))),
                        code: .statement(
                            statement: .assignment(
                                name: .variable(reference: .variable(name: y)),
                                value: .literal(value: .bit(value: .low))
                            )
                        )
                    ),
                ]
            )
        )
        XCTAssertEqual(caseStatement.rawValue, expected3)
    }

    /// Test statement raw value initialiser.
    func testStatementRawValueInit() {
        let expected = SynchronousBlock.statement(
            statement: Statement.assignment(
                name: .variable(reference: .variable(name: x)),
                value: .literal(value: .bit(value: .high))
            )
        )
        XCTAssertEqual(SynchronousBlock(rawValue: "x <= '1';"), expected)
        XCTAssertEqual(SynchronousBlock(rawValue: "x <= '1'; "), expected)
        XCTAssertEqual(SynchronousBlock(rawValue: " x <= '1';"), expected)
        XCTAssertEqual(SynchronousBlock(rawValue: " x <= '1'; "), expected)
        XCTAssertEqual(SynchronousBlock(rawValue: "x <= '1'; -- signal x"), expected)
        XCTAssertNil(SynchronousBlock(rawValue: "x; <= '1'"))
        XCTAssertNil(SynchronousBlock(rawValue: "signal x: std_logic; <= '1'"))
        XCTAssertNil(SynchronousBlock(rawValue: ""))
        XCTAssertNil(SynchronousBlock(rawValue: " "))
        XCTAssertNil(SynchronousBlock(rawValue: "\n"))
        XCTAssertNil(SynchronousBlock(rawValue: "signal \(String(repeating: "x", count: 256)): std_logic;"))
    }

    // swiftlint:disable function_body_length

    /// Test if statement raw value initialiser.
    func testIfRawValueInit() {
        let x = Expression.reference(variable: .variable(reference: .variable(name: x)))
        let y = Expression.reference(variable: .variable(reference: .variable(name: y)))
        let expected = SynchronousBlock.ifStatement(
            block: IfBlock.ifElse(
                condition: .conditional(condition: .comparison(value: .equality(lhs: x, rhs: y))),
                ifBlock: .blocks(
                    blocks: [
                        .statement(
                            statement: .assignment(
                                name: .variable(reference: .variable(name: VariableName(text: "x"))),
                                value: y
                            )
                        ),
                        .ifStatement(
                            block: IfBlock.ifStatement(
                                condition: .conditional(
                                    condition: .comparison(
                                        value: .equality(lhs: x, rhs: .literal(value: .bit(value: .high)))
                                    )
                                ),
                                ifBlock: .statement(
                                    statement: .assignment(
                                        name: .variable(reference: .variable(name: VariableName(text: "x"))),
                                        value: .literal(value: .bit(value: .low))
                                    )
                                )
                            )
                        ),
                    ]
                ),
                elseBlock: .ifStatement(
                    block: .ifElse(
                        condition: .conditional(condition: .comparison(value: .notEquals(lhs: x, rhs: y))),
                        ifBlock: .statement(
                            statement: .assignment(
                                name: .variable(reference: .variable(name: VariableName(text: "y"))),
                                value: x
                            )
                        ),
                        elseBlock: .statement(
                            statement: .assignment(
                                name: .variable(reference: .variable(name: VariableName(text: "x"))),
                                value: .literal(value: .bit(value: .low))
                            )
                        )
                    )
                )
            )
        )
        let raw = """
            if (x = y) then
                x <= y;
                if (x = '1') then
                    x <= '0';
                end if;
            elsif (x /= y) then
                y <= x;
            else
                x <= '0';
            end if;
            """
        XCTAssertEqual(SynchronousBlock(rawValue: raw), expected)
    }

    // swiftlint:enable function_body_length

    /// Test multiple statements raw value init.
    func testMultipleStatementsRawValueInit() {
        let statement = SynchronousBlock.statement(
            statement: Statement.assignment(
                name: .variable(reference: .variable(name: x)),
                value: .literal(value: .bit(value: .high))
            )
        )
        let expected = SynchronousBlock.blocks(blocks: [statement, statement])
        XCTAssertEqual(SynchronousBlock(rawValue: "x <= '1';\nx <= '1';"), expected)
        XCTAssertEqual(SynchronousBlock(rawValue: "x <= '1';\nx <= '1'; "), expected)
        XCTAssertEqual(SynchronousBlock(rawValue: "x <= '1'; \nx <= '1';"), expected)
        XCTAssertEqual(SynchronousBlock(rawValue: "x <= '1'; \nx <= '1'; "), expected)
        XCTAssertEqual(SynchronousBlock(rawValue: "x <= '1'; -- signal x\nx <= '1';"), expected)
        XCTAssertEqual(SynchronousBlock(rawValue: "x <= '1'; -- signal x\nx <= '1'; "), expected)
        XCTAssertEqual(SynchronousBlock(rawValue: "x <= '1'; -- signal x\nx <= '1'; -- signal x"), expected)
        XCTAssertEqual(SynchronousBlock(rawValue: "x <= '1';\n\n\nx <= '1'; -- signal x "), expected)
        XCTAssertEqual(
            SynchronousBlock(rawValue: "x <= '1'; -- signal x\n\n\nx <= '1'; -- signal x "),
            expected
        )
        XCTAssertNil(SynchronousBlock(rawValue: "x <= '1';\n2x <= '1';"))
        XCTAssertNil(SynchronousBlock(rawValue: "\(String(repeating: "x", count: 4096)) <= '1';"))
    }

}
