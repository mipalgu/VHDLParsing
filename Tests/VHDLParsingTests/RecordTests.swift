// RecordTests.swift
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

/// Test class for ``Record``.
final class RecordTests: XCTestCase {

    /// The name of the record under test.
    let recordName = VariableName(text: "NewRecord")

    /// A variable `x`.
    let x = VariableName(text: "x")

    /// A variable `y`.
    let y = VariableName(text: "y")

    /// The type of `x`.
    let xType = Type.signal(type: .stdLogic)

    /// The type of `y`.
    let yType = Type.signal(
        type: .ranged(
            type: .stdLogicVector(
                size: .downto(
                    upper: .literal(value: .integer(value: 3)),
                    lower: .literal(value: .integer(value: 0))
                )
            )
        )
    )

    /// The x-declaration.
    lazy var xDeclaration = RecordTypeDeclaration(name: x, type: xType)

    /// The y-declaration.
    lazy var yDeclaration = RecordTypeDeclaration(name: y, type: yType)

    /// The record under test.
    lazy var record = Record(name: recordName, types: [xDeclaration, yDeclaration])

    /// Initialise the record before every test.
    override func setUp() {
        xDeclaration = RecordTypeDeclaration(name: x, type: xType)
        yDeclaration = RecordTypeDeclaration(name: y, type: yType)
        record = Record(name: recordName, types: [xDeclaration, yDeclaration])
    }

    /// Test that the record is correctly initialised.
    func testInit() {
        XCTAssertEqual(record.name, recordName)
        XCTAssertEqual(record.types, [xDeclaration, yDeclaration])
    }

    /// Test that the `rawValue` generates the `VHDL` code correctly.
    func testRawValue() {
        let expected = """
            type NewRecord is record
                x: std_logic;
                y: std_logic_vector(3 downto 0);
            end record NewRecord;
            """
        XCTAssertEqual(record.rawValue, expected)
    }

    /// Test that `init(rawValue:)` parses the `VHDL` code correctly.
    func testRawValueInit() {
        let raw = """
            type NewRecord is record
                x: std_logic;
                y: std_logic_vector(3 downto 0);
            end record NewRecord;
            """
        XCTAssertEqual(Record(rawValue: raw), record)
        let raw2 = """
            type NewRecord is record
                x: std_logic; y: std_logic_vector(3 downto 0);
            end record NewRecord;
            """
        XCTAssertEqual(Record(rawValue: raw2), record)
        let raw3 = """
            type NewRecord is record x: std_logic; y: std_logic_vector(3 downto 0); end record NewRecord;
            """
        XCTAssertEqual(Record(rawValue: raw3), record)
        let raw4 = """
               \n   type   \n  \n   NewRecord     \n    is   \n   record
                x :   std_logic  ;
                y :         std_logic_vector(3 downto 0);
               end     RECORD     NewRecord\n   ;    \n
            """
        XCTAssertEqual(Record(rawValue: raw4), record)
    }

    /// Test that `init(rawValue:)` returns nil for invalid `VHDL` code.
    func testInvalidRawValueInit() {
        XCTAssertNil(Record(rawValue: ""))
        let raw = """
            type NewRecord is record
                x: std_logic;
                y: std_logic_vector(3 downto 0);
            end record NewRecord;;
            """
        XCTAssertNil(Record(rawValue: raw))
        let raw2 = """
            type NewRecord is record
                x: std_logic;;
                y: std_logic_vector(3 downto 0);
            end record NewRecord;
            """
        XCTAssertNil(Record(rawValue: raw2))
        let raw3 = """
            type NewRecord is record
                x: std_logic;
                y: std_logic_vector(3 downto 0);;
            end record NewRecord;
            """
        XCTAssertNil(Record(rawValue: raw3))
        let raw4 = """
            type NewRecord is record
                x: std_logic;
                y: std_logic_vector(3 downto 0);
            end record NewRecords;
            """
        XCTAssertNil(Record(rawValue: raw4))
        let raw5 = """
            type 2NewRecord is record
                x: std_logic;
                y: std_logic_vector(3 downto 0);
            end record 2NewRecord;
            """
        XCTAssertNil(Record(rawValue: raw5))
    }

    /// Invalid continued...
    func testInvalidRawValueInit2() {
        let raw6 = """
            type NewRecord is record
                x: std_logic;
                y: std_logic_vector(3s downto 0);
            end record NewRecord;
            """
        XCTAssertNil(Record(rawValue: raw6))
        let raw7 = """
            type NewRecord is record
                x: std_logic;
                y: std_logic_vector(3 downto 0);
            end records NewRecord;
            """
        XCTAssertNil(Record(rawValue: raw7))
        let raw8 = """
            type NewRecord is record
                x: std_logic;
                y: std_logic_vector(3 downto 0);
            ends record NewRecord;
            """
        XCTAssertNil(Record(rawValue: raw8))
        let raw9 = """
            type NewRecord is record
                x: record;
                y: std_logic_vector(3 downto 0);
            end record NewRecord;
            """
        XCTAssertNil(Record(rawValue: raw9))
        let raw10 = """
            type NewRecord is record
                x: std_logic;
                y: std_logic_vector(3 downto 0);
            end record NewRecord;   record
            """
        XCTAssertNil(Record(rawValue: raw10))
        let raw11 = """
            type NewRecord is record
            """
        XCTAssertNil(Record(rawValue: raw11))
    }

    /// Invalid init continued...
    func testInvalidRawValueInit3() {
        let raw12 = """
            type NewRecord is
                x: std_logic;
                y: std_logic_vector(3 downto 0);
            end record NewRecord;
            """
        XCTAssertNil(Record(rawValue: raw12))
        let raw13 = """
            type NewRecord is record
                x: std_logic;
                y: std_logic_vector(3 downto 0);
            end record NewRecord;   ;
            """
        XCTAssertNil(Record(rawValue: raw13))
        let raw14 = """
            type NewRecord is record
                x: std_logic;
                y: std_logic_vector(3 downto 0)  ;  ;\n
            end record NewRecord;
            """
        XCTAssertNil(Record(rawValue: raw14))
        let raw15 = """
            type NewRecord is record
                x: std_logic;
                z: std_logic
                y: std_logic_vector(3 downto 0);
            end record NewRecord;;
            """
        XCTAssertNil(Record(rawValue: raw15))
        let raw16 = """
            type NewRecord is record
                x: std_logic;
                y: std_logic_vector(3 downto 0); abc
            end record NewRecord;
            """
        XCTAssertNil(Record(rawValue: raw16))
        let raw17 = """
            type NewRecord is record
                x: std_logic;
                y: std_logic_vector(3 downto 0); record
            end record NewRecord;;
            """
        XCTAssertNil(Record(rawValue: raw17))
    }

}
