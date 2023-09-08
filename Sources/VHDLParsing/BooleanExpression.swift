// BooleanExpression.swift
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

/// A boolean expression containing common boolean operations.
/// 
/// This type represents an expression that can be represented as a single logic expression. For example,
/// `a and b` is a valid expression, but `a and b or c` is not since it contains two logic operations. On the
/// contrary, `a and (b or c)` is a valid expression since the expression is represented as an `and` operation
/// on two subexpressions (one of which is also a logical expression).
public enum BooleanExpression: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// An `and` operation.
    case and(lhs: Expression, rhs: Expression)

    /// An `or` operation.
    case or(lhs: Expression, rhs: Expression)

    /// A `nand` operation.
    case nand(lhs: Expression, rhs: Expression)

    /// A `not` operation.
    case not(value: Expression)

    /// A `nor` operation.
    case nor(lhs: Expression, rhs: Expression)

    /// An `xor` operation.
    case xor(lhs: Expression, rhs: Expression)

    /// An `xnor` operation.
    case xnor(lhs: Expression, rhs: Expression)

    /// The `VHDL` code representing this expression.
    @inlinable public var rawValue: String {
        switch self {
        case .and(let lhs, let rhs):
            return "\(lhs.rawValue) and \(rhs.rawValue)"
        case .or(let lhs, let rhs):
            return "\(lhs.rawValue) or \(rhs.rawValue)"
        case .nand(let lhs, let rhs):
            return "\(lhs.rawValue) nand \(rhs.rawValue)"
        case .not(let value):
            return "not \(value.rawValue)"
        case .nor(let lhs, let rhs):
            return "\(lhs.rawValue) nor \(rhs.rawValue)"
        case .xor(let lhs, let rhs):
            return "\(lhs.rawValue) xor \(rhs.rawValue)"
        case .xnor(let lhs, let rhs):
            return "\(lhs.rawValue) xnor \(rhs.rawValue)"
        }
    }

    /// Creates a new `BooleanExpression` from the given `VHDL` code.
    /// - Parameter rawValue: The `VHDL` code representing the boolean expression.
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count < 256 else {
            return nil
        }
        if trimmedString.hasPrefix("(") {
            self.init(brackets: trimmedString)
            return
        }
        if let notExpression = BooleanExpression(not: trimmedString) {
            self = notExpression
            return
        }
        guard
            let (values, operation) = String(trimmedString).split(
                words: .vhdlBooleanBinaryOperations
            ),
            values.count == 2
        else {
            return nil
        }
        let lhs = String(values[0])
        let rhs = String(values[1])
        guard let newValue = BooleanExpression(lhs: lhs, rhs: rhs, splittingOn: operation) else {
            return nil
        }
        self = newValue
    }

    /// Creates a new `BooleanExpression` expecting the code to be a `not` operation.
    /// - Parameter trimmedString: The code containing the `not` operation.
    private init?(not trimmedString: String) {
        guard trimmedString.firstWord?.lowercased() == "not" else {
            return nil
        }
        let value = trimmedString.dropFirst(3).trimmingCharacters(in: .whitespacesAndNewlines)
        guard let expression = Expression(rawValue: value) else {
            return nil
        }
        self = .not(value: expression)
        return
    }

    /// Creates a new `BooleanExpression` from the given code, expecting it to be a binary operation prefaced
    /// with an opening bracket.
    /// - Parameter value: The code to convert.
    private init?(brackets value: String) {
        guard let lhs = value.uptoBalancedBracket else {
            return nil
        }
        let remaining = value.dropFirst(lhs.count).trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !remaining.isEmpty,
            let firstWord = remaining.firstWord?.lowercased(),
            Set<String>.vhdlBooleanBinaryOperations.contains(firstWord)
        else {
            return nil
        }
        let rhs = remaining.dropFirst(firstWord.count).trimmingCharacters(in: .whitespacesAndNewlines)
        self.init(lhs: String(lhs), rhs: rhs, splittingOn: firstWord)
    }

    /// Creates a new `BooleanExpression` from the given code, expecting it to be a specific operation.
    /// - Parameters:
    ///   - lhs: The left hand expression.
    ///   - rhs: The right hand expression.
    ///   - value: The operation to perform.
    private init?(lhs: String, rhs: String, splittingOn value: String) {
        guard let lhsExp = Expression(rawValue: lhs), let rhsExp = Expression(rawValue: rhs) else {
            return nil
        }
        self.init(lhs: lhsExp, rhs: rhsExp, operation: value)
    }

    /// Creates a new `BooleanExpression` from the given code, expecting it to be a specific binary operation.
    /// - Parameters:
    ///   - lhs: The first operand located at the left of the operation.
    ///   - rhs: The second operand located at the right of the operation.
    ///   - operation: The operation to perform.
    @usableFromInline
    init?(lhs: Expression, rhs: Expression, operation: String) {
        switch operation.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "and":
            self = .and(lhs: lhs, rhs: rhs)
        case "or":
            self = .or(lhs: lhs, rhs: rhs)
        case "nand":
            self = .nand(lhs: lhs, rhs: rhs)
        case "nor":
            self = .nor(lhs: lhs, rhs: rhs)
        case "xor":
            self = .xor(lhs: lhs, rhs: rhs)
        case "xnor":
            self = .xnor(lhs: lhs, rhs: rhs)
        default:
            return nil
        }
    }

}
