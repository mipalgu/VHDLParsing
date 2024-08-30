// Entity.swift
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
import StringHelpers

/// A `VHDL` entity statement.
public struct Entity: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The name of the entity.
    public let name: VariableName

    /// The port declaration in the entity.
    public let port: PortBlock

    /// The generic declaration in the entity.
    public let generic: GenericBlock?

    /// The `VHDL` code for this `Entity`.
    @inlinable public var rawValue: String {
        guard let generic = self.generic else {
            return """
                entity \(self.name.rawValue) is
                \(port.rawValue.indent(amount: 1))
                end \(self.name.rawValue);
                """
        }
        return """
            entity \(self.name.rawValue) is
            \(generic.rawValue.indent(amount: 1))
            \(port.rawValue.indent(amount: 1))
            end \(self.name.rawValue);
            """
    }

    /// Creates a new `Entity` with the given name and port declaration.
    /// - Parameters:
    ///   - name: The name of the entity.
    ///   - port: The port declaration.
    @inlinable
    public init(name: VariableName, port: PortBlock, generic: GenericBlock? = nil) {
        self.name = name
        self.port = port
        self.generic = generic
    }

    /// Creates a new `Entity` from the given `VHDL` code.
    /// - Parameter rawValue: The `VHDL` code defining the entity.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines).withoutComments
        guard trimmedString.firstWord?.lowercased() == "entity" else {
            return nil
        }
        let nameAndPort = trimmedString.dropFirst(7)
        let nameAndIs = nameAndPort.components(separatedBy: "is")
        guard
            let nameString = nameAndIs.first,
            let name = VariableName(rawValue: nameString),
            nameAndIs.count >= 2
        else {
            return nil
        }
        let remaining = nameAndIs[1...].joined(separator: "is")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let nameRaw = nameString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard remaining.hasSuffix(";") else {
            return nil
        }
        let noSemicolon = remaining.dropLast().trimmingCharacters(in: .whitespacesAndNewlines)
        guard noSemicolon.hasSuffix("\(nameRaw)") else {
            return nil
        }
        let noName = noSemicolon.dropLast(nameRaw.count).trimmingCharacters(in: .whitespacesAndNewlines)
        guard noName.lastWord?.lowercased() == "end" else {
            return nil
        }
        let remainingRaw = noName.dropLast(3).trimmingCharacters(in: .whitespacesAndNewlines)
        self.init(name: name, genericAndPort: remainingRaw)
    }

    /// Initialise a new `Entity` from the given name and code for the generic and port declaration.
    /// - Parameters:
    ///   - name: The name of the entity.
    ///   - remainingRaw: The `VHDL` code within the entity declaration. This code must be trimmed before
    /// being passed into this initialiser.
    @usableFromInline
    init?(name: VariableName, genericAndPort remainingRaw: String) {
        let portRaw: String
        let generic: GenericBlock?
        if remainingRaw.lowercased().hasPrefix("generic") {
            guard
                let genericRaw = remainingRaw.dropFirst(7).uptoBalancedBracket,
                let genericBlock = GenericBlock(rawValue: "generic" + String(genericRaw) + ";"),
                let portIndex = remainingRaw.index(
                    remainingRaw.startIndex,
                    offsetBy: genericRaw.count + 7,
                    limitedBy: remainingRaw.endIndex
                ),
                portIndex < remainingRaw.endIndex
            else {
                return nil
            }
            let raw = String(remainingRaw[portIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard raw.hasPrefix(";") else {
                return nil
            }
            portRaw = String(raw.dropFirst())
            generic = genericBlock
        } else {
            portRaw = remainingRaw
            generic = nil
        }
        guard let port = PortBlock(rawValue: portRaw) else {
            return nil
        }
        self.init(name: name, port: port, generic: generic)
    }

}
