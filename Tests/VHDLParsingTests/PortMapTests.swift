// PortMapTests.swift
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

/// Test class for ``PortMap``.
final class PortMapTests: XCTestCase {

    /// A variable `x`.
    let x = VariableReference.variable(reference: .variable(name: VariableName(text: "x")))

    /// A variable `y`.
    let y = VariableReference.variable(reference: .variable(name: VariableName(text: "y")))

    /// A variable `z`.
    let z = VariableReference.variable(reference: .variable(name: VariableName(text: "z")))

    /// The `PortMap` under test.
    lazy var map = PortMap(
        variables: [
            VariableMap(lhs: x, rhs: .expression(value: .reference(variable: z))),
            VariableMap(lhs: y, rhs: .open)
        ]
    )

    /// Initialise the uut before every test case.
    override func setUp() {
        map = PortMap(
            variables: [
                VariableMap(lhs: x, rhs: .expression(value: .reference(variable: z))),
                VariableMap(lhs: y, rhs: .open)
            ]
        )
    }

    /// Test that the initialiser sets the stored properties correctly.
    func testInit() {
        XCTAssertEqual(
            map.variables,
            [
                VariableMap(lhs: x, rhs: .expression(value: .reference(variable: z))),
                VariableMap(lhs: y, rhs: .open)
            ]
        )
    }

    /// Test that the `rawValue` generates the `VHDL` code correctly.
    func testRawValue() {
        XCTAssertEqual(
            map.rawValue,
            """
            port map (
                x => z,
                y => open
            );
            """
        )
    }

    /// Test that `init(rawValue:)` parses the `VHDL` code correctly.
    func testRawValueInit() {
        let raw = """
            port map (
                x => z,
                y => open
            );
            """
        XCTAssertEqual(PortMap(rawValue: raw), map)
        XCTAssertNil(PortMap(rawValue: String(raw.dropFirst())))
        let raw2 = """
            port (
                x => z,
                y => open
            );
            """
        XCTAssertNil(PortMap(rawValue: raw2))
        let raw3 = """
            port map (
                x => z,
                y => open
            )
            """
        XCTAssertNil(PortMap(rawValue: raw3))
        let raw4 = """
            port map (
                x => z,
                y => open
            ;
            """
        XCTAssertNil(PortMap(rawValue: raw4))
        let raw5 = """
            port map (
                x => z,
                y => 2open
            );
            """
        XCTAssertNil(PortMap(rawValue: raw5))
        XCTAssertNil(PortMap(rawValue: ""))
    }

}
