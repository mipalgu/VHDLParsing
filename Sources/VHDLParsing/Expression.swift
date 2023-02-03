// Expression.swift
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

/// An `Expression` represents a stand-alone statement that resolves to some value in `VHDL`. Typical
/// expressions would include all operations after the `<=` symbol in a `VHDL` assignment operation. Some
/// examples include arithmetic operations (+, -, /, *), comparison operations (>, <, <=, >=, =, /=), bitwise
/// operations (sll, srl, sla, sra, rol, ror), and may include references to pre-defined variables or literal
/// values. This type should not be used to describe branch statements such as `if` or `case` statements, or
/// loops such as `for` and `while` loops. For those types of expressions, use ``Statement``.
/// - SeeAlso: ``Statement``.
indirect public enum Expression: RawRepresentable,
    Equatable, Hashable, Codable, Sendable, CustomStringConvertible {

    /// A reference to a variable.
    case variable(name: VariableName)

    /// A literal value.
    case literal(value: SignalLiteral)

    /// An arithmetic expression that uses two operands.
    case binary(operation: BinaryOperation)

    /// A precedence operation. This is equivalent to placing brackets around an Expression.
    case precedence(value: Expression)

    /// A conditional expression.
    case conditional(condition: ConditionalExpression)

    /// A boolean logic expression.
    case logical(operation: BooleanExpression)

    /// A type-cast operation.
    case cast(operation: CastOperation)

    case functionCall(call: FunctionCall)

    /// The raw value is a string.
    public typealias RawValue = String

    /// The equivalent VHDL code of this expression.
    @inlinable public var rawValue: String {
        switch self {
        case .variable(let name):
            return name.rawValue
        case .literal(let value):
            return value.rawValue
        case .binary(let operation):
            return operation.rawValue
        case .precedence(let value):
            return "(\(value.rawValue))"
        case .conditional(let condition):
            return condition.rawValue
        case .logical(let operation):
            return operation.rawValue
        case .cast(let operation):
            return operation.rawValue
        case .functionCall(let call):
            return call.rawValue
        }
    }

    /// The equivalent VHDL code of this expression.
    @inlinable public var description: String {
        rawValue
    }

    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity

    /// Create an `Expression` from valid VHDL code.
    /// - Parameter rawValue: The code to convert to this expression.
    @inlinable
    public init?(rawValue: String) {
        let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.count < 256 else {
            return nil
        }
        if let literal = SignalLiteral(rawValue: value) {
            self = .literal(value: literal)
            return
        }
        if let cast = CastOperation(rawValue: value) {
            self = .cast(operation: cast)
            return
        }
        if let call = FunctionCall(rawValue: value) {
            self = .functionCall(call: call)
            return
        }
        if
            value.hasPrefix("("),
            value.hasSuffix(")"),
            let bracketExp = value.uptoBalancedBracket,
            bracketExp.startIndex == value.startIndex,
            bracketExp.endIndex == value.endIndex {
            guard let expression = Expression(rawValue: String(value.dropFirst().dropLast())) else {
                return nil
            }
            self = .precedence(value: expression)
            return
        }
        if value.hasPrefix("(") {
            guard
                let subExpression = value.subExpressions?.first,
                let expression = Expression(rawValue: String(subExpression.dropFirst().dropLast())),
                let lastSubIndex = subExpression.indices.last
            else {
                return nil
            }
            let rhsStart = value.index(after: lastSubIndex)
            let rhs = value[rhsStart...]
            guard
                let (parts, str) = String(rhs).split(on: Set<String>.vhdlOperations),
                parts[0].trimmingCharacters(in: .whitespaces).isEmpty,
                let other = parts.last,
                let rhsExp = Expression(rawValue: other)
            else {
                return nil
            }
            let lhsExp = Expression.precedence(value: expression)
            if let comparison = ComparisonOperation(lhs: lhsExp, rhs: rhsExp, operation: str) {
                self = .conditional(condition: .comparison(value: comparison))
                return
            }
            if let binary = BinaryOperation(lhs: lhsExp, rhs: rhsExp, str: str) {
                self = .binary(operation: binary)
                return
            }
            if let logical = BooleanExpression(lhs: lhsExp, rhs: rhsExp, operation: str) {
                self = .logical(operation: logical)
                return
            }
            return nil
        }
        if let operation = BinaryOperation(rawValue: value) {
            self = .binary(operation: operation)
            return
        }
        if let conditional = ConditionalExpression(rawValue: value) {
            self = .conditional(condition: conditional)
            return
        }
        if let logical = BooleanExpression(rawValue: value) {
            self = .logical(operation: logical)
            return
        }
        if let variable = VariableName(rawValue: value) {
            self = .variable(name: variable)
            return
        }
        return nil
    }

    // swiftlint:enable function_body_length
    // swiftlint:enable cyclomatic_complexity

}
