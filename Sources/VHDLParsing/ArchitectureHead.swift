// ArchitectureHead.swift
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

/// A type representing the statements in the architectures head.
public struct ArchitectureHead: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The statements in the architecture that define the signals and variables.
    public let statements: [HeadStatement]

    /// The `VHDL` of the architecture head.
    @inlinable public var rawValue: String {
        self.statements.map { $0.rawValue }.joined(separator: "\n")
    }

    /// Creates a new `ArchitectureHead` with the given statements.
    /// - Parameter statements: The statements in the architecture that define the signals and variables.
    @inlinable
    public init(statements: [HeadStatement]) {
        self.statements = statements
    }

    /// Creates a new `ArchitectureHead` from it's `VHDL` representation.
    /// - Parameter rawValue: The `VHDL` code defining the architecture head. This code should simply be lines
    /// of signal definitions. The architecture keyword should not be present.
    @inlinable
    public init?(rawValue: String) {
        self.init(remaining: rawValue)
    }

    /// Creates a new `ArchitectureHead` from a partially parsed `VHDL` definition.
    /// - Parameters:
    ///   - carry: The parsed code in the architecture head.
    ///   - remaining: The remaining code to be parsed.
    @usableFromInline
    init?(carry: [HeadStatement] = [], remaining: String) {
        let trimmed = remaining.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("--") {
            self.init(carry: carry, comment: trimmed)
            return
        }
        let firstWord = trimmed.firstWord?.lowercased()
        if firstWord == "component" {
            self.init(carry: carry, component: trimmed)
            return
        }
        if firstWord == "type" {
            self.init(carry: carry, type: trimmed)
            return
        }
        let line = trimmed.uptoSemicolon
        guard let definition = Definition(rawValue: line + ";") else {
            return nil
        }
        let remaining = trimmed.dropFirst(line.count + 1).trimmingCharacters(in: .whitespacesAndNewlines)
        guard remaining.isEmpty else {
            self.init(carry: carry + [.definition(value: definition)], remaining: remaining)
            return
        }
        self.init(statements: carry + [.definition(value: definition)])
    }

    /// Creates a new `ArchitectureHead` from a partially parsed `VHDL` definition expecting the remaining
    /// string to start with a comment.
    /// - Parameters:
    ///   - carry: The parsed code in the architecture head.
    ///   - trimmed: The remaining code to be parsed. This code is assumed to contain a comment at the start.
    @usableFromInline
    init?(carry: [HeadStatement] = [], comment trimmed: String) {
        guard trimmed.hasPrefix("--") else {
            return nil
        }
        guard
            let newLineIndex = trimmed.firstIndex(where: {
                guard let unicode = $0.unicodeScalars.first else {
                    return false
                }
                return CharacterSet.newlines.contains(unicode)
            })
        else {
            guard let comment = Comment(rawValue: trimmed) else {
                return nil
            }
            self.init(statements: carry + [.comment(value: comment)])
            return
        }
        guard let comment = Comment(rawValue: String(trimmed[..<newLineIndex])) else {
            return nil
        }
        self.init(carry: carry + [.comment(value: comment)], remaining: String(trimmed[newLineIndex...]))
        return
    }

    /// Creates a new `ArchitectureHead` from a partially parsed `VHDL` definition expecting the remaining
    /// string to start with a component definition.
    /// - Parameters:
    ///   - carry: The parsed code in the architecture head.
    ///   - trimmed: The remaining code to be parsed. This code is assumed to contain a component definition
    /// at the start.
    @usableFromInline
    init?(carry: [HeadStatement] = [], component trimmed: String) {
        guard
            trimmed.firstWord?.lowercased() == "component",
            let componentString = trimmed.subExpression(
                beginningWith: ["component"],
                endingWith: ["end", "component;"]
            ),
            let component = ComponentDefinition(rawValue: String(componentString))
        else {
            return nil
        }
        guard componentString.endIndex == trimmed.endIndex else {
            self.init(
                carry: carry + [.definition(value: .component(value: component))],
                remaining: String(trimmed[componentString.endIndex...])
            )
            return
        }
        self.init(statements: carry + [.definition(value: .component(value: component))])
        return
    }

    /// Creates a new `ArchitectureHead` from a partially parsed `VHDL` definition expecting the remaining
    /// string to start with a type definition.
    /// - Parameters:
    ///   - carry: The parsed code in the architecture head.
    ///   - trimmed: The remaining code to be parsed. This code is assumed to contain a type definition.
    @usableFromInline
    init?(carry: [HeadStatement] = [], type trimmed: String) {
        guard trimmed.firstWord?.lowercased() == "type" else {
            return nil
        }
        let words = trimmed.words
        guard words.count >= 4 else {
            return nil
        }
        if words[3].lowercased() == "record" {
            self.init(carry: carry, record: trimmed)
            return
        }
        guard
            let semicolonIndex = trimmed.firstIndex(of: ";"),
            let type = TypeDefinition(rawValue: String(trimmed[...semicolonIndex]))
        else {
            return nil
        }
        let nextIndex = trimmed.index(after: semicolonIndex)
        guard nextIndex != trimmed.endIndex else {
            self.init(statements: carry + [.definition(value: .type(value: type))])
            return
        }
        self.init(
            carry: carry + [.definition(value: .type(value: type))],
            remaining: String(trimmed[nextIndex...])
        )
    }

    /// Creates a new `ArchitectureHead` from a partially parsed `VHDL` definition expecting the remaining
    /// string to start with a record type definition.
    /// - Parameters:
    ///   - carry: The parsed code in the architecture head.
    ///   - trimmed: The remaining code to be parsed. This code is assumed to contain a record type
    /// definition.
    @usableFromInline
    init?(carry: [HeadStatement] = [], record trimmed: String) {
        let words = trimmed.words
        guard
            words.count >= 4,
            words[0].lowercased() == "type",
            words[2].lowercased() == "is",
            words[3].lowercased() == "record",
            let endEndIndex = trimmed.indexes(for: ["end", "record"]).first?.1,
            endEndIndex < trimmed.endIndex,
            let semicolonIndex = trimmed[endEndIndex...].firstIndex(of: ";"),
            let record = Record(rawValue: String(trimmed[...semicolonIndex]))
        else {
            return nil
        }
        let nextIndex = trimmed.index(after: semicolonIndex)
        guard nextIndex != trimmed.endIndex else {
            self.init(statements: carry + [.definition(value: .type(value: .record(value: record)))])
            return
        }
        self.init(
            carry: carry + [.definition(value: .type(value: .record(value: record)))],
            remaining: String(trimmed[nextIndex...])
        )
    }

}
