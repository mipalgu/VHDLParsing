// CastOperation.swift
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

/// A cast operation converting an expression to a specific ``SignalType``.
public enum CastOperation: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// Convert to a `bit`.
    case bit(expression: Expression)

    /// Convert to a `bit_vector`.
    case bitVector(expression: Expression)

    /// Convert to a `boolean`.
    case boolean(expression: Expression)

    /// Convert to an `integer`.
    case integer(expression: Expression)

    /// Convert to a `natural`.
    case natural(expression: Expression)

    /// Convert to a `positive`.
    case positive(expression: Expression)

    /// Convert to a `real`.
    case real(expression: Expression)

    /// Convert to a `signed`.
    case signed(expression: Expression)

    /// Convert to a `std_logic`.
    case stdLogic(expression: Expression)

    /// Convert to a `std_logic_vector`.
    case stdLogicVector(expression: Expression)

    /// Convert to a `std_ulogic`.
    case stdULogic(expression: Expression)

    /// Convert to a `std_ulogic_vector`.
    case stdULogicVector(expression: Expression)

    /// Convert to an `unsigned`.
    case unsigned(expression: Expression)

    /// The `VHDL` code performing the cast operation.
    @inlinable public var rawValue: String {
        switch self {
        case .bit(let expression):
            return "bit(\(expression.rawValue))"
        case .bitVector(let expression):
            return "bit_vector(\(expression.rawValue))"
        case .boolean(let expression):
            return "boolean(\(expression.rawValue))"
        case .integer(let expression):
            return "integer(\(expression.rawValue))"
        case .natural(let expression):
            return "natural(\(expression.rawValue))"
        case .positive(let expression):
            return "positive(\(expression.rawValue))"
        case .real(let expression):
            return "real(\(expression.rawValue))"
        case .signed(let expression):
            return "signed(\(expression.rawValue))"
        case .stdLogic(let expression):
            return "std_logic(\(expression.rawValue))"
        case .stdLogicVector(let expression):
            return "std_logic_vector(\(expression.rawValue))"
        case .stdULogic(let expression):
            return "std_ulogic(\(expression.rawValue))"
        case .stdULogicVector(let expression):
            return "std_ulogic_vector(\(expression.rawValue))"
        case .unsigned(let expression):
            return "unsigned(\(expression.rawValue))"
        }
    }

    /// Creates a new ``CastOperation`` from a `String` representing the `VHDL` code performing the cast
    /// operation.
    /// - Parameter rawValue: The `VHDL` code performing the cast operation.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            trimmedString.count < 256,
            !trimmedString.isEmpty,
            let firstWord = trimmedString.firstWord?.lowercased()
        else {
            return nil
        }
        guard Set<String>.vhdlSignalTypes.contains(firstWord) else {
            return nil
        }
        let expressionString = trimmedString.dropFirst(firstWord.count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let rawString = expressionString.uptoBalancedBracket,
            rawString.endIndex == expressionString.endIndex,
            rawString.hasPrefix("("),
            rawString.hasSuffix(")"),
            let expression = Expression(rawValue: String(rawString.dropFirst().dropLast()))
        else {
            return nil
        }
        self.init(type: firstWord, expression: expression)
    }

    /// Creates a new ``CastOperation`` from the type casting to (as a string) and the expression that is to
    /// be casted.
    /// - Parameters:
    ///   - type: The type of the cast operation. This type must not contain any whitespace or newlines.
    ///   - expression: The expression to cast to the new type.
    @usableFromInline
    init?(type: String, expression: Expression) {
        guard let maxSize = Set<String>.vhdlSignalTypes.map(\.count).max(), type.count <= maxSize else {
            return nil
        }
        switch type.lowercased() {
        case "bit":
            self = .bit(expression: expression)
        case "bit_vector":
            self = .bitVector(expression: expression)
        case "boolean":
            self = .boolean(expression: expression)
        case "integer":
            self = .integer(expression: expression)
        case "natural":
            self = .natural(expression: expression)
        case "positive":
            self = .positive(expression: expression)
        case "real":
            self = .real(expression: expression)
        case "signed":
            self = .signed(expression: expression)
        case "std_logic":
            self = .stdLogic(expression: expression)
        case "std_logic_vector":
            self = .stdLogicVector(expression: expression)
        case "std_ulogic":
            self = .stdULogic(expression: expression)
        case "std_ulogic_vector":
            self = .stdULogicVector(expression: expression)
        case "unsigned":
            self = .unsigned(expression: expression)
        default:
            return nil
        }
    }

}
