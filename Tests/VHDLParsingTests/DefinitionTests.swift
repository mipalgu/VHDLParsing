// DefinitionTests.swift
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

/// Test class for ``Definition``.
final class DefinitionTests: XCTestCase {

    /// A variable `x`.
    let x = VariableName(text: "x")

    /// Test that `rawValue` generates the correct `VHDL` code.
    func testRawValue() {
        guard let constant = ConstantSignal(
            name: x, type: .stdLogic, value: .literal(value: .bit(value: .high))
        ) else {
            XCTFail("Failed to create constant")
            return
        }
        XCTAssertEqual(Definition.constant(value: constant).rawValue, "constant x: std_logic := '1';")
        let signal = LocalSignal(type: .stdLogic, name: x, defaultValue: .literal(value: .bit(value: .high)))
        XCTAssertEqual(Definition.signal(value: signal).rawValue, "signal x: std_logic := '1';")
    }

    /// Test `init(rawValue:)` parses `VHDL` code correctly for constant signals.
    func testConstantRawValueInit() {
        guard
            let constant = ConstantSignal(
                name: x, type: .stdLogic, value: .literal(value: .bit(value: .high))
            )
        else {
            XCTFail("Failed to create initial variables.")
            return
        }
        XCTAssertEqual(
            Definition(rawValue: "constant x: std_logic := '1';"), .constant(value: constant)
        )
        XCTAssertEqual(
            Definition(rawValue: "constant x:    std_logic := '1';"), .constant(value: constant)
        )
        XCTAssertEqual(
            Definition(rawValue: " constant x: std_logic := '1';"), .constant(value: constant)
        )
        XCTAssertEqual(
            Definition(rawValue: "constant x: std_logic := '1' ;"), .constant(value: constant)
        )
        XCTAssertEqual(
            Definition(rawValue: "constant x: std_logic := '1'; "), .constant(value: constant)
        )
        XCTAssertEqual(
            Definition(rawValue: " constant x: std_logic := '1'; "), .constant(value: constant)
        )
        XCTAssertNil(Definition(rawValue: "constant x := '1';"))
        XCTAssertNil(Definition(rawValue: "constant x: std_logic := 1';"))
        XCTAssertNil(Definition(rawValue: "constant x: std_logic := '1'"))
        XCTAssertNil(Definition(rawValue: "constant x: std_logic"))
        XCTAssertNil(Definition(rawValue: ""))
        XCTAssertNil(Definition(rawValue: " "))
        XCTAssertNil(Definition(rawValue: "constant "))
        XCTAssertNil(
            Definition(rawValue: "constant \(String(repeating: "x", count: 256)): std_logic := '1';")
        )
    }

    /// Test `init(rawValue:)` parses `VHDL` code correctly for signals definitions.
    func testSignalRawValueInit() {
        let signal = LocalSignal(
            type: .stdLogic,
            name: x,
            defaultValue: .literal(value: .bit(value: .high)),
            comment: Comment(text: "signal x.")
        )
        XCTAssertEqual(
            Definition(rawValue: "signal x: std_logic := '1'; -- signal x."),
            .signal(value: signal)
        )
        XCTAssertEqual(
            Definition(rawValue: " signal x: std_logic := '1'; -- signal x."),
            .signal(value: signal)
        )
        XCTAssertEqual(
            Definition(rawValue: "signal x: std_logic := '1' ; -- signal x."),
            .signal(value: signal)
        )
        XCTAssertEqual(
            Definition(rawValue: " signal x: std_logic := '1' ; -- signal x."),
            .signal(value: signal)
        )
        XCTAssertEqual(
            Definition(rawValue: "signal x: std_logic; -- signal x."),
            .signal(
                value: LocalSignal(
                    type: .stdLogic, name: x, defaultValue: nil, comment: Comment(text: "signal x.")
                )
            )
        )
        XCTAssertEqual(
            Definition(rawValue: "signal x: std_logic := '1';"),
            .signal(
                value: LocalSignal(
                    type: .stdLogic,
                    name: x,
                    defaultValue: .literal(value: .bit(value: .high)),
                    comment: nil
                )
            )
        )
        XCTAssertEqual(
            Definition(rawValue: "signal x: std_logic;"),
            .signal(
                value: LocalSignal(type: .stdLogic, name: x, defaultValue: nil, comment: nil)
            )
        )
        XCTAssertNil(Definition(rawValue: "signal x: std_logic := '1' -- signal x."))
        XCTAssertNil(Definition(rawValue: "signal x: std_logic := '1'; -- signal x.\n --"))
        XCTAssertNil(Definition(rawValue: "-- signal x: std_logic\n := '1';"))
    }

    /// Test component raw value init.
    func testComponentRawValueInit() {
        let raw = """
        component C is
            port(
                x: in std_logic;
                y: out std_logic
            );
        end component;
        """
        guard let port = PortBlock(signals: [
            PortSignal(type: .stdLogic, name: x, mode: .input),
            PortSignal(type: .stdLogic, name: VariableName(text: "y"), mode: .output)
        ]) else {
            XCTFail("Failed to create port!")
            return
        }
        XCTAssertEqual(
            Definition(rawValue: raw),
            .component(value: ComponentDefinition(name: VariableName(text: "C"), port: port))
        )
        let raw2 = """
        component component C is
            port(
                x: in std_logic;
                y: out std_logic
            );
        end component;
        """
        XCTAssertNil(Definition(rawValue: raw2))
    }

}
