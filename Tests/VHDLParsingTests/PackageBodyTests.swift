// PackageBodyTests.swift
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

/// Test class for ``PackageBody``.
final class PackageBodyTests: XCTestCase {

    /// The name of the package.
    let packageName = VariableName(text: "PackageA")

    // swiftlint:disable force_unwrapping

    /// The package body.
    let body = PackageBodyBlock.blocks(values: [
        .include(statement: UseStatement(rawValue: "use IEEE.std_logic_1164.all;")!),
        .include(statement: UseStatement(rawValue: "use IEEE.math_real.all;")!),
        .constant(value: ConstantSignal(
            name: VariableName(rawValue: "pi")!, type: .real, value: .literal(value: .decimal(value: 3.14))
        )!)
    ])

    // swiftlint:enable force_unwrapping

    /// The package body under test.
    lazy var package = PackageBody(name: packageName, body: body)

    /// The equivalent `VHDL` code for `package`.
    let raw = """
    package body PackageA is
        use IEEE.std_logic_1164.all;
        use IEEE.math_real.all;
        constant pi: real := 3.14;
    end package body PackageA;
    """

    /// Create the package body before every test.
    override func setUp() {
        package = PackageBody(name: packageName, body: body)
    }

    /// Test the `rawValue` generates the correct `VHDL` code.
    func testRawValue() {
        XCTAssertEqual(package.rawValue, raw)
    }

    /// Test that `VHDL` code is parsed correctly.
    func testRawValueInit() {
        XCTAssertEqual(PackageBody(rawValue: raw), package)
        XCTAssertNil(PackageBody(rawValue: String(raw.dropLast())))
        let longPackage = """
        package body PackageA is
            constant \(String(repeating: "x", count: 4096)): std_logic := '0';
        end package body PackageA;
        """
        XCTAssertNil(PackageBody(rawValue: longPackage))
        XCTAssertNil(PackageBody(rawValue: String(raw.dropFirst())))
        let raw2 = """
        package bodys PackageA is
            use IEEE.std_logic_1164.all;
            use IEEE.math_real.all;
            constant pi: real := 3.14;
        end package body PackageA;
        """
        XCTAssertNil(PackageBody(rawValue: raw2))
        let raw3 = """
        package body !PackageA is
            use IEEE.std_logic_1164.all;
            use IEEE.math_real.all;
            constant pi: real := 3.14;
        end package body PackageA;
        """
        XCTAssertNil(PackageBody(rawValue: raw3))
        let raw4 = """
        package body PackageA is
            use IEEE.std_logic_1164.all;
            use IEEE.math_real.all;
            constant pi: real := 3.14;
        end package body PackageB;
        """
        XCTAssertNil(PackageBody(rawValue: raw4))
        let raw5 = """
        package body PackageA
            use IEEE.std_logic_1164.all;
            use IEEE.math_real.all;
            constant pi: real := 3.14;
        end package body PackageA;
        """
        XCTAssertNil(PackageBody(rawValue: raw5))
        // swiftlint:disable line_length
        let rawFlattened = """
        package body PackageA is use IEEE.std_logic_1164.all; use IEEE.math_real.all; constant pi: real := 3.14; end package body PackageA;
        """
        // swiftlint:enable line_length
        XCTAssertEqual(PackageBody(rawValue: rawFlattened), package)
    }

    /// Test invalid raw values in `init(rawValue:)`
    func testInvalidRawValueInit() {
        let raw6 = """
        package body PackageA is
            use IEEE.std_logic_1164.all;
            use IEEE.math_real.all;
            constant pi: real := 3.14;
        end package body PACKAGEA;
        """
        XCTAssertEqual(PackageBody(rawValue: raw6), package)
        let raw7 = """
        package body PackageA is
            use IEEE.std_logic_1164.all;
            use IEEE.math_real.all;
            constant pi: real := 3.14
        end package body PackageA;
        """
        XCTAssertNil(PackageBody(rawValue: raw7))
        let raw8 = """
        package body PackageA is
            use IEEE.std_logic_1164.all;
            use IEEE.math_real.all;
            constant pi: real := 3.14;
        end body PackageA;
        """
        XCTAssertNil(PackageBody(rawValue: raw8))
        let raw9 = """
        package body PackageA is
            use IEEE.std_logic_1164.all;
            use IEEE.math_real.all;
            constant pi: real := 3.14;
        package body PackageA;
        """
        XCTAssertNil(PackageBody(rawValue: raw9))
    }

}
