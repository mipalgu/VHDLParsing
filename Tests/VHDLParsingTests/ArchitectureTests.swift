// ArchitectureTests.swift
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

/// Test class for ``Architecture``.
final class ArchitectureTests: XCTestCase {

    /// The name of the architecture.
    let arch = VariableName(text: "Behavioral")

    /// The entities name.
    let entity = VariableName(text: "TestEntity")

    /// The body of the architecture.
    let body = AsynchronousBlock.process(block: ProcessBlock(
        sensitivityList: [VariableName(text: "clk")],
        code: .ifStatement(block: .ifStatement(
            condition: .conditional(condition: .edge(
                value: .rising(expression: .variable(name: VariableName(text: "clk")))
            )),
            ifBlock: .statement(statement: .assignment(
                name: .variable(name: VariableName(text: "x")),
                value: .literal(value: .bit(value: .high))
            ))
        ))
    ))

    /// The head of the architecture.
    let head = ArchitectureHead(statements: [
        .definition(signal: LocalSignal(
            type: .stdLogic, name: VariableName(text: "x"), defaultValue: nil, comment: nil
        ))
    ])

    /// The architecture under test.
    lazy var architecture = Architecture(body: body, entity: entity, head: head, name: arch)

    /// Initialise the uut.
    override func setUp() {
        super.setUp()
        architecture = Architecture(body: body, entity: entity, head: head, name: arch)
    }

    /// Test that the initialiser sets the stored properties correctly.
    func testInit() {
        XCTAssertEqual(architecture.body, body)
        XCTAssertEqual(architecture.entity, entity)
        XCTAssertEqual(architecture.head, head)
        XCTAssertEqual(architecture.name, arch)
    }

    /// Test `rawValue` generated `VHDL` code correctly.
    func testRawValue() {
        let expected = """
        architecture Behavioral of TestEntity is
            signal x: std_logic;
        begin
            process(clk)
            begin
                if (rising_edge(clk)) then
                    x <= '1';
                end if;
            end process;
        end Behavioral;
        """
        XCTAssertEqual(architecture.rawValue, expected)
    }

    /// Test `init(rawValue:)` parses `VHDL` code correctly.
    func testRawValueInit() {
        let raw = """
        architecture Behavioral of TestEntity is
            signal x: std_logic;
        begin
            process (clk)
            begin
                if (rising_edge(clk)) then
                    x <= '1';
                end if;
            end process;
        end Behavioral;
        """
        XCTAssertEqual(Architecture(rawValue: raw), architecture)
        let raw2 = """
           architecture
           Behavioral    of    TestEntity
              is
            signal x: std_logic;
                  begin
            process ( clk)
            begin
                if (  rising_edge(clk)   )
                then
                    x   <=    '1';
                end
                 if;
            end
            process;
        end     Behavioral  ;
        """
        XCTAssertEqual(Architecture(rawValue: raw2), architecture)
    }

    // swiftlint:disable function_body_length

    /// Test invalid cases return nil in raw value init.
    func testInvalidRawValueInit() {
        let raw = """
        architecture Behavioral of TestEntity
            signal x: std_logic;
        begin
            process (clk)
            begin
                if (rising_edge(clk)) then
                    x <= '1';
                end if;
            end process;
        end Behavioral;
        """
        XCTAssertNil(Architecture(rawValue: raw))
        let raw2 = """
        architecture Behavioral of TestEntity is
            signal x: std_logic;
        begin
            process (clk)
            begin
                if (rising_edge(clk)) then
                    x <= '1';
                end if;
            end process;
        end Behavioral
        """
        XCTAssertNil(Architecture(rawValue: raw2))
        let raw3 = """
        architecture Behavioral of TestEntity is
            signal x: std_logic;
        begin
            process (clk)
            begin
                if (rising_edge(clk)) then
                    x <= '1';
                end if;
            end process;
        end Behaviorals;
        """
        XCTAssertNil(Architecture(rawValue: raw3))
        let raw4 = """
        architecture Behavioral of TestEntity is
            signal x: std_logic;
        begin
            process (clk)
            begin
                if (rising_edge(clk)) then
                    x <= '1';
                end if;
            end process;
        Behavioral;
        """
        XCTAssertNil(Architecture(rawValue: raw4))
        let raw5 = """
        architecture Behavioral of TestEntity is
            signal x: std_logic;
            process (clk)
                if (rising_edge(clk)) then
                    x <= '1';
                end if;
            end process;
        end Behavioral;
        """
        XCTAssertNil(Architecture(rawValue: raw5))
        let raw6 = """
        architecture Behavioral of TestEntity is
            signal 2x: std_logic;
        begin
            process (clk)
            begin
                if (rising_edge(clk)) then
                    x <= '1';
                end if;
            end process;
        end Behavioral;
        """
        XCTAssertNil(Architecture(rawValue: raw6))
    }

    // swiftlint:enable function_body_length

}
