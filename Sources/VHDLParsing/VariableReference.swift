// VariableReference.swift
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

/// A type for defining types of references to a variable.
public enum VariableReference: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// Referencing a variable directly.
    case variable(reference: DirectReference)

    /// Indexing a variable.
    case indexed(name: Expression, index: VectorIndex)

    /// The equivalent `VHDL` code.
    @inlinable public var rawValue: String {
        switch self {
        case .variable(let name):
            return name.rawValue
        case .indexed(let name, let index):
            return "\(name.rawValue)(\(index.rawValue))"
        }
    }

    /// Creates a new instance by parsing the given `VHDL` code.
    /// - Parameter rawValue: The `VHDL` code to parse.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count < 256 else {
            return nil
        }
        if let reference = DirectReference(rawValue: trimmedString) {
            self = .variable(reference: reference)
            return
        }
        guard let bracketIndex = trimmedString.firstIndex(of: "(") else {
            return nil
        }
        guard
            let name = Expression(rawValue: String(trimmedString[trimmedString.startIndex..<bracketIndex])),
            let bracketRemaining = trimmedString[bracketIndex...].uptoBalancedBracket,
            bracketRemaining.hasPrefix("("),
            bracketRemaining.hasSuffix(")"),
            bracketRemaining.endIndex == trimmedString.endIndex,
            let index = VectorIndex(rawValue: String(bracketRemaining.dropFirst().dropLast()))
        else {
            return nil
        }
        self = .indexed(name: name, index: index)
    }

    /// Create and indexed variable reference to a variable.
    /// - Parameters:
    ///   - name: The name of the variable.
    ///   - index: The index in the variable
    /// - Returns: The indexed variable reference.
    @inlinable
    @available(*, deprecated)
    public static func indexed(name: VariableName, index: VectorIndex) -> VariableReference {
        .indexed(name: .reference(variable: .variable(reference: .variable(name: name))), index: index)
    }

}
