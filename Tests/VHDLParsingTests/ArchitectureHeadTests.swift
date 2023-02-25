// ArchitectureHeadTests.swift
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

/// Test class for ``ArchitectureHead``.
final class ArchitectureHeadTests: XCTestCase {

    /// The architecture statements.
    let statements = [
        HeadStatement.definition(value: .signal(value: LocalSignal(
            type: .stdLogic, name: VariableName(text: "x"), defaultValue: nil, comment: nil
        ))),
        .comment(value: Comment(text: "comment")),
        .definition(value: .component(value: ComponentDefinition(
            name: VariableName(text: "C"),
            port: PortBlock(signals: [
                PortSignal(type: .stdLogic, name: VariableName(text: "a"), mode: .input),
                PortSignal(type: .stdLogic, name: VariableName(text: "b"), mode: .output)
            // swiftlint:disable:next force_unwrapping
            ])!
        ))),
        .definition(value: .signal(value: LocalSignal(
            type: .stdLogic, name: VariableName(text: "y"), defaultValue: nil, comment: nil
        )))
    ]

    /// The head under test.
    lazy var head = ArchitectureHead(statements: statements)

    /// Setup the test case.
    override func setUp() {
        super.setUp()
        head = ArchitectureHead(statements: statements)
    }

    /// Test init sets stored properties correctly.
    func testInit() {
        XCTAssertEqual(head.statements, statements)
    }

    /// Test `rawValue` generated `VHDL` code correctly.
    func testRawValue() {
        let expected = """
        signal x: std_logic;
        -- comment
        component C is
            port(
                a: in std_logic;
                b: out std_logic
            );
        end component;
        signal y: std_logic;
        """
        XCTAssertEqual(head.rawValue, expected)
    }

    /// Test raw value init can parse `VHDL` code correctly.
    func testRawValueInit() {
        let raw = """
        signal x: std_logic;
        -- comment
        component C is
            port(
                a: in std_logic;
                b: out std_logic
            );
        end component;
        signal y: std_logic;
        """
        XCTAssertEqual(ArchitectureHead(rawValue: raw), head)
        let inlineHead = ArchitectureHead(statements: [statements[0], statements[3]])
        XCTAssertEqual(ArchitectureHead(rawValue: "signal x: std_logic;signal y: std_logic;"), inlineHead)
        let raw2 = """
        signal x: std_logic;
        signal y: std_logic;
        component C is
            port(
                a: in std_logic;
                b: out std_logic
            );
        end component;
        """
        let expected = ArchitectureHead(statements: [statements[0], statements[3], statements[2]])
        XCTAssertEqual(ArchitectureHead(rawValue: raw2), expected)
        XCTAssertNil(ArchitectureHead(rawValue: String(raw2.dropLast())))
        XCTAssertNil(ArchitectureHead(rawValue: ";;"))
        XCTAssertNil(ArchitectureHead(rawValue: "signal x: std_logic; signal y;"))
        XCTAssertNil(ArchitectureHead(rawValue: ""))
        XCTAssertNil(ArchitectureHead(rawValue: " "))
        XCTAssertNil(ArchitectureHead(rawValue: "\n"))
    }

    /// Test `init(rawValue:)` that contains comments.
    func testRawValueInitWithComment() {
        XCTAssertEqual(
            ArchitectureHead(rawValue: "-- comment"),
            ArchitectureHead(statements: [.comment(value: Comment(text: "comment"))])
        )
        XCTAssertEqual(
            ArchitectureHead(rawValue: "-- comment\n"),
            ArchitectureHead(statements: [.comment(value: Comment(text: "comment"))])
        )
        XCTAssertEqual(
            ArchitectureHead(rawValue: "-- comment\n--comment2"),
            ArchitectureHead(statements: [
                .comment(value: Comment(text: "comment")), .comment(value: Comment(text: "comment2"))
            ])
        )
        XCTAssertNil(ArchitectureHead(rawValue: "--\(String(repeating: "x", count: 256))"))
        XCTAssertNil(ArchitectureHead(rawValue: "--\(String(repeating: "x", count: 256))\n-- comment\n"))
    }

}
