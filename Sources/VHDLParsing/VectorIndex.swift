// VectorIndex.swift
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

/// An index of a vector in `VHDL`. This type is designed to represent indexes in an assignment statement for
/// a vector type. For example, you may have a signal `x` of type `std_logic_vector(7 downto 0)` that you
/// want to assign a value to. In `VHDL`, you can do this with the statement `x <= (others => '0');`.
/// This type is designed to represent the `others` in that statement and other supported values like it, such
/// as those found in `x <= (7 => '1', others => '0');`. This statement would produce two instances of this
/// type for the values `7` and `others`. This type also supports `VHDL2008` statements that support a range
/// of values, e.g. `x <= (7 downto 0 => '1');`.
public enum VectorIndex: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// An index in a vector.
    case index(value: Int)

    /// The `others` statement in `VHDL`. Refers to all remaining indexes in a vector.
    case others

    /// A range of indexes in a vector.
    case range(value: VectorSize)

    /// The `VHDL` code representing this index.
    @inlinable public var rawValue: String {
        switch self {
        case .index(let value):
            return "\(value)"
        case .others:
            return "others"
        case .range(let value):
            return value.rawValue
        }
    }

    /// Creates a new `VectorIndex` from the `VHDL` code representing it.
    /// - Parameter rawValue: The `VHDL` code representing the index. This code should only contain the index
    /// itself and no other statements or parantheses.
    @inlinable
    public init?(rawValue: String) {
        let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.count < 256 else {
            return nil
        }
        if value.count == 6, value.lowercased() == "others" {
            self = .others
            return
        }
        if let range = VectorSize(rawValue: value) {
            self = .range(value: range)
            return
        }
        if let index = Int(value) {
            guard index >= 0 else {
                return nil
            }
            self = .index(value: index)
            return
        }
        return nil
    }

}
