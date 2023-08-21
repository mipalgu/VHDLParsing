// ArgumentDefinitionTests.swift
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

/// Test class for ``ArgumentDefinition``.
final class ArgumentDefinitionTests: XCTestCase {

    /// The name of an argument.
    let arg = VariableName(text: "value")

    /// The type of the argument.
    let type = Type.signal(type: .real)

    /// The default value for the argument.
    let defaultValue = Expression.literal(value: .decimal(value: 1.0))

    /// The definition of the argument.
    var definition: ArgumentDefinition {
        ArgumentDefinition(name: arg, type: type, defaultValue: defaultValue)
    }

    /// Test that the stored properties are initialised correctly.
    func testInit() {
        let definition = definition
        XCTAssertEqual(definition.name, arg)
        XCTAssertEqual(definition.type, type)
        XCTAssertEqual(definition.defaultValue, defaultValue)
        let definition2 = ArgumentDefinition(name: arg, type: type)
        XCTAssertEqual(definition2.name, arg)
        XCTAssertEqual(definition2.type, type)
        XCTAssertNil(definition2.defaultValue)
    }

    /// Test that `rawValue` generates the correct `VHDL` code.
    func testRawValue() {
        XCTAssertEqual(definition.rawValue, "value: real := 1.0")
        let definition2 = ArgumentDefinition(name: arg, type: type, defaultValue: nil)
        XCTAssertEqual(definition2.rawValue, "value: real")
    }

    /// Test the `init(rawValue:)` parses the `VHDL` code correctly.
    func testRawValueInit() {
        let raw = "value: real := 1.0"
        let definition = ArgumentDefinition(rawValue: raw)
        XCTAssertEqual(self.definition, definition)
        let definition2 = ArgumentDefinition(name: arg, type: type)
        let result2 = ArgumentDefinition(rawValue: "value: real")
        let result3 = ArgumentDefinition(rawValue: "value:real:=1.0")
        XCTAssertEqual(self.definition, result3)
        XCTAssertEqual(definition2, result2)
        XCTAssertNil(ArgumentDefinition(rawValue: ": real"))
        XCTAssertNil(ArgumentDefinition(rawValue: "value:"))
        XCTAssertNil(ArgumentDefinition(rawValue: "integer: real"))
        XCTAssertNil(ArgumentDefinition(rawValue: "\(String(repeating: "A", count: 2048)): real"))
        XCTAssertNil(ArgumentDefinition(rawValue: ""))
        XCTAssertNil(ArgumentDefinition(rawValue: " "))
        XCTAssertNil(ArgumentDefinition(rawValue: "value: real :="))
        XCTAssertNil(ArgumentDefinition(rawValue: "value := real"))
        XCTAssertNil(ArgumentDefinition(rawValue: ".value: real"))
        XCTAssertNil(ArgumentDefinition(rawValue: "_value: real"))
        XCTAssertNil(ArgumentDefinition(rawValue: "%value: real"))
        XCTAssertNil(ArgumentDefinition(rawValue: "value: real := 123abc!"))
        XCTAssertNil(ArgumentDefinition(rawValue: "value:real:1.0"))
        XCTAssertNil(ArgumentDefinition(rawValue: "value:real::=1.0"))
        XCTAssertNil(ArgumentDefinition(rawValue: "value:real: =1.0"))
        XCTAssertNil(ArgumentDefinition(rawValue: "value:real=1.0"))
    }

}
