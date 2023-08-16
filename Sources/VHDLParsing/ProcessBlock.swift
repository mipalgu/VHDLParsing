// ProcessBlock.swift
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

/// A struct for representing a process block.
public struct ProcessBlock: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The sensitivity list of the process block.
    public let sensitivityList: [VariableName]

    /// The code within the process block.
    public let code: SynchronousBlock

    /// The `VHDL` representation of the process block.
    @inlinable public var rawValue: String {
        let blocksCode = code.rawValue.indent(amount: 1)
        guard !sensitivityList.isEmpty else {
            return """
            process
            begin
            \(blocksCode)
            end process;
            """
        }
        return """
        process(\(sensitivityList.map(\.rawValue).joined(separator: ", ")))
        begin
        \(blocksCode)
        end process;
        """
    }

    /// Creates a new process block with the given sensitivity list and code.
    /// - Parameters:
    ///   - sensitivityList: The sentitivty list.
    ///   - code: The code in the process block.
    @inlinable
    public init(sensitivityList: [VariableName], code: SynchronousBlock) {
        self.sensitivityList = sensitivityList
        self.code = code
    }

    /// Creates a new process block from the given `VHDL` representation.
    /// - Parameter rawValue: The `VHDL` code for this process block.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines).withoutComments
        guard
            trimmedString.firstWord?.lowercased() == "process",
            trimmedString.hasSuffix(";")
        else {
            return nil
        }
        let noSemicolon = trimmedString.dropLast().trimmingCharacters(in: .whitespacesAndNewlines)
        guard noSemicolon.lastWord?.lowercased() == "process" else {
            return nil
        }
        let noProcess = noSemicolon.dropFirst(7).dropLast(8).trimmingCharacters(in: .whitespacesAndNewlines)
        guard noProcess.lastWord?.lowercased() == "end" else {
            return nil
        }
        let trimmed = noProcess.dropLast(3).trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("("), let bracketsString = trimmed.uptoBalancedBracket else {
            return nil
        }
        let list = bracketsString.dropFirst().dropLast()
        let components = list.components(separatedBy: ",").map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let variables = components.compactMap { VariableName(rawValue: $0) }
        guard variables.count == components.count else {
            return nil
        }
        let noList = trimmed.dropFirst(bracketsString.count).trimmingCharacters(in: .whitespacesAndNewlines)
        guard noList.firstWord?.lowercased() == "begin", let content = SynchronousBlock(
            rawValue: noList.dropFirst(5).trimmingCharacters(in: .whitespacesAndNewlines)
        ) else {
            return nil
        }
        self.sensitivityList = variables
        self.code = content
    }

}
