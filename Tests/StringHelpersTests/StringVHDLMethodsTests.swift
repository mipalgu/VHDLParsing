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

@testable import StringHelpers
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
            XCTFail("Incorrect indexes returned \(result.count).")
            return
        }
        XCTAssertEqual(result[0].0, data.index(data.startIndex, offsetBy: 1))
        XCTAssertEqual(result[0].1, data.index(data.startIndex, offsetBy: 3))
        let data2 = "abcabc"
        let result2 = data2.indexes(startingWith: "a", endingWith: "c")
        guard result2.count == 2 else {
            XCTFail("Incorrect indexes returned \(result2.count).")
            return
        }
        XCTAssertEqual(result2[0].0, data2.startIndex)
        XCTAssertEqual(result2[0].1, data2.index(data2.startIndex, offsetBy: 2))
        XCTAssertEqual(result2[1].0, data2.index(data2.startIndex, offsetBy: 3))
        XCTAssertEqual(result2[1].1, data2.index(data2.startIndex, offsetBy: 5))
        XCTAssertTrue(data.indexes(startingWith: "", endingWith: "lo").isEmpty)
        XCTAssertTrue(data.indexes(startingWith: "e", endingWith: "").isEmpty)
    }

    /// Test `withoutEmptyLines` removes lines correctly.
    func testWithoutEmptyLines() {
        let data = """

            a

            b

            c


            d

            """
        let expected = "a\nb\nc\nd"
        XCTAssertEqual(data.withoutEmptyLines, expected)
    }

    /// Test indent works correctly.
    func testIndent() {
        let data = "a\nb\nc\nd"
        let expected = """
            \(String.tab)a
            \(String.tab)b
            \(String.tab)c
            \(String.tab)d
            """
        XCTAssertEqual(data.indent(amount: 1), expected)
        let expected2 = """
            \(String(repeating: String.tab, count: 2))a
            \(String(repeating: String.tab, count: 2))b
            \(String(repeating: String.tab, count: 2))c
            \(String(repeating: String.tab, count: 2))d
            """
        XCTAssertEqual(data.indent(amount: 2), expected2)
        XCTAssertEqual(data.indent(amount: 0), data)
        XCTAssertEqual(data.indent(amount: -1), data)
    }

    /// Test `removeLast` removes correct character.
    func testRemoveLast() {
        var data = "a;b;c;d"
        data.removeLast(character: ";")
        XCTAssertEqual(data, "a;b;cd")
        data.removeLast(character: "e")
        XCTAssertEqual(data, "a;b;cd")
    }

    /// Test `upToSemicolon` returns correct substring.
    func testUpToSemicolon() {
        let data = "a;b;c;d"
        XCTAssertEqual(data.uptoSemicolon, "a")
        let data2 = "abc;d;"
        XCTAssertEqual(data2.uptoSemicolon, "abc")
        XCTAssertEqual("".uptoSemicolon, "")
        let data3 = "abcde"
        XCTAssertEqual(data3.uptoSemicolon, data3)
    }

    /// Test `split` function splits correctly and returns the correct character.
    func testSplitCharacters() {
        let characters = CharacterSet(charactersIn: ".;_")
        let data = "abc_d;e."
        guard let (parts, character) = data.split(on: characters) else {
            XCTFail("Failed to split.")
            return
        }
        XCTAssertEqual(parts, ["abc", "d;e."])
        XCTAssertEqual(character, "_")
        XCTAssertNil("".split(on: characters))
        XCTAssertNil("abc".split(on: characters))
        let data2 = "abcde;"
        guard let (parts2, character2) = data2.split(on: characters) else {
            XCTFail("Failed to split.")
            return
        }
        XCTAssertEqual(parts2, ["abcde", ""])
        XCTAssertEqual(character2, ";")
        let data3 = ".abcde"
        guard let (parts3, character3) = data3.split(on: characters) else {
            XCTFail("Failed to split.")
            return
        }
        XCTAssertEqual(parts3, ["", "abcde"])
        XCTAssertEqual(character3, ".")
    }

    /// Test split method for strings.
    func testSplitStrings() {
        let characters: Set<String> = [".", ";", "_", "def"]
        let data = "abc_d;e."
        guard let (parts, character) = data.split(on: characters) else {
            XCTFail("Failed to split.")
            return
        }
        XCTAssertEqual(parts, ["abc", "d;e."])
        XCTAssertEqual(character, "_")
        XCTAssertNil("".split(on: characters))
        XCTAssertNil("abc".split(on: characters))
        let data2 = "abcde;"
        guard let (parts2, character2) = data2.split(on: characters) else {
            XCTFail("Failed to split.")
            return
        }
        XCTAssertEqual(parts2, ["abcde", ""])
        XCTAssertEqual(character2, ";")
        let data3 = ".abcde"
        guard let (parts3, character3) = data3.split(on: characters) else {
            XCTFail("Failed to split.")
            return
        }
        XCTAssertEqual(parts3, ["", "abcde"])
        XCTAssertEqual(character3, ".")
        let data4 = "abcdefghijk"
        guard let (parts4, character4) = data4.split(on: characters) else {
            XCTFail("Failed to split.")
            return
        }
        XCTAssertEqual(parts4, ["abc", "ghijk"])
        XCTAssertEqual(character4, "def")
    }

    /// Test `upToBalancedElements` returns correct substring.
    func testUpToBalancedElements() {
        let data = "a(b(c)d)e"
        let expected = data[data.index(after: data.startIndex)...data.index(data.startIndex, offsetBy: 7)]
        XCTAssertEqual(data.upToBalancedElements(startsWith: "(", endsWith: ")"), expected)
        XCTAssertNil("".upToBalancedElements(startsWith: "(", endsWith: ")"))
        XCTAssertNil(data.upToBalancedElements(startsWith: "", endsWith: ")"))
        XCTAssertNil(data.upToBalancedElements(startsWith: "(", endsWith: ""))
        XCTAssertEqual(data.upToBalancedElements(startsWith: "(b", endsWith: "d)"), expected)
        XCTAssertEqual(data.upToBalancedElements(startsWith: "c", endsWith: "e"), "c)d)e")
    }

    /// Test `upToBalancedBracket` returns the correct substring.
    func testUpToBalancedBrackets() {
        let data = "a(b(c)d)e"
        let expected = data[data.index(after: data.startIndex)...data.index(data.startIndex, offsetBy: 7)]
        XCTAssertEqual(data.uptoBalancedBracket, expected)
    }

    /// Test `subExpressions` return correct substrings.
    func testSubExpressions() {
        let data = "a(b(c)d)e(fg)"
        let expected = [
            data[data.index(data.startIndex, offsetBy: 1)...data.index(data.startIndex, offsetBy: 7)],
            data[data.index(data.startIndex, offsetBy: 9)...data.index(data.startIndex, offsetBy: 12)],
        ]
        XCTAssertEqual(data.subExpressions, expected)
    }

    /// Test words.
    func testWords() {
        XCTAssertEqual("Hello World!".words, ["Hello", "World!"])
        XCTAssertEqual(" a b\nc \n d  \n \n e\n\n\nf   g\n".words, ["a", "b", "c", "d", "e", "f", "g"])
    }

    /// Test `firstWord`.
    func testFirstWord() {
        XCTAssertEqual(" a b\nc \n d  \n \n e\n\n\nf   g\n".firstWord, "a")
    }

    /// Test `lastWord`.
    func testLastWord() {
        XCTAssertEqual(" a b\nc \n d  \n \n e\n\n\nf   g\n".lastWord, "g")
    }

    /// Test `startIndex(word:)`.
    func testStartIndexWord() {
        let raw = "abcd abc abc"
        XCTAssertEqual(raw.startIndex(word: "abc"), raw.index(raw.startIndex, offsetBy: 5))
        XCTAssertNil("".startIndex(word: "abc"))
        XCTAssertNil(raw.startIndex(word: ""))
        let raw2 = "abc"
        XCTAssertEqual(raw2.startIndex(word: "abc"), raw2.startIndex)
        XCTAssertNil("defghijk".startIndex(word: "abc"))
        let raw3 = "if (x = y) then"
        XCTAssertEqual(raw3.startIndex(word: "if"), raw3.startIndex)
        let raw4 = "if (x = '1') then"
        XCTAssertEqual(raw4.startIndex(word: "if"), raw4.startIndex)
        XCTAssertNil("end if;".startIndex(word: "if"))
        XCTAssertNil("elsif (x /= y) then".startIndex(word: "if"))
        XCTAssertNil("end if;".startIndex(word: "if"))
        let raw5 = " abc"
        XCTAssertEqual(raw5.startIndex(word: "abc"), raw5.index(after: raw5.startIndex))
        XCTAssertNil("defabc".startIndex(word: "abc"))
    }

    /// Test `subExpression`.
    func testSubExpression() {
        let raw = """
            x <= '1';
            if (x = y) then
                x <= y;
                if (x = '1') then
                    x <= '0';
                end if;
            elsif (x /= y) then
                y <= x;
            else
                x <= '0';
            end if;
            x <= '1';
            """
        let expected = """
            if (x = y) then
                x <= y;
                if (x = '1') then
                    x <= '0';
                end if;
            elsif (x /= y) then
                y <= x;
            else
                x <= '0';
            end if;
            """
        guard let subExpression = raw.subExpression(beginningWith: ["if"], endingWith: ["end", "if;"]) else {
            XCTFail("Failed to get sub expression.")
            return
        }
        XCTAssertEqual(subExpression.trimmingCharacters(in: .whitespacesAndNewlines), expected)
    }

    /// Test process expression.
    func testSubExpression2() {
        // swiftlint:disable:next line_length
        let raw = """
            process (clk)\nbegin\nif (rising_edge(clk)) then\nx <= y;\nend if;\nend process;\nx <= y;\nx <= y;
            """
        let expected = "process (clk)\nbegin\nif (rising_edge(clk)) then\nx <= y;\nend if;\nend process;"
        guard
            let expression = raw.subExpression(beginningWith: ["process"], endingWith: ["end", "process;"])
        else {
            XCTFail("Failed to get sub expression.")
            return
        }
        XCTAssertEqual(expression.trimmingCharacters(in: .whitespacesAndNewlines), expected)
    }

}
