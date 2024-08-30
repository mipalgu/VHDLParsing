// ComponentInstantiationTests.swift
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

/// Test class for ``ComponentInstantiation``.
final class ComponentInstantiationTests: XCTestCase {

    /// The component label.
    let label = VariableName(text: "comp1")

    /// The component name.
    let entityName = VariableName(text: "C1")

    /// The port map.
    let port = PortMap(variables: [
        VariableMap(
            lhs: .variable(reference: .variable(name: VariableName(text: "x"))),
            rhs: .reference(variable: .variable(reference: .variable(name: VariableName(text: "z"))))
        ),
        VariableMap(lhs: .variable(reference: .variable(name: VariableName(text: "y"))), rhs: .open),
    ])

    /// The generic map.
    let generic = GenericMap(variables: [
        GenericVariableMap(
            lhs: .variable(reference: .variable(name: VariableName(text: "N"))),
            rhs: .reference(variable: .variable(reference: .variable(name: VariableName(text: "A"))))
        )
    ])

    /// The component under test.
    lazy var component = ComponentInstantiation(label: label, name: entityName, port: port, generic: generic)

    /// Initialises the component under test.
    override func setUp() {
        super.setUp()
        component = ComponentInstantiation(label: label, name: entityName, port: port, generic: generic)
    }

    /// Test that the initialiser sets the stored properties correctly.
    func testInit() {
        XCTAssertEqual(component.label, label)
        XCTAssertEqual(component.name, entityName)
        XCTAssertEqual(component.port, port)
        XCTAssertEqual(component.generic, generic)
        let component2 = ComponentInstantiation(label: label, name: entityName, port: port)
        XCTAssertEqual(component2.label, label)
        XCTAssertEqual(component2.name, entityName)
        XCTAssertEqual(component2.port, port)
        XCTAssertNil(component2.generic)
    }

    /// Test that `rawValue` generates the correct `VHDL` code.
    func testRawValue() {
        let expected = """
            comp1: component C1
                generic map (
                    N => A
                )
                port map (
                    x => z,
                    y => open
                );
            """
        XCTAssertEqual(component.rawValue, expected)
        let component2 = ComponentInstantiation(label: label, name: entityName, port: port)
        let expected2 = """
            comp1: component C1 port map (
                x => z,
                y => open
            );
            """
        XCTAssertEqual(component2.rawValue, expected2)
    }

    /// Tests that `init(rawValue:)` parses the `VHDL` correctly when that code doesn't contain generics.
    func testRawValueInitWithoutGeneric() {
        let raw = """
            comp1: component C1 port map (
                x => z,
                y => open
            );
            """
        let component = ComponentInstantiation(label: label, name: entityName, port: port)
        XCTAssertEqual(ComponentInstantiation(rawValue: raw), component)
        let raw2 = """
            comp1: C1 port map (
                x => z,
                y => open
            );
            """
        XCTAssertEqual(ComponentInstantiation(rawValue: raw2), component)
        let raw3 = """
            comp1 : C1 port map (
                x => z,
                y => open
            );
            """
        XCTAssertEqual(ComponentInstantiation(rawValue: raw3), component)
        let raw4 = """
            comp1 :C1 port map (
                x => z,
                y => open
            );
            """
        XCTAssertEqual(ComponentInstantiation(rawValue: raw4), component)
        let raw5 = "comp1: component C1 port map (x => z, y => open);"
        XCTAssertEqual(ComponentInstantiation(rawValue: raw5), component)
        let raw6 = "comp1: C1 port map (x => z, y => open);"
        XCTAssertEqual(ComponentInstantiation(rawValue: raw6), component)
    }

    /// Tests that `init(rawValue:)` parses the `VHDL` correctly when that code contains generics.
    func testRawValueInitWithGeneric() {
        let raw = """
            comp1: component C1
                generic map (
                    N => A
                )
                port map (
                    x => z,
                    y => open
                );
            """
        XCTAssertEqual(ComponentInstantiation(rawValue: raw), component)
        let raw2 = """
            comp1: component C1
                generic map (
                    N => A
                );
                port map (
                    x => z,
                    y => open
                );
            """
        XCTAssertNil(ComponentInstantiation(rawValue: raw2))
        let raw3 = """
            comp1: component C1
                generic map (
                    N => A
                );
            """
        XCTAssertNil(ComponentInstantiation(rawValue: raw3))
        let raw4 = """
            comp1: component C1
                generic map (
                    N => A
                )
            """
        XCTAssertNil(ComponentInstantiation(rawValue: raw4))
        let raw5 = "comp1: component C1 generic map (N => A) port map (x => z, y => open);"
        XCTAssertEqual(ComponentInstantiation(rawValue: raw5), component)
        let raw6 = "comp1: C1 generic map (N => A) port map (x => z, y => open);"
        XCTAssertEqual(ComponentInstantiation(rawValue: raw6), component)
    }

    /// Test that invalid code fails to create the component.
    func testInvalidRawValueInit() {
        XCTAssertNil(ComponentInstantiation(rawValue: "comp1:"))
        let raw = """
            comp1 component C1 port map (
                x => z,
                y => open
            );
            """
        XCTAssertNil(ComponentInstantiation(rawValue: raw))
        let raw2 = """
            comp1: component C1 port map (
                x => z,
                y => open
            )
            """
        XCTAssertNil(ComponentInstantiation(rawValue: raw2))
        let raw3 = """
            comp1: component C1 port map (
                x => z,
                y => 2open
            );
            """
        XCTAssertNil(ComponentInstantiation(rawValue: raw3))
        XCTAssertNil(ComponentInstantiation(rawValue: ""))
    }

}
