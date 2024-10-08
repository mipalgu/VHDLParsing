// FunctionDefinitionTests.swift
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

/// Test class for ``FunctionDefinition``.
final class FunctionDefinitionTests: XCTestCase {

    /// The name of the function.
    let fnName = VariableName(text: "max")

    /// The arguments in the function.
    let arguments = [
        ArgumentDefinition(
            name: VariableName(text: "arg1"),
            type: .signal(type: .integer),
            defaultValue: .literal(value: .integer(value: 0))
        ),
        ArgumentDefinition(
            name: VariableName(text: "arg2"),
            type: .signal(type: .integer),
            defaultValue: .literal(value: .integer(value: 0))
        ),
    ]

    /// The return type of the function.
    let returnType = Type.signal(type: .integer)

    /// The function definition.
    var definition: FunctionDefinition {
        FunctionDefinition(name: fnName, arguments: arguments, returnType: returnType)
    }

    /// Test the init sets the stored properties correctly.
    func testInit() {
        XCTAssertEqual(definition.name, fnName)
        XCTAssertEqual(definition.arguments, arguments)
        XCTAssertEqual(definition.returnType, returnType)
    }

    /// Test the `rawValue` generates the correct `VHDL` code.
    func testRawValue() {
        XCTAssertEqual(
            definition.rawValue,
            "function max(arg1: integer := 0; arg2: integer := 0) return integer;"
        )
    }

    // swiftlint:disable function_body_length

    /// Test the `init(rawValue:)` parses the `VHDL` code correctly.
    func testRawValueInit() {
        XCTAssertEqual(
            FunctionDefinition(
                rawValue: "function max(arg1: integer := 0; arg2: integer := 0) return integer;"
            ),
            definition
        )
        XCTAssertNil(FunctionDefinition(rawValue: ""))
        XCTAssertNil(FunctionDefinition(rawValue: " "))
        XCTAssertNil(
            FunctionDefinition(
                rawValue: "function \(String(repeating: "A", count: 2048))"
                    + "(arg1: integer := 0; arg2: integer := 0) return integer;"
            )
        )
        XCTAssertNil(
            FunctionDefinition(
                rawValue: "fun max(arg1: integer := 0; arg2: integer := 0) return integer;"
            )
        )
        XCTAssertNil(
            FunctionDefinition(
                rawValue: "function record(arg1: integer := 0; arg2: integer := 0) return integer;"
            )
        )
        XCTAssertNil(
            FunctionDefinition(
                rawValue: "function max(arg1: integer := 0; arg2: integer := 0) return integer"
            )
        )
        XCTAssertNil(
            FunctionDefinition(
                rawValue: "function max(arg1: integer := 0; arg2: integer := 0) return;"
            )
        )
        XCTAssertNil(
            FunctionDefinition(
                rawValue: "function max(arg1: integer := 0; arg2: integer := 0) ret integer;"
            )
        )
        XCTAssertNil(
            FunctionDefinition(
                rawValue: "function max(arg1: integer := 0, arg2: integer := 0) return integer;"
            )
        )
        XCTAssertNil(
            FunctionDefinition(
                rawValue: "function max(arg1: integer := 0; arg2: integer := 0)) return integer;"
            )
        )
        XCTAssertNil(
            FunctionDefinition(
                rawValue: "function max((arg1: integer := 0; arg2: integer := 0) return integer;"
            )
        )
        XCTAssertNil(
            FunctionDefinition(
                rawValue: "function (arg1: integer := 0; arg2: integer := 0) return integer;"
            )
        )
        XCTAssertNil(
            FunctionDefinition(
                rawValue: "function( max(arg1: integer := 0; arg2: integer := 0) return integer;"
            )
        )
        XCTAssertNil(
            FunctionDefinition(
                rawValue: "function max(arg1: integer := 0; arg2: integer := 0 return integer;"
            )
        )
        XCTAssertNil(
            FunctionDefinition(
                rawValue: "function max(arg1: integer := 0; arg2: integer := 0) return !integer;"
            )
        )
    }

    // swiftlint:enable function_body_length

}
