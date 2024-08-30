// ArrayDefinition.swift
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

/// Definition of a new array type.
public struct ArrayDefinition: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The name of the array type.
    public let name: VariableName

    /// The size of the array.
    public let size: [VectorSize]

    /// The type of the elements stored in the array.
    public let elementType: Type

    /// The equivalent `VHDL` code.
    @inlinable public var rawValue: String {
        let matrixSize = self.size.map { $0.rawValue }.joined(separator: ", ")
        return "type \(name.rawValue) is array (\(matrixSize)) of \(elementType.rawValue);"
    }

    /// Creates a new `ArrayDefinition` with the given name, size and element type.
    /// - Parameters:
    ///   - name: The name of the array type.
    ///   - size: The size of the array.
    ///   - elementType: The type of the elements stored in the array.
    @inlinable
    public init(name: VariableName, size: [VectorSize], elementType: Type) {
        self.name = name
        self.size = size
        self.elementType = elementType
    }

    /// Creates a new `ArrayDefinition` from the given `VHDL` code.
    /// - Parameter rawValue: The `VHDL` code to create the `ArrayDefinition` from.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespaces)
        guard trimmedString.hasSuffix(";"), trimmedString.firstWord?.lowercased() == "type" else {
            return nil
        }
        let withoutType = trimmedString.dropFirst(4)
            .dropLast()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let firstWord = withoutType.firstWord, let name = VariableName(rawValue: firstWord) else {
            return nil
        }
        let withoutName = withoutType.dropFirst(firstWord.count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutName.firstWord?.lowercased() == "is" else {
            return nil
        }
        let withoutIs = withoutName.dropFirst(2).trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutIs.firstWord?.lowercased() == "array" else {
            return nil
        }
        let withoutArray = withoutIs.dropFirst(5).trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            withoutArray.hasPrefix("("),
            let ranges = withoutArray.uptoBalancedBracket,
            ranges.endIndex < withoutArray.endIndex
        else {
            return nil
        }
        let rangesRaw = ranges.dropFirst().dropLast().components(separatedBy: ",")
        let size = rangesRaw.compactMap { VectorSize(rawValue: $0) }
        guard rangesRaw.count == size.count, !size.isEmpty else {
            return nil
        }
        let remaining = withoutArray[ranges.endIndex...].trimmingCharacters(in: .whitespacesAndNewlines)
        guard remaining.firstWord?.lowercased() == "of" else {
            return nil
        }
        let elementTypeRaw = remaining.dropFirst(2).trimmingCharacters(in: .whitespacesAndNewlines)
        guard let type = Type(rawValue: elementTypeRaw) else {
            return nil
        }
        self.init(name: name, size: size, elementType: type)
    }

}
