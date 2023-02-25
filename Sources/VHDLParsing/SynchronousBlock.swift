// Block.swift
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

/// A type for representing code that exists within a `process` block in `VHDL`.
indirect public enum SynchronousBlock: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// Several blocks of synchronous code.
    case blocks(blocks: [SynchronousBlock])

    /// A single statement.
    case statement(statement: Statement)

    /// An if-statement.
    case ifStatement(block: IfBlock)

    /// A case statement.
    case caseStatement(block: CaseStatement)

    /// A For loop.
    case forLoop(loop: ForLoop)

    /// The `VHDL` code that performs this block.
    @inlinable public var rawValue: String {
        switch self {
        case .blocks(let blocks):
            return blocks.map(\.rawValue).joined(separator: "\n")
        case .ifStatement(let block):
            return block.rawValue
        case .statement(let statement):
            return statement.rawValue
        case .caseStatement(let block):
            return block.rawValue
        case .forLoop(let loop):
            return loop.rawValue
        }
    }

    /// Initialise this `SynchronousBlock` from its `VHDL` representation.
    /// - Parameter rawValue: The `VHDL` code that exists within a `process` block.
    public init?(rawValue: String) {
        guard rawValue.count < 4096 else {
            return nil
        }
        self.init(rawValue: rawValue.withoutComments, carry: [])
    }

    // swiftlint:disable function_body_length

    /// Accumulater method to parse the `rawValue` incrementally.
    /// - Parameters:
    ///   - rawValue: The current string to parse.
    ///   - carry: The previous strings that have parsed correctly.
    private init?(rawValue: String, carry: [SynchronousBlock]) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.contains(";") else {
            return nil
        }
        let firstWord = trimmedString.firstWord?.lowercased()
        switch firstWord {
        case "case":
            self.init(
                trimmedString: trimmedString,
                blockCreator: { .caseStatement(block: $0) },
                beginningWith: ["case"],
                endingWith: ["end", "case;"],
                carry: carry
            )
        case "if":
            self.init(
                trimmedString: trimmedString,
                blockCreator: { .ifStatement(block: $0) },
                beginningWith: ["if"],
                endingWith: ["end", "if;"],
                carry: carry
            )
        case "for":
            self.init(
                trimmedString: trimmedString,
                blockCreator: { .forLoop(loop: $0) },
                beginningWith: ["for"],
                endingWith: ["end", "loop;"],
                carry: carry
            )
        default:
            // Check for single semicolon.
            if
                trimmedString.firstIndex(of: ";") == trimmedString.lastIndex(of: ";"),
                trimmedString.hasSuffix(";")
            {
                guard
                    let statement = Statement(rawValue: trimmedString),
                    let newBlock = SynchronousBlock(carry: carry + [.statement(statement: statement)])
                else {
                    return nil
                }
                self = newBlock
                return
            }
            self.init(multiple: trimmedString, carry: carry)
        }
    }

    // swiftlint:enable function_body_length

    /// Initialise a `SynchronousBlock` from it's `VHDL` representation that also contains sub-blocks. This
    /// initialiser tries to create a specific sub-block specified by the input parameters. If that sub-block
    /// cannot be created, it will return `nil`. This initialiser only work for multi-statement sub-blocks
    /// such as `if`, `case` and `for` blocks.
    /// - Parameters:
    ///   - trimmedString: The remaining trimmed raw data yet to be parsed.
    ///   - blockCreator: A function that creates the sub-block in the raw data.
    ///   - beginningWith: The words beginning the sub-block.
    ///   - endingWith: The words ending the sub-block.
    ///   - carry: The sub-blocks already parsed in the raw value.
    private init?<T>(
        trimmedString: String,
        blockCreator: (T) -> SynchronousBlock,
        beginningWith: [String],
        endingWith: [String],
        carry: [SynchronousBlock]
    ) where T: RawRepresentable, T.RawValue == String {
        if
            let type = T(rawValue: trimmedString),
            let newBlock = SynchronousBlock(carry: carry + [blockCreator(type)])
        {
            self = newBlock
            return
        }
        guard
            let str = trimmedString.subExpression(
                beginningWith: beginningWith, endingWith: endingWith
            ),
            let statement = T(rawValue: String(str)),
            str.endIndex < trimmedString.endIndex,
            let remainingBlock = SynchronousBlock(
                rawValue: String(trimmedString[str.endIndex...]),
                carry: carry + [blockCreator(statement)]
            )
        else {
            return nil
        }
        self = remainingBlock
        return
    }

    /// Initialise a `rawValue` with multiple statements.
    /// - Parameters:
    ///   - trimmedString: The trimmed string containing multiple statements.
    ///   - carry: The previous strings that have parsed correctly.
    private init?(multiple trimmedString: String, carry: [SynchronousBlock]) {
        let currentBlock = trimmedString.uptoSemicolon + ";"
        guard let statement = Statement(rawValue: currentBlock) else {
            return nil
        }
        let remaining = String(trimmedString.dropFirst(currentBlock.count))
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let newBlock = SynchronousBlock.statement(statement: statement)
        guard !remaining.isEmpty else {
            guard let block = SynchronousBlock(carry: carry + [newBlock]) else {
                return nil
            }
            self = block
            return
        }
        self.init(rawValue: remaining, carry: carry + [newBlock])
    }

    /// Combine multiple `SynchronousBlock`s into a single `SynchronousBlock`.
    /// - Parameter carry: The array containing the blocks to combine.
    private init?(carry: [SynchronousBlock]) {
        guard !carry.isEmpty else {
            return nil
        }
        if carry.count == 1 {
            self = carry[0]
        } else {
            self = .blocks(blocks: carry)
        }
    }

}
