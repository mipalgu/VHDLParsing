// WhenCase.swift
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

/// A single when case including the code within it. The when statement exists within a case statement and
/// represents code that is executed under a specific condition.
public struct WhenCase: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The condition of the when statement.
    public let condition: WhenCondition

    /// The code that is executed when the condition is met.
    public let code: SynchronousBlock

    /// The `VHDL` code representing this statement.
    @inlinable public var rawValue: String {
        """
        when \(condition.rawValue) =>
        \(code.rawValue.indent(amount: 1))
        """
    }

    /// Creates a new `WhenCase` with the given condition and code.
    /// - Parameters:
    ///   - condition: The condition of the when statement.
    ///   - code: The code that is executed when the condition is met.
    @inlinable
    public init(condition: WhenCondition, code: SynchronousBlock) {
        self.condition = condition
        self.code = code
    }

    /// Creates a new `WhenCase` from the given `VHDL` code.
    /// - Parameter rawValue: The `VHDL` code representing this statement. Code should be in the form:
    /// `when <condition> => <code>`.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.contains("=>") else {
            return nil
        }
        guard
            let whenAndCode = trimmedString.split(on: ["=>"]),
            whenAndCode.0.count >= 2,
            let whenString = whenAndCode.0.first?.trimmingCharacters(in: .whitespacesAndNewlines),
            whenString.firstWord?.lowercased() == "when"
        else {
            return nil
        }
        let conditionString = whenString.dropFirst(4).trimmingCharacters(in: .whitespacesAndNewlines)
        guard let condition = WhenCondition(rawValue: conditionString) else {
            return nil
        }
        let codeString = whenAndCode.0[1...]
            .joined(separator: "=>")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let code = SynchronousBlock(rawValue: codeString) else {
            return nil
        }
        self.condition = condition
        self.code = code
    }

}
