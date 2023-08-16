// ExpressionTests.swift
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

// swiftlint:disable type_body_length

/// Test class for ``Expression``.
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

    /// Expression `a`.
    var a: Expression { .reference(variable: .variable(name: aname)) }

    /// Expression `b`.
    var b: Expression { .reference(variable: .variable(name: bname)) }

    /// Expression `c`.
    var c: Expression { .reference(variable: .variable(name: cname)) }

    /// Expression `d`.
    var d: Expression { .reference(variable: .variable(name: dname)) }

    /// Expression `e`.
    var e: Expression { .reference(variable: .variable(name: ename)) }

    /// Test raw values are correct.
    func testRawValues() {
        XCTAssertEqual(a.rawValue, "a")
        XCTAssertEqual(Expression.binary(operation: .addition(lhs: a, rhs: b)).rawValue, "a + b")
        XCTAssertEqual(Expression.binary(operation: .subtraction(lhs: a, rhs: b)).rawValue, "a - b")
        XCTAssertEqual(Expression.binary(operation: .multiplication(lhs: a, rhs: b)).rawValue, "a * b")
        XCTAssertEqual(Expression.binary(operation: .division(lhs: a, rhs: b)).rawValue, "a / b")
        XCTAssertEqual(Expression.precedence(value: a).rawValue, "(a)")
        XCTAssertEqual(
            Expression.literal(value: .logic(value: .uninitialized)).rawValue,
            LogicLiteral.uninitialized.rawValue
        )
        XCTAssertEqual(Expression.logical(operation: .and(lhs: a, rhs: b)).rawValue, "a and b")
        XCTAssertEqual(Expression.cast(operation: .real(expression: a)).rawValue, "real(a)")
        XCTAssertEqual(
            Expression.functionCall(call: .custom(
                function: CustomFunctionCall(name: aname, arguments: [b])
            )).rawValue,
            "a(b)"
        )
    }

    /// Test init successfully creates `Expression` for simple statements.
    func testSimpleInit() {
        XCTAssertEqual(Expression(rawValue: "a"), a)
        XCTAssertNil(Expression(rawValue: "a;"))
        XCTAssertEqual(Expression(rawValue: "(a)"), .precedence(value: a))
        XCTAssertEqual(
            Expression(rawValue: "a * b"), .binary(operation: .multiplication(lhs: a, rhs: b))
        )
        XCTAssertEqual(
            Expression(rawValue: "a(3 downto 0) * 5"),
            .binary(operation: .multiplication(
                lhs: .reference(variable: .indexed(name: aname, index: .range(value: .downto(
                    upper: .literal(value: .integer(value: 3)), lower: .literal(value: .integer(value: 0))
                )))),
                rhs: .literal(value: .integer(value: 5))
            ))
        )
        XCTAssertEqual(
            Expression(rawValue: "5 * a(3 downto 0)"),
            .binary(operation: .multiplication(
                lhs: .literal(value: .integer(value: 5)),
                rhs: .reference(variable: .indexed(name: aname, index: .range(value: .downto(
                        upper: .literal(value: .integer(value: 3)),
                        lower: .literal(value: .integer(value: 0))
                ))))
            ))
        )
        XCTAssertEqual(
            Expression(rawValue: "a / b"), .binary(operation: .division(lhs: a, rhs: b))
        )
        XCTAssertEqual(
            Expression(rawValue: "a + b"), .binary(operation: .addition(lhs: a, rhs: b))
        )
        XCTAssertEqual(
            Expression(rawValue: "a - b"), .binary(operation: .subtraction(lhs: a, rhs: b))
        )
        XCTAssertEqual(
            Expression(rawValue: "a + 5"),
            .binary(operation: .addition(lhs: a, rhs: .literal(value: .integer(value: 5))))
        )
        XCTAssertEqual(
            Expression(rawValue: "(a) + b"),
            .binary(operation: .addition(lhs: .precedence(value: a), rhs: b))
        )
        XCTAssertEqual(
            Expression(rawValue: "(a)+b"),
            .binary(operation: .addition(lhs: .precedence(value: a), rhs: b))
        )
        XCTAssertEqual(
            Expression(rawValue: "(a) > b"),
            .conditional(condition: .comparison(value: .greaterThan(lhs: .precedence(value: a), rhs: b)))
        )
    }

    /// Test invalid raw values return nil.
    func testInvalidRawValueInit() {
        XCTAssertNil(Expression(rawValue: "()"))
        XCTAssertNil(Expression(rawValue: ""))
        XCTAssertNil(Expression(rawValue: " "))
        XCTAssertNil(Expression(rawValue: "\n"))
        XCTAssertNil(Expression(rawValue: "a + ()"))
        XCTAssertNil(Expression(rawValue: "(a + b"))
        XCTAssertNil(Expression(rawValue: String(repeating: "a", count: 256)))
        XCTAssertNil(Expression(rawValue: "-- a\n-- b"))
        XCTAssertNil(Expression(rawValue: "a + b--;"))
        XCTAssertNil(Expression(rawValue: "a + b;-- a\n--b"))
        XCTAssertNil(Expression(rawValue: "a + b;-- a\n--b\n--c"))
        XCTAssertNil(Expression(rawValue: "a; +-- b;"))
        XCTAssertNil(Expression(rawValue: "(a) ++ b"))
    }

    /// Test init works for statement with multiple sub expressions.
    func testMultipleInit() {
        let raw = "(a - b) + c"
        let expected = Expression.binary(operation: .addition(
            lhs: .precedence(value: .binary(operation: .subtraction(lhs: a, rhs: b))), rhs: c
        ))
        let result = Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    /// Test init works for statement with multiple sub expressions in different order.
    func testMultipleInit2() {
        let raw = "a * (b - c)"
        let expected = Expression.binary(operation: .multiplication(
            lhs: a, rhs: .precedence(value: .binary(operation: .subtraction(lhs: b, rhs: c)))
        ))
        let result = Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
        XCTAssertEqual(
            Expression(rawValue: "a * b * c"),
            .binary(operation: .multiplication(
                lhs: a, rhs: .binary(operation: .multiplication(lhs: b, rhs: c))
            ))
        )
        XCTAssertEqual(
            Expression(rawValue: "(a + b) + (c + d)"),
            .binary(
                operation: .addition(
                    lhs: .precedence(value: .binary(operation: .addition(lhs: a, rhs: b))),
                    rhs: .precedence(value: .binary(operation: .addition(lhs: c, rhs: d)))
                )
            )
        )
        XCTAssertEqual(
            Expression(rawValue: "((a + b) + c)"),
            .precedence(value: .binary(operation: .addition(
                lhs: .precedence(value: .binary(operation: .addition(lhs: a, rhs: b))), rhs: c
            )))
        )
    }

    /// Test complex expression is created correctly.
    func testComplexInit() {
        let raw = "(a - b) + c * d / e"
        let expected = Expression.binary(operation: .multiplication(
            lhs: .binary(operation: .addition(
                lhs: .precedence(value: .binary(operation: .subtraction(lhs: a, rhs: b))), rhs: c
            )),
            rhs: .binary(operation: .division(lhs: d, rhs: e))
        ))
        let result = Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    /// Test another complex expression is created correctly.
    func testComplexInit2() {
        let raw = "a + b * (c + d) / e"
        let expected = Expression.binary(operation: .multiplication(
            lhs: .binary(operation: .addition(lhs: a, rhs: b)),
            rhs: .binary(operation: .division(
                lhs: .precedence(value: .binary(operation: .addition(lhs: c, rhs: d))), rhs: e
            ))
        ))
        let result = Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    /// Test another complex raw value.
    func testComplexInit3() {
        let raw = "a + b * c + d / e"
        let expected = Expression.binary(operation: .multiplication(
            lhs: .binary(operation: .addition(lhs: a, rhs: b)),
            rhs: .binary(operation: .addition(lhs: c, rhs: .binary(operation: .division(lhs: d, rhs: e))))
        ))
        let result = Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    /// Test another complex raw value.
    func testComplexInit4() {
        let raw = "a + b * c + d / e - 5"
        let expected = Expression.binary(operation: .multiplication(
            lhs: .binary(operation: .addition(lhs: a, rhs: b)),
            rhs: .binary(operation: .addition(
                lhs: c,
                rhs: .binary(operation: .subtraction(
                    lhs: .binary(operation: .division(lhs: d, rhs: e)),
                    rhs: .literal(value: .integer(value: 5))
                ))
            ))
        ))
        let result = Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    /// Test raw value works for complex expression.
    func testComplexRawValue() {
        let expected = "a + b * c + d / e"
        let expression = Expression.binary(operation: .multiplication(
            lhs: .binary(operation: .addition(lhs: a, rhs: b)),
            rhs: .binary(operation: .addition(lhs: c, rhs: .binary(operation: .division(lhs: d, rhs: e))))
        ))
        XCTAssertEqual(expected, expression.rawValue)
    }

    /// Test conditionals are created correctly.
    func testConditionals() {
        let raw = "a > b"
        XCTAssertEqual(
            Expression(rawValue: raw),
            .conditional(condition: .comparison(value: .greaterThan(lhs: a, rhs: b)))
        )
        let raw2 = "a + b > c + d"
        XCTAssertEqual(
            Expression(rawValue: raw2),
            .conditional(condition: .comparison(value: .greaterThan(
                lhs: .binary(operation: .addition(lhs: a, rhs: b)),
                rhs: .binary(operation: .addition(lhs: c, rhs: d))
            )))
        )
    }

    /// Test `description` matches `rawValue`.
    func testDescription() {
        let expression = Expression.conditional(
            condition: .comparison(
                value: .greaterThan(
                    lhs: .binary(operation: .addition(lhs: a, rhs: b)),
                    rhs: .binary(operation: .addition(lhs: c, rhs: d))
                )
            )
        )
        XCTAssertEqual(expression.description, expression.rawValue)
    }

    /// Test expression creates logical expression correctly.
    func testLogicalInit() {
        XCTAssertEqual(Expression(rawValue: "a and b"), .logical(operation: .and(lhs: a, rhs: b)))
        XCTAssertEqual(Expression(rawValue: "not a"), .logical(operation: .not(value: a)))
        XCTAssertEqual(
            Expression(rawValue: "a or b and c"),
            .logical(operation: .and(lhs: .logical(operation: .or(lhs: a, rhs: b)), rhs: c))
        )
        XCTAssertEqual(
            Expression(rawValue: "a xor (b and c) or d"),
            .logical(operation: .xor(lhs: a, rhs: .logical(operation: .or(
                lhs: .precedence(value: .logical(operation: .and(lhs: b, rhs: c))), rhs: d
            ))))
        )
        XCTAssertEqual(
            Expression(rawValue: "a xor (b and c) or not d"),
            .logical(operation: .xor(lhs: a, rhs: .logical(operation: .or(
                lhs: .precedence(value: .logical(operation: .and(lhs: b, rhs: c))),
                rhs: .logical(operation: .not(value: d))
            ))))
        )
    }

    /// Test init for cast expressions.
    func testCastInit() {
        XCTAssertEqual(Expression(rawValue: "real(a)"), .cast(operation: .real(expression: a)))
        XCTAssertEqual(
            Expression(rawValue: "(real(a))"), .precedence(value: .cast(operation: .real(expression: a)))
        )
        XCTAssertEqual(
            Expression(rawValue: "real(a) + 5.0"),
            .binary(operation: .addition(
                lhs: .cast(operation: .real(expression: a)), rhs: .literal(value: .decimal(value: 5.0))
            ))
        )
        XCTAssertEqual(
            Expression(rawValue: "real(a) + (b - 5.0)"),
            .binary(operation: .addition(
                lhs: .cast(operation: .real(expression: a)),
                rhs: .precedence(value: .binary(
                    operation: .subtraction(lhs: b, rhs: .literal(value: .decimal(value: 5.0)))
                ))
            ))
        )
        XCTAssertEqual(
            Expression(rawValue: "(b - real(a)) + 5.0"),
            .binary(operation: .addition(
                lhs: .precedence(value: .binary(operation: .subtraction(
                    lhs: b,
                    rhs: .cast(operation: .real(expression: a))
                ))),
                rhs: .literal(value: .decimal(value: 5.0))
            ))
        )
        XCTAssertEqual(
            Expression(rawValue: "real(a + b)"),
            .cast(operation: .real(expression: .binary(operation: .addition(lhs: a, rhs: b))))
        )
    }

    /// Test `init(rawValue:)` for function calls.
    func testFunctionCallInit() {
        let f = VariableName(text: "f")
        let g = VariableName(text: "g")
        XCTAssertEqual(
            Expression(rawValue: "f()"),
            .functionCall(call: .custom(function: CustomFunctionCall(name: f, arguments: [])))
        )
        XCTAssertEqual(
            Expression(rawValue: "f(a, b, c, d)"),
            .functionCall(call: .custom(function: CustomFunctionCall(name: f, arguments: [a, b, c, d])))
        )
        XCTAssertEqual(
            Expression(rawValue: "(a + b) + f(c) - g(c * d)"),
            .binary(operation: .addition(
                lhs: .precedence(value: .binary(operation: .addition(lhs: a, rhs: b))),
                rhs: .binary(operation: .subtraction(
                    lhs: .functionCall(call: .custom(function: CustomFunctionCall(name: f, arguments: [c]))),
                    rhs: .functionCall(call: .custom(function: CustomFunctionCall(
                        name: g,
                        arguments: [.binary(operation: .multiplication(lhs: c, rhs: d))]
                    )))
                ))
            ))
        )
        XCTAssertEqual(Expression(rawValue: "f(g(a))"), .functionCall(call: .custom(
            function: CustomFunctionCall(
                name: f,
                arguments: [
                    .functionCall(call: .custom(function: CustomFunctionCall(name: g, arguments: [a])))
                ]
            )
        )))
    }

    /// Tests that `isValidOtherValue` correctly identifies valid other values.
    func testIsValidOtherValue() {
        XCTAssertTrue(Expression.binary(operation: .addition(lhs: a, rhs: b)).isValidOtherValue)
        XCTAssertTrue(Expression.cast(operation: .bit(expression: a)).isValidOtherValue)
        XCTAssertFalse(Expression.cast(operation: .boolean(expression: a)).isValidOtherValue)
        XCTAssertFalse(
            Expression.conditional(condition: .edge(value: .falling(expression: a))).isValidOtherValue
        )
        XCTAssertTrue(
            Expression.functionCall(
                call: .custom(function: CustomFunctionCall(name: VariableName(text: "a"), arguments: []))
            ).isValidOtherValue
        )
        XCTAssertFalse(Expression.logical(operation: .and(lhs: a, rhs: b)).isValidOtherValue)
        XCTAssertTrue(Expression.literal(value: .bit(value: .low)).isValidOtherValue)
        XCTAssertTrue(Expression.literal(value: .logic(value: .high)).isValidOtherValue)
        XCTAssertFalse(Expression.literal(value: .boolean(value: false)).isValidOtherValue)
        XCTAssertTrue(Expression.precedence(value: a).isValidOtherValue)
        XCTAssertTrue(
            Expression.reference(variable: .variable(name: VariableName(text: "a"))).isValidOtherValue
        )
        XCTAssertFalse(Expression.reference(variable: .indexed(
            name: VariableName(text: "a"), index: .range(value: .downto(upper: a, lower: b))
        )).isValidOtherValue)
        XCTAssertTrue(Expression.reference(variable: .indexed(
            name: VariableName(text: "a"), index: .index(value: a)
        )).isValidOtherValue)
    }

}

// swiftlint:enable type_body_length
