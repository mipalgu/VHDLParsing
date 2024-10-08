// BinaryOperation.swift
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

/// A type for representing arithmetic operations that work with two operands.
public enum BinaryOperation: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// An addition operation.
    case addition(lhs: Expression, rhs: Expression)

    /// A subtraction operation.
    case subtraction(lhs: Expression, rhs: Expression)

    /// A multiplication operation.
    case multiplication(lhs: Expression, rhs: Expression)

    /// A division operation.
    case division(lhs: Expression, rhs: Expression)

    /// A concatenation between `lhs` and `rhs`.
    case concatenate(lhs: Expression, rhs: Expression)

    /// The left-hand side operand in this binary operation.
    @inlinable public var lhs: Expression {
        switch self {
        case .addition(let lhs, _), .subtraction(let lhs, _), .division(let lhs, _),
            .multiplication(let lhs, _), .concatenate(let lhs, _):
            return lhs
        }
    }

    /// The `VHDL` code representing this operation.
    @inlinable public var rawValue: String {
        switch self {
        case .addition(let lhs, let rhs):
            return "\(lhs.rawValue) + \(rhs.rawValue)"
        case .subtraction(let lhs, let rhs):
            return "\(lhs.rawValue) - \(rhs.rawValue)"
        case .multiplication(let lhs, let rhs):
            return "\(lhs.rawValue) * \(rhs.rawValue)"
        case .division(let lhs, let rhs):
            return "\(lhs.rawValue) / \(rhs.rawValue)"
        case .concatenate(let lhs, let rhs):
            return "\(lhs.rawValue) & \(rhs.rawValue)"
        }
    }

    /// The right-hand side operand in this binary operation.
    @inlinable public var rhs: Expression {
        switch self {
        case .addition(_, let rhs), .subtraction(_, let rhs), .division(_, let rhs),
            .multiplication(_, let rhs), .concatenate(_, let rhs):
            return rhs
        }
    }

    /// Initialise the `BinaryOperation` from it's `VHDL` code representation.
    /// - Parameter rawValue: The `VHDL` performing this operation.
    public init?(rawValue: String) {
        let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.count < 256 else {
            return nil
        }
        guard CharacterSet.vhdlOperations.within(string: value) else {
            return nil
        }
        if let multiplicative = BinaryOperation(value: value, characters: .vhdlMultiplicativeOperations) {
            self = multiplicative
            return
        }
        if let additive = BinaryOperation(value: value, characters: .vhdlAdditiveOperations) {
            self = additive
            return
        }
        return nil
    }

    /// Create a binary `Expression` from a string and a set of possible operations.
    /// - Parameters:
    ///   - value: The string containing a binary operation.
    ///   - characters: The valid characters representing the operator of this operation.
    private init?(value: String, characters: CharacterSet) {
        guard
            let (parts, char) = value.split(on: characters),
            let lhs = parts.first,
            let rhs = parts.last,
            let lhsExp = Expression(rawValue: lhs),
            let rhsExp = Expression(rawValue: rhs)
        else {
            return nil
        }
        self.init(lhs: lhsExp, rhs: rhsExp, str: String(char))
    }

    /// Create a binary `Expression` from a left and right hand side and an operator.
    /// - Parameters:
    ///   - lhs: The left-hand side expression.
    ///   - rhs: The right-hand side expression.
    ///   - char: The operator betweent the lhs and rhs.
    @inlinable
    init?(lhs: Expression, rhs: Expression, str: String) {
        switch str.trimmingCharacters(in: .whitespaces) {
        case "-":
            self = .subtraction(lhs: lhs, rhs: rhs)
        case "+":
            self = .addition(lhs: lhs, rhs: rhs)
        case "&":
            self = .concatenate(lhs: lhs, rhs: rhs)
        case "*":
            self = .multiplication(lhs: lhs, rhs: rhs)
        case "/":
            self = .division(lhs: lhs, rhs: rhs)
        default:
            return nil
        }
    }

}
