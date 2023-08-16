// CaseStatement.swift
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

/// A struct that represents a `case` statement in `VHDL`.
public struct CaseStatement: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The condition inside the case statement.
    public let condition: Expression

    /// The when statements inside the case statement.
    public let cases: [WhenCase]

    /// The `VHDL` code for this statement.
    @inlinable public var rawValue: String {
        """
        case \(condition.rawValue) is
        \(cases.map(\.rawValue).joined(separator: "\n").indent(amount: 1))
        end case;
        """
    }

    /// Creates a new `CaseStatement` with the given condition and cases.
    /// - Parameters:
    ///   - condition: The condition inside the case statement.
    ///   - cases: The when statements inside the case statement.
    @inlinable
    public init(condition: Expression, cases: [WhenCase]) {
        self.condition = condition
        self.cases = cases
    }

    /// Creates a new `CaseStatement` from the given `VHDL` code.
    /// - Parameter rawValue: The `VHDL` code for this statement.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.withoutComments.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.firstWord?.lowercased() == "case", trimmedString.hasSuffix(";") else {
            return nil
        }
        let withoutSemicolon = trimmedString.dropLast().trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutSemicolon.lastWord?.lowercased() == "case" else {
            return nil
        }
        let withoutLastCase = withoutSemicolon.dropLast(4).trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutLastCase.lastWord?.lowercased() == "end" else {
            return nil
        }
        let withoutEnd = withoutLastCase.dropLast(3).trimmingCharacters(in: .whitespacesAndNewlines)
        let withoutCase = withoutEnd.dropFirst(4).trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let isIndex = withoutCase.startIndex(word: "is"),
            let condition = Expression(rawValue: String(withoutCase[..<isIndex]))
        else {
            return nil
        }
        let remaining = withoutCase[isIndex...].dropFirst(2).trimmingCharacters(in: .whitespacesAndNewlines)
        let cases = remaining.components(separatedBy: "when")
        .map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        .filter { !$0.isEmpty }
        let whenCases = cases.compactMap { WhenCase(rawValue: "when " + $0) }
        guard whenCases.count == cases.count else {
            return nil
        }
        self.condition = condition
        self.cases = whenCases
    }

}
