// ComponentDefinitionTests.swift
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

/// Test class for ``ComponentDefinition``.
final class ComponentDefinitionTests: XCTestCase {

    /// Then name of the component.
    let componentName = VariableName(text: "TestComponent")

    // swiftlint:disable implicitly_unwrapped_optional

    /// The port in the component.
    let port: PortBlock! = PortBlock(signals: [
        PortSignal(type: .stdLogic, name: VariableName(text: "x"), mode: .input),
        PortSignal(type: .stdLogic, name: VariableName(text: "y"), mode: .output)
    ])

    // swiftlint:enable implicitly_unwrapped_optional

    /// A generic block in the component.
    let generic = GenericBlock(types: [
        GenericTypeDeclaration(name: VariableName(text: "a"), type: .stdLogic),
        GenericTypeDeclaration(name: VariableName(text: "b"), type: .stdLogic)
    ])

    /// The component under test.
    lazy var component = ComponentDefinition(name: componentName, port: port)

    /// An component under test that has a generic block.
    lazy var componentWithGeneric = ComponentDefinition(name: componentName, port: port, generic: generic)

    /// Setup the component before every test.
    override func setUp() {
        super.setUp()
        component = ComponentDefinition(name: componentName, port: port)
        componentWithGeneric = ComponentDefinition(name: componentName, port: port, generic: generic)
    }

    /// Test the init sets the stored properties correctly.
    func testInit() {
        XCTAssertEqual(component.name, componentName)
        XCTAssertEqual(component.port, port)
    }

    /// Test that `rawValue` is correct.
    func testRawValue() {
        let expected = """
        component TestComponent is
            port(
                x: in std_logic;
                y: out std_logic
            );
        end component;
        """
        XCTAssertEqual(component.rawValue, expected)
        let genericExpected = """
        component TestComponent is
            generic(
                a: std_logic;
                b: std_logic
            );
            port(
                x: in std_logic;
                y: out std_logic
            );
        end component;
        """
        XCTAssertEqual(componentWithGeneric.rawValue, genericExpected)
    }

    /// Test `init(rawValue:)` parses the `VHDL` code correctly.
    func testRawValueInit() {
        let raw = """
        component TestComponent is
            port(
                x: in std_logic;
                y: out std_logic
            );
        end component;
        """
        XCTAssertEqual(ComponentDefinition(rawValue: raw), component)
        XCTAssertNil(ComponentDefinition(rawValue: String(raw.dropFirst())))
        XCTAssertNil(ComponentDefinition(rawValue: String(raw.dropLast())))
        let raw5 = """
        component     TestComponent
        is
            port   (
                  x:   in   std_logic  ;
                y :  out   std_logic
            ) ;
        end    component     ;
        """
        XCTAssertEqual(ComponentDefinition(rawValue: raw5), component)
    }

    /// Test invlaid values for raw value init.
    func testInvalidRawValueInit() {
        let raw2 = """
        component 2TestComponent is
            port(
                x: in std_logic;
                y: out std_logic
            );
        end component;
        """
        XCTAssertNil(ComponentDefinition(rawValue: raw2))
        let raw3 = """
        component 2TestComponent is
            port(
                x: in std_logic;
                y: out std_logic
            );
        end;
        """
        XCTAssertNil(ComponentDefinition(rawValue: raw3))
        let raw4 = """
        component 2TestComponent is
            port(
                x: in std_logic;
                y: out std_logic
            );
        """
        XCTAssertNil(ComponentDefinition(rawValue: raw4))
        let raw7 = """
        component TestComponent is
            generic(
                a: std_logic;
                b: std_logic
            );
            port(
                x: in std_logic;
                y: out std_logic
            );
        ends component;
        """
        XCTAssertNil(ComponentDefinition(rawValue: raw7))
    }

    /// Test `init(rawValue:)` when `rawValue` contains a generic block.
    func testRawValueInitWithGeneric() {
        let raw = """
        component TestComponent is
            generic(
                a: std_logic;
                b: std_logic
            );
            port(
                x: in std_logic;
                y: out std_logic
            );
        end component;
        """
        XCTAssertEqual(ComponentDefinition(rawValue: raw), componentWithGeneric)
        let raw2 = """
        component TestComponent is
            generic(
                a: std_logic;
                b: std_logic
            );port(
                x: in std_logic;
                y: out std_logic
            );
        end component;
        """
        XCTAssertEqual(ComponentDefinition(rawValue: raw2), componentWithGeneric)
    }

    /// Test `init(rawValue:)` with invalid generic.
    func testInvalidRawValueInitWithGeneric() {
        let raw3 = """
        component TestComponent is
            generic(
                a: std_logic;
                b: std_logic
            )
            port(
                x: in std_logic;
                y: out std_logic
            );
        end component;
        """
        XCTAssertNil(ComponentDefinition(rawValue: raw3))
        let raw4 = """
        component TestComponent is
            generic(
                a: std_logic;
                b: std_logic
            );
        end component;
        """
        XCTAssertNil(ComponentDefinition(rawValue: raw4))
        let raw5 = """
        component TestComponent is
            generic port(
                x: in std_logic;
                y: out std_logic
            );
        end component;
        """
        XCTAssertNil(ComponentDefinition(rawValue: raw5))
        let raw6 = """
        component TestComponent is
            generic(
                a: std_logic;
                b: std_logic
            );
            port(
                x: in std_logic;
                y: out std_logic
            );
        end components;
        """
        XCTAssertNil(ComponentDefinition(rawValue: raw6))
    }

}
