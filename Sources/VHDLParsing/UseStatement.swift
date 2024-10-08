// UseStatement.swift
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

/// An include statement that imports module from a library.
///
/// This statement uses the `use` keyword in `VHDL` to import modules from a library. E.G.:
/// ```VHDL
/// use IEEE.std_logic_1164.all;
/// ```
public struct UseStatement: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// Each component of the statement.
    ///
    /// This is the modules that are imported.
    public let components: [IncludeComponent]

    /// The `VHDL` code representation of the statement.
    @inlinable public var rawValue: String {
        "use \(components.map(\.rawValue).joined(separator: "."));"
    }

    /// Creates a new `UseStatement` from the given components.
    ///
    /// This initialiser first checks to make sure that the components are valid for the statement. If they
    /// are not, then `nil` is returned.
    /// - Parameter components: The components of this statement.
    @inlinable
    public init?(nonEmptyComponents components: [IncludeComponent]) {
        guard !components.isEmpty else {
            return nil
        }
        if let allIndex = components.firstIndex(of: .all) {
            guard allIndex == components.count - 1 else {
                return nil
            }
        }
        self.init(components: components)
    }

    /// Creates a new `UseStatement` from the given `VHDL` code representing this statement.
    /// - Parameter rawValue: The `VHDL` code enacting this statement.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            trimmedString.count < 2048,
            trimmedString.firstWord?.lowercased() == "use",
            trimmedString.hasSuffix(";")
        else {
            return nil
        }
        let data = String(trimmedString.dropFirst(3).dropLast()).trimmingCharacters(in: .whitespaces)
        guard !data.isEmpty else {
            return nil
        }
        let components = data.components(separatedBy: ".")
        let includes = components.compactMap(IncludeComponent.init(rawValue:))
        guard includes.count == components.count else {
            return nil
        }
        self.init(nonEmptyComponents: includes)
    }

    /// Creates a new `UseStatement` from the given components.
    /// - Parameter components: The components of this statement.
    @inlinable
    init(components: [IncludeComponent]) {
        self.components = components
    }

}
