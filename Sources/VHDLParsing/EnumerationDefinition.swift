// EnumerationDefinition.swift
// VHDLParsing
// 
// Created by Morgan McColl.
// Copyright © 2024 Morgan McColl. All rights reserved.
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

import Foundation
import StringHelpers

/// A type defined as an enumeration of values.
/// 
/// This struct represents a new type definition in `VHDL` that is an enumeration of values. The equivalent
/// `VHDL` code of this definition is:
/// ```vhdl
/// type <name> is (<case0>, <case1>, <case2>, ...);
/// ```
/// The number of cases (`values`) within the definition is not limited, but there must be at least 1 case.
public struct EnumerationDefinition: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The name of the enumeration type.
    public let name: VariableName

    /// The valid values within the enumeration. This array will always contain at least 1 value.
    public let values: [VariableName]

    /// The equivalent `VHDL` code defining this enumeration.
    @inlinable public var rawValue: String {
        "type \(name.rawValue) is (\(values.map(\.rawValue).joined(separator: ", ")));"
    }

    /// Create an enumeration definition from it's stored properties.
    /// 
    /// This initialiser will check that the `nonEmptyValues` contains at least 1 value. If this is not the
    /// case, then the initialiser will return `nil`.
    /// - Parameters:
    ///   - name: The name of the enumeration.
    ///   - nonEmptyValues: The valid values within the enumeration.
    /// - Warning: The `nonEmptyValues` array must contain at least 1 value.
    @inlinable
    public init?(name: VariableName, nonEmptyValues: [VariableName]) {
        guard !nonEmptyValues.isEmpty else {
            return nil
        }
        self.init(name: name, values: nonEmptyValues)
    }

    /// Create an enumeration definition from it's `VHDL` code defining it.
    /// - Parameter rawValue: The `VHDL` code that defines a new type as an enumeration of values.
    @inlinable
    public init?(rawValue: String) {
        let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            trimmedValue.count <= 4096,
            trimmedValue.words.first?.lowercased() == "type",
            trimmedValue.hasSuffix(";")
        else {
            return nil
        }
        let withoutType = trimmedValue
            .dropLast(1).dropFirst(4).trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let rawName = withoutType.words.first,
            withoutType.hasSuffix(")"),
            let name = VariableName(rawValue: rawName)
        else {
            return nil
        }
        let withoutName = withoutType
            .dropLast().dropFirst(rawName.count).trimmingCharacters(in: .whitespacesAndNewlines)
        guard let rawIs = withoutName.words.first?.lowercased(), rawIs == "is" else {
            return nil
        }
        let withoutIs = withoutName.dropFirst(2).trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutIs.hasPrefix("(") else {
            return nil
        }
        let withoutBrackets = withoutIs.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !withoutBrackets.isEmpty else {
            return nil
        }
        let valuesRaw = withoutBrackets.components(separatedBy: ",")
        let values = valuesRaw.compactMap {
            VariableName(rawValue: $0.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        guard values.count == valuesRaw.count else {
            return nil
        }
        self.init(name: name, values: values)
    }

    /// Set the stored properties of the enumeration without checking for validity.
    /// - Parameters:
    ///   - name: The name of this enumeration.
    ///   - values: The valid values of this enumeration.
    @inlinable
    init(name: VariableName, values: [VariableName]) {
        self.name = name
        self.values = values
    }

}
