// EntityTests.swift
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

/// Test class for ``Entity``.
final class EntityTests: XCTestCase {

    /// Then name of the entity.
    let entityName = VariableName(text: "TestEntity")

    // swiftlint:disable implicitly_unwrapped_optional

    /// The port in the entity.
    let port: PortBlock! = PortBlock(signals: [
        PortSignal(type: .stdLogic, name: VariableName(text: "x"), mode: .input),
        PortSignal(type: .stdLogic, name: VariableName(text: "y"), mode: .output),
    ])

    // swiftlint:enable implicitly_unwrapped_optional

    /// A generic block in the entity.
    let generic = GenericBlock(types: [
        GenericTypeDeclaration(name: VariableName(text: "a"), type: .stdLogic),
        GenericTypeDeclaration(name: VariableName(text: "b"), type: .stdLogic),
    ])

    /// The entity under test.
    lazy var entity = Entity(name: entityName, port: port)

    /// An entity under test that has a generic block.
    lazy var entityWithGeneric = Entity(name: entityName, port: port, generic: generic)

    /// Setup the entity before every test.
    override func setUp() {
        super.setUp()
        entity = Entity(name: entityName, port: port)
        entityWithGeneric = Entity(name: entityName, port: port, generic: generic)
    }

    /// Test the init sets the stored properties correctly.
    func testInit() {
        XCTAssertEqual(entity.name, entityName)
        XCTAssertEqual(entity.port, port)
    }

    /// Test that `rawValue` is correct.
    func testRawValue() {
        let expected = """
            entity TestEntity is
                port(
                    x: in std_logic;
                    y: out std_logic
                );
            end TestEntity;
            """
        XCTAssertEqual(entity.rawValue, expected)
        let genericExpected = """
            entity TestEntity is
                generic(
                    a: std_logic;
                    b: std_logic
                );
                port(
                    x: in std_logic;
                    y: out std_logic
                );
            end TestEntity;
            """
        XCTAssertEqual(entityWithGeneric.rawValue, genericExpected)
    }

    /// Test `init(rawValue:)` parses the `VHDL` code correctly.
    func testRawValueInit() {
        let raw = """
            entity TestEntity is
                port(
                    x: in std_logic;
                    y: out std_logic
                );
            end TestEntity;
            """
        XCTAssertEqual(Entity(rawValue: raw), entity)
        XCTAssertNil(Entity(rawValue: String(raw.dropFirst())))
        XCTAssertNil(Entity(rawValue: String(raw.dropLast())))
        let raw5 = """
            entity     TestEntity
            is
                port   (
                      x:   in   std_logic  ;
                    y :  out   std_logic
                ) ;
            end    TestEntity     ;
            """
        XCTAssertEqual(Entity(rawValue: raw5), entity)
    }

    /// Test invlaid values for raw value init.
    func testInvalidRawValueInit() {
        let raw2 = """
            entity 2TestEntity is
                port(
                    x: in std_logic;
                    y: out std_logic
                );
            end TestEntity;
            """
        XCTAssertNil(Entity(rawValue: raw2))
        let raw3 = """
            entity 2TestEntity is
                port(
                    x: in std_logic;
                    y: out std_logic
                );
            end;
            """
        XCTAssertNil(Entity(rawValue: raw3))
        let raw4 = """
            entity 2TestEntity is
                port(
                    x: in std_logic;
                    y: out std_logic
                );
            """
        XCTAssertNil(Entity(rawValue: raw4))
        let raw7 = """
            entity TestEntity is
                generic(
                    a: std_logic;
                    b: std_logic
                );
                port(
                    x: in std_logic;
                    y: out std_logic
                );
            ends TestEntity;
            """
        XCTAssertNil(Entity(rawValue: raw7))
    }

    /// Test `init(rawValue:)` when `rawValue` contains a generic block.
    func testRawValueInitWithGeneric() {
        let raw = """
            entity TestEntity is
                generic(
                    a: std_logic;
                    b: std_logic
                );
                port(
                    x: in std_logic;
                    y: out std_logic
                );
            end TestEntity;
            """
        XCTAssertEqual(Entity(rawValue: raw), entityWithGeneric)
        let raw2 = """
            entity TestEntity is
                generic(
                    a: std_logic;
                    b: std_logic
                );port(
                    x: in std_logic;
                    y: out std_logic
                );
            end TestEntity;
            """
        XCTAssertEqual(Entity(rawValue: raw2), entityWithGeneric)
    }

    /// Test `init(rawValue:)` with invalid generic.
    func testInvalidRawValueInitWithGeneric() {
        let raw3 = """
            entity TestEntity is
                generic(
                    a: std_logic;
                    b: std_logic
                )
                port(
                    x: in std_logic;
                    y: out std_logic
                );
            end TestEntity;
            """
        XCTAssertNil(Entity(rawValue: raw3))
        let raw4 = """
            entity TestEntity is
                generic(
                    a: std_logic;
                    b: std_logic
                );
            end TestEntity;
            """
        XCTAssertNil(Entity(rawValue: raw4))
        let raw5 = """
            entity TestEntity is
                generic port(
                    x: in std_logic;
                    y: out std_logic
                );
            end TestEntity;
            """
        XCTAssertNil(Entity(rawValue: raw5))
        let raw6 = """
            entity TestEntity is
                generic(
                    a: std_logic;
                    b: std_logic
                );
                port(
                    x: in std_logic;
                    y: out std_logic
                );
            end TestsEntity;
            """
        XCTAssertNil(Entity(rawValue: raw6))
    }

}
