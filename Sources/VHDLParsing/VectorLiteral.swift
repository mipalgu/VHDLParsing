// VectorLiteral.swift
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

/// A vector literal is a string of bits, hexademical digits, or octal digits.
///
/// This enum allows VHDL signal literal values to be represented.
public enum VectorLiteral: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// A vector of bit values.
    case bits(value: BitVector)

    /// A vector of logic values.
    case logics(value: LogicVector)

    /// A hexadecimal value.
    case hexademical(value: HexVector)

    /// An octal value.
    case octal(value: OctalVector)

    /// An indexed literal setting values to specific indexes.
    case indexed(values: IndexedVector)

    /// The raw value is a string.
    public typealias RawValue = String

    /// The equivalent VHDL code for representing this literal.
    @inlinable public var rawValue: String {
        switch self {
        case .bits(let values):
            return values.rawValue
        case .logics(let values):
            return values.rawValue
        case .hexademical(let values):
            return values.rawValue
        case .octal(let values):
            return values.rawValue
        case .indexed(let vector):
            return vector.rawValue
        }
    }

    /// The number of bits in this vector literal.
    @inlinable public var size: Int? {
        switch self {
        case .bits(let values):
            return values.values.count
        case .logics(let values):
            return values.values.count
        case .hexademical(let values):
            return values.values.count * 4
        case .octal(let values):
            return values.values.count * 3
        case .indexed:
            return nil
        }
    }

    /// Creates a new vector literal from the VHDL equivalent representation.
    /// - Parameter rawValue: The VHDL equivalent representation of the vector literal.
    @inlinable
    public init?(rawValue: String) {
        let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.count < 2048 else {
            return nil
        }
        if let vector = IndexedVector(rawValue: value) {
            self = .indexed(values: vector)
            return
        }
        if let vector = HexVector(rawValue: value) {
            self = .hexademical(value: vector)
            return
        }
        if let vector = OctalVector(rawValue: value) {
            self = .octal(value: vector)
            return
        }
        if let vector = BitVector(rawValue: value) {
            self = .bits(value: vector)
            return
        }
        if let vector = LogicVector(rawValue: value) {
            self = .logics(value: vector)
            return
        }
        return nil
    }

    /// Equality operation.
    @inlinable
    public static func == (lhs: VectorLiteral, rhs: VectorLiteral) -> Bool {
        switch (lhs, rhs) {
        case (.bits(let lhs), .bits(let rhs)):
            return lhs == rhs
        case (.logics(let lhs), .logics(let rhs)):
            return lhs == rhs
        case (.hexademical(let lhs), .hexademical(let rhs)):
            return lhs == rhs
        case (.octal(let lhs), .octal(let rhs)):
            return lhs == rhs
        case (.indexed(let lhs), .indexed(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }

}
