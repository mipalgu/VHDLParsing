// IfBlockTests.swift
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

/// Test class for ``IfBlock``.
final class IfBlockTests: XCTestCase {

    /// A variable `x`.
    let x = Expression.variable(name: VariableName(text: "x"))

    /// A variable `y`.
    let y = Expression.variable(name: VariableName(text: "y"))

    /// Test `rawValue` generates `VHDL` code correctly.
    func testRawValue() {
        let condition = Expression.conditional(condition: .comparison(value: .equality(lhs: x, rhs: y)))
        let assignment = Block.statement(
            statement: Statement.assignment(name: VariableName(text: "x"), value: y)
        )
        let reset = Block.statement(statement: Statement.assignment(
            name: VariableName(text: "x"), value: .literal(value: .bit(value: .low))
        ))
        let block = IfBlock.ifStatement(condition: condition, ifBlock: assignment)
        let expected = """
        if (x = y) then
            x <= y;
        end if;
        """
        XCTAssertEqual(block.rawValue, expected)
        let block2 = IfBlock.ifElse(condition: condition, ifBlock: assignment, elseBlock: reset)
        let expected2 = """
        if (x = y) then
            x <= y;
        else
            x <= '0';
        end if;
        """
        XCTAssertEqual(block2.rawValue, expected2)
        // let condition2 = Expression.conditional(condition: .comparison(value: .notEquals(lhs: x, rhs: y)))
        // let assignment2 = Block.statement(statement: .assignment(name: VariableName(text: "y"), value: x))
        // let block3 = IfBlock.ifElse(condition: condition, ifBlock: Block, elseBlock: Block)
    }

    func testIfRawValueInit() {
        let raw = """
        if (x = y) then
            x <= y;
        end if;
        """
        XCTAssertEqual(
            IfBlock(rawValue: raw),
            IfBlock.ifStatement(
                condition: .conditional(
                    condition: .comparison(value: .equality(lhs: x, rhs: y))
                ),
                ifBlock: Block.statement(
                    statement: Statement.assignment(name: VariableName(text: "x"), value: y)
                )
            )
        )
        let raw2 = """
        if (x = y) then
            x <= y;
        else
            x <= '0';
        end if;
        """
        let expected = IfBlock.ifElse(
            condition: .conditional(condition: .comparison(value: .equality(lhs: x, rhs: y))),
            ifBlock: .statement(statement: .assignment(name: VariableName(text: "x"), value: y)),
            elseBlock: .statement(
                statement: .assignment(
                    name: VariableName(text: "x"),
                    value: .literal(value: .bit(value: .low))
                )
            )
        )
        XCTAssertEqual(IfBlock(rawValue: raw2), expected)
    }

    /// Test recursive if-else statement raw value initialiser.
    func testRecursiveRawValueInit() {
        let raw = """
        if (x = y) then
            x <= y;
        elsif (x /= y) then
            y <= x;
        else
            x <= '0';
        end if;
        """
        let expected = IfBlock.ifElse(
            condition: .conditional(condition: .comparison(value: .equality(lhs: x, rhs: y))),
            ifBlock: .statement(statement: .assignment(name: VariableName(text: "x"), value: y)),
            elseBlock: .ifStatement(
                block: .ifElse(
                    condition: .conditional(condition: .comparison(value: .notEquals(lhs: x, rhs: y))),
                    ifBlock: .statement(statement: .assignment(name: VariableName(text: "y"), value: x)),
                    elseBlock: .statement(
                        statement: .assignment(
                            name: VariableName(text: "x"), value: .literal(value: .bit(value: .low))
                        )
                    )
                )
            )
        )
        XCTAssertEqual(IfBlock(rawValue: raw), expected)
    }

}