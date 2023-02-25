// Package.swift
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

/// A struct representing a package definition in `VHDL`. This struct does not represent the body definition,
/// i.e. using `package body <name> is` in `VHDL`.
public struct VHDLPackage: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The name of the package.
    public let name: VariableName

    /// The statements in the package.
    public let statements: [HeadStatement]

    /// The equivalent `VHDL` code.
    @inlinable public var rawValue: String {
        """
        package \(name.rawValue) is
        \(statements.map { $0.rawValue }.joined(separator: "\n").indent(amount: 1))
        end package \(name.rawValue);
        """
    }

    /// Creates a new `VHDLPackage` with the given name and statements.
    /// - Parameters:
    ///   - name: The name of the package.
    ///   - statements: The statements in the package.
    @inlinable
    public init(name: VariableName, statements: [HeadStatement]) {
        self.name = name
        self.statements = statements
    }

    /// Creates a new `VHDLPackage` from the raw `VHDL` code.
    /// - Parameter rawValue: The raw `VHDL` code.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.hasSuffix(";") else {
            return nil
        }
        let data = trimmedString.dropLast().trimmingCharacters(in: .whitespacesAndNewlines)
        let words = data.words
        guard
            words.count >= 3,
            words[0].lowercased() == "package",
            words[2].lowercased() == "is",
            let name = VariableName(rawValue: words[1]),
            let isEndIndex = data.indexes(for: ["is"]).first?.1
        else {
            return nil
        }
        let remaining = data[isEndIndex...].trimmingCharacters(in: .whitespacesAndNewlines)
        guard remaining.lastWord?.lowercased() == words[1].lowercased() else {
            return nil
        }
        let withoutName = remaining.dropLast(words[1].count).trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutName.lastWord?.lowercased() == "package" else {
            return nil
        }
        let withoutPackage = withoutName.dropLast("package".count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutPackage.lastWord?.lowercased() == "end" else {
            return nil
        }
        let withoutEnd = withoutPackage.dropLast("end".count).trimmingCharacters(in: .whitespacesAndNewlines)
        self.init(name: name, data: withoutEnd)
    }

    /// Creates a new `VHDLPackage` with the given name, data yet to be parsed, and an accumulator of data
    /// that has already been parsed.
    /// - Parameters:
    ///   - name: The name of the package.
    ///   - data: The data yet to be parsed.
    ///   - carry: The accumulator of data that has already been parsed.
    @usableFromInline
    init?(name: VariableName, data: String, carry: [HeadStatement] = []) {
        let firstWord = data.firstWord?.lowercased()
        switch firstWord {
        case "type":
            let words = data.words
            if words.count >= 4, words[3].lowercased() != "record" {
                self.init(name: name, line: data, carry: carry)
            } else {
                self.init(name: name, block: data, carry: carry)
            }
        default:
            self.init(name: name, line: data, carry: carry)
        }
    }

    /// Creates a new `VHDLPackage` with the given name, data yet to be parsed, and an accumulator of data
    /// that has already been parsed. This initialiser assumes that the data is in the form of a block, i.e.
    /// the data contains subexpressions that also contain semicolons at the end.
    /// - Parameters:
    ///   - name: The name of the package.
    ///   - data: The data yet to be parsed.
    ///   - carry: The accumulator of data that has already been parsed.
    @usableFromInline
    init?(name: VariableName, block data: String, carry: [HeadStatement] = []) {
        let words = data.words
        guard words.count >= 2 else {
            return nil
        }
        let typeName = words[1]
        let blockWords = ["record"]
        let indexes = blockWords.compactMap {
            data.indexes(for: ["end", $0, typeName + ";"]).first?.1
        }
        guard let endIndex = indexes.min() else {
            return nil
        }
        guard let statement = HeadStatement(rawValue: String(data[..<endIndex])) else {
            return nil
        }
        guard data.endIndex > endIndex else {
            self.init(name: name, statements: carry + [statement])
            return
        }
        let remaining = data[endIndex...].trimmingCharacters(in: .whitespacesAndNewlines)
        guard !remaining.isEmpty else {
            self.init(name: name, statements: carry + [statement])
            return
        }
        self.init(name: name, data: remaining, carry: carry + [statement])
    }

    /// Creates a new `VHDLPackage` with the given name, data yet to be parsed, and an accumulator of data
    /// that has already been parsed. This initialiser assumes that the data is in the form of a line, i.e.
    /// the data does not contain subexpressions. this initialiser assumes the a single semicolon terminates
    /// the first statement.
    /// - Parameters:
    ///   - name: The name of the package.
    ///   - data: The data yet to be parsed.
    ///   - carry: The accumulator of data that has already been parsed.
    @usableFromInline
    init?(name: VariableName, line data: String, carry: [HeadStatement] = []) {
        if data.hasPrefix("--") {
            guard let newLineIndex = data.firstIndex(of: "\n") else {
                guard let statement = HeadStatement(rawValue: data) else {
                    return nil
                }
                self.init(name: name, statements: carry + [statement])
                return
            }
            let endIndex = data.index(after: newLineIndex)
            guard let statement = HeadStatement(rawValue: String(data[..<newLineIndex])) else {
                return nil
            }
            let remaining = data[endIndex...].trimmingCharacters(in: .whitespacesAndNewlines)
            self.init(name: name, data: remaining, carry: carry + [statement])
            return
        }
        let raw = data.uptoSemicolon
        guard let statement = HeadStatement(rawValue: raw + ";") else {
            return nil
        }
        guard let nextIndex = data.index(
            data.startIndex, offsetBy: raw.count + 2, limitedBy: data.endIndex
        ) else {
            self.init(name: name, statements: carry + [statement])
            return
        }
        let remaining = data[nextIndex...].trimmingCharacters(in: .whitespacesAndNewlines)
        guard !remaining.isEmpty else {
            self.init(name: name, statements: carry + [statement])
            return
        }
        self.init(name: name, data: remaining, carry: carry + [statement])
    }

}
