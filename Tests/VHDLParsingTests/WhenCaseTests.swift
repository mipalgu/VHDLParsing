// WhenCaseTests.swift
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

/// Test class for ``WhenCase``.
final class WhenCaseTests: XCTestCase {

    /// The condition of the when case.
    let condition = WhenCondition.others

    /// The null statement.
    let code = SynchronousBlock.statement(statement: Statement.null)

    /// The case under test.
    lazy var whenCase = WhenCase(condition: condition, code: code)

    /// Initialise the test case.
    override func setUp() {
        super.setUp()
        whenCase = WhenCase(condition: condition, code: code)
    }

    /// Test that the init sets the stored properties correctly.
    func testInit() {
        XCTAssertEqual(whenCase.condition, condition)
        XCTAssertEqual(whenCase.code, code)
    }

    /// Test the `rawValue` generated the `VHDL` code correctly.
    func testRawValue() {
        let expected = """
        when others =>
            null;
        """
        XCTAssertEqual(whenCase.rawValue, expected)
    }

    /// Test init parses `VHDL` code correctly.
    func testRawValueInit() {
        let raw = """
        when others =>
            null;
        """
        XCTAssertEqual(WhenCase(rawValue: raw), whenCase)
        let raw2 = """
        when 3 downto 0 =>
            null;
        """
        let expected = WhenCase(
            condition: .range(range: VectorSize.downto(upper: 3, lower: 0)),
            code: .statement(statement: .null)
        )
        XCTAssertEqual(WhenCase(rawValue: raw2), expected)
        let raw3 = """
          when\n   others    \n\n=>
               null   ;
        """
        let result = WhenCase(rawValue: raw3)
        XCTAssertEqual(result, whenCase)
    }

    /// Test invalid cases return nil in raw value init.
    func testInvalidRawValueInit() {
        XCTAssertNil(WhenCase(rawValue: "when others null;"))
        XCTAssertNil(WhenCase(rawValue: "others =>\n    null;"))
        XCTAssertNil(WhenCase(rawValue: "when 2others =>\n    null;"))
        XCTAssertNil(WhenCase(rawValue: "when others =>\n    null2;"))
    }

    /// Test others null block is correct.
    func testOthersNull() {
        let whenCase = WhenCase.othersNull
        XCTAssertEqual(whenCase.condition, .others)
        XCTAssertEqual(whenCase.code, .statement(statement: .null))
    }

}
