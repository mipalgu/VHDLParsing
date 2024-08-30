// VHDLFileInvalidTests.swift
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

/// Test class for invalid `VHDL` code in `VHDLFile`.
final class VHDLFileInvalidTests: XCTestCase {

    /// Test invalid `init(rawValue:)` returns nil.
    func testInvalidRawValueInit() {
        XCTAssertNil(VHDLFile(rawValue: ""))
        XCTAssertNil(VHDLFile(rawValue: "library IEEE"))
    }

    /// Test invalid entity in raw value init.
    func testInvalidEntityRawValueInit() {
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
        XCTAssertNil(VHDLFile(rawValue: ""))
        XCTAssertNil(VHDLFile(rawValue: "abc"))
    }

    /// Test invalid package init.
    func testInvalidPackageInit() {
        let raw3 = """
            package Package1 iss
                constant high: std_logic := '1';
                type Record1_t iss record
                    a: std_logic;
                    b: std_logic;
                end record Record1_t;
                type xs iss std_logic_vector(3 downto 0);
            end package Package1;
            """
        XCTAssertNil(VHDLFile(rawValue: raw3))
        let raw4 = """
            package 2Package1 is
                constant high: std_logic := '1';
                type Record1_t is record
                    a: std_logic;
                    b: std_logic;
                end record Record1_t;
                type xs is std_logic_vector(3 downto 0);
            end package 2Package1;
            """
        XCTAssertNil(VHDLFile(rawValue: raw4))
        let raw5 = """
            package Package1 iss
                constant high: std_logic := '1';
                type Record1_t is record
                    a: std_logic;
                    b: std_logic;
                end record Record1_t;
                type xs is std_logic_vector(3 downto 0);
            end package Package1;
            """
        XCTAssertNil(VHDLFile(rawValue: raw5))
        XCTAssertNil(VHDLFile(rawValue: "package is"))
    }

    /// Test invalid package body init.
    func testInvalidPackageBodyInit() {
        let raw = """
            package body Package1
                constant low: std_logic := '0';
                constant zeros: xs := x"0";
            end package body Package1;
            """
        XCTAssertNil(VHDLFile(rawValue: raw))
        let raw2 = """
            package body is
                constant low: std_logic := '0';
                constant zeros: xs := x"0";
            end package body Package1;
            """
        XCTAssertNil(VHDLFile(rawValue: raw2))
        let raw3 = """
            package body Package1 is
                constant low: std_logic := '0';
                constant zeros: xs := x"0";
            end package body Package2;
            """
        XCTAssertNil(VHDLFile(rawValue: raw3))
        let raw4 = """
            package body Package1 is
                constant low: std_logic := '0';
                constants zeros: xs := x"0";
            end package body Package1;
            """
        XCTAssertNil(VHDLFile(rawValue: raw4))
    }

}
