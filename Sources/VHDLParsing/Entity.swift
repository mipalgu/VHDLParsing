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

public struct Entity: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    public let name: VariableName

    public let port: PortBlock

    public var rawValue: String {
        """
        entity \(self.name.rawValue) is
        \(port.rawValue.indent(amount: 1))
        end \(self.name.rawValue);
        """
    }

    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.lowercased().hasPrefix("entity ") else {
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
        let nameRaw = nameString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard nameAndPort.hasSuffix("end \(nameRaw);") else {
            return nil
        }
        let portRaw = remaining.dropLast(4 + nameRaw.count + 1)
        guard let port = PortBlock(rawValue: String(portRaw)) else {
            return nil
        }
        self.name = name
        self.port = port
    }

    public init?(machine: Machine) {
        let clocks = machine.clocks.map { PortSignal(clock: $0) }
        guard
            let name = VariableName(rawValue: machine.name),
            let port = PortBlock(signals: machine.externalSignals + clocks)
        else {
            return nil
        }
        self.name = name
        self.port = port
    }

}
