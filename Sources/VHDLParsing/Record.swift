// Record.swift
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

/// A record type definition.
public struct Record: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The name of the record.
    public let name: VariableName

    /// The variables within the record.
    public let types: [RecordTypeDeclaration]

    /// The equivalent `VHDL` for this record.
    @inlinable public var rawValue: String {
        """
        type \(self.name.rawValue) is record
        \(self.types.map { $0.rawValue }.joined(separator: "\n").indent(amount: 1))
        end record \(self.name.rawValue);
        """
    }

    /// Creates a new record with the given name and types.
    /// - Parameters:
    ///   - name: The name of the record.
    ///   - types: The types within the record.
    @inlinable
    public init(name: VariableName, types: [RecordTypeDeclaration]) {
        self.name = name
        self.types = types
    }

    /// Creates a new record type from the given `VHDL` if possible.
    /// - Parameter rawValue: The `VHDL` to create the record from.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let words = trimmedString.words
        guard
            trimmedString.hasSuffix(";"),
            words.count >= 4,
            words[0].lowercased() == "type",
            words[2].lowercased() == "is",
            words[3].lowercased() == "record",
            let name = VariableName(rawValue: words[1])
        else {
            return nil
        }
        let withoutSemicolon = trimmedString.dropLast().trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutSemicolon.lastWord?.lowercased() == words[1].lowercased() else {
            return nil
        }
        let withoutName = withoutSemicolon.dropLast(words[1].count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutName.lastWord?.lowercased() == "record" else {
            return nil
        }
        let withoutRecord = withoutName.dropLast(6).trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutRecord.lastWord?.lowercased() == "end" else {
            return nil
        }
        let withoutEnd = withoutRecord.dropLast(3).trimmingCharacters(in: .whitespacesAndNewlines)
        let indexes = withoutEnd.indexes(for: ["record"])
        guard
            indexes.count >= 1, let recordEndIndex = indexes.first?.1, recordEndIndex < withoutEnd.endIndex
        else {
            return nil
        }
        let typesRaw = withoutEnd[recordEndIndex...].trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: ";")
        guard let last = typesRaw.last?.trimmingCharacters(in: .whitespacesAndNewlines), last.isEmpty else {
            return nil
        }
        let types = typesRaw.dropLast().compactMap { RecordTypeDeclaration(rawValue: $0 + ";") }
        guard typesRaw.count - 1 == types.count else {
            return nil
        }
        self.init(name: name, types: types)
    }

}
