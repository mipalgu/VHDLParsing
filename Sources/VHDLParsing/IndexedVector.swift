// IndexedVector.swift
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

/// A type for representing vector literals that assign specific bit/logic values to specific indices.
///
/// This struct is used to represent `VHDL` expressions of the form `(0 => '0', 1 => '1', 2 => '0')`, etc.
/// For example, consider a signal `x` that is a `std_logic_vector(7 downto 0)`. We may assign values to `x`
/// by using the `VHDL` expression `x <= (7 => '1', 6 downto 3 => '0', others => '1')`. We can use an instance
/// of this type to parse and generate the expression after the `<=` symbol.
public struct IndexedVector: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The values for each index.
    public let values: [IndexedValue]

    /// The `VHDL` code representing this expression.
    @inlinable public var rawValue: String {
        "(" + values.map(\.rawValue).joined(separator: ", ") + ")"
    }

    /// Initialise an instance of this type with the index values.
    /// - Parameter values: The values at each index.
    @inlinable
    public init(values: [IndexedValue]) {
        self.values = values
    }

    /// Create an instance of this type from the given `VHDL` code.
    /// - Parameter rawValue: The `VHDL` representation. The `VHDL` code must be of the form
    /// `(<index> => <value>, ...)`.
    @inlinable
    public init?(rawValue: String) {
        let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.count < 2048, value.hasPrefix("("), value.hasSuffix(")") else {
            return nil
        }
        let values = String(value.dropLast().dropFirst()).withoutComments
        let components = values.components(separatedBy: ",")
        guard components.allSatisfy({ $0.contains("=>") }) else {
            return nil
        }
        let bits: [IndexedValue] = components.compactMap {
            IndexedValue(rawValue: $0)
        }
        guard bits.count == components.count else {
            return nil
        }
        let hasLogic = bits.contains {
            guard case .literal(let literal) = $0.value else {
                return false
            }
            switch literal {
            case .logic:
                return true
            default:
                return false
            }
        }
        if hasLogic {
            let logics: [IndexedValue] = bits.compactMap {
                guard case .literal(let literal) = $0.value else {
                    return nil
                }
                switch literal {
                case .logic:
                    return $0
                case .bit(let bit):
                    return IndexedValue(index: $0.index, value: .logic(value: LogicLiteral(bit: bit)))
                default:
                    return nil
                }
            }
            self.init(values: logics)
        } else {
            self.init(values: bits)
        }
    }

}
