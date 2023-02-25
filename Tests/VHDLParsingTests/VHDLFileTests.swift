// VHDLFileTests.swift
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

/// Test class for ``VHDLFile``.
final class VHDLFileTests: XCTestCase {

    /// The includes in the file.
    let includes = [
        Include.library(value: "IEEE"),
        Include.include(value: "IEEE.std_logic_1164.all")
    ]

    // swiftlint:disable force_unwrapping

    /// The entities in the file.
    let entities = [
        Entity(
            name: VariableName(text: "TestEntity"),
            port: PortBlock(signals: [
                PortSignal(type: .stdLogic, name: VariableName(text: "clk"), mode: .input)
            ])!
        )
    ]

    // swiftlint:enable force_unwrapping

    /// The architectures in the file.
    let architectures = [
        Architecture(
            body: .process(block: ProcessBlock(
                sensitivityList: [VariableName(text: "clk")],
                code: .ifStatement(block: .ifStatement(
                    condition: .conditional(condition: .edge(
                        value: .rising(expression: .reference(
                            variable: .variable(name: VariableName(text: "clk"))
                        ))
                    )),
                    ifBlock: .statement(statement: .assignment(
                        name: .variable(name: VariableName(text: "y")),
                        value: .reference(variable: .variable(name: VariableName(text: "x")))
                    ))
                ))
            )),
            entity: VariableName(text: "TestEntity"),
            head: ArchitectureHead(statements: [
                .definition(value: .signal(value: LocalSignal(
                    type: .stdLogic, name: VariableName(text: "x"), defaultValue: nil, comment: nil
                ))),
                .definition(value: .signal(value: LocalSignal(
                    type: .stdLogic, name: VariableName(text: "y"), defaultValue: nil, comment: nil
                )))
            ]),
            name: VariableName(text: "Behavioral")
        )
    ]

    /// The file under test.
    lazy var file = VHDLFile(architectures: architectures, entities: entities, includes: includes)

    /// Initialise the uut before every test.
    override func setUp() {
        super.setUp()
        file = VHDLFile(architectures: architectures, entities: entities, includes: includes)
    }

    /// Test init sets stored properties correctly.
    func testInit() {
        XCTAssertEqual(file.includes, includes)
        XCTAssertEqual(file.entities, entities)
        XCTAssertEqual(file.architectures, architectures)
    }

    /// Test that `rawValue` generates the `VHDL` code correctly.
    func testRawValue() {
        let expected = """
        library IEEE;
        use IEEE.std_logic_1164.all;

        entity TestEntity is
            port(
                clk: in std_logic
            );
        end TestEntity;

        architecture Behavioral of TestEntity is
            signal x: std_logic;
            signal y: std_logic;
        begin
            process(clk)
            begin
                if (rising_edge(clk)) then
                    y <= x;
                end if;
            end process;
        end Behavioral;

        """
        XCTAssertEqual(file.rawValue, expected)
    }

    /// Test `init(rawValue:)` works for test file.
    func testRawValueInit() {
        let raw = """
        library IEEE;
        use IEEE.std_logic_1164.all;

        entity TestEntity is
            port(
                clk: in std_logic
            );
        end TestEntity;

        architecture Behavioral of TestEntity is
            signal x: std_logic;
            signal y: std_logic;
        begin
            process(clk)
            begin
                if (rising_edge(clk)) then
                    y <= x;
                end if;
            end process;
        end Behavioral;

        """
        XCTAssertEqual(VHDLFile(rawValue: raw), file)
    }

    /// Test invalid `init(rawValue:)` returns nil.
    func testInvalidRawValueInit() {
        XCTAssertNil(VHDLFile(rawValue: ""))
        XCTAssertNil(VHDLFile(rawValue: "library IEEE"))
    }

    /// Test invalid entity in raw value init.
    func testInvalidEntityRawValueInit() {
        let raw = """
        entity TestEntity is
            port(
                clk: in std_logic
            );
        end TestEntity;
        """
        XCTAssertEqual(VHDLFile(rawValue: raw), VHDLFile(architectures: [], entities: entities, includes: []))
        let raw2 = """
        entity is
            port(
                clk: in std_logic
            );
        end TestEntity;
        """
        XCTAssertNil(VHDLFile(rawValue: raw2))
        let raw3 = """
        entity TestEntity
            port(
                clk: in std_logic
            );
        end TestEntity;
        """
        XCTAssertNil(VHDLFile(rawValue: raw3))
        let raw4 = """
        entity TestEntity is
            port(
                clk: in std_logic
            );
        endTestEntity;
        """
        XCTAssertNil(VHDLFile(rawValue: raw4))
    }

    // swiftlint:disable function_body_length

    /// Test architecture raw value init.
    func testArchitectureRawValueInit() {
        let raw = """
        architecture Behavioral of TestEntity is
            signal x: std_logic;
            signal y: std_logic;
        begin
            process(clk)
            begin
                if (rising_edge(clk)) then
                    y <= x;
                end if;
            end process;
        end Behavioral;
        """
        XCTAssertEqual(
            VHDLFile(rawValue: raw), VHDLFile(architectures: architectures, entities: [], includes: [])
        )
        let raw2 = """
        architecture Behavioral of TestEntity
            signal x: std_logic;
            signal y: std_logic;
        begin
            process(clk)
            begin
                if (rising_edge(clk)) then
                    y <= x;
                end if;
            end process;
        end Behavioral;
        """
        XCTAssertNil(VHDLFile(rawValue: raw2))
        let raw3 = """
        architecture Behavioral of2 TestEntity is
            signal x: std_logic;
            signal y: std_logic;
        begin
            process(clk)
            begin
                if (rising_edge(clk)) then
                    y <= x;
                end if;
            end process;
        end Behavioral;
        """
        XCTAssertNil(VHDLFile(rawValue: raw3))
        let raw4 = """
        architecture Behavioral of TestEntity is
            signal x: std_logic;
            signal y: std_logic;
        begins
            process(clk)
            begin
                if (rising_edge(clk)) then
                    y <= x;
                end if;
            end process;
        end Behavioral;
        """
        XCTAssertNil(VHDLFile(rawValue: raw4))
    }

    // swiftlint:enable function_body_length

    /// Test multiple entities
    func testMultipleEntities() {
        let raw = """
        entity TestEntity is
            port(
                clk: in std_logic
            );
        end TestEntity;

        entity TestEntity2 is
            port(
                clk: in std_logic
            );
        end TestEntity2;

        """
        let entity1 = entities[0]
        let entity2 = Entity(name: VariableName(text: "TestEntity2"), port: entity1.port)
        XCTAssertEqual(
            VHDLFile(rawValue: raw), VHDLFile(architectures: [], entities: [entity1, entity2], includes: [])
        )
        XCTAssertEqual(VHDLFile(rawValue: raw)?.rawValue, raw)
    }

    /// Test multiple architectures
    func testMultipleArchitectures() {
        let raw = """
        architecture Behavioral of TestEntity is
            signal x: std_logic;
            signal y: std_logic;
        begin
            process(clk)
            begin
                if (rising_edge(clk)) then
                    y <= x;
                end if;
            end process;
        end Behavioral;

        architecture Behavioral of TestEntity2 is
            signal x: std_logic;
            signal y: std_logic;
        begin
            process(clk)
            begin
                if (rising_edge(clk)) then
                    y <= x;
                end if;
            end process;
        end Behavioral;

        """
        let architecture1 = architectures[0]
        let architecture2 = Architecture(
            body: architecture1.body,
            entity: VariableName(text: "TestEntity2"),
            head: architecture1.head,
            name: architecture1.name
        )
        XCTAssertEqual(
            VHDLFile(rawValue: raw),
            VHDLFile(architectures: [architecture1, architecture2], entities: [], includes: [])
        )
        XCTAssertEqual(VHDLFile(rawValue: raw)?.rawValue, raw)
    }

}
