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
    @inlinable public static var nullBlock: String {
        """
        when others =>
        \(String.tab)null;
        """
    }

    /// A tab is considered 4 spaces.
    @usableFromInline static var tab: String {
        "    "
    }

    /// Get the first word in the string.
    @usableFromInline var firstWord: String? {
        guard
            let components = self.trimmingCharacters(in: .whitespacesAndNewlines)
                .split(
                    on: .whitespacesAndNewlines.union(CharacterSet(charactersIn: "();")
                        .union(.vhdlOperators)
                        .union(.vhdlComparisonOperations))
                )
        else {
            return nil
        }
        return components.0.first
    }

    /// Get the last word in the string.
    @usableFromInline var lastWord: String? {
        let characters = CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "();")
            .union(.vhdlOperators)
            .union(.vhdlComparisonOperations))
        guard
            let index = self.trimmingCharacters(in: .whitespacesAndNewlines).unicodeScalars
                .lastIndex(where: { characters.contains($0) })
        else {
            return nil
        }
        return String(self[index...]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Remove all `VHDL` comments and empty lines from the string.
    @usableFromInline var withoutComments: String {
        performWithoutComments(for: self)
    }

    /// Remove all empty lines from the string.
    @usableFromInline var withoutEmptyLines: String {
        self.components(separatedBy: .newlines).lazy
        .map {
            $0.trimmingCharacters(in: .whitespaces)
        }
        .filter { !$0.isEmpty }
        .joined(separator: "\n")
    }

    /// Find all expressions within self that exist within a set of brackets. The substrings returned may also
    /// contain substrings with brackets within them.
    @usableFromInline var subExpressions: [Substring]? {
        var expressions: [Substring] = []
        var index = self.startIndex
        while index < self.endIndex {
            guard let brackets = self[index...].uptoBalancedBracket else {
                return expressions
            }
            expressions.append(brackets)
            index = brackets.endIndex
        }
        return expressions
    }

    @usableFromInline var topExpressions: [Substring]? {
        self[self.startIndex..<self.endIndex].topExpressions
    }

    /// Return a string that exists within self that starts with an open bracket and ends with the balanced
    /// closing bracket.
    @usableFromInline var uptoBalancedBracket: Substring? {
        self[self.startIndex..<self.endIndex].uptoBalancedBracket
    }

    /// The string up to the first semicolon.
    @usableFromInline var uptoSemicolon: String {
        guard let semicolonIndex = self.firstIndex(where: { $0 == ";" }) else {
            return self
        }
        return String(self[self.startIndex..<semicolonIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// All the words in the string.
    @usableFromInline var words: [String] {
        self.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
    }

    /// Indent every line within the string by a specified amount.
    /// - Parameter amount: The number of tabs to indent.
    /// - Returns: The indented string.
    @inlinable
    public func indent(amount: Int) -> String {
        guard amount > 0 else {
            return self
        }
        let indentAmount = String(repeating: String.tab, count: amount)
        return self.components(separatedBy: .newlines).map { indentAmount + $0 }.joined(separator: "\n")
    }

    /// Remove the last specified character from the string.
    /// - Parameter character: The character to remove from the end of the string.
    @inlinable
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
    @usableFromInline
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

    /// Split the string on the first delimiter string within a set.
    /// - Parameter strings: The strings to split on.
    /// - Returns: The 2 halves of the string around the delimter and the delimiter that this string was split
    /// on.
    @usableFromInline
    func split(on strings: Set<String>) -> ([String], String)? {
        let sortedStrings: [(String, String.Index)] = strings.compactMap {
            guard let index = self.startIndex(for: $0) else {
                return nil
            }
            return ($0, index)
        }
        guard let (str, index) = sortedStrings.min(by: { $0.1 < $1.1 }) else {
            return nil
        }
        let str1 = self[self.startIndex..<index]
        let str2 = self[self.index(index, offsetBy: str.count)...]
        return ([String(str1), String(str2)], str)
    }

    /// Split the string on the first word within a set.
    /// - Parameter strings: The words to split on.
    /// - Returns: The 2 halves of the string around the word and the word that this string was split on.
    @usableFromInline
    func split(words: Set<String>) -> ([String], String)? {
        let sortedStrings: [(String, String.Index)] = words.compactMap {
            guard let index = self.startIndex(word: $0) else {
                return nil
            }
            return ($0, index)
        }
        guard let (str, index) = sortedStrings.min(by: { $0.1 < $1.1 }) else {
            return nil
        }
        let str1 = self[self.startIndex..<index]
        let str2 = self[self.index(index, offsetBy: str.count)...]
        return ([String(str1), String(str2)], str)
    }

    /// Return the starting index of a substring value within self.
    /// - Parameter value: The substring to search for.
    /// - Returns: The first index within self that matches the substring.
    @usableFromInline
    func startIndex(for value: String) -> String.Index? {
        self[self.startIndex..<self.endIndex].startIndex(for: value)
    }

    /// Find the start index for a word.
    /// - Parameter word: The word to search for.
    /// - Returns: The index if the word was found.
    @usableFromInline
    func startIndex(word: String) -> String.Index? {
        self[self.startIndex..<self.endIndex].startIndex(word: word)
    }

    /// Find the indexes of all occurrences of a given sentence within the string.
    /// - Parameter words: The sentence to match against as an array of ordered words.
    /// - Returns: The indexes of all occurrences of the sentence within the string.
    @usableFromInline
    func indexes(for words: [String]) -> [(String.Index, String.Index)] {
        let wordPattern = words.map { $0.lowercased() }.joined(separator: "\\s+") // whitespace.
        guard
            !self.isEmpty,
            !words.isEmpty,
            let regex = try? Regex("(^|\\s)" + wordPattern + "($|\\s)") // start of line or whitespace.
        else {
            return []
        }
        let matches = self.lowercased().matches(of: regex)
        return matches.map { ($0.range.lowerBound, $0.range.upperBound) }
    }

    /// Find the substrings that start with a given sentence and end with a given sentence. This method also
    /// returns the subexpressions as well, matching starting sentences with ending sentences.
    /// - Parameters:
    ///   - startWords: The starting sentence.
    ///   - endWords: The ending sentence.
    /// - Returns: The substrings that start with `startWords` and end with `endWords`.
    @usableFromInline
    func subExpression(beginningWith startWords: [String], endingWith endWords: [String]) -> Substring? {
        let startIndexes = self.indexes(for: startWords)
        let endIndexes = self.indexes(for: endWords)
        let allIndexes = startIndexes.map { ($0.0, $0.1, startWords) } +
            endIndexes.map { ($0.0, $0.1, endWords) }
        let sortedIndexes = allIndexes.sorted { $0.0 < $1.0 }
        var tracker = 0
        var start: String.Index?
        var end: String.Index?
        for (i, j, w) in sortedIndexes {
            if w == startWords {
                if tracker == 0 {
                    start = i
                }
                tracker += 1
            } else {
                if tracker == 0 {
                    continue
                }
                tracker -= 1
                if tracker == 0 {
                    end = j
                    break
                }
            }
        }
        guard let start = start, let end = end else {
            return nil
        }
        return self[start..<end]
    }

    /// Find a string that starts with a specified string and ends with a specified string including
    /// substrings following the same pattern. For example, consider the string \"a(b(c)d)e\", starting with
    /// \"(\" and ending with \")\". The result would be \"(b(c)d)\".
    /// - Parameters:
    ///   - startsWith: The begining delimiter for the substring.
    ///   - endsWith: The ending delimiter for the substring.
    /// - Returns: The substring that starts with `startsWith` and ends with `endsWith` including any
    /// strings within that match the same pattern.
    @usableFromInline
    func upToBalancedElements(startsWith: String, endsWith: String) -> Substring? {
        self[self.startIndex..<self.endIndex].upToBalancedElements(startsWith: startsWith, endsWith: endsWith)
    }

    /// Helper function for removing the comments from a string.
    /// - Parameters:
    ///   - value: The string to remove the comments from.
    ///   - carry: An accumulator that holds the string without comments.
    /// - Returns: The string without comments.
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
