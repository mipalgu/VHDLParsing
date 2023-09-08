// WhenStatement.swift
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

/// An expression using a `when` conditional.
/// 
/// This type represents asynchronous statements that are conditionally assigned under specific conditions.
/// A `WhenStatement` with condition `A` and value `B` is equivalent to the following VHDL:
/// ```VHDL
/// B when A
/// ```
/// It can be used in assignment operations thus: `C <= B when A;`.
/// - SeeAlso: ``Expression``.
public struct WhenStatement: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The condition that must evaluate to `true` for the value to be assigned.
    public let condition: Expression

    /// The value to assign when `condition` is `true`.
    public let value: Expression

    /// The equivalent `VHDL` code for this statement.
    @inlinable public var rawValue: String {
        "\(value.rawValue) when \(condition.rawValue)"
    }

    /// Create a new `WhenStatement` from a condition and a value.
    /// - Parameters:
    ///   - condition: The condition that must evaluate to `true` for the value to be assigned.
    ///   - value: The value to assign when `condition` is `true`.
    @inlinable
    public init(condition: Expression, value: Expression) {
        self.condition = condition
        self.value = value
    }

    /// Create a new `WhenStatement` from a `VHDL` code string.
    /// - Parameter rawValue: The `VHDL` code string to parse.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedString.isEmpty, trimmedString.count < 2048 else {
            return nil
        }
        guard
            let whenIndex = trimmedString.indexes(for: ["when"]).first,
            whenIndex.0 > trimmedString.startIndex,
            whenIndex.1 < trimmedString.endIndex
        else {
            return nil
        }
        let lhs = String(trimmedString[..<whenIndex.0])
        let rhs = String(trimmedString[whenIndex.1...])
        guard let value = Expression(rawValue: lhs), let condition = Expression(rawValue: rhs) else {
            return nil
        }
        self.init(condition: condition, value: value)
    }

}
