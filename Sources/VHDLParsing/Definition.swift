// Definition.swift
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

/// A definition of a new variable in `VHDL`.
public enum Definition: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The variable is a signal.
    case signal(value: LocalSignal)

    /// The variable is a constant.
    case constant(value: ConstantSignal)

    /// A component definition.
    case component(value: ComponentDefinition)

    /// A new type definition.
    case type(value: TypeDefinition)

    /// The equivalent `VHDL` code for this definition.
    @inlinable public var rawValue: String {
        switch self {
        case .signal(let value):
            return value.rawValue
        case .constant(let value):
            return value.rawValue
        case .component(let value):
            return value.rawValue
        case .type(let type):
            return type.rawValue
        }
    }

    /// Creates a new `Definition` from the given `VHDL` code.
    /// - Parameter rawValue: The `VHDL` code to create the `Definition` from.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count < 2048 else {
            return nil
        }
        let firstWord = trimmedString.firstWord?.lowercased()
        switch firstWord {
        case "constant":
            self.init(trimmedString: trimmedString) { .constant(value: $0) }
        case "signal":
            self.init(trimmedString: trimmedString) { .signal(value: $0) }
        case "component":
            self.init(trimmedString: trimmedString) { .component(value: $0) }
        case "type":
            self.init(trimmedString: trimmedString) { .type(value: $0) }
        default:
            return nil
        }
    }

    /// Creates a new `Definition` from the given `VHDL` code by trying to cast to a specific case of
    /// `Definition`.
    /// - Parameters:
    ///   - trimmedString: The `VHDL` code to parse.
    ///   - fn: A function that creates a specific case of `Definition` from an expected parsed version of 
    /// the `VHDL` code.
    @usableFromInline
    init?<T>(
        trimmedString: String, trying fn: (T) -> Definition
    ) where T: RawRepresentable, T.RawValue == String {
        guard let value = T(rawValue: trimmedString) else {
            return nil
        }
        self = fn(value)
    }

}
