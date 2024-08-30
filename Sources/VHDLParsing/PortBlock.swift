// PortBlock.swift
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

/// A port statement in `VHDL`.
public struct PortBlock: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The signals in the port.
    public let signals: [PortSignal]

    /// The `VHDL` code defining the port.
    @inlinable public var rawValue: String {
        var signalsString = signals.map(\.rawValue).joined(separator: "\n").indent(amount: 1)
        signalsString.removeLast(character: ";")
        return """
            port(
            \(signalsString)
            );
            """
    }

    /// Creates a new `PortBlock` from the given `VHDL` code.
    /// - Parameter rawValue: The `VHDL` code defining the port.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let words = trimmedString.components(separatedBy: .whitespacesAndNewlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined()
        guard words.lowercased().hasPrefix("port(") && words.hasSuffix(");") else {
            return nil
        }
        let signalsString = trimmedString.dropFirst("port".count)
            .dropLast()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .dropFirst()
            .dropLast()
        let signalsWithoutComments = String(signalsString).withoutComments
        let signals = signalsWithoutComments.components(separatedBy: ";")
        let externalSignals = signals.compactMap(PortSignal.init(rawValue:))
        guard signals.count == externalSignals.count else {
            return nil
        }
        self.signals = externalSignals
    }

    /// Define a port with the given signals.
    /// - Parameter signals: The signals in the port.
    @inlinable
    public init?(signals: [PortSignal]) {
        let signalNames = signals.map(\.name)
        let signalSet = Set(signalNames)
        guard signalNames.count == signalSet.count else {
            return nil
        }
        self.signals = signals
    }

}
