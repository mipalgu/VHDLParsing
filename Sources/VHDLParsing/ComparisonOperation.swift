// ComparisonOperation.swift
// Machines
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

/// A type for representing VHDL comparison operations. These operations exist within a
/// ``ConditionalExpression``. The supported operations are:
/// - Less than (operation <).
/// - Less than or equal to (operation <=).
/// - Greater than (operation >).
/// - Greater than or equal to (operation >=).
/// - Equality (operation =).
/// - Not equal to (operation /=).
public enum ComparisonOperation: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The `lessThan` operation (<).
    case lessThan(lhs: Expression, rhs: Expression)

    /// The `lessThanOrEqual` operation (<=).
    case lessThanOrEqual(lhs: Expression, rhs: Expression)

    /// The `greaterThan` operation (>).
    case greaterThan(lhs: Expression, rhs: Expression)

    /// The `greaterThanOrEqual` operation (>=).
    case greaterThanOrEqual(lhs: Expression, rhs: Expression)

    /// The `equality` operation (=).
    case equality(lhs: Expression, rhs: Expression)

    /// The `notEquals` operation (/=).
    case notEquals(lhs: Expression, rhs: Expression)

    /// The `VHDL` code equivalent to this operation.
    @inlinable public var rawValue: String {
        switch self {
        case .lessThan(let lhs, let rhs):
            return "\(lhs.rawValue) < \(rhs.rawValue)"
        case .lessThanOrEqual(let lhs, let rhs):
            return "\(lhs.rawValue) <= \(rhs.rawValue)"
        case .greaterThan(let lhs, let rhs):
            return "\(lhs.rawValue) > \(rhs.rawValue)"
        case .greaterThanOrEqual(let lhs, let rhs):
            return "\(lhs.rawValue) >= \(rhs.rawValue)"
        case .equality(let lhs, let rhs):
            return "\(lhs.rawValue) = \(rhs.rawValue)"
        case .notEquals(let lhs, let rhs):
            return "\(lhs.rawValue) /= \(rhs.rawValue)"
        }
    }

    /// Creates a new ``ComparisonOperation`` from the given `VHDL` code.
    /// - Parameter rawValue: The `VHDL` code that represents the operation.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count < 256 else {
            return nil
        }
        let value = trimmedString.uptoSemicolon
        guard
            let (operation, components) = ["<=", ">=", "/=", "<", ">", "="].lazy.compactMap(
                { (op: String) -> (String, [String])? in
                    let components = value.components(separatedBy: op).map {
                        $0.trimmingCharacters(in: .whitespaces)
                    }
                    guard components.count == 2 else {
                        return nil
                    }
                    return (op, components)
                }
            ).first,
            let lhs = Expression(rawValue: components[0]),
            let rhs = Expression(rawValue: components[1])
        else {
            return nil
        }
        self.init(lhs: lhs, rhs: rhs, operation: operation)
    }

    /// Initialise the `ComparisonOperation` from the expressions and a string that represents the operation
    /// that is being performed.
    /// - Parameters:
    ///   - lhs: The left-hand side expression.
    ///   - rhs: The right-hand side expression.
    ///   - operation: A string of a valid `VHDL` comparison operation.
    @usableFromInline
    init?(lhs: Expression, rhs: Expression, operation: String) {
        switch operation.trimmingCharacters(in: .whitespacesAndNewlines) {
        case "<":
            self = .lessThan(lhs: lhs, rhs: rhs)
        case "<=":
            self = .lessThanOrEqual(lhs: lhs, rhs: rhs)
        case ">":
            self = .greaterThan(lhs: lhs, rhs: rhs)
        case ">=":
            self = .greaterThanOrEqual(lhs: lhs, rhs: rhs)
        case "=":
            self = .equality(lhs: lhs, rhs: rhs)
        case "/=":
            self = .notEquals(lhs: lhs, rhs: rhs)
        default:
            return nil
        }
    }

    /// `Equatable` conformance.
    @inlinable
    public static func == (lhs: ComparisonOperation, rhs: ComparisonOperation) -> Bool {
        switch (lhs, rhs) {
        case (.lessThan(let lhsLhs, let lhsRhs), .lessThan(let rhsLhs, let rhsRhs)):
            return lhsLhs == rhsLhs && lhsRhs == rhsRhs
        case (.lessThanOrEqual(let lhsLhs, let lhsRhs), .lessThanOrEqual(let rhsLhs, let rhsRhs)):
            return lhsLhs == rhsLhs && lhsRhs == rhsRhs
        case (.greaterThan(let lhsLhs, let lhsRhs), .greaterThan(let rhsLhs, let rhsRhs)):
            return lhsLhs == rhsLhs && lhsRhs == rhsRhs
        case (.greaterThanOrEqual(let lhsLhs, let lhsRhs), .greaterThanOrEqual(let rhsLhs, let rhsRhs)):
            return lhsLhs == rhsLhs && lhsRhs == rhsRhs
        case (.equality(let lhsLhs, let lhsRhs), .equality(let rhsLhs, let rhsRhs)):
            return lhsLhs == rhsLhs && lhsRhs == rhsRhs
        case (.notEquals(let lhsLhs, let lhsRhs), .notEquals(let rhsLhs, let rhsRhs)):
            return lhsLhs == rhsLhs && lhsRhs == rhsRhs
        default:
            return false
        }
    }

}
