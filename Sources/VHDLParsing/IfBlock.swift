// IfBlock.swift
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

/// This type is used to represent an if-statement in `VHDL`.
///
/// The if-statement may contain nested if-statements or `elsif` conditions.
public enum IfBlock: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// An if-statement without an else block. E.g. `if <condition> then <code> end if;`
    case ifStatement(condition: Expression, ifBlock: SynchronousBlock)

    /// An if-statement with an else block.
    ///
    /// E.g. `if <condition> then <code> else <other_code> end if;` This
    /// case can also represent `elsif` blocks by placing other if-statements inside the `elseBlock`
    /// parameter. E.g. `if <condition> then <code> elsif <other_condition> then <other_code> end if;` or
    /// `if <condition> then <code> elsif <other_condition> then <other_code> else <default_code> end if;`
    case ifElse(condition: Expression, ifBlock: SynchronousBlock, elseBlock: SynchronousBlock)

    /// The `VHDL` code representing this if-statement.
    @inlinable public var rawValue: String {
        switch self {
        case .ifStatement(let condition, let code):
            return """
                if (\(condition.rawValue)) then
                \(code.rawValue.indent(amount: 1))
                end if;
                """
        case .ifElse(let condition, let thenBlock, let elseBlock):
            if case .ifStatement(let block) = elseBlock {
                return """
                    if (\(condition.rawValue)) then
                    \(thenBlock.rawValue.indent(amount: 1))
                    els\(block.rawValue)
                    """
            } else {
                return """
                    if (\(condition.rawValue)) then
                    \(thenBlock.rawValue.indent(amount: 1))
                    else
                    \(elseBlock.rawValue.indent(amount: 1))
                    end if;
                    """
            }
        }
    }

    // swiftlint:disable function_body_length

    /// Initialise the if-statement from the `VHDL` representation.
    /// - Parameter rawValue: The `VHDL` code executing this if-statement.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines).withoutComments
        let value = trimmedString.lowercased()
        let words = value.words
        guard words.first?.lowercased() == "if", words.last?.hasSuffix(";") == true else {
            return nil
        }
        let newValue = value.dropLast().trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            words.last?.lowercased() == "if;"
                || (words.count > 1 && words.dropLast().last?.lowercased() == "if")
        else {
            return nil
        }
        let newValueString = newValue.dropLast(2).trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            newValueString.words.last?.lowercased() == "end",
            words.count > 1,
            words[1].hasPrefix("("),
            let conditionString = value.subExpressions?.first?.dropFirst().dropLast(),
            let condition = Expression(rawValue: String(conditionString))
        else {
            return nil
        }
        let endIndex = newValueString.dropLast(3).endIndex
        let lastIndex = trimmedString.index(conditionString.endIndex, offsetBy: 1)
        guard
            value.endIndex > lastIndex,
            value[lastIndex..<endIndex].trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("then"),
            let thenIndex = value.startIndex(for: "then"),
            let bodyIndex = value.index(thenIndex, offsetBy: 4, limitedBy: value.endIndex)
        else {
            return nil
        }
        let body = trimmedString[bodyIndex...]
        let elseSet = Set(["else", "elsif"])
        let bodyComponents = value[bodyIndex...].components(separatedBy: .whitespacesAndNewlines)
            .map {
                $0.lowercased()
            }
            .filter { elseSet.contains($0) }
        if bodyComponents.contains("elsif"), let elsifIndex = body.startIndex(for: "elsif") {
            let myBody = body[..<elsifIndex]
            let otherBody = trimmedString[elsifIndex...].dropFirst(3)
            guard
                let bodyBlock = SynchronousBlock(rawValue: String(myBody)),
                let block = SynchronousBlock(rawValue: String(otherBody))
            else {
                return nil
            }
            self = .ifElse(condition: condition, ifBlock: bodyBlock, elseBlock: block)
            return
        }
        if bodyComponents.contains("else"), let elseIndex = body.startIndex(for: "else") {
            let myBody = body[..<elseIndex]
            let otherBody = trimmedString[elseIndex..<endIndex].dropFirst(4)
            guard
                let bodyBlock = SynchronousBlock(rawValue: String(myBody)),
                let block = SynchronousBlock(rawValue: String(otherBody))
            else {
                return nil
            }
            self = .ifElse(condition: condition, ifBlock: bodyBlock, elseBlock: block)
            return
        }
        let thenBody = String(trimmedString[bodyIndex..<endIndex])
        guard let thenBlock = SynchronousBlock(rawValue: thenBody) else {
            return nil
        }
        self = .ifStatement(condition: condition, ifBlock: thenBlock)
    }

    // swiftlint:enable function_body_length

}
