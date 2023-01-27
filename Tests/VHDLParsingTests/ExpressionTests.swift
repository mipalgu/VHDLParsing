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

    /// Test raw values are correct.
    func testRawValues() {
        XCTAssertEqual(Expression.variable(name: aname).rawValue, "a")
        XCTAssertEqual(
            Expression.binary(
                operation: .addition(lhs: .variable(name: aname), rhs: .variable(name: bname))
            ).rawValue,
            "a + b"
        )
        XCTAssertEqual(
            Expression.binary(
                operation: .subtraction(lhs: .variable(name: aname), rhs: .variable(name: bname))
            ).rawValue,
            "a - b"
        )
        XCTAssertEqual(
            Expression.binary(
                operation: .multiplication(lhs: .variable(name: aname), rhs: .variable(name: bname))
            ).rawValue,
            "a * b"
        )
        XCTAssertEqual(
            Expression.binary(
                operation: .division(lhs: .variable(name: aname), rhs: .variable(name: bname))
            ).rawValue,
            "a / b"
        )
        XCTAssertEqual(Expression.precedence(value: .variable(name: aname)).rawValue, "(a)")
        XCTAssertEqual(
            Expression.literal(value: .logic(value: .uninitialized)).rawValue,
            LogicLiteral.uninitialized.rawValue
        )
        XCTAssertEqual(
            Expression.logical(
                operation: .and(lhs: .variable(name: aname), rhs: .variable(name: bname))
            ).rawValue,
            "a and b"
        )
    }

    /// Test init successfully creates `Expression` for simple statements.
    func testSimpleInit() {
        XCTAssertEqual(Expression(rawValue: "a"), .variable(name: aname))
        XCTAssertNil(Expression(rawValue: "a;"))
        XCTAssertEqual(Expression(rawValue: "(a)"), .precedence(value: .variable(name: aname)))
        XCTAssertEqual(
            Expression(rawValue: "a * b"),
            .binary(operation: .multiplication(lhs: .variable(name: aname), rhs: .variable(name: bname)))
        )
        XCTAssertEqual(
            Expression(rawValue: "a / b"),
            .binary(operation: .division(lhs: .variable(name: aname), rhs: .variable(name: bname)))
        )
        XCTAssertEqual(
            Expression(rawValue: "a + b"),
            .binary(operation: .addition(lhs: .variable(name: aname), rhs: .variable(name: bname)))
        )
        XCTAssertEqual(
            Expression(rawValue: "a - b"),
            .binary(operation: .subtraction(lhs: .variable(name: aname), rhs: .variable(name: bname)))
        )
        XCTAssertEqual(
            Expression(rawValue: "a + 5"),
            .binary(
                operation: .addition(lhs: .variable(name: aname), rhs: .literal(value: .integer(value: 5)))
            )
        )
        XCTAssertEqual(
            Expression(rawValue: "(a) + b"),
            .binary(
                operation: .addition(
                    lhs: .precedence(value: .variable(name: aname)), rhs: .variable(name: bname)
                )
            )
        )
        XCTAssertEqual(
            Expression(rawValue: "(a)+b"),
            .binary(
                operation: .addition(
                    lhs: .precedence(value: .variable(name: aname)), rhs: .variable(name: bname)
                )
            )
        )
        XCTAssertEqual(
            Expression(rawValue: "(a) > b"),
            .conditional(
                condition: .comparison(value: .greaterThan(
                    lhs: .precedence(value: .variable(name: aname)), rhs: .variable(name: bname)
                ))
            )
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
            lhs: .precedence(
                value: .binary(
                    operation: .subtraction(lhs: .variable(name: aname), rhs: .variable(name: bname))
                )
            ),
            rhs: .variable(name: cname)
        ))
        let result = Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    /// Test init works for statement with multiple sub expressions in different order.
    func testMultipleInit2() {
        let raw = "a * (b - c)"
        let expected = Expression.binary(operation: .multiplication(
            lhs: .variable(name: aname),
            rhs: .precedence(
                value: .binary(
                    operation: .subtraction(lhs: .variable(name: bname), rhs: .variable(name: cname))
                )
            )
        ))
        let result = Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
        let a = Expression.variable(name: aname)
        let b = Expression.variable(name: bname)
        let c = Expression.variable(name: cname)
        XCTAssertEqual(
            Expression(rawValue: "a * b * c"),
            .binary(operation: .multiplication(
                lhs: a, rhs: .binary(operation: .multiplication(lhs: b, rhs: c))
            ))
        )
    }

    /// Test complex expression is created correctly.
    func testComplexInit() {
        let raw = "(a - b) + c * d / e"
        let expected = Expression.binary(operation: .multiplication(
            lhs: .binary(operation: .addition(
                lhs: .precedence(
                    value: .binary(operation: .subtraction(
                        lhs: .variable(name: aname),
                        rhs: .variable(name: bname)
                    ))
                ),
                rhs: .variable(name: cname)
            )),
            rhs: .binary(operation: .division(lhs: .variable(name: dname), rhs: .variable(name: ename)))
        ))
        let result = Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    /// Test another complex expression is created correctly.
    func testComplexInit2() {
        let raw = "a + b * (c + d) / e"
        let expected = Expression.binary(operation: .multiplication(
            lhs: .binary(operation: .addition(
                lhs: .variable(name: aname),
                rhs: .variable(name: bname)
            )),
            rhs: .binary(operation: .division(
                lhs: .precedence(
                    value: .binary(operation: .addition(
                        lhs: .variable(name: cname),
                        rhs: .variable(name: dname)
                    ))
                ),
                rhs: .variable(name: ename)
            ))
        ))
        let result = Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    /// Test another complex raw value.
    func testComplexInit3() {
        let raw = "a + b * c + d / e"
        let expected = Expression.binary(operation: .multiplication(
            lhs: .binary(operation: .addition(
                lhs: .variable(name: aname),
                rhs: .variable(name: bname)
            )),
            rhs: .binary(operation: .addition(
                lhs: .variable(name: cname),
                rhs: .binary(
                    operation: .division(lhs: .variable(name: dname), rhs: .variable(name: ename))
                )
            ))
        ))
        let result = Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    /// Test another complex raw value.
    func testComplexInit4() {
        let raw = "a + b * c + d / e - 5"
        let expected = Expression.binary(operation: .multiplication(
            lhs: .binary(operation: .addition(
                lhs: .variable(name: aname),
                rhs: .variable(name: bname)
            )),
            rhs: .binary(operation: .addition(
                lhs: .variable(name: cname),
                rhs: .binary(operation: .subtraction(
                    lhs: .binary(
                        operation: .division(lhs: .variable(name: dname), rhs: .variable(name: ename))
                    ),
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
            lhs: .binary(operation: .addition(
                lhs: .variable(name: aname),
                rhs: .variable(name: bname)
            )),
            rhs: .binary(operation: .addition(
                lhs: .variable(name: cname),
                rhs: .binary(
                    operation: .division(lhs: .variable(name: dname), rhs: .variable(name: ename))
                )
            ))
        ))
        XCTAssertEqual(expected, expression.rawValue)
    }

    /// Test conditionals are created correctly.
    func testConditionals() {
        let raw = "a > b"
        XCTAssertEqual(
            Expression(rawValue: raw),
            .conditional(
                condition: .comparison(
                    value: .greaterThan(
                        lhs: .variable(name: VariableName(text: "a")),
                        rhs: .variable(name: VariableName(text: "b"))
                    )
                )
            )
        )
        let raw2 = "a + b > c + d"
        XCTAssertEqual(
            Expression(rawValue: raw2),
            .conditional(
                condition: .comparison(
                    value: .greaterThan(
                        lhs: .binary(
                            operation: .addition(
                                lhs: .variable(name: VariableName(text: "a")),
                                rhs: .variable(name: VariableName(text: "b"))
                            )
                        ),
                        rhs: .binary(
                            operation: .addition(
                                lhs: .variable(name: VariableName(text: "c")),
                                rhs: .variable(name: VariableName(text: "d"))
                            )
                        )
                    )
                )
            )
        )
    }

    /// Test `description` matches `rawValue`.
    func testDescription() {
        let expression = Expression.conditional(
            condition: .comparison(
                value: .greaterThan(
                    lhs: .binary(
                        operation: .addition(
                            lhs: .variable(name: VariableName(text: "a")),
                            rhs: .variable(name: VariableName(text: "b"))
                        )
                    ),
                    rhs: .binary(
                        operation: .addition(
                            lhs: .variable(name: VariableName(text: "c")),
                            rhs: .variable(name: VariableName(text: "d"))
                        )
                    )
                )
            )
        )
        XCTAssertEqual(expression.description, expression.rawValue)
    }

    /// Test expression creates logical expression correctly.
    func testLogicalInit() {
        let a = Expression.variable(name: aname)
        let b = Expression.variable(name: bname)
        let c = Expression.variable(name: cname)
        XCTAssertEqual(Expression(rawValue: "a and b"), .logical(operation: .and(lhs: a, rhs: b)))
        XCTAssertEqual(Expression(rawValue: "not a"), .logical(operation: .not(value: a)))
        XCTAssertEqual(
            Expression(rawValue: "a or b and c"),
            .logical(operation: .and(lhs: .logical(operation: .or(lhs: a, rhs: b)), rhs: c))
        )
    }

}
