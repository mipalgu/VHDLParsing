// BinaryOperationTests.swift
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

/// Test class for ``BinaryOperation``.
final class BinaryOperationTests: XCTestCase {

    /// A variable called `x`.
    let x = Expression.reference(variable: .variable(reference: .variable(name: VariableName(text: "x"))))

    /// The variable y.
    let y = Expression.reference(variable: .variable(reference: .variable(name: VariableName(text: "y"))))

    /// Test raw values are correct.
    func testRawValues() {
        XCTAssertEqual(BinaryOperation.addition(lhs: x, rhs: y).rawValue, "x + y")
        XCTAssertEqual(BinaryOperation.subtraction(lhs: x, rhs: y).rawValue, "x - y")
        XCTAssertEqual(BinaryOperation.multiplication(lhs: x, rhs: y).rawValue, "x * y")
        XCTAssertEqual(BinaryOperation.division(lhs: x, rhs: y).rawValue, "x / y")
        XCTAssertEqual(BinaryOperation.concatenate(lhs: x, rhs: y).rawValue, "x & y")
    }

    /// Test rawValue init for addition.
    func testAdditionInit() {
        XCTAssertEqual(BinaryOperation(rawValue: "x + y"), BinaryOperation.addition(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: " x + y "), BinaryOperation.addition(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x + y "), BinaryOperation.addition(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x  + y"), BinaryOperation.addition(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x +y"), BinaryOperation.addition(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x+ y"), BinaryOperation.addition(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x+y"), BinaryOperation.addition(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x +  y"), BinaryOperation.addition(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x  +  y"), BinaryOperation.addition(lhs: x, rhs: y))
        XCTAssertEqual(
            BinaryOperation(rawValue: "x + y + z "),
            BinaryOperation.addition(
                lhs: .binary(operation: .addition(lhs: x, rhs: y)),
                rhs: .reference(variable: .variable(reference: .variable(name: VariableName(text: "z"))))
            )
        )
    }

    /// Test rawValue init for subtraction.
    func testSubtractionInit() {
        XCTAssertEqual(BinaryOperation(rawValue: "x - y"), BinaryOperation.subtraction(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: " x - y "), BinaryOperation.subtraction(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x - y "), BinaryOperation.subtraction(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x  - y"), BinaryOperation.subtraction(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x -y"), BinaryOperation.subtraction(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x- y"), BinaryOperation.subtraction(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x-y"), BinaryOperation.subtraction(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x -  y"), BinaryOperation.subtraction(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x  -  y"), BinaryOperation.subtraction(lhs: x, rhs: y))
        XCTAssertEqual(
            BinaryOperation(rawValue: "x - y - z "),
            BinaryOperation.subtraction(
                lhs: .binary(operation: .subtraction(lhs: x, rhs: y)),
                rhs: .reference(variable: .variable(reference: .variable(name: VariableName(text: "z"))))
            )
        )
    }

    /// Test rawValue init for multiplication.
    func testMultiplicationInit() {
        XCTAssertEqual(BinaryOperation(rawValue: "x * y"), BinaryOperation.multiplication(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: " x * y "), BinaryOperation.multiplication(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x * y "), BinaryOperation.multiplication(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x  * y"), BinaryOperation.multiplication(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x *y"), BinaryOperation.multiplication(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x* y"), BinaryOperation.multiplication(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x*y"), BinaryOperation.multiplication(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x *  y"), BinaryOperation.multiplication(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x  *  y"), BinaryOperation.multiplication(lhs: x, rhs: y))
        XCTAssertEqual(
            BinaryOperation(rawValue: "x * y * z "),
            BinaryOperation.multiplication(
                lhs: .binary(operation: .multiplication(lhs: x, rhs: y)),
                rhs: .reference(variable: .variable(reference: .variable(name: VariableName(text: "z"))))
            )
        )
    }

    /// Test rawValue init for division.
    func testDivisionInit() {
        XCTAssertEqual(BinaryOperation(rawValue: "x / y"), BinaryOperation.division(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: " x / y "), BinaryOperation.division(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x / y "), BinaryOperation.division(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x  / y"), BinaryOperation.division(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x /y"), BinaryOperation.division(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x/ y"), BinaryOperation.division(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x/y"), BinaryOperation.division(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x /  y"), BinaryOperation.division(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x  /  y"), BinaryOperation.division(lhs: x, rhs: y))
        XCTAssertEqual(
            BinaryOperation(rawValue: "x / y / z "),
            BinaryOperation.division(
                lhs: .binary(operation: .division(lhs: x, rhs: y)),
                rhs: .reference(variable: .variable(reference: .variable(name: VariableName(text: "z"))))
            )
        )
    }

    /// Test rawValue init for concatenation.
    func testConcatInit() {
        XCTAssertEqual(BinaryOperation(rawValue: "x & y"), .concatenate(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: " x & y "), .concatenate(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x & y "), .concatenate(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x  & y"), .concatenate(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x &y"), .concatenate(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x& y"), .concatenate(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x&y"), .concatenate(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x &  y"), .concatenate(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(rawValue: "x  &  y"), .concatenate(lhs: x, rhs: y))
        XCTAssertEqual(
            BinaryOperation(rawValue: "x & y & z "),
            .concatenate(
                lhs: .binary(operation: .concatenate(lhs: x, rhs: y)),
                rhs: .reference(variable: .variable(reference: .variable(name: VariableName(text: "z"))))
            )
        )
    }

    /// Test rawValue init returns nil for invalid input.
    func testInvalidInput() {
        XCTAssertNil(BinaryOperation(rawValue: "x +"))
        XCTAssertNil(BinaryOperation(rawValue: "x + "))
        XCTAssertNil(BinaryOperation(rawValue: "x + y +"))
        XCTAssertNil(BinaryOperation(rawValue: "2x + y"))
        XCTAssertNil(BinaryOperation(rawValue: String(repeating: "x", count: 256) + " + y"))
        XCTAssertNil(BinaryOperation(rawValue: "x ^ y"))
        XCTAssertNil(BinaryOperation(rawValue: "x &"))
    }

    /// Test operation init works correctly.
    func testOperationInit() {
        XCTAssertEqual(BinaryOperation(lhs: x, rhs: y, str: "+"), .addition(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(lhs: x, rhs: y, str: "-"), .subtraction(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(lhs: x, rhs: y, str: "*"), .multiplication(lhs: x, rhs: y))
        XCTAssertEqual(BinaryOperation(lhs: x, rhs: y, str: "/"), .division(lhs: x, rhs: y))
        XCTAssertNil(BinaryOperation(lhs: x, rhs: y, str: "^"))
    }

    /// Test `lhs` computed property.
    func testLHS() {
        XCTAssertEqual(BinaryOperation.addition(lhs: x, rhs: y).lhs, x)
        XCTAssertEqual(BinaryOperation.subtraction(lhs: x, rhs: y).lhs, x)
        XCTAssertEqual(BinaryOperation.multiplication(lhs: x, rhs: y).lhs, x)
        XCTAssertEqual(BinaryOperation.division(lhs: x, rhs: y).lhs, x)
        XCTAssertEqual(BinaryOperation.concatenate(lhs: x, rhs: y).lhs, x)
    }

    /// Test `rhs` computed property.
    func testRHS() {
        XCTAssertEqual(BinaryOperation.addition(lhs: x, rhs: y).rhs, y)
        XCTAssertEqual(BinaryOperation.subtraction(lhs: x, rhs: y).rhs, y)
        XCTAssertEqual(BinaryOperation.multiplication(lhs: x, rhs: y).rhs, y)
        XCTAssertEqual(BinaryOperation.division(lhs: x, rhs: y).rhs, y)
        XCTAssertEqual(BinaryOperation.concatenate(lhs: x, rhs: y).rhs, y)
    }

}
