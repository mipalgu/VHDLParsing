// MemberAccess.swift
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

/// An expression accessing a member within a record instance.
/// 
/// This type correctly parses the `VHDL` that
/// is used to access a member within a record. For example, consider the record `foo` with the member `bar`.
/// The `VHDL` code to access this member would be `foo.bar`. This type correctly parses this code and stores
/// the record and member as separate properties of this struct. If this `VHDL` is parsed by this type, i.e.
/// by using `MemberAccess(rawValue: "foo.bar")`, then the `record` property will be `foo` and the `member`
/// property will be `bar`.
/// 
/// This type also supports chaining member access as the member property is a
/// ``DirectReference``. For example, consider the record `foo` with the member `bar` which is a record with
/// the member `baz`. The `VHDL` code to access this member would be `foo.bar.baz`. This type will store
/// `foo` in the `record` property and `bar.baz` in the `member` property as a ``DirectReference`` instance.
/// - SeeAlso: ``DirectReference``, ``VariableName``.
public struct MemberAccess: Codable, Equatable, Hashable, RawRepresentable, Sendable {

    /// The name of the record the `member` belongs too.
    public let record: VariableName

    /// The member that is accessed within the `record`.
    public let member: DirectReference

    /// The `VHDL` code that represents this member access.
    @inlinable public var rawValue: String {
        "\(self.record.rawValue).\(self.member.rawValue)"
    }

    /// Creates a new instance of this type with the given record and member.
    /// - Parameters:
    ///   - record: The name of the record the `member` belongs too.
    ///   - member: The member that is accessed within the `record`.
    @inlinable
    public init(record: VariableName, member: DirectReference) {
        self.record = record
        self.member = member
    }

    /// Creates a new instance of this type by parsing the given `VHDL` code.
    /// - Parameter rawValue: The `VHDL` code to parse.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            trimmedString.count >= 3,
            trimmedString.count < 2048,
            let dotIndex = trimmedString.firstIndex(of: "."),
            dotIndex > trimmedString.startIndex,
            dotIndex < trimmedString.index(before: trimmedString.endIndex)
        else {
            return nil
        }
        let lhs = String(trimmedString[trimmedString.startIndex..<dotIndex])
        let rhs = String(trimmedString[trimmedString.index(after: dotIndex)..<trimmedString.endIndex])
        guard
            lhs.trimmingCharacters(in: .whitespacesAndNewlines).count == lhs.count,
            rhs.trimmingCharacters(in: .whitespacesAndNewlines).count == rhs.count,
            let lhsExp = VariableName(rawValue: lhs),
            let rhsExp = DirectReference(rawValue: rhs)
        else {
            return nil
        }
        self.init(record: lhsExp, member: rhsExp)
    }

}
