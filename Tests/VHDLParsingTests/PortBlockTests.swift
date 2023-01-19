// PortBlockTests.swift
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

/// Test class for ``PortBlock``.
final class PortBlockTests: XCTestCase {

    /// Variable named `x`.
    let x = VariableName(text: "x")

    /// Variable named `y`
    let y = VariableName(text: "y")

    /// Signal definition for `x`.
    var signalX: PortSignal {
        PortSignal(
            type: .stdLogic, name: self.x, mode: .input, defaultValue: .literal(value: .bit(value: .high))
        )
    }

    /// Signal definition for `y`.
    var signalY: PortSignal {
        PortSignal(
            type: .stdLogic,
            name: self.y,
            mode: .output,
            defaultValue: nil,
            comment: Comment(text: "signal y.")
        )
    }

    // swiftlint:disable implicitly_unwrapped_optional

    /// The port under test.
    var port: PortBlock! {
        PortBlock(signals: [signalX, signalY])
    }

    // swiftlint:enable implicitly_unwrapped_optional

    /// The expected `rawValue` for `port`.
    let expected = """
    port(
        x: in std_logic := '1';
        y: out std_logic -- signal y.
    );
    """

    /// Tests that the init sets the stored properties correctly.
    func testInit() {
        XCTAssertEqual(port.signals, [signalX, signalY])
    }

    /// Test init returns nil when the signal names are the same.
    func testInitReturnsNil() {
        var signal2 = signalX
        signal2.mode = .output
        signal2.defaultValue = nil
        signal2.comment = Comment(text: "Signal 2.")
        XCTAssertNil(PortBlock(signals: [signalX, signal2]))
    }

    /// Test `rawValue` generated `VHDL` code correctly.
    func testRawValue() {
        XCTAssertEqual(port.rawValue, expected)
    }

    /// Test `init(rawValue:)` works correctly.
    func testRawValueInit() {
        let port = PortBlock(signals: [
            signalX,
            PortSignal(type: .stdLogic, name: y, mode: .output)
        ])
        XCTAssertEqual(PortBlock(rawValue: expected), port)
        XCTAssertEqual(PortBlock(rawValue: "port(x: in std_logic := '1'; y: out std_logic);"), port)
        XCTAssertEqual(PortBlock(rawValue: "port(x: in std_logic := '1'; y: out std_logic); "), port)
        XCTAssertEqual(PortBlock(rawValue: " port(x: in std_logic := '1'; y: out std_logic);"), port)
        XCTAssertEqual(PortBlock(rawValue: " port(x: in std_logic := '1'; y: out std_logic); "), port)
        let result = PortBlock(
            rawValue: "port   ( x :    in  std_logic  :=  '1'  ; y  :    out  std_logic  )   ; "
        )
        XCTAssertEqual(result, port)
        XCTAssertNil(PortBlock(rawValue: "port(x: in std_logic := '1'; 2y: out std_logic);"))
        XCTAssertNil(PortBlock(rawValue: "port(x: in std_logic := '1'; y: out1 std_logic);"))
        XCTAssertNil(PortBlock(rawValue: "ports(x: in std_logic := '1'; y: out std_logic);"))
    }

}
