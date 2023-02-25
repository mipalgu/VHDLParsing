// VHDLPackageTests.swift
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

/// Test class for ``VHDLPackage``.
final class VHDLPackageTests: XCTestCase {

    /// The package name.
    let packageName = VariableName(text: "Package1")

    // swiftlint:disable force_unwrapping

    /// The package statements.
    let statements = [
        HeadStatement.comment(value: Comment(text: "Statements")),
        .definition(value: .constant(value: ConstantSignal(
            name: VariableName(text: "high"), type: .stdLogic, value: .literal(value: .bit(value: .high))
        )!)),
        .definition(value: .type(value: .record(
            value: Record(name: VariableName(text: "Record1_t"), types: [
                RecordTypeDeclaration(name: VariableName(text: "a"), type: .signal(type: .stdLogic)),
                RecordTypeDeclaration(name: VariableName(text: "b"), type: .signal(type: .stdLogic))
            ])
        ))),
        .definition(value: .type(value: .alias(
            name: VariableName(text: "xs"),
            type: .ranged(type: .stdLogicVector(size: .downto(
                upper: .literal(value: .integer(value: 3)), lower: .literal(value: .integer(value: 0))
            )))
        )))
    ]

    // swiftlint:enable force_unwrapping

    /// The package under test.
    lazy var package = VHDLPackage(name: packageName, statements: statements)

    /// Initialise the package under test.
    override func setUp() {
        package = VHDLPackage(name: packageName, statements: statements)
    }

    /// Test that the stored properties are set correctly.
    func testInit() {
        XCTAssertEqual(package.name, packageName)
        XCTAssertEqual(package.statements, statements)
    }

    /// Test that the `VHDL` code is generated correctly.
    func testRawValue() {
        let expected = """
        package Package1 is
            -- Statements
            constant high: std_logic := '1';
            type Record1_t is record
                a: std_logic;
                b: std_logic;
            end record Record1_t;
            type xs is std_logic_vector(3 downto 0);
        end package Package1;
        """
        XCTAssertEqual(package.rawValue, expected)
    }

    /// Test that `init(rawValue:)` parses the `VHDL` code correctly.
    func testRawValueInit() {
        let raw = """
        package Package1 is
            -- Statements
            constant high: std_logic := '1';
            type Record1_t is record
                a: std_logic;
                b: std_logic;
            end record Record1_t;
            type xs is std_logic_vector(3 downto 0);
        end package Package1;
        """
        XCTAssertEqual(VHDLPackage(rawValue: raw), package)
        let raw2 = """
        package Package1 is
            -- Statements
            constant high: std_logic := '1';
            type Record1_t is record
                a: std_logic;
                b: std_logic;
            end record Record1_t; type xs is std_logic_vector(3 downto 0);
        end package Package1;
        """
        XCTAssertEqual(VHDLPackage(rawValue: raw2), package)
        let raw3 = """
        package Package1 is
            -- Statements
            constant high: std_logic := '1'; type Record1_t is record
                a: std_logic;
                b: std_logic;
            end record Record1_t;
            type xs is std_logic_vector(3 downto 0);
        end package Package1;
        """
        XCTAssertEqual(VHDLPackage(rawValue: raw3), package)
        let raw4 = """
        package Package1 is
            -- Statements
            constant high: std_logic := '1';
            type Record1_t is record
                a: std_logic;
                b: std_logic;
            end record Record1_t;
            type xs is std_logic_vector(3 downto 0);
            -- Statements
        end package Package1;
        """
        let newPackage = VHDLPackage(name: packageName, statements: statements + [statements[0]])
        XCTAssertEqual(VHDLPackage(rawValue: raw4), newPackage)
    }

    /// Test `init(rawValue:)` for invalid package definition.
    func testInvalidRawValueInit() {
        let raw = """
        package Package1 is
            -- Statements
            constant high: std_logic := '1';
            type Record1_t is record
                a: std_logic;
                b: std_logic;
            end record Record1_t;
            type xs is std_logic_vector(3 downto 0);
        end package Package1
        """
        XCTAssertNil(VHDLPackage(rawValue: raw))
        let raw2 = """
        packages Package1 is
            -- Statements
            constant high: std_logic := '1';
            type Record1_t is record
                a: std_logic;
                b: std_logic;
            end record Record1_t;
            type xs is std_logic_vector(3 downto 0);
        end package Package1;
        """
        XCTAssertNil(VHDLPackage(rawValue: raw2))
        let raw3 = """
        package Package12 is
            -- Statements
            constant high: std_logic := '1';
            type Record1_t is record
                a: std_logic;
                b: std_logic;
            end record Record1_t;
            type xs is std_logic_vector(3 downto 0);
        end package Package1;
        """
        XCTAssertNil(VHDLPackage(rawValue: raw3))
        let raw4 = """
        package 2Package1 is
            -- Statements
            constant high: std_logic := '1';
            type Record1_t is record
                a: std_logic;
                b: std_logic;
            end record Record1_t;
            type xs is std_logic_vector(3 downto 0);
        end package 2Package1;
        """
        XCTAssertNil(VHDLPackage(rawValue: raw4))
        XCTAssertNil(VHDLPackage(rawValue: ""))
    }

    /// Test `init(rawValue:)` for invalid package definition.
    func testInvalidRawValueInit2() {
        let raw5 = """
        package Package1 is
            -- Statements
            constant high: std_logic := '1';
            type Record1_t is record
                a: std_logic;
                b: std_logic;
            end record Record1_t;
            type xs is std_logic_vector(3 downto 0);
        end packages Package1;
        """
        XCTAssertNil(VHDLPackage(rawValue: raw5))
        let raw6 = """
        package Package1 is
            -- Statements
            constant high: std_logic := '1';
            type Record1_t is record
                a: std_logic;
                b: std_logic;
            end record Record1_t;
            type xs is std_logic_vector(3 downto 0);
        ends package Package1;
        """
        XCTAssertNil(VHDLPackage(rawValue: raw6))
    }

    /// Test block init.
    func testBlockInit() {
        XCTAssertNil(VHDLPackage(name: packageName, block: "type"))
        XCTAssertNil(VHDLPackage(name: packageName, block: "type Record1_t is record"))
        let raw = """
        type Record1_t is record
            a: std_logic;
            b: std_logic
        end record Record1_t;
        """
        XCTAssertNil(VHDLPackage(name: packageName, block: raw))
        let raw2 = """
        package Package1 is
            type Record1_t is record
                a: std_logic;
                b: std_logic;
            end record Record1_t;
        end package Package1;
        """
        let expected = VHDLPackage(name: packageName, statements: [statements[2]])
        XCTAssertEqual(VHDLPackage(rawValue: raw2), expected)
        let raw3 = """
        type Record1_t is record
            a: std_logic;
            b: std_logic;
        end record Record1_t;
        """
        XCTAssertEqual(VHDLPackage(name: packageName, block: raw3), expected)
        let raw4 = """
        type Record1_t is record
            a: std_logic;
            b: std_logic;
        end record Record1_t;

        """
        XCTAssertEqual(VHDLPackage(name: packageName, block: raw4), expected)
        XCTAssertNil(VHDLPackage(name: packageName, block: ""))
    }

    /// Test line init.
    func testLineInit() {
        XCTAssertNil(VHDLPackage(name: packageName, line: "2x: std_logic;"))
        XCTAssertEqual(
            VHDLPackage(name: packageName, line: "type xs is std_logic_vector(3 downto 0);    "),
            VHDLPackage(name: packageName, statements: [statements[3]])
        )
        XCTAssertNil(VHDLPackage(name: packageName, line: ""))
    }

}
