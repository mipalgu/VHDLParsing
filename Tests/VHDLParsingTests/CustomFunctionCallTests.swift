// CustomFunctionCallTests.swift
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

/// Test class for ``CustomFunctionCall``.
final class CustomFunctionCallTests: XCTestCase {

    /// The function name.
    let f = VariableName(text: "f")

    /// A variable `x`.
    let x = VHDLParsing.Expression.reference(variable: .variable(
        reference: .variable(name: VariableName(text: "x"))
    ))

    /// A variable `y`.
    let y = VHDLParsing.Expression.reference(variable: .variable(
        reference: .variable(name: VariableName(text: "y"))
    ))

    /// The function arguments.
    var arguments: [VHDLParsing.Expression] {
        [x, y]
    }

    /// The parameters.
    var parameters: [Argument] {
        [
            Argument(label: VariableName(text: "x"), argument: x),
            Argument(label: VariableName(text: "y"), argument: y),
        ]
    }

    /// The function call under test.
    lazy var function = CustomFunctionCall(name: f, parameters: parameters)

    /// Initialise the function before every test.
    override func setUp() {
        function = CustomFunctionCall(name: f, parameters: parameters)
    }

    /// Test that the stored properties are set correctly.
    func testStoredPropertyInit() {
        XCTAssertEqual(function.parameters, parameters)
        XCTAssertEqual(function.name, f)
        let func2 = CustomFunctionCall(name: f, parameters: parameters)
        XCTAssertEqual(func2.name, f)
        XCTAssertEqual(func2.parameters, parameters)
    }

    /// Test that the `VHDL` code is created correctly in `rawValue`.
    func testRawValue() {
        XCTAssertEqual(function.rawValue, "f(x => x, y => y)")
        XCTAssertEqual(CustomFunctionCall(name: f, parameters: []).rawValue, "f()")
        let func2 = CustomFunctionCall(name: f, parameters: [Argument(argument: x), Argument(argument: y)])
        XCTAssertEqual(func2.rawValue, "f(x, y)")
    }

    /// Test that the function init is correct.
    func testFunctionInit() {
        XCTAssertEqual(CustomFunctionCall(name: f, parameters: parameters), function)
    }

    /// Test `init(rawValue:)`.
    func testRawValueInit() {
        XCTAssertEqual(CustomFunctionCall(rawValue: "f()"), CustomFunctionCall(name: f, parameters: []))
        XCTAssertNil(CustomFunctionCall(rawValue: "and(x)"))
        XCTAssertNil(CustomFunctionCall(rawValue: "a * (b - c)"))
    }

}
