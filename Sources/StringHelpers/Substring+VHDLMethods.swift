// Substring+VHDLMethods.swift
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

import Foundation

/// Add `startIndex`.
extension Substring {

    /// Return whether this substring represents a word in the base string. This property will check the
    /// characters around the substring for whitespaces.
    @usableFromInline var isWord: Bool {
        !self.isEmpty && !self.unicodeScalars.allSatisfy { CharacterSet.whitespacesAndNewlines.contains($0) }
            && (self.endIndex == self.base.endIndex
                || CharacterSet.whitespacesAndNewlines.contains(
                    self.base.unicodeScalars[self.endIndex]
                ))
            && (self.startIndex == self.base.startIndex
                || CharacterSet.whitespacesAndNewlines.contains(
                    self.base.unicodeScalars[self.base.index(before: self.startIndex)]
                ))
    }

    /// Return a string that exists within self that starts with an open bracket and ends with the balanced
    /// closing bracket.
    @inlinable public var uptoBalancedBracket: Substring? {
        self.upToBalancedElements(startsWith: "(", endsWith: ")")
    }

    /// Return the starting index of a substring value within self.
    /// - Parameter value: The substring to search for.
    /// - Returns: The first index within self that matches the substring.
    @inlinable
    public func startIndex(for value: String) -> String.Index? {
        let size = value.count
        guard !value.isEmpty, self.count >= size else {
            return nil
        }
        let offset = size - 1
        let startIndex = self.index(self.startIndex, offsetBy: offset)
        for i in self[startIndex...].indices {
            guard
                let wordStart = self.index(i, offsetBy: -offset, limitedBy: self.startIndex),
                self[wordStart...i].lowercased() == value.lowercased()
            else {
                continue
            }
            return wordStart
        }
        return nil
    }

    /// Find the start index for a word.
    /// - Parameter word: The word to search for.
    /// - Returns: The index if the word was found.
    @inlinable
    public func startIndex(word: String) -> String.Index? {
        guard !word.isEmpty, !self.isEmpty else {
            return nil
        }
        var index = self.startIndex
        while index < self.endIndex {
            guard let startIndex = self[index...].startIndex(for: word) else {
                return nil
            }
            guard let previousIndex = self.index(startIndex, offsetBy: -1, limitedBy: self.startIndex) else {
                guard
                    let endIndex = self.index(
                        startIndex,
                        offsetBy: word.count,
                        limitedBy: self.index(before: self.endIndex)
                    )
                else {
                    return startIndex
                }
                guard CharacterSet.whitespacesAndNewlines.contains(self.unicodeScalars[endIndex]) else {
                    index = self.index(startIndex, offsetBy: word.count)
                    continue
                }
                return startIndex
            }
            guard
                let endIndex = self.index(
                    startIndex,
                    offsetBy: word.count,
                    limitedBy: self.index(before: self.endIndex)
                )
            else {
                guard CharacterSet.whitespacesAndNewlines.contains(self.unicodeScalars[previousIndex]) else {
                    index = self.index(startIndex, offsetBy: word.count)
                    continue
                }
                return startIndex
            }
            guard
                CharacterSet.whitespacesAndNewlines.contains(self.unicodeScalars[previousIndex]),
                CharacterSet.whitespacesAndNewlines.contains(self.unicodeScalars[endIndex])
            else {
                index = self.index(startIndex, offsetBy: word.count)
                continue
            }
            return startIndex
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
    @usableFromInline
    func upToBalancedElements(startsWith: String, endsWith: String) -> Substring? {
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
            return self[beginIndex..<lastIndex]
        }
        return nil
    }

}
