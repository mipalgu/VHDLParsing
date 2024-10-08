// FunctionImplementationTests.swift
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

/// Test class for ``FunctionImplementation``.
final class FunctionImplementationTests: XCTestCase {

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

    /// The function body.
    let body = SynchronousBlock.ifStatement(
        block: .ifElse(
            condition: .conditional(
                condition: .comparison(
                    value: .lessThan(
                        lhs: .reference(
                            variable: .variable(reference: .variable(name: VariableName(text: "arg1")))
                        ),
                        rhs: .reference(
                            variable: .variable(reference: .variable(name: VariableName(text: "arg2")))
                        )
                    )
                )
            ),
            ifBlock: .statement(
                statement: .returns(
                    value: .reference(
                        variable: .variable(reference: .variable(name: VariableName(text: "arg2")))
                    )
                )
            ),
            elseBlock: .statement(
                statement: .returns(
                    value: .reference(
                        variable: .variable(reference: .variable(name: VariableName(text: "arg1")))
                    )
                )
            )
        )
    )

    /// The function definition.
    var definition: FunctionDefinition {
        FunctionDefinition(name: fnName, arguments: arguments, returnType: returnType)
    }

    /// The implementation of the function.
    var implementation: FunctionImplementation {
        FunctionImplementation(name: fnName, arguments: arguments, returnType: returnType, body: body)
    }

    /// Test that the stored properties are initialised correctly.
    func testInit() {
        XCTAssertEqual(implementation.name, fnName)
        XCTAssertEqual(implementation.arguments, arguments)
        XCTAssertEqual(implementation.returnType, returnType)
        XCTAssertEqual(implementation.body, body)
    }

    /// Test that the stored properties are initialised correctly when the function definition is passed.
    func testDefinitionInit() {
        let definition = definition
        let implementation = FunctionImplementation(definition: definition, body: body)
        XCTAssertEqual(implementation.name, definition.name)
        XCTAssertEqual(implementation.arguments, definition.arguments)
        XCTAssertEqual(implementation.returnType, definition.returnType)
        XCTAssertEqual(implementation.body, body)
    }

    /// Test the `rawValue` generates the correct `VHDL` code.
    func testRawValue() {
        let expected = """
            function max(arg1: integer := 0; arg2: integer := 0) return integer is
            begin
                if (arg1 < arg2) then
                    return arg2;
                else
                    return arg1;
                end if;
            end function;
            """
        XCTAssertEqual(implementation.rawValue, expected)
    }

    // swiftlint:disable function_body_length

    /// Test that `init(rawValue:)` parses the `VHDL` code correctly.
    func testRawValueInit() {
        let raw = """
            function max(arg1: integer := 0; arg2: integer := 0) return integer is
            begin
                if (arg1 < arg2) then
                    return arg2;
                else
                    return arg1;
                end if;
            end function;
            """
        XCTAssertEqual(FunctionImplementation(rawValue: raw), implementation)
        XCTAssertNil(
            FunctionImplementation(
                rawValue: """
                    is function max(arg1: integer := 0; arg2: integer := 0) return integer is
                    begin
                        if (arg1 < arg2) then
                            return arg2;
                        else
                            return arg1;
                        end if;
                    end function;
                    """
            )
        )
        XCTAssertNil(
            FunctionImplementation(
                rawValue: """
                    max(arg1: integer := 0; arg2: integer := 0) return integer is
                    begin
                        if (arg1 < arg2) then
                            return arg2;
                        else
                            return arg1;
                        end if;
                    end function;
                    """
            )
        )
        XCTAssertNil(
            FunctionImplementation(
                rawValue: """
                    function max(arg1: integer := 0; arg2: integer := 0) return integer is
                    begin
                        if (arg1 < arg2) then
                            return arg2;
                        else
                            return arg1;
                        end if;
                    end function
                    """
            )
        )
        XCTAssertNil(
            FunctionImplementation(
                rawValue: """
                    function max(arg1: integer := 0; arg2: integer := 0) return integer is
                    begin
                        if (arg1 < arg2) then
                            return arg2;
                        else
                            return arg1;
                        end if;
                    end;
                    """
            )
        )
        XCTAssertNil(
            FunctionImplementation(
                rawValue: """
                    function max(arg1: integer := 0; arg2: integer := 0) return integer is
                    begin
                        if (arg1 < arg2) then
                            return arg2;
                        else
                            return arg1;
                        end if;
                    function;
                    """
            )
        )
        XCTAssertNil(
            FunctionImplementation(
                rawValue: """
                    function max(arg1: integer := 0; arg2: integer := 0) return integer is
                        if (arg1 < arg2) then
                            return arg2;
                        else
                            return arg1;
                        end if;
                    end function;
                    """
            )
        )
        XCTAssertNil(
            FunctionImplementation(
                rawValue: """
                    function max(arg1: integer := 0; arg2: integer := 0) return integer is
                    begin
                        ifs (arg1 < arg2) then
                            return arg2;
                        else
                            return arg1;
                        end if;
                    end function;
                    """
            )
        )
    }

    // swiftlint:enable function_body_length

}
