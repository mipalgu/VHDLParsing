// SignalType.swift
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

/// Valid VHDL Signal types.
public enum SignalType: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// A bit type.
    case bit

    /// A boolean type.
    case boolean

    /// An integer type.
    case integer

    /// A natural type.
    case natural

    /// A positive type.
    case positive

    /// A real type.
    case real

    /// Standard logic (`std_logic`).
    case stdLogic

    /// Standard unresolved logic (`std_ulogic`).
    case stdULogic

    /// A type with a bounded range.
    case ranged(type: RangedType)

    /// The raw value is a String.
    public typealias RawValue = String

    /// The equivalent VHDL code for this type.
    @inlinable public var rawValue: String {
        switch self {
        case .bit:
            return "bit"
        case .boolean:
            return "boolean"
        case .integer:
            return "integer"
        case .natural:
            return "natural"
        case .positive:
            return "positive"
        case .real:
            return "real"
        case .stdLogic:
            return "std_logic"
        case .stdULogic:
            return "std_ulogic"
        case .ranged(let type):
            return type.rawValue
        }
    }

    /// Initialise the type from it's VHDL representation.
    /// - Parameter rawValue: The VHDL code of this type.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count < 256 else {
            return nil
        }
        let value = trimmedString.lowercased()
        if value == "bit" {
            self = .bit
            return
        }
        if value == "boolean" {
            self = .boolean
            return
        }
        if value == "integer" {
            self = .integer
            return
        }
        if value == "natural" {
            self = .natural
            return
        }
        if value == "positive" {
            self = .positive
            return
        }
        if value == "real" {
            self = .real
            return
        }
        if value == "std_logic" {
            self = .stdLogic
            return
        }
        if value == "std_ulogic" {
            self = .stdULogic
            return
        }
        if let type = RangedType(rawValue: value) {
            self = .ranged(type: type)
            return
        }
        return nil
    }

}

/// `CustomStringConvertible` conformance.
extension SignalType: CustomStringConvertible {

    /// The equivalent VHDL code for this type.
    @inlinable public var description: String {
        self.rawValue
    }

}
