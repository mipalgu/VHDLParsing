// ForGenerate.swift
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
import StringHelpers

/// A generate expression utilising a `For` loop.
/// 
/// The for of this generate expression is:
/// ```VHDL
/// <label>: for <iterator> in <range> generate
///     <body>
/// end generate <label>;
/// ```
/// - SeeAlso: ``VariableName``, ``VectorSize``, ``AsynchronousBlock``.
public struct ForGenerate: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The label of the generate expression.
    public let label: VariableName

    /// The iterator in the for-loop of this generate expression.
    public let iterator: VariableName

    /// The range the iterator will iterate over.
    public let range: VectorSize

    /// The body of the for-loop.
    public let body: AsynchronousBlock

    /// The equivalent `VHDL` code enacting this generate statement.
    @inlinable public var rawValue: String {
        """
        \(label.rawValue): for \(iterator.rawValue) in \(range.rawValue) generate
        \(body.rawValue.indent(amount: 1))
        end generate \(label.rawValue);
        """
    }

    /// Creates a new generate expression utilising a `For` loop.
    /// - Parameters:
    ///   - label: The label of the generate block.
    ///   - iterator: The iterator in the for-loop.
    ///   - range: The range the iterator iterates over.
    ///   - body: The body of the for-loop.
    @inlinable
    public init(label: VariableName, iterator: VariableName, range: VectorSize, body: AsynchronousBlock) {
        self.label = label
        self.iterator = iterator
        self.range = range
        self.body = body
    }

    // swiftlint:disable function_body_length

    /// Creates a new generate expression utilising a `For` loop from it's `VHDL` representation.
    /// - Parameter rawValue: The `VHDL` code enacting this generate statement.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            trimmedString.count < 4096,
            trimmedString.last == ";",
            let splitOnColon = trimmedString.split(on: [":"])
        else {
            return nil
        }
        let firstWord = splitOnColon.0[0].trimmingCharacters(in: .whitespacesAndNewlines)
        guard let label = VariableName(rawValue: firstWord) else {
            return nil
        }
        let withoutSemicolon = String(splitOnColon.0[1].dropLast())
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            withoutSemicolon.firstWord?.lowercased() == "for",
            withoutSemicolon.lastWord?.lowercased() == firstWord.lowercased()
        else {
            return nil
        }
        let withoutFor = withoutSemicolon.dropFirst(3)
            .dropLast(firstWord.count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let generateEnd = withoutFor.lastWord,
            generateEnd.lowercased() == "generate",
            let iteratorWord = withoutFor.firstWord,
            let iterator = VariableName(rawValue: iteratorWord)
        else {
            return nil
        }
        let withoutIterator = withoutFor.dropFirst(iteratorWord.count)
            .dropLast(8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            withoutIterator.firstWord?.lowercased() == "in", withoutIterator.lastWord?.lowercased() == "end"
        else {
            return nil
        }
        let withoutIn = withoutIterator.dropFirst(2)
            .dropLast(3)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let generateIndex = withoutIn.startIndex(word: "generate", isCaseSensitive: false) else {
            return nil
        }
        let rangeExpression = withoutIn[..<generateIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        guard let range = VectorSize(rawValue: rangeExpression) else {
            return nil
        }
        let bodyRaw = withoutIn[generateIndex...].dropFirst(8).trimmingCharacters(in: .whitespacesAndNewlines)
        guard let body = AsynchronousBlock(rawValue: bodyRaw) else {
            return nil
        }
        self.init(label: label, iterator: iterator, range: range, body: body)
    }

    // swiftlint:enable function_body_length

}
