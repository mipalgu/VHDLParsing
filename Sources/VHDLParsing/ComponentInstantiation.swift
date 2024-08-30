// ComponentInstantiation.swift
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

/// A component instantiation in `VHDL`. This struct represents a component that is instantiated using a
/// `port map` and optionally a `generic map`.
public struct ComponentInstantiation: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The label for the instantiation.
    public let label: VariableName

    /// The name of the component.
    public let name: VariableName

    /// The port map for the instantiation.
    public let port: PortMap

    /// The generic map for the instantiation.
    public let generic: GenericMap?

    /// The `VHDL` representation of this instantiation.
    @inlinable public var rawValue: String {
        guard let generic else {
            return "\(self.label.rawValue): component \(name.rawValue) \(port.rawValue)"
        }
        return """
            \(self.label.rawValue): component \(name.rawValue)
            \(generic.rawValue.indent(amount: 1))
            \(port.rawValue.indent(amount: 1))
            """
    }

    /// Creates a new `ComponentInstantiation` with the given label, name, port map and generic map.
    /// - Parameters:
    ///   - label: The label for the instantiation.
    ///   - name: The name of the component.
    ///   - port: The port map for the instantiation.
    ///   - generic: The generic map for the instantiation.
    @inlinable
    public init(label: VariableName, name: VariableName, port: PortMap, generic: GenericMap? = nil) {
        self.label = label
        self.name = name
        self.port = port
        self.generic = generic
    }

    /// Creates a new `ComponentInstantiation` from the given `VHDL` representation.
    /// - Parameter rawValue: The `VHDL` representation of the instantiation.
    @inlinable
    public init?(rawValue: String) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let colonIndex = trimmed.firstIndex(of: ":"),
            let label = VariableName(rawValue: String(trimmed[..<colonIndex]))
        else {
            return nil
        }
        let nextIndex = trimmed.index(after: colonIndex)
        guard nextIndex < trimmed.endIndex else {
            return nil
        }
        let remaining = trimmed[nextIndex...].trimmingCharacters(in: .whitespacesAndNewlines)
        let nameAndMaps: String
        if remaining.firstWord?.lowercased() == "component" {
            nameAndMaps = remaining.dropFirst("component".count)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            nameAndMaps = remaining
        }
        guard
            nameAndMaps.hasSuffix(";"),
            let component = nameAndMaps.firstWord,
            let name = VariableName(rawValue: component)
        else {
            return nil
        }
        let maps = nameAndMaps.dropFirst(component.count).trimmingCharacters(in: .whitespacesAndNewlines)
        let generic: GenericMap?
        let portRaw: String
        if maps.firstWord?.lowercased() == "generic" {
            let portIndexes = maps.indexes(for: ["port", "map"])
            guard
                portIndexes.count == 1,
                let portIndex = portIndexes.first,
                maps.endIndex > portIndex.1,
                let genericMap = GenericMap(rawValue: String(maps[..<portIndex.0]))
            else {
                return nil
            }
            generic = genericMap
            portRaw = String(maps[portIndex.0...])
        } else {
            generic = nil
            portRaw = maps
        }
        guard let port = PortMap(rawValue: portRaw) else {
            return nil
        }
        self.init(label: label, name: name, port: port, generic: generic)
    }

}
