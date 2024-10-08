// SignalValue.swift
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

/// A type for representing all signal literals.
public enum SignalLiteral: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// A literal for single bit; either `high` or `low`.
    case bit(value: BitLiteral)

    /// A boolean literal.
    case boolean(value: Bool)

    /// A decimal literal.
    case decimal(value: Double)

    /// An integer literal.
    case integer(value: Int)

    /// A single-bit logic literal.
    case logic(value: LogicLiteral)

    /// A vector of logic literals.
    case vector(value: VectorLiteral)

    /// The raw value of the signal literal is a string.
    public typealias RawValue = String

    /// The VHDL equivalent code.
    @inlinable public var rawValue: String {
        switch self {
        case .bit(let value):
            return value.rawValue
        case .boolean(let value):
            return value ? "true" : "false"
        case .decimal(let value):
            return "\(value)"
        case .logic(let value):
            return value.rawValue
        case .vector(let value):
            return value.rawValue
        case .integer(let value):
            return "\(value)"
        }
    }

    /// Creates a signal literal from a VHDL representation.
    /// - Parameter rawValue: The VHDL code equivalent to this literal.
    @inlinable
    public init?(rawValue: String) {
        let trimmedCharacters = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedCharacters.count < 2048 else {
            return nil
        }
        let value = trimmedCharacters.lowercased()
        if value == "true" {
            self = .boolean(value: true)
            return
        }
        if value == "false" {
            self = .boolean(value: false)
            return
        }
        if let val = Int(value) {
            self = .integer(value: val)
            return
        }
        if value.contains("."), let val = Double(value) {
            self = .decimal(value: val)
            return
        }
        if let val = BitLiteral(rawValue: value) {
            self = .bit(value: val)
            return
        }
        if let val = LogicLiteral(rawValue: value) {
            self = .logic(value: val)
            return
        }
        if let val = VectorLiteral(rawValue: value) {
            self = .vector(value: val)
            return
        }
        return nil
    }

    /// Creates the default signal literal for a given signal type.
    /// - Parameter type: The type to create the literal for.
    /// - Returns: The default literal for the given type.
    @inlinable
    public static func `default`(for type: SignalType) -> SignalLiteral {
        switch type {
        case .bit:
            return .bit(value: .low)
        case .boolean:
            return .boolean(value: false)
        case .real:
            return .decimal(value: 0.0)
        case .integer, .natural:
            return .integer(value: 0)
        case .positive:
            return .integer(value: 1)
        case .stdLogic, .stdULogic:
            return .logic(value: .low)
        case .ranged(let type):
            switch type {
            case .integer(let size):
                guard
                    case .literal(let maxLiteral) = size.max,
                    case .integer(let maxValue) = maxLiteral,
                    case .literal(let minLiteral) = size.min,
                    case .integer(let minValue) = minLiteral,
                    maxValue >= minValue,
                    minValue > 0 || maxValue < 0
                else {
                    return .integer(value: 0)
                }
                return .integer(value: minValue)
            case .bitVector, .signed, .unsigned, .stdLogicVector, .stdULogicVector:
                return .vector(
                    value: .indexed(
                        values: IndexedVector(
                            values: [IndexedValue(index: .others, value: .bit(value: .low))]
                        )
                    )
                )
            }
        }
    }

    /// Equality operation.
    @inlinable
    public static func == (lhs: SignalLiteral, rhs: SignalLiteral) -> Bool {
        switch (lhs, rhs) {
        case (.bit(let lhs), .bit(let rhs)):
            return lhs == rhs
        case (.boolean(let lhs), .boolean(let rhs)):
            return lhs == rhs
        case (.decimal(let lhs), .decimal(let rhs)):
            return lhs == rhs
        case (.integer(let lhs), .integer(let rhs)):
            return lhs == rhs
        case (.logic(let lhs), .logic(let rhs)):
            return lhs == rhs
        case (.vector(let lhs), .vector(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }

    // swiftlint:disable function_body_length

    /// Checks whether this literal is valid for a given signal type.
    /// - Parameter type: The type of the signal to check.
    /// - Returns: Whether this literal can be assigned to the given signal type.
    @inlinable
    public func isValid(for type: SignalType) -> Bool {
        switch (self, type) {
        case (.boolean, .boolean):
            return true
        case (.integer, .integer), (.integer, .real), (.decimal, .real):
            return true
        case (.integer(let value), .ranged(type: .integer(let size))):
            guard
                case .literal(let literal) = size.min,
                case .integer(let lhsValue) = literal,
                case .literal(let rhsLiteral) = size.max,
                case .integer(let rhsValue) = rhsLiteral
            else {
                return true
            }
            return lhsValue <= value && value <= rhsValue
        case (.bit, .bit), (.bit, .stdLogic), (.bit, .stdULogic):
            return true
        case (.logic(let value), .bit):
            switch value {
            case .high, .low:
                return true
            default:
                return false
            }
        case (.integer(let value), .natural):
            return value >= 0
        case (.integer(let value), .positive):
            return value > 0
        case (.logic, .stdLogic), (.logic, .stdULogic):
            return true
        case (.vector(let value), .ranged(let type)):
            switch value {
            case .logics(let values):
                switch type {
                case .integer:
                    return false
                case .stdLogicVector(let size), .signed(let size), .unsigned(let size),
                    .stdULogicVector(let size):
                    return value.size == size.size
                case .bitVector(let size):
                    return values.count == size.size && values.values.allSatisfy { $0 == .low || $0 == .high }
                }
            default:
                switch type {
                case .integer:
                    return false
                case .stdLogicVector(let size), .signed(let size), .unsigned(let size),
                    .stdULogicVector(let size), .bitVector(let size):
                    return value.size == size.size
                }
            }
        default:
            return false
        }
    }

    // swiftlint:enable function_body_length

}

/// `CustomStringConvertible` conformance.
extension SignalLiteral: CustomStringConvertible {

    /// The description is the equivalent `VHDL` code.
    @inlinable public var description: String {
        rawValue
    }

}
