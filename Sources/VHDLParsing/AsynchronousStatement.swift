// AsynchronousStatement.swift
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

/// A statement that can exist within asynchronous code.
public enum AsynchronousStatement: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// Assigning a value to a variable that has been pre-defined, e.g. `a <= b + 1;`.
    case assignment(name: VariableReference, value: AsynchronousExpression)

    /// A comment, e.g. `-- This is a comment.`.
    case comment(value: Comment)

    /// The `VHDL` code of this statement.
    @inlinable public var rawValue: String {
        switch self {
        case .assignment(let name, let value):
            return "\(name.rawValue) <= \(value.rawValue);"
        case .comment(let comment):
            return comment.rawValue
        }
    }

    /// Creates a statement from the `VHDL` code that performs it.
    /// - Parameter rawValue: The `VHDL` code that performs this statement. Note well that if a statement
    /// usually requires a semicolon, then it must in the code representation for this initialiser to work.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count < 2048 else {
            return nil
        }
        if let exp = Comment(rawValue: trimmedString) {
            self = .comment(value: exp)
            return
        }
        if let assignmentOperatorIndex = trimmedString.indexes(for: ["<="]).first {
            guard
                assignmentOperatorIndex.0 > trimmedString.startIndex,
                assignmentOperatorIndex.1 < trimmedString.endIndex
            else {
                return nil
            }
            let nameRaw = String(trimmedString[..<assignmentOperatorIndex.0])
            let expressionRaw = trimmedString[assignmentOperatorIndex.1...]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard
                expressionRaw.hasSuffix(";"),
                let name = VariableReference(rawValue: nameRaw),
                let exp = AsynchronousExpression(rawValue: String(expressionRaw.dropLast()))
            else {
                return nil
            }
            self = .assignment(name: name, value: exp)
            return
        }
        return nil
    }

}
