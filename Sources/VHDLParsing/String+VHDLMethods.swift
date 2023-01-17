// String+indent.swift
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

import Foundation

/// Add helper methods for VHDL parsing.
extension String {

    /// A `VHDL` null block in a case statement.
    public static var nullBlock: String {
        """
        when others =>
        \(String.tab)null;
        """
    }

    /// A tab is considered 4 spaces.
    static var tab: String {
        "    "
    }

    /// Remove all `VHDL` comments and empty lines from the string.
    var withoutComments: String {
        performWithoutComments(for: self)
    }

    /// Remove all empty lines from the string.
    var withoutEmptyLines: String {
        self.components(separatedBy: .newlines).lazy
        .map {
            $0.trimmingCharacters(in: .whitespaces)
        }
        .filter { !$0.isEmpty }
        .joined(separator: "\n")
    }

    /// Find all expressions within self that exist within a set of brackets.
    @usableFromInline var subExpressions: [Substring]? {
        var expressions: [Substring] = []
        var openCount = 0
        var openIndex = self.startIndex
        for i in self.indices {
            let c = self[i]
            if c == "(" && openCount == 0 {
                openCount += 1
                openIndex = i
                continue
            }
            if c == "(" {
                openCount += 1
                continue
            }
            if c == ")" && openCount == 0 {
                return nil
            }
            if c == ")" {
                openCount -= 1
                if openCount == 0 {
                    expressions.append(self[openIndex...i])
                }
            }
        }
        guard openCount == 0 else {
            return nil
        }
        return expressions
    }

    var uptoBalancedBracket: String? {
        self.upToBalancedElements(startsWith: "(", endsWith: ")")
    }

    /// The string up to the first semicolon.
    @usableFromInline var uptoSemicolon: String {
        guard let semicolonIndex = self.firstIndex(where: { $0 == ";" }) else {
            return self
        }
        return String(self[self.startIndex..<semicolonIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Indent every line within the string by a specified amount.
    /// - Parameter amount: The number of tabs to indent.
    /// - Returns: The indented string.
    public func indent(amount: Int) -> String {
        guard amount > 0 else {
            return self
        }
        let indentAmount = String(repeating: String.tab, count: amount)
        return self.components(separatedBy: .newlines).map { indentAmount + $0 }.joined(separator: "\n")
    }

    /// Remove the last specified character from the string.
    /// - Parameter character: The character to remove from the end of the string.
    public mutating func removeLast(character: Character) {
        guard let lastIndex = self.lastIndex(of: character) else {
            return
        }
        _ = self.remove(at: lastIndex)
    }

    /// Grab indexes of all occurrences of a string that starts with a specified string and ends with a
    /// specified string.
    /// - Parameters:
    ///   - startingWith: The starting delimiter for the substring.
    ///   - endingWith: The ending delimter for the substring.
    /// - Returns: All indexes for substrings that begin with `startingWith` and end with `endingWith`.
    func indexes(startingWith: String, endingWith: String) -> [(String.Index, String.Index)] {
        guard !startingWith.isEmpty, !endingWith.isEmpty else {
            return []
        }
        var indexes: [(String.Index, String.Index)] = []
        var index = self.startIndex
        while index < self.endIndex {
            guard let startIndex = self[index...].startIndex(for: startingWith) else {
                return indexes
            }
            let nextIndex = self.index(after: startIndex)
            guard nextIndex < endIndex, let endIndex = self[nextIndex...].startIndex(for: endingWith) else {
                return indexes
            }
            indexes.append((startIndex, endIndex))
            index = self.index(after: endIndex)
        }
        return indexes
    }

    /// Split the string into 2 strings. The first string is the string up to the first character in the given
    /// character set.
    /// - Parameter characters: The characters to split on.
    /// - Returns: A tuple containing the 2 halves of the string and the character that was split on.
    @usableFromInline
    func split(on characters: CharacterSet) -> ([String], Character)? {
        guard let firstIndex = self.unicodeScalars.firstIndex(where: { characters.contains($0) }) else {
            return nil
        }
        let char = self[firstIndex]
        let op = String(char)
        let components = self.components(separatedBy: op)
        guard components.count >= 2 else {
            return nil
        }
        return ([components[0], components[1...].joined(separator: op)], char)
    }

    /// Return the starting index of a substring value within self.
    /// - Parameter value: The substring to search for.
    /// - Returns: The first index within self that matches the substring.
    func startIndex(for value: String) -> String.Index? {
        let size = value.count
        guard !value.isEmpty, self.count >= size else {
            return nil
        }
        let offset = size - 1
        let startIndex = self.index(self.startIndex, offsetBy: offset)
        for i in self[startIndex...].indices {
            guard
                let wordStart = self.index(i, offsetBy: -offset, limitedBy: self.startIndex),
                self[wordStart...i] == value
            else {
                continue
            }
            return wordStart
        }
        return nil
    }

    /// Find a string that starts with a specified string and ends with a specified string including
    /// substrings following the same pattern. For example, consider the string \"a(b(c)d)e\", starting with
    /// \"(\" and ending with \")\". The result would be \"(b(c)d)\".
    /// - Parameters:
    ///   - startsWith: The begining delimiter for the substring.
    ///   - endsWith: The ending delimiter for the substring.
    /// - Returns: The substring that starts with `startsWith` and ends with `endsWith` including any
    /// strings within that match the same pattern.
    func upToBalancedElements(startsWith: String, endsWith: String) -> String? {
        guard !startsWith.isEmpty, !endsWith.isEmpty else {
            return nil
        }
        let startSize = startsWith.count
        let endSize = endsWith.count
        var startCount = 0
        var hasStarted = false
        var index = self.startIndex
        var beginIndex: String.Index?
        while index < self.endIndex {
            guard hasStarted else {
                guard
                    let startIndex = self.startIndex(for: startsWith),
                    let nextIndex = self.index(startIndex, offsetBy: startSize, limitedBy: self.endIndex)
                else {
                    return nil
                }
                beginIndex = startIndex
                index = nextIndex
                hasStarted = true
                startCount += 1
                continue
            }
            let data = self[index...]
            guard let endIndex = data.startIndex(for: endsWith) else {
                return nil
            }
            if let nextStartIndex = data.startIndex(for: startsWith) {
                guard nextStartIndex > endIndex else {
                    startCount += 1
                    index = self.index(nextStartIndex, offsetBy: startSize)
                    continue
                }
            }
            let lastIndex = self.index(endIndex, offsetBy: endSize)
            guard startCount <= 1 else {
                startCount -= 1
                index = lastIndex
                continue
            }
            guard let beginIndex = beginIndex else {
                return nil
            }
            return String(self[beginIndex..<lastIndex])
        }
        return nil
    }

    private func performWithoutComments(for value: String, carry: String = "") -> String {
        guard let firstIndex = value.startIndex(for: "--") else {
            return carry + value.withoutEmptyLines
        }
        let subString = value[firstIndex...]
        guard let endIndex = subString.startIndex(for: "\n") else {
            return carry + String(value[..<firstIndex]).withoutEmptyLines
        }
        var newString = value
        newString.removeSubrange(firstIndex..<endIndex)
        return performWithoutComments(
            for: String(newString[firstIndex...]),
            carry: carry + String(
                newString[newString.startIndex..<firstIndex]
            ).trimmingCharacters(in: .whitespaces)
        )
    }

}

extension Substring {

    /// Return the starting index of a substring value within self.
    /// - Parameter value: The substring to search for.
    /// - Returns: The first index within self that matches the substring.
    func startIndex(for value: String) -> String.Index? {
        let size = value.count
        guard !value.isEmpty, self.count >= size else {
            return nil
        }
        let offset = size - 1
        let startIndex = self.index(self.startIndex, offsetBy: offset)
        for i in self[startIndex...].indices {
            guard
                let wordStart = self.index(i, offsetBy: -offset, limitedBy: self.startIndex),
                self[wordStart...i] == value
            else {
                continue
            }
            return wordStart
        }
        return nil
    }

}
