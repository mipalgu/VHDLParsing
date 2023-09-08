// AAsynchronousBlock.swift
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

/// A block of code that exists within an architecture body. This code executes asynchronously.
indirect public enum AsynchronousBlock: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// Many blocks of asynchronous code.
    case blocks(blocks: [AsynchronousBlock])

    /// A process statement.
    case process(block: ProcessBlock)

    /// A single statement.
    case statement(statement: AsynchronousStatement)

    /// A component instantiation.
    case component(block: ComponentInstantiation)

    /// A function implementation.
    case function(block: FunctionImplementation)

    /// The `VHDL` code representing this block.
    @inlinable public var rawValue: String {
        switch self {
        case .blocks(let blocks):
            return blocks.map(\.rawValue).joined(separator: "\n")
        case .process(let block):
            return block.rawValue
        case .statement(let statement):
            return statement.rawValue
        case .component(let block):
            return block.rawValue
        case .function(let block):
            return block.rawValue
        }
    }

    /// Initialise this `AsynchronousBlock` from its `VHDL` representation.
    /// - Parameter rawValue: The `VHDL` code that exists within a `process` block.
    public init?(rawValue: String) {
        guard rawValue.count < 4096 else {
            return nil
        }
        self.init(rawValue: rawValue.withoutComments, carry: [])
    }

    /// Accumulater method to parse the `rawValue` incrementally.
    /// - Parameters:
    ///   - rawValue: The current string to parse.
    ///   - carry: The previous strings that have parsed correctly.
    private init?(rawValue: String, carry: [AsynchronousBlock]) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedString.firstWord?.lowercased() == "function" {
            self.init(function: trimmedString, carry: carry)
            return
        }
        guard let semicolonIndex = trimmedString.firstIndex(of: ";") else {
            return nil
        }
        if let colonIndex = trimmedString.firstIndex(of: ":"), colonIndex < semicolonIndex {
            self.init(component: trimmedString, carry: carry)
            return
        }
        if trimmedString.firstWord?.lowercased() == "process" {
            self.init(process: trimmedString, carry: carry)
            return
        }
        // Check for single semicolon.
        if semicolonIndex == trimmedString.lastIndex(of: ";"), trimmedString.hasSuffix(";") {
            guard let statement = AsynchronousStatement(rawValue: trimmedString) else {
                return nil
            }
            self.init(carry: carry + [.statement(statement: statement)])
            return
        }
        self.init(multiple: trimmedString, carry: carry)
    }

    /// Initialise an `AsynchronousBlock` assuming it contains a ``FunctionImplementation``.
    /// - Parameters:
    ///  - function: The `VHDL` code that exists within a `function` block.
    ///  - carry: The previous strings that have parsed correctly.
    private init?(function trimmedString: String, carry: [AsynchronousBlock]) {
        if let function = FunctionImplementation(rawValue: trimmedString) {
            self.init(carry: carry + [.function(block: function)])
            return
        }
        let indexes = trimmedString.indexes(for: ["end", "function;"], isCaseSensitive: false)
        guard
            !indexes.isEmpty,
            let endIndex = indexes.first?.1,
            endIndex < trimmedString.endIndex
        else {
            return nil
        }
        let functionRaw = String(trimmedString[trimmedString.startIndex..<endIndex])
        guard let implementation = FunctionImplementation(rawValue: functionRaw) else {
            return nil
        }
        let remaining = trimmedString[endIndex...].trimmingCharacters(in: .whitespacesAndNewlines)
        self.init(rawValue: remaining, carry: carry + [.function(block: implementation)])
    }

    /// Initialise an `AsynchronousBlock` assuming it contains a `ComponentInstantiation`.
    /// - Parameters:
    ///   - trimmedString: The `VHDL` code that contains the component.
    ///   - carry: The previous strings that have parsed correctly.
    private init?(component trimmedString: String, carry: [AsynchronousBlock]) {
        if let component = ComponentInstantiation(rawValue: trimmedString) {
            self.init(carry: carry + [.component(block: component)])
            return
        }
        let subExpression = trimmedString[...trimmedString.uptoSemicolon.endIndex]
        guard
            let component = ComponentInstantiation(rawValue: String(subExpression)),
            subExpression.endIndex < trimmedString.endIndex
        else {
            return nil
        }
        self.init(
            rawValue: String(trimmedString[subExpression.endIndex...]),
            carry: carry + [.component(block: component)]
        )
        return
    }

    /// Initialise an `AsynchronousBlock` assuming it contains a process block.
    /// - Parameters:
    ///   - trimmedString: The `VHDL` code that contains the process.
    ///   - carry: The previous strings that have parsed correctly.
    private init?(process trimmedString: String, carry: [AsynchronousBlock]) {
        if let process = ProcessBlock(rawValue: trimmedString) {
            self.init(carry: carry + [.process(block: process)])
            return
        }
        guard
            let processString = trimmedString.subExpression(
                beginningWith: ["process"], endingWith: ["end", "process;"]
            ),
            let process = ProcessBlock(rawValue: String(processString)),
            processString.endIndex < trimmedString.endIndex
        else {
            return nil
        }
        self.init(
            rawValue: String(trimmedString[processString.endIndex...]),
            carry: carry + [.process(block: process)]
        )
    }

    /// Initialise a `rawValue` with multiple statements.
    /// - Parameters:
    ///   - trimmedString: The trimmed string containing multiple statements.
    ///   - carry: The previous strings that have parsed correctly.
    private init?(multiple trimmedString: String, carry: [AsynchronousBlock]) {
        let currentBlock = trimmedString.uptoSemicolon + ";"
        guard let statement = AsynchronousStatement(rawValue: currentBlock) else {
            return nil
        }
        let remaining = String(trimmedString.dropFirst(currentBlock.count))
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let newBlock = AsynchronousBlock.statement(statement: statement)
        guard !remaining.isEmpty else {
            guard let block = AsynchronousBlock(carry: carry + [newBlock]) else {
                return nil
            }
            self = block
            return
        }
        self.init(rawValue: remaining, carry: carry + [newBlock])
    }

    /// Combine multiple `AsynchronousBlock`s into a single `AsynchronousBlock`.
    /// - Parameter carry: The array containing the blocks to combine.
    private init?(carry: [AsynchronousBlock]) {
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
