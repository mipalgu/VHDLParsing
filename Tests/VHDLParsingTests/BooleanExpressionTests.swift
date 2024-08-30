// BooleanExpressionTests.swift
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

/// Test class for ``BooleanExpression``.
final class BooleanExpressionTests: XCTestCase {

    /// A variable `x`.
    let x = Expression.reference(variable: .variable(reference: .variable(name: VariableName(text: "x"))))

    /// A variable `y`.
    let y = Expression.reference(variable: .variable(reference: .variable(name: VariableName(text: "y"))))

    /// A variable `z`.
    let z = Expression.reference(variable: .variable(reference: .variable(name: VariableName(text: "z"))))

    /// Test the raw values generate the correct `VHDL` code.
    func testRawValue() {
        XCTAssertEqual(BooleanExpression.not(value: x).rawValue, "not x")
        XCTAssertEqual(BooleanExpression.and(lhs: x, rhs: y).rawValue, "x and y")
        XCTAssertEqual(BooleanExpression.or(lhs: x, rhs: y).rawValue, "x or y")
        XCTAssertEqual(BooleanExpression.nand(lhs: x, rhs: y).rawValue, "x nand y")
        XCTAssertEqual(BooleanExpression.nor(lhs: x, rhs: y).rawValue, "x nor y")
        XCTAssertEqual(BooleanExpression.xor(lhs: x, rhs: y).rawValue, "x xor y")
        XCTAssertEqual(BooleanExpression.xnor(lhs: x, rhs: y).rawValue, "x xnor y")
    }

    /// Test `init(lhs:, rhs:, operation:)` created correct instance.
    func testExpressionInit() {
        XCTAssertEqual(BooleanExpression(lhs: x, rhs: y, operation: "and"), .and(lhs: x, rhs: y))
        XCTAssertEqual(BooleanExpression(lhs: x, rhs: y, operation: "or"), .or(lhs: x, rhs: y))
        XCTAssertEqual(BooleanExpression(lhs: x, rhs: y, operation: "nand"), .nand(lhs: x, rhs: y))
        XCTAssertEqual(BooleanExpression(lhs: x, rhs: y, operation: "nor"), .nor(lhs: x, rhs: y))
        XCTAssertEqual(BooleanExpression(lhs: x, rhs: y, operation: "xor"), .xor(lhs: x, rhs: y))
        XCTAssertEqual(BooleanExpression(lhs: x, rhs: y, operation: "xnor"), .xnor(lhs: x, rhs: y))
        XCTAssertNil(BooleanExpression(lhs: x, rhs: y, operation: ""))
    }

    /// Test `init(rawValue: )` for a string containing a `not` expression.
    func testNotInit() {
        XCTAssertEqual(BooleanExpression(rawValue: "not x"), BooleanExpression.not(value: x))
        XCTAssertEqual(BooleanExpression(rawValue: " not x "), BooleanExpression.not(value: x))
        XCTAssertEqual(
            BooleanExpression(rawValue: "not (x)"),
            BooleanExpression.not(value: .precedence(value: x))
        )
        XCTAssertEqual(
            BooleanExpression(rawValue: "not (x + y)"),
            BooleanExpression.not(value: .precedence(value: .binary(operation: .addition(lhs: x, rhs: y))))
        )
        XCTAssertEqual(
            BooleanExpression(rawValue: "not (not x)"),
            .not(value: .precedence(value: .logical(operation: .not(value: x))))
        )
        XCTAssertNil(BooleanExpression(rawValue: "not"))
        XCTAssertNil(BooleanExpression(rawValue: "not x y"))
        XCTAssertNil(BooleanExpression(rawValue: "not (x + y"))
        XCTAssertNil(BooleanExpression(rawValue: "not x + y)"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "not (x + y) + z"),
            .not(
                value: .binary(
                    operation: .addition(
                        lhs: .precedence(value: .binary(operation: .addition(lhs: x, rhs: y))),
                        rhs: z
                    )
                )
            )
        )
        XCTAssertNil(BooleanExpression(rawValue: "not (x + y) z"))
        XCTAssertNil(BooleanExpression(rawValue: "not \(String(repeating: "x", count: 256))"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "not x + (y + z)"),
            .not(
                value: .binary(
                    operation: .addition(
                        lhs: x,
                        rhs: .precedence(value: .binary(operation: .addition(lhs: y, rhs: z)))
                    )
                )
            )
        )
        XCTAssertNil(BooleanExpression(rawValue: "not (!x)"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "not x + y"),
            .not(value: .binary(operation: .addition(lhs: x, rhs: y)))
        )
        XCTAssertNil(BooleanExpression(rawValue: "(not x)"))
    }

    /// Test `init(rawValue: )` for a string containing an `and` expression.
    func testAndInit() {
        XCTAssertEqual(BooleanExpression(rawValue: "x and y"), .and(lhs: x, rhs: y))
        XCTAssertEqual(BooleanExpression(rawValue: "x and (y)"), .and(lhs: x, rhs: .precedence(value: y)))
        XCTAssertEqual(BooleanExpression(rawValue: "(x) and y"), .and(lhs: .precedence(value: x), rhs: y))
        XCTAssertNil(BooleanExpression(rawValue: "(x and y)"))
        XCTAssertNil(BooleanExpression(rawValue: "x and"))
        XCTAssertNil(BooleanExpression(rawValue: "and y"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "x and y and z"),
            .and(lhs: .logical(operation: .and(lhs: x, rhs: y)), rhs: z)
        )
        XCTAssertNil(BooleanExpression(rawValue: "x and y z"))
        XCTAssertNil(BooleanExpression(rawValue: "x and \(String(repeating: "y", count: 256))"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "x and y + z"),
            .and(lhs: x, rhs: .binary(operation: .addition(lhs: y, rhs: z)))
        )
        XCTAssertNil(BooleanExpression(rawValue: "x and !y"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "x + y and z"),
            .and(lhs: .binary(operation: .addition(lhs: x, rhs: y)), rhs: z)
        )
    }

    /// Test `init(rawValue: )` for a string containing an `or` expression.
    func testOrInit() {
        XCTAssertEqual(BooleanExpression(rawValue: "x or y"), .or(lhs: x, rhs: y))
        XCTAssertEqual(BooleanExpression(rawValue: "x or (y)"), .or(lhs: x, rhs: .precedence(value: y)))
        XCTAssertEqual(BooleanExpression(rawValue: "(x) or y"), .or(lhs: .precedence(value: x), rhs: y))
        XCTAssertNil(BooleanExpression(rawValue: "(x or y)"))
        XCTAssertNil(BooleanExpression(rawValue: "x or"))
        XCTAssertNil(BooleanExpression(rawValue: "or y"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "x or y or z"),
            .or(lhs: .logical(operation: .or(lhs: x, rhs: y)), rhs: z)
        )
        XCTAssertNil(BooleanExpression(rawValue: "x or y z"))
        XCTAssertNil(BooleanExpression(rawValue: "x or \(String(repeating: "y", count: 256))"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "x or y + z"),
            .or(lhs: x, rhs: .binary(operation: .addition(lhs: y, rhs: z)))
        )
        XCTAssertNil(BooleanExpression(rawValue: "x or !y"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "x + y or z"),
            .or(lhs: .binary(operation: .addition(lhs: x, rhs: y)), rhs: z)
        )
    }

    /// Test `init(rawValue: )` for a string containing an `nand` expression.
    func testNandInit() {
        XCTAssertEqual(BooleanExpression(rawValue: "x nand y"), .nand(lhs: x, rhs: y))
        XCTAssertEqual(BooleanExpression(rawValue: "x nand (y)"), .nand(lhs: x, rhs: .precedence(value: y)))
        XCTAssertEqual(BooleanExpression(rawValue: "(x) nand y"), .nand(lhs: .precedence(value: x), rhs: y))
        XCTAssertNil(BooleanExpression(rawValue: "(x nand y)"))
        XCTAssertNil(BooleanExpression(rawValue: "(x nand y"))
        XCTAssertNil(BooleanExpression(rawValue: "x nand"))
        XCTAssertNil(BooleanExpression(rawValue: "nand y"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "x nand y nand z"),
            .nand(lhs: .logical(operation: .nand(lhs: x, rhs: y)), rhs: z)
        )
        XCTAssertNil(BooleanExpression(rawValue: "x nand y z"))
        XCTAssertNil(BooleanExpression(rawValue: "x nand \(String(repeating: "y", count: 256))"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "x nand y + z"),
            .nand(lhs: x, rhs: .binary(operation: .addition(lhs: y, rhs: z)))
        )
        XCTAssertNil(BooleanExpression(rawValue: "x nand !y"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "x + y nand z"),
            .nand(lhs: .binary(operation: .addition(lhs: x, rhs: y)), rhs: z)
        )
    }

    /// Test `init(rawValue: )` for a string containing an `nor` expression.
    func testNorInit() {
        XCTAssertEqual(BooleanExpression(rawValue: "x nor y"), .nor(lhs: x, rhs: y))
        XCTAssertEqual(BooleanExpression(rawValue: "x nor (y)"), .nor(lhs: x, rhs: .precedence(value: y)))
        XCTAssertEqual(BooleanExpression(rawValue: "(x) nor y"), .nor(lhs: .precedence(value: x), rhs: y))
        XCTAssertNil(BooleanExpression(rawValue: "(x nor y)"))
        XCTAssertNil(BooleanExpression(rawValue: "x nor"))
        XCTAssertNil(BooleanExpression(rawValue: "nor y"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "x nor y nor z"),
            .nor(lhs: .logical(operation: .nor(lhs: x, rhs: y)), rhs: z)
        )
        XCTAssertNil(BooleanExpression(rawValue: "x nor y z"))
        XCTAssertNil(BooleanExpression(rawValue: "x nor \(String(repeating: "y", count: 256))"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "x nor y + z"),
            .nor(lhs: x, rhs: .binary(operation: .addition(lhs: y, rhs: z)))
        )
        XCTAssertNil(BooleanExpression(rawValue: "x nor !y"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "x + y nor z"),
            .nor(lhs: .binary(operation: .addition(lhs: x, rhs: y)), rhs: z)
        )
    }

    /// Test `init(rawValue: )` for a string containing an `xor` expression.
    func testXorInit() {
        XCTAssertEqual(BooleanExpression(rawValue: "x xor y"), .xor(lhs: x, rhs: y))
        XCTAssertEqual(BooleanExpression(rawValue: "x xor (y)"), .xor(lhs: x, rhs: .precedence(value: y)))
        XCTAssertEqual(BooleanExpression(rawValue: "(x) xor y"), .xor(lhs: .precedence(value: x), rhs: y))
        XCTAssertNil(BooleanExpression(rawValue: "(x xor y)"))
        XCTAssertNil(BooleanExpression(rawValue: "x xor"))
        XCTAssertNil(BooleanExpression(rawValue: "xor y"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "x xor y xor z"),
            .xor(lhs: .logical(operation: .xor(lhs: x, rhs: y)), rhs: z)
        )
        XCTAssertNil(BooleanExpression(rawValue: "x xor y z"))
        XCTAssertNil(BooleanExpression(rawValue: "x xor \(String(repeating: "y", count: 256))"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "x xor y + z"),
            .xor(lhs: x, rhs: .binary(operation: .addition(lhs: y, rhs: z)))
        )
        XCTAssertNil(BooleanExpression(rawValue: "x xor !y"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "x + y xor z"),
            .xor(lhs: .binary(operation: .addition(lhs: x, rhs: y)), rhs: z)
        )
    }

    /// Test `init(rawValue: )` for a string containing an `xnor` expression.
    func testXnorInit() {
        XCTAssertEqual(BooleanExpression(rawValue: "x xnor y"), .xnor(lhs: x, rhs: y))
        XCTAssertEqual(BooleanExpression(rawValue: "x xnor (y)"), .xnor(lhs: x, rhs: .precedence(value: y)))
        XCTAssertEqual(BooleanExpression(rawValue: "(x) xnor y"), .xnor(lhs: .precedence(value: x), rhs: y))
        XCTAssertNil(BooleanExpression(rawValue: "(x xnor y)"))
        XCTAssertNil(BooleanExpression(rawValue: "x xnor"))
        XCTAssertNil(BooleanExpression(rawValue: "xnor y"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "x xnor y xnor z"),
            .xnor(lhs: .logical(operation: .xnor(lhs: x, rhs: y)), rhs: z)
        )
        XCTAssertNil(BooleanExpression(rawValue: "x xnor y z"))
        XCTAssertNil(BooleanExpression(rawValue: "x xnor \(String(repeating: "y", count: 256))"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "x xnor y + z"),
            .xnor(lhs: x, rhs: .binary(operation: .addition(lhs: y, rhs: z)))
        )
        XCTAssertNil(BooleanExpression(rawValue: "x xnor !y"))
        XCTAssertEqual(
            BooleanExpression(rawValue: "x + y xnor z"),
            .xnor(lhs: .binary(operation: .addition(lhs: x, rhs: y)), rhs: z)
        )
    }

    /// Test `init(rawValue: )` for a string containing multiple boolean expressions.
    func testMultipleInit() {
        XCTAssertEqual(
            BooleanExpression(rawValue: "x and (y or z)"),
            .and(lhs: x, rhs: .precedence(value: .logical(operation: .or(lhs: y, rhs: z))))
        )
        XCTAssertEqual(
            BooleanExpression(rawValue: "x and y or (x and z) or (y and z)"),
            .and(
                lhs: x,
                rhs: .logical(
                    operation: .or(
                        lhs: y,
                        rhs: .logical(
                            operation: .or(
                                lhs: .precedence(value: .logical(operation: .and(lhs: x, rhs: z))),
                                rhs: .precedence(value: .logical(operation: .and(lhs: y, rhs: z)))
                            )
                        )
                    )
                )
            )
        )
        XCTAssertEqual(
            BooleanExpression(rawValue: "(x and y) or (x and (y and z))"),
            .or(
                lhs: .precedence(value: .logical(operation: .and(lhs: x, rhs: y))),
                rhs: .precedence(
                    value: .logical(
                        operation: .and(
                            lhs: x,
                            rhs: .precedence(value: .logical(operation: .and(lhs: y, rhs: z)))
                        )
                    )
                )
            )
        )
    }

    /// Test a large expression.
    func testBigConditional() {
        XCTAssertEqual(
            BooleanExpression(
                rawValue: "(true) and (not (statusIn = '1' and count = \"0010\")) and (not (count = "
                    + "\"0011\"))"
            ),
            .and(
                lhs: .precedence(value: .literal(value: .boolean(value: true))),
                rhs: .logical(
                    operation: .and(
                        lhs: .precedence(
                            value: .logical(
                                operation: .not(
                                    value: .precedence(
                                        value: .logical(
                                            operation: .and(
                                                lhs: .conditional(
                                                    condition: .comparison(
                                                        value: .equality(
                                                            lhs: .reference(
                                                                variable: .variable(
                                                                    reference: .variable(
                                                                        name: VariableName(text: "statusIn")
                                                                    )
                                                                )
                                                            ),
                                                            rhs: .literal(value: .bit(value: .high))
                                                        )
                                                    )
                                                ),
                                                rhs: .conditional(
                                                    condition: .comparison(
                                                        value: .equality(
                                                            lhs: .reference(
                                                                variable: .variable(
                                                                    reference: .variable(
                                                                        name: VariableName(text: "count")
                                                                    )
                                                                )
                                                            ),
                                                            rhs: .literal(
                                                                value: .vector(
                                                                    value: .bits(
                                                                        value: BitVector(values: [
                                                                            .low, .low, .high, .low,
                                                                        ])
                                                                    )
                                                                )
                                                            )
                                                        )
                                                    )
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        ),
                        rhs: .precedence(
                            value: .logical(
                                operation: .not(
                                    value: .precedence(
                                        value: .conditional(
                                            condition: .comparison(
                                                value: .equality(
                                                    lhs: .reference(
                                                        variable: .variable(
                                                            reference: .variable(
                                                                name: VariableName(text: "count")
                                                            )
                                                        )
                                                    ),
                                                    rhs: .literal(
                                                        value: .vector(
                                                            value: .bits(
                                                                value: BitVector(values: [
                                                                    .low, .low, .high, .high,
                                                                ])
                                                            )
                                                        )
                                                    )
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    }

}
