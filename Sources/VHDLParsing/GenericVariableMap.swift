// GenericVariableMap.swift
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

/// An operation that maps 2 generics together. This operation is used in generic maps for components.
public struct GenericVariableMap: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The left-hand side generic to map.
    public let lhs: VariableReference

    /// The right-hand side generic to map.
    public let rhs: Expression

    /// The equivalent `VHDL` code.
    @inlinable public var rawValue: String {
        "\(lhs.rawValue) => \(rhs.rawValue)"
    }

    /// Creates a new `GenericVariableMap` from the given `lhs` and `rhs`.
    /// - Parameters:
    ///   - lhs: The left-hand side generic to map.
    ///   - rhs: The right-hand side generic to map.
    @inlinable
    public init(lhs: VariableReference, rhs: Expression) {
        self.lhs = lhs
        self.rhs = rhs
    }

    /// Creates a new `GenericVariableMap` from the given `VHDL` code.
    /// - Parameter rawValue: The `VHDL` code to use to create the new `GenericVariableMap`.
    @inlinable
    public init?(rawValue: String) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count < 1024 else {
            return nil
        }
        let lhsEnd = trimmed.indexes(for: ["=>"])
        guard
            lhsEnd.count == 1,
            let operatorIndex = lhsEnd.first,
            operatorIndex.1 < trimmed.endIndex,
            let lhs = VariableReference(rawValue: String(trimmed[trimmed.startIndex..<operatorIndex.0])),
            let rhs = Expression(rawValue: String(trimmed[trimmed.index(after: operatorIndex.1)...]))
        else {
            return nil
        }
        self.init(lhs: lhs, rhs: rhs)
    }

}
