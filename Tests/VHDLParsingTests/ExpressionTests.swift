// VHDLParsing.ExpressionTests.swift
// Machines
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
// either version 2 of the License, or (at your option) any later version.func toStateV
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

// swiftlint:disable file_length
// swiftlint:disable type_body_length

/// Test class for ``VHDLParsing.Expression``.
final class ExpressionTests: XCTestCase {

    /// A variable called `a`.
    let aname = VariableName(text: "a")

    /// A variable called `b`.
    let bname = VariableName(text: "b")

    /// A variable called `c`.
    let cname = VariableName(text: "c")

    /// A variable called `d`.
    let dname = VariableName(text: "d")

    /// A variable called `e`.
    let ename = VariableName(text: "e")

    /// VHDLParsing.Expression `a`.
    var a: VHDLParsing.Expression { .reference(variable: .variable(reference: .variable(name: aname))) }

    /// VHDLParsing.Expression `b`.
    var b: VHDLParsing.Expression { .reference(variable: .variable(reference: .variable(name: bname))) }

    /// VHDLParsing.Expression `c`.
    var c: VHDLParsing.Expression { .reference(variable: .variable(reference: .variable(name: cname))) }

    /// VHDLParsing.Expression `d`.
    var d: VHDLParsing.Expression { .reference(variable: .variable(reference: .variable(name: dname))) }

    /// VHDLParsing.Expression `e`.
    var e: VHDLParsing.Expression { .reference(variable: .variable(reference: .variable(name: ename))) }

    /// Test raw values are correct.
    func testRawValues() {
        XCTAssertEqual(a.rawValue, "a")
        XCTAssertEqual(VHDLParsing.Expression.binary(operation: .addition(lhs: a, rhs: b)).rawValue, "a + b")
        XCTAssertEqual(
            VHDLParsing.Expression.binary(operation: .subtraction(lhs: a, rhs: b)).rawValue, "a - b"
        )
        XCTAssertEqual(
            VHDLParsing.Expression.binary(operation: .multiplication(lhs: a, rhs: b)).rawValue, "a * b"
        )
        XCTAssertEqual(VHDLParsing.Expression.binary(operation: .division(lhs: a, rhs: b)).rawValue, "a / b")
        XCTAssertEqual(VHDLParsing.Expression.precedence(value: a).rawValue, "(a)")
        XCTAssertEqual(
            VHDLParsing.Expression.literal(value: .logic(value: .uninitialized)).rawValue,
            LogicLiteral.uninitialized.rawValue
        )
        XCTAssertEqual(VHDLParsing.Expression.logical(operation: .and(lhs: a, rhs: b)).rawValue, "a and b")
        XCTAssertEqual(
            VHDLParsing.Expression.cast(operation: .real(expression: a)).rawValue, "real(a)"
        )
        XCTAssertEqual(
            VHDLParsing.Expression.functionCall(
                call: .custom(
                    function: CustomFunctionCall(name: aname, parameters: [Argument(argument: b)])
                )
            )
            .rawValue,
            "a(b)"
        )
    }

    // swiftlint:disable function_body_length

    /// Test init successfully creates `VHDLParsing.Expression` for simple statements.
    func testSimpleInit() {
        XCTAssertEqual(VHDLParsing.Expression(rawValue: "a"), a)
        XCTAssertNil(VHDLParsing.Expression(rawValue: "a;"))
        XCTAssertEqual(VHDLParsing.Expression(rawValue: "(a)"), .precedence(value: a))
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "a * b"),
            .binary(operation: .multiplication(lhs: a, rhs: b))
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "a(3 downto 0) * 5"),
            .binary(
                operation: .multiplication(
                    lhs: .reference(
                        variable: .indexed(
                            name: a,
                            index: .range(
                                value: .downto(
                                    upper: .literal(value: .integer(value: 3)),
                                    lower: .literal(value: .integer(value: 0))
                                )
                            )
                        )
                    ),
                    rhs: .literal(value: .integer(value: 5))
                )
            )
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "5 * a(3 downto 0)"),
            .binary(
                operation: .multiplication(
                    lhs: .literal(value: .integer(value: 5)),
                    rhs: .reference(
                        variable: .indexed(
                            name: a,
                            index: .range(
                                value: .downto(
                                    upper: .literal(value: .integer(value: 3)),
                                    lower: .literal(value: .integer(value: 0))
                                )
                            )
                        )
                    )
                )
            )
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "a / b"),
            .binary(operation: .division(lhs: a, rhs: b))
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "a + b"),
            .binary(operation: .addition(lhs: a, rhs: b))
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "a - b"),
            .binary(operation: .subtraction(lhs: a, rhs: b))
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "a + 5"),
            .binary(operation: .addition(lhs: a, rhs: .literal(value: .integer(value: 5))))
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "(a) + b"),
            .binary(operation: .addition(lhs: .precedence(value: a), rhs: b))
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "(a)+b"),
            .binary(operation: .addition(lhs: .precedence(value: a), rhs: b))
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "(a) > b"),
            .conditional(condition: .comparison(value: .greaterThan(lhs: .precedence(value: a), rhs: b)))
        )
    }

    // swiftlint:enable function_body_length

    /// Test invalid raw values return nil.
    func testInvalidRawValueInit() {
        XCTAssertNil(VHDLParsing.Expression(rawValue: "()"))
        XCTAssertNil(VHDLParsing.Expression(rawValue: ""))
        XCTAssertNil(VHDLParsing.Expression(rawValue: " "))
        XCTAssertNil(VHDLParsing.Expression(rawValue: "\n"))
        XCTAssertNil(VHDLParsing.Expression(rawValue: "a + ()"))
        XCTAssertNil(VHDLParsing.Expression(rawValue: "(a + b"))
        XCTAssertNil(VHDLParsing.Expression(rawValue: String(repeating: "a", count: 2048)))
        XCTAssertNil(VHDLParsing.Expression(rawValue: "-- a\n-- b"))
        XCTAssertNil(VHDLParsing.Expression(rawValue: "a + b--;"))
        XCTAssertNil(VHDLParsing.Expression(rawValue: "a + b;-- a\n--b"))
        XCTAssertNil(VHDLParsing.Expression(rawValue: "a + b;-- a\n--b\n--c"))
        XCTAssertNil(VHDLParsing.Expression(rawValue: "a; +-- b;"))
        XCTAssertNil(VHDLParsing.Expression(rawValue: "(a) ++ b"))
    }

    /// Test init works for statement with multiple sub VHDLParsing.Expressions.
    func testMultipleInit() {
        let raw = "(a - b) + c"
        let expected = VHDLParsing.Expression.binary(
            operation: .addition(
                lhs: .precedence(value: .binary(operation: .subtraction(lhs: a, rhs: b))),
                rhs: c
            )
        )
        let result = VHDLParsing.Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    /// Test init works for statement with multiple sub VHDLParsing.Expressions in different order.
    func testMultipleInit2() {
        let raw = "a * (b - c)"
        let expected = VHDLParsing.Expression.binary(
            operation: .multiplication(
                lhs: a,
                rhs: .precedence(value: .binary(operation: .subtraction(lhs: b, rhs: c)))
            )
        )
        let result = VHDLParsing.Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "a * b * c"),
            .binary(
                operation: .multiplication(
                    lhs: a,
                    rhs: .binary(operation: .multiplication(lhs: b, rhs: c))
                )
            )
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "(a + b) + (c + d)"),
            .binary(
                operation: .addition(
                    lhs: .precedence(value: .binary(operation: .addition(lhs: a, rhs: b))),
                    rhs: .precedence(value: .binary(operation: .addition(lhs: c, rhs: d)))
                )
            )
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "((a + b) + c)"),
            .precedence(
                value: .binary(
                    operation: .addition(
                        lhs: .precedence(value: .binary(operation: .addition(lhs: a, rhs: b))),
                        rhs: c
                    )
                )
            )
        )
    }

    /// Test complex VHDLParsing.Expression is created correctly.
    func testComplexInit() {
        let raw = "(a - b) + c * d / e"
        let expected = VHDLParsing.Expression.binary(
            operation: .multiplication(
                lhs: .binary(
                    operation: .addition(
                        lhs: .precedence(value: .binary(operation: .subtraction(lhs: a, rhs: b))),
                        rhs: c
                    )
                ),
                rhs: .binary(operation: .division(lhs: d, rhs: e))
            )
        )
        let result = VHDLParsing.Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    /// Test another complex VHDLParsing.Expression is created correctly.
    func testComplexInit2() {
        let raw = "a + b * (c + d) / e"
        let expected = VHDLParsing.Expression.binary(
            operation: .multiplication(
                lhs: .binary(operation: .addition(lhs: a, rhs: b)),
                rhs: .binary(
                    operation: .division(
                        lhs: .precedence(value: .binary(operation: .addition(lhs: c, rhs: d))),
                        rhs: e
                    )
                )
            )
        )
        let result = VHDLParsing.Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    /// Test another complex raw value.
    func testComplexInit3() {
        let raw = "a + b * c + d / e"
        let expected = VHDLParsing.Expression.binary(
            operation: .multiplication(
                lhs: .binary(operation: .addition(lhs: a, rhs: b)),
                rhs: .binary(operation: .addition(lhs: c, rhs: .binary(operation: .division(lhs: d, rhs: e))))
            )
        )
        let result = VHDLParsing.Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    /// Test another complex raw value.
    func testComplexInit4() {
        let raw = "a + b * c + d / e - 5"
        let expected = VHDLParsing.Expression.binary(
            operation: .multiplication(
                lhs: .binary(operation: .addition(lhs: a, rhs: b)),
                rhs: .binary(
                    operation: .addition(
                        lhs: c,
                        rhs: .binary(
                            operation: .subtraction(
                                lhs: .binary(operation: .division(lhs: d, rhs: e)),
                                rhs: .literal(value: .integer(value: 5))
                            )
                        )
                    )
                )
            )
        )
        let result = VHDLParsing.Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    /// Test raw value works for complex VHDLParsing.Expression.
    func testComplexRawValue() {
        let expected = "a + b * c + d / e"
        let expression = VHDLParsing.Expression.binary(
            operation: .multiplication(
                lhs: .binary(operation: .addition(lhs: a, rhs: b)),
                rhs: .binary(operation: .addition(lhs: c, rhs: .binary(operation: .division(lhs: d, rhs: e))))
            )
        )
        XCTAssertEqual(expected, expression.rawValue)
    }

    /// Test conditionals are created correctly.
    func testConditionals() {
        let raw = "a > b"
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: raw),
            .conditional(condition: .comparison(value: .greaterThan(lhs: a, rhs: b)))
        )
        let raw2 = "a + b > c + d"
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: raw2),
            .conditional(
                condition: .comparison(
                    value: .greaterThan(
                        lhs: .binary(operation: .addition(lhs: a, rhs: b)),
                        rhs: .binary(operation: .addition(lhs: c, rhs: d))
                    )
                )
            )
        )
    }

    /// Test `description` matches `rawValue`.
    func testDescription() {
        let expression = VHDLParsing.Expression.conditional(
            condition: .comparison(
                value: .greaterThan(
                    lhs: .binary(operation: .addition(lhs: a, rhs: b)),
                    rhs: .binary(operation: .addition(lhs: c, rhs: d))
                )
            )
        )
        XCTAssertEqual(expression.description, expression.rawValue)
    }

    /// Test VHDLParsing.Expression creates logical VHDLParsing.Expression correctly.
    func testLogicalInit() {
        XCTAssertEqual(VHDLParsing.Expression(rawValue: "a and b"), .logical(operation: .and(lhs: a, rhs: b)))
        XCTAssertEqual(VHDLParsing.Expression(rawValue: "not a"), .logical(operation: .not(value: a)))
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "a or b and c"),
            .logical(operation: .and(lhs: .logical(operation: .or(lhs: a, rhs: b)), rhs: c))
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "a xor (b and c) or d"),
            .logical(
                operation: .xor(
                    lhs: a,
                    rhs: .logical(
                        operation: .or(
                            lhs: .precedence(value: .logical(operation: .and(lhs: b, rhs: c))),
                            rhs: d
                        )
                    )
                )
            )
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "a xor (b and c) or not d"),
            .logical(
                operation: .xor(
                    lhs: a,
                    rhs: .logical(
                        operation: .or(
                            lhs: .precedence(value: .logical(operation: .and(lhs: b, rhs: c))),
                            rhs: .logical(operation: .not(value: d))
                        )
                    )
                )
            )
        )
    }

    /// Test init for cast VHDLParsing.Expressions.
    func testCastInit() {
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "real(a)"), .cast(operation: .real(expression: a))
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "(real(a))"),
            .precedence(value: .cast(operation: .real(expression: a)))
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "real(a) + 5.0"),
            .binary(
                operation: .addition(
                    lhs: .cast(operation: .real(expression: a)),
                    rhs: .literal(value: .decimal(value: 5.0))
                )
            )
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "real(a) + (b - 5.0)"),
            .binary(
                operation: .addition(
                    lhs: .cast(operation: .real(expression: a)),
                    rhs: .precedence(
                        value: .binary(
                            operation: .subtraction(lhs: b, rhs: .literal(value: .decimal(value: 5.0)))
                        )
                    )
                )
            )
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "(b - real(a)) + 5.0"),
            .binary(
                operation: .addition(
                    lhs: .precedence(
                        value: .binary(
                            operation: .subtraction(
                                lhs: b,
                                rhs: .cast(operation: .real(expression: a))
                            )
                        )
                    ),
                    rhs: .literal(value: .decimal(value: 5.0))
                )
            )
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "real(a + b)"),
            .cast(operation: .real(expression: .binary(operation: .addition(lhs: a, rhs: b))))
        )
    }

    // swiftlint:disable function_body_length

    /// Test `init(rawValue:)` for function calls.
    func testFunctionCallInit() {
        let f = VariableName(text: "f")
        let g = VariableName(text: "g")
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "f()"),
            .functionCall(call: .custom(function: CustomFunctionCall(name: f, parameters: [])))
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "f(a, b, c, d)"),
            .functionCall(call: .custom(function: CustomFunctionCall(
                name: f, parameters: [a, b, c, d].map { Argument(argument: $0) }
            )))
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "(a + b) + f(c) - g(c * d)"),
            .binary(
                operation: .addition(
                    lhs: .precedence(value: .binary(operation: .addition(lhs: a, rhs: b))),
                    rhs: .binary(
                        operation: .subtraction(
                            lhs: .functionCall(
                                call: .custom(function: CustomFunctionCall(
                                    name: f, parameters: [Argument(argument: c)]
                                ))
                            ),
                            rhs: .functionCall(
                                call: .custom(
                                    function: CustomFunctionCall(
                                        name: g,
                                        parameters: [
                                            Argument(
                                                argument: .binary(operation: .multiplication(lhs: c, rhs: d))
                                            )
                                        ]
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
        XCTAssertEqual(
            VHDLParsing.Expression(rawValue: "f(g(a))"),
            .functionCall(
                call: .custom(
                    function: CustomFunctionCall(
                        name: f,
                        parameters: [
                            Argument(argument: .functionCall(
                                call: .custom(
                                    function: CustomFunctionCall(name: g, parameters: [Argument(argument: a)])
                                )
                            ))
                        ]
                    )
                )
            )
        )
    }

    // swiftlint:enable function_body_length

    /// Tests that `isValidOtherValue` correctly identifies valid other values.
    func testIsValidOtherValue() {
        XCTAssertTrue(VHDLParsing.Expression.binary(operation: .addition(lhs: a, rhs: b)).isValidOtherValue)
        XCTAssertTrue(
            VHDLParsing.Expression.cast(operation: .bit(expression: a)).isValidOtherValue
        )
        XCTAssertFalse(
            VHDLParsing.Expression.cast(operation: .boolean(expression: a)).isValidOtherValue
        )
        XCTAssertFalse(
            VHDLParsing.Expression.conditional(condition: .edge(value: .falling(expression: a)))
                .isValidOtherValue
        )
        XCTAssertTrue(
            VHDLParsing.Expression.functionCall(
                call: .custom(function: CustomFunctionCall(name: VariableName(text: "a"), parameters: []))
            )
            .isValidOtherValue
        )
        XCTAssertFalse(VHDLParsing.Expression.logical(operation: .and(lhs: a, rhs: b)).isValidOtherValue)
        XCTAssertTrue(VHDLParsing.Expression.literal(value: .bit(value: .low)).isValidOtherValue)
        XCTAssertTrue(VHDLParsing.Expression.literal(value: .logic(value: .high)).isValidOtherValue)
        XCTAssertFalse(VHDLParsing.Expression.literal(value: .boolean(value: false)).isValidOtherValue)
        XCTAssertTrue(VHDLParsing.Expression.precedence(value: a).isValidOtherValue)
        XCTAssertTrue(
            VHDLParsing.Expression.reference(
                variable: .variable(reference: .variable(name: VariableName(text: "a")))
            )
            .isValidOtherValue
        )
        XCTAssertFalse(
            VHDLParsing.Expression.reference(
                variable: .indexed(
                    name: a,
                    index: .range(value: .downto(upper: a, lower: b))
                )
            )
            .isValidOtherValue
        )
        XCTAssertTrue(
            VHDLParsing.Expression.reference(
                variable: .indexed(
                    name: a,
                    index: .index(value: a)
                )
            )
            .isValidOtherValue
        )
    }

}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
