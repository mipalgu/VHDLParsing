// StringVHDLMethodsTests.swift
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

/// Test class for `String` extension methods.
final class StringVHDLMethodsTests: XCTestCase {

    /// Test null block is correct.
    func testNullBlock() {
        let expected = """
        when others =>
            null;
        """
        XCTAssertEqual(String.nullBlock, expected)
    }

    /// Test tab is four spaces.
    func testTab() {
        XCTAssertEqual(String.tab, "    ")
    }

    /// Test withoutComments removes comments.
    func testWithoutComments() {
        let data = """
        signal x: std_logic; -- Signal x.
        -- signal y
        signal y: std_logic := '0';
        -- end
        """
        let expected = """
        signal x: std_logic;
        signal y: std_logic := '0';
        """
        let result = data.withoutComments
        XCTAssertEqual(result, expected)
    }

    /// Test startIndex returns correct index.
    func testStartIndex() {
        let data = "Hello World!"
        let result = data.startIndex(for: "World!")
        XCTAssertEqual(result, data.index(data.startIndex, offsetBy: 6))
        let data2 = data[data.startIndex..<data.endIndex]
        let result2 = data2.startIndex(for: "World")
        XCTAssertEqual(result2, data.index(data.startIndex, offsetBy: 6))
    }

    /// Test indexes grab substring correctly.
    func testIndexes() {
        let data = "Hello World!"
        let result = data.indexes(startingWith: "e", endingWith: "lo")
        guard result.count == 1 else {
            XCTFail("Incorrect indexes returned.")
            return
        }
        XCTAssertEqual(result[0].0, data.index(data.startIndex, offsetBy: 1))
        XCTAssertEqual(result[0].1, data.index(data.startIndex, offsetBy: 3))
    }

}
