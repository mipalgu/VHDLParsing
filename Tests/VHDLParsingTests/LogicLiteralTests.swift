// LogicLiteralTests.swift
// Machines
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

/// Test class for ``LogicLiteral``.
final class LogicLiteralTests: XCTestCase {

    /// Test rawValue is created correctly.
    func testRawValue() {
        XCTAssertEqual(LogicLiteral.high.rawValue, "'1'")
        XCTAssertEqual(LogicLiteral.low.rawValue, "'0'")
        XCTAssertEqual(LogicLiteral.unknown.rawValue, "'X'")
        XCTAssertEqual(LogicLiteral.dontCare.rawValue, "'-'")
        XCTAssertEqual(LogicLiteral.highImpedance.rawValue, "'Z'")
        XCTAssertEqual(LogicLiteral.uninitialized.rawValue, "'U'")
        XCTAssertEqual(LogicLiteral.weakSignal.rawValue, "'W'")
        XCTAssertEqual(LogicLiteral.weakSignalHigh.rawValue, "'H'")
        XCTAssertEqual(LogicLiteral.weakSignalLow.rawValue, "'L'")
    }

    /// Test that the init sets the correct case for valid raw values.
    func testValidRawInit() {
        XCTAssertEqual(LogicLiteral(rawValue: "'1'"), .high)
        XCTAssertEqual(LogicLiteral(rawValue: "'0'"), .low)
        XCTAssertEqual(LogicLiteral(rawValue: "'X'"), .unknown)
        XCTAssertEqual(LogicLiteral(rawValue: "'-'"), .dontCare)
        XCTAssertEqual(LogicLiteral(rawValue: "'Z'"), .highImpedance)
        XCTAssertEqual(LogicLiteral(rawValue: "'U'"), .uninitialized)
        XCTAssertEqual(LogicLiteral(rawValue: "'W'"), .weakSignal)
        XCTAssertEqual(LogicLiteral(rawValue: "'H'"), .weakSignalHigh)
        XCTAssertEqual(LogicLiteral(rawValue: "'L'"), .weakSignalLow)
    }

    /// Test init returns nil for invalid raw values.
    func testInvalidRawValueInit() {
        XCTAssertNil(LogicLiteral(rawValue: "1"))
        XCTAssertNil(LogicLiteral(rawValue: "'i'"))
    }

    /// Test that the raw value init creates the correct cases for lowercased raw values.
    func testLowercasedRawValues() {
        XCTAssertEqual(LogicLiteral(rawValue: "'x'"), .unknown)
        XCTAssertEqual(LogicLiteral(rawValue: "'-'"), .dontCare)
        XCTAssertEqual(LogicLiteral(rawValue: "'z'"), .highImpedance)
        XCTAssertEqual(LogicLiteral(rawValue: "'u'"), .uninitialized)
        XCTAssertEqual(LogicLiteral(rawValue: "'w'"), .weakSignal)
        XCTAssertEqual(LogicLiteral(rawValue: "'h'"), .weakSignalHigh)
        XCTAssertEqual(LogicLiteral(rawValue: "'l'"), .weakSignalLow)
    }

    /// Test rawValue init creates correct cases when whitespace is present.
    func testWhitespaceRawValues() {
        XCTAssertEqual(LogicLiteral(rawValue: " '1' "), .high)
        XCTAssertEqual(LogicLiteral(rawValue: " '0' "), .low)
        XCTAssertEqual(LogicLiteral(rawValue: " 'X' "), .unknown)
        XCTAssertEqual(LogicLiteral(rawValue: " '-' "), .dontCare)
        XCTAssertEqual(LogicLiteral(rawValue: " 'Z' "), .highImpedance)
        XCTAssertEqual(LogicLiteral(rawValue: " 'U' "), .uninitialized)
        XCTAssertEqual(LogicLiteral(rawValue: " 'W' "), .weakSignal)
        XCTAssertEqual(LogicLiteral(rawValue: " 'H' "), .weakSignalHigh)
        XCTAssertEqual(LogicLiteral(rawValue: " 'L' "), .weakSignalLow)
    }

    /// Test vector literal computed property is correct.
    func testVectorLiteral() {
        XCTAssertEqual(LogicLiteral.high.vectorLiteral, "1")
        XCTAssertEqual(LogicLiteral.low.vectorLiteral, "0")
        XCTAssertEqual(LogicLiteral.unknown.vectorLiteral, "X")
        XCTAssertEqual(LogicLiteral.dontCare.vectorLiteral, "-")
        XCTAssertEqual(LogicLiteral.highImpedance.vectorLiteral, "Z")
        XCTAssertEqual(LogicLiteral.uninitialized.vectorLiteral, "U")
        XCTAssertEqual(LogicLiteral.weakSignal.vectorLiteral, "W")
        XCTAssertEqual(LogicLiteral.weakSignalHigh.vectorLiteral, "H")
        XCTAssertEqual(LogicLiteral.weakSignalLow.vectorLiteral, "L")
    }

    /// Test ``BitLiteral`` initialiser.
    func testBitLiteralInit() {
        XCTAssertEqual(LogicLiteral(bit: .high), .high)
        XCTAssertEqual(LogicLiteral(bit: .low), .low)
    }

}
