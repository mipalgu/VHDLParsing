// IndexedValue.swift
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

/// This type represents a value for a specific index in a vector type within `VHDL`.
/// 
/// For example, consider a signal `x` with type `std_logic_vector(3 downto 0)`. We can assign specific bits
/// within `x` by using the `VHDL` statement `x <= (3 => '1', others => '0');`. This statement says bit 3 of
/// `x` should be set to 1 and all other bits to be set to 0. This type can be used to represent both
/// expressions `3 => '1'` and `others => '0'` as two separate instances of this type.
public struct IndexedValue: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The index within the vector type to assign the `value` to.
    public let index: VectorIndex

    /// The value to assign to the bit located at `index`.
    public let value: Expression

    /// The `VHDL` representation of this type.
    @inlinable public var rawValue: String {
        "\(self.index.rawValue) => \(self.value.rawValue)"
    }

    /// Initialise an indexed value from the `VHDL` code that represents it.
    /// - Parameter rawValue: The `VHDL` code representing this indexed value. This code should be of the form
    /// `<index> => <value>`. This initialiser will also parse strings that contain a comma in the suffix.
    @inlinable
    public init?(rawValue: String) {
        let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.count < 256 else {
            return nil
        }
        guard
            let operatorIndex = value.indexes(for: ["=>"]).first,
            value.endIndex > value.startIndex,
            operatorIndex.1 < value.index(before: value.endIndex),
            operatorIndex.0 > value.startIndex
        else {
            return nil
        }
        let lhs = String(value[..<operatorIndex.0])
        let rhs = String(value[operatorIndex.1...])
        guard let index = VectorIndex(rawValue: lhs) else {
            return nil
        }
        var bitString = rhs.trimmingCharacters(in: .whitespacesAndNewlines)
        if bitString.hasSuffix(",") {
            bitString = String(bitString.dropLast())
        }
        if let expression = Expression(rawValue: bitString) {
            if index == .others {
                guard expression.isValidOtherValue else {
                    return nil
                }
            }
            self.init(index: index, value: expression)
            return
        }
        return nil
    }

    /// Intialise an indexed value with an index and signal literal.
    /// - Parameters:
    ///   - index: The index within a vector type to assign the `value` to.
    ///   - value: The signal literal to assign to the bit located at `index`.
    @inlinable
    public init(index: VectorIndex, value: SignalLiteral) {
        self.index = index
        self.value = .literal(value: value)
    }

    /// Initialise an indexed value with an index and value.
    /// - Parameters:
    ///   - index: The index within a vector type to assign the `value` to.
    ///   - value: The value to assign to the location with the resource.
    @inlinable
    public init(index: VectorIndex, value: Expression) {
        self.index = index
        self.value = value
    }

}

/// Add property for determining valid other values.
extension Expression {

    /// Check whether a given expression can be assigned to the `other` index in an ``IndexedValue``.
    @inlinable var isValidOtherValue: Bool {
        switch self {
        case .literal(let value):
            switch value {
            case .bit, .logic:
                return true
            default:
                return false
            }
        case .binary(let operation):
            return operation.lhs.isValidOtherValue && operation.rhs.isValidOtherValue
        case .cast(let operation):
            switch operation {
            case .bit, .stdLogic, .stdULogic:
                return true
            default:
                return false
            }
        case .functionCall:
            return true
        case .reference(let variable):
            switch variable {
            case .variable:
                return true
            case .indexed(_, let index):
                guard case .index = index else {
                    return false
                }
                return true
            }
        case .conditional, .logical:
            return false
        case .precedence(let value):
            return value.isValidOtherValue
        }
    }

}
