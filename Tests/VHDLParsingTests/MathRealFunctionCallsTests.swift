// MathRealFunctionCallsTests.swift
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

/// Test class for ``MathRealFunctionCalls``.
final class MathRealFunctionCallsTests: XCTestCase {

    /// A variable `x`.
    let x = Expression.reference(variable: .variable(reference: .variable(name: VariableName(text: "x"))))

    /// A variable `y`.
    let y = Expression.reference(variable: .variable(reference: .variable(name: VariableName(text: "y"))))

    /// Test `rawValue` generated `VHDL` code correctly.
    func testRawValue() {
        XCTAssertEqual(MathRealFunctionCalls.ceil(expression: x).rawValue, "ceil(x)")
        XCTAssertEqual(MathRealFunctionCalls.floor(expression: x).rawValue, "floor(x)")
        XCTAssertEqual(MathRealFunctionCalls.round(expression: x).rawValue, "round(x)")
        XCTAssertEqual(MathRealFunctionCalls.sign(expression: x).rawValue, "sign(x)")
        XCTAssertEqual(MathRealFunctionCalls.sqrt(expression: x).rawValue, "sqrt(x)")
        XCTAssertEqual(MathRealFunctionCalls.fmax(arg0: x, arg1: y).rawValue, "fmax(x, y)")
        XCTAssertEqual(MathRealFunctionCalls.fmin(arg0: x, arg1: y).rawValue, "fmin(x, y)")
    }

    /// Test `init(rawValue:)` for `fmin` case.
    func testFminInit() {
        XCTAssertEqual(MathRealFunctionCalls(rawValue: "fmin(x, y)"), .fmin(arg0: x, arg1: y))
        XCTAssertEqual(
            MathRealFunctionCalls(rawValue: "fmin((x), y)"), .fmin(arg0: .precedence(value: x), arg1: y)
        )
        XCTAssertNil(MathRealFunctionCalls(rawValue: "fmin(x, y, z)"))
        XCTAssertNil(MathRealFunctionCalls(rawValue: "fmin(x, y, )"))
        XCTAssertNil(MathRealFunctionCalls(rawValue: "fmin(x, , y)"))
        XCTAssertNil(MathRealFunctionCalls(rawValue: "fmin(x,, y)"))
        XCTAssertNil(MathRealFunctionCalls(rawValue: "fmin(x, y,)"))
        XCTAssertNil(MathRealFunctionCalls(rawValue: "fmin()"))
        XCTAssertNil(MathRealFunctionCalls(rawValue: ""))
        XCTAssertNil(MathRealFunctionCalls(rawValue: "fmin(x)"))
    }

    /// Test `init(rawValue:)` for functions with 2 arguments.
    func testTwoArgumentFunctions() {
        XCTAssertEqual(MathRealFunctionCalls(rawValue: "fmax(x, y)"), .fmax(arg0: x, arg1: y))
    }

    /// Test `init(rawValue:)` for functions with 1 argument.
    func testOneArgumentFunctions() {
        XCTAssertEqual(MathRealFunctionCalls(rawValue: "ceil(x)"), .ceil(expression: x))
        XCTAssertEqual(MathRealFunctionCalls(rawValue: "floor(x)"), .floor(expression: x))
        XCTAssertEqual(MathRealFunctionCalls(rawValue: "round(x)"), .round(expression: x))
        XCTAssertEqual(MathRealFunctionCalls(rawValue: "sign(x)"), .sign(expression: x))
        XCTAssertEqual(MathRealFunctionCalls(rawValue: "sqrt(x)"), .sqrt(expression: x))
        XCTAssertNil(MathRealFunctionCalls(rawValue: "ceil(x, y)"))
    }

}
