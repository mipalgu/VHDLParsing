// WhenCase.swift
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

/// A condition that can be used in a `when` statement.
public enum WhenCondition: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The `others` condition.
    case others

    /// An expression.
    case expression(expression: Expression)

    /// A selection of values.
    case selection(expressions: [Expression])

    /// A range of indices.
    case range(range: VectorSize)

    /// The `VHDL` code for this condition.
    @inlinable public var rawValue: String {
        switch self {
        case .others:
            return "others"
        case .expression(let expression):
            return expression.rawValue
        case .selection(let expressions):
            return expressions.map(\.rawValue).joined(separator: "|")
        case .range(let range):
            return range.rawValue
        }
    }

    /// Creates a new `WhenCondition` from the given `VHDL` code.
    /// - Parameter rawValue: The `VHDL` code for this condition.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.withoutComments.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count < 256 else {
            return nil
        }
        if trimmedString.count == 6, trimmedString.lowercased() == "others" {
            self = .others
            return
        }
        if let range = VectorSize(rawValue: trimmedString) {
            self = .range(range: range)
            return
        }
        if trimmedString.contains("|") {
            let components = trimmedString.components(separatedBy: "|")
            let expressions = components.compactMap { Expression(rawValue: $0) }
            guard components.count == expressions.count else {
                return nil
            }
            self = .selection(expressions: expressions)
            return
        }
        guard let expression = Expression(rawValue: trimmedString) else {
            return nil
        }
        self = .expression(expression: expression)
    }

}
