// ConditionalExpressionTests.swift
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

/// Test class for ``ConditionalExpression``.
final class ConditionalExpressionTests: XCTestCase {

    /// A variable called `x`.
    let x = Expression.reference(variable: .variable(reference: .variable(name: VariableName(text: "x"))))

    /// The variable y.
    let y = Expression.reference(variable: .variable(reference: .variable(name: VariableName(text: "y"))))

    /// Test `rawValue` delegates to operations `rawValue`.
    func testRawValue() {
        let comparison = ComparisonOperation.greaterThan(lhs: x, rhs: y)
        XCTAssertEqual(ConditionalExpression.comparison(value: comparison).rawValue, comparison.rawValue)
        let condition = EdgeCondition.rising(expression: x)
        XCTAssertEqual(ConditionalExpression.edge(value: condition).rawValue, condition.rawValue)
        XCTAssertEqual(ConditionalExpression.literal(value: true).rawValue, "true")
        XCTAssertEqual(ConditionalExpression.literal(value: false).rawValue, "false")
    }

    /// Test edge condition is created correctly.
    func testEdgeInit() {
        let condition = ConditionalExpression.edge(value: .rising(expression: x))
        XCTAssertEqual(ConditionalExpression(rawValue: "rising_edge(x)"), condition)
        XCTAssertNil(ConditionalExpression(rawValue: "rising_edge(x);"))
        XCTAssertNil(ConditionalExpression(rawValue: "x << 2"))
        XCTAssertNil(ConditionalExpression(rawValue: "rising_edge(\(String(repeating: "x", count: 256)))"))
    }

    /// Test comparison condition is created correctly.
    func testComparisonInit() {
        let comparison = ConditionalExpression.comparison(value: .greaterThan(lhs: x, rhs: y))
        XCTAssertEqual(ConditionalExpression(rawValue: "x > y"), comparison)
        XCTAssertNil(ConditionalExpression(rawValue: "x > y;"))
        XCTAssertNil(ConditionalExpression(rawValue: "x >> 2"))
        XCTAssertNil(ConditionalExpression(rawValue: "x > \(String(repeating: "y", count: 256))"))
    }

    /// Test literal condition is created correctly.
    func testLiteralInit() {
        let literal = ConditionalExpression.literal(value: true)
        XCTAssertEqual(ConditionalExpression(rawValue: "true"), literal)
        XCTAssertEqual(ConditionalExpression(rawValue: "TRUE"), literal)
        XCTAssertEqual(ConditionalExpression(rawValue: "false"), .literal(value: false))
        XCTAssertEqual(ConditionalExpression(rawValue: "FALSE"), .literal(value: false))
        XCTAssertNil(ConditionalExpression(rawValue: "true;"))
        XCTAssertNil(ConditionalExpression(rawValue: "x"))
        XCTAssertNil(ConditionalExpression(rawValue: "true; false"))
    }

}
