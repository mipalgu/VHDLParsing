// ComparisonOperationTests.swift
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

/// Test class for ``ComparisonOperation``.
final class ComparisonOperationTests: XCTestCase {

    /// The variable x.
    let x = Expression.reference(variable: .variable(name: VariableName(text: "x")))

    /// The variable y.
    let y = Expression.reference(variable: .variable(name: VariableName(text: "y")))

    /// Test that the `rawValue` property creates the correct `VHDL` code.
    func testRawValue() {
        XCTAssertEqual(ComparisonOperation.equality(lhs: x, rhs: y).rawValue, "x = y")
        XCTAssertEqual(ComparisonOperation.notEquals(lhs: x, rhs: y).rawValue, "x /= y")
        XCTAssertEqual(ComparisonOperation.lessThan(lhs: x, rhs: y).rawValue, "x < y")
        XCTAssertEqual(ComparisonOperation.lessThanOrEqual(lhs: x, rhs: y).rawValue, "x <= y")
        XCTAssertEqual(ComparisonOperation.greaterThan(lhs: x, rhs: y).rawValue, "x > y")
        XCTAssertEqual(ComparisonOperation.greaterThanOrEqual(lhs: x, rhs: y).rawValue, "x >= y")
    }

    /// Test lessThan raw value initialiser.
    func testLessThanInit() {
        let expected = ComparisonOperation.lessThan(lhs: x, rhs: y)
        XCTAssertEqual(ComparisonOperation(rawValue: "x < y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x<y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x <y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x< y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x < y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x<y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x <y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x< y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x < y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x < y "), expected)
        XCTAssertNil(ComparisonOperation(rawValue: "2x < y"))
        XCTAssertNil(ComparisonOperation(rawValue: "x < 2y"))
        XCTAssertNil(ComparisonOperation(rawValue: "x <2 y"))
        XCTAssertNil(ComparisonOperation(rawValue: "x << y"))
        XCTAssertNil(ComparisonOperation(rawValue: String(repeating: "x", count: 256) + " < y"))
    }

    /// Test lessThanOrEqual raw value initialiser.
    func testLessThanEqualInit() {
        let expected = ComparisonOperation.lessThanOrEqual(lhs: x, rhs: y)
        XCTAssertEqual(ComparisonOperation(rawValue: "x <= y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x<=y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x <=y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x<= y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x <= y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x<=y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x <=y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x<= y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x <= y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x <= y "), expected)
        XCTAssertNil(ComparisonOperation(rawValue: "2x <= y"))
        XCTAssertNil(ComparisonOperation(rawValue: "x <= 2y"))
        XCTAssertNil(ComparisonOperation(rawValue: "x <=2 y"))
        XCTAssertNil(ComparisonOperation(rawValue: "x <== y"))
        XCTAssertNil(ComparisonOperation(rawValue: String(repeating: "x", count: 256) + " <= y"))
    }

    /// Test greaterThan raw value initialiser.
    func testGreaterThanInit() {
        let expected = ComparisonOperation.greaterThan(lhs: x, rhs: y)
        XCTAssertEqual(ComparisonOperation(rawValue: "x > y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x>y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x >y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x> y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x > y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x>y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x >y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x> y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x > y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x > y "), expected)
        XCTAssertNil(ComparisonOperation(rawValue: "2x > y"))
        XCTAssertNil(ComparisonOperation(rawValue: "x > 2y"))
        XCTAssertNil(ComparisonOperation(rawValue: "x >2 y"))
        XCTAssertNil(ComparisonOperation(rawValue: "x >> y"))
        XCTAssertNil(ComparisonOperation(rawValue: String(repeating: "x", count: 256) + " > y"))
    }

    /// Test greaterThanOrEqual raw value initialiser.
    func testGreaterThanEqualInit() {
        let expected = ComparisonOperation.greaterThanOrEqual(lhs: x, rhs: y)
        XCTAssertEqual(ComparisonOperation(rawValue: "x >= y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x>=y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x >=y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x>= y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x >= y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x>=y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x >=y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x>= y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x >= y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x >= y "), expected)
        XCTAssertNil(ComparisonOperation(rawValue: "2x >= y"))
        XCTAssertNil(ComparisonOperation(rawValue: "x >= 2y"))
        XCTAssertNil(ComparisonOperation(rawValue: "x >=2 y"))
        XCTAssertNil(ComparisonOperation(rawValue: "x >== y"))
        XCTAssertNil(ComparisonOperation(rawValue: String(repeating: "x", count: 256) + " >= y"))
    }

    /// Test equality raw value initialiser.
    func testEqualityInit() {
        let expected = ComparisonOperation.equality(lhs: x, rhs: y)
        XCTAssertEqual(ComparisonOperation(rawValue: "x = y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x=y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x =y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x= y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x = y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x=y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x =y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x= y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x = y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x = y "), expected)
        XCTAssertNil(ComparisonOperation(rawValue: "2x = y"))
        XCTAssertNil(ComparisonOperation(rawValue: "x = 2y"))
        XCTAssertNil(ComparisonOperation(rawValue: "x =2 y"))
        XCTAssertNil(ComparisonOperation(rawValue: "x == y"))
        XCTAssertNil(ComparisonOperation(rawValue: String(repeating: "x", count: 256) + " = y"))
    }

    /// Test notEquals raw value initialiser.
    func testNotEqualsInit() {
        let expected = ComparisonOperation.notEquals(lhs: x, rhs: y)
        XCTAssertEqual(ComparisonOperation(rawValue: "x /= y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x/=y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x /=y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x/= y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x /= y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x/=y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x /=y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x/= y "), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: " x /= y"), expected)
        XCTAssertEqual(ComparisonOperation(rawValue: "x /= y "), expected)
        XCTAssertNil(ComparisonOperation(rawValue: "2x /= y"))
        XCTAssertNil(ComparisonOperation(rawValue: "x /= 2y"))
        XCTAssertNil(ComparisonOperation(rawValue: "x /=2 y"))
        XCTAssertNil(ComparisonOperation(rawValue: "x /== y"))
        XCTAssertNil(ComparisonOperation(rawValue: "x != y"))
        XCTAssertNil(ComparisonOperation(rawValue: String(repeating: "x", count: 256) + " != y"))
    }

    /// Test operation init.
    func testOperationInit() {
        XCTAssertEqual(ComparisonOperation(lhs: x, rhs: y, operation: "<"), .lessThan(lhs: x, rhs: y))
        XCTAssertEqual(ComparisonOperation(lhs: x, rhs: y, operation: "<="), .lessThanOrEqual(lhs: x, rhs: y))
        XCTAssertEqual(ComparisonOperation(lhs: x, rhs: y, operation: ">"), .greaterThan(lhs: x, rhs: y))
        XCTAssertEqual(
            ComparisonOperation(lhs: x, rhs: y, operation: ">="), .greaterThanOrEqual(lhs: x, rhs: y)
        )
        XCTAssertEqual(ComparisonOperation(lhs: x, rhs: y, operation: "="), .equality(lhs: x, rhs: y))
        XCTAssertEqual(ComparisonOperation(lhs: x, rhs: y, operation: "/="), .notEquals(lhs: x, rhs: y))
        XCTAssertNil(ComparisonOperation(lhs: x, rhs: y, operation: "<<"))
    }

}
