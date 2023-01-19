// AsynchronousBlock.swift
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

indirect public enum AsynchronousBlock: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    case blocks(blocks: [AsynchronousBlock])

    case process(block: ProcessBlock)

    case statement(statement: Statement)

    public var rawValue: String {
        switch self {
        case .blocks(let blocks):
            return blocks.map(\.rawValue).joined(separator: "\n")
        case .process(let block):
            return block.rawValue
        case .statement(let statement):
            return statement.rawValue
        }
    }

    public init?(rawValue: String) {
        guard rawValue.count < 4096 else {
            return nil
        }
        self.init(rawValue: rawValue.withoutComments, carry: [])
    }

    private init?(rawValue: String, carry: [AsynchronousBlock]) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.contains(";") else {
            return nil
        }
        if let process = ProcessBlock(rawValue: trimmedString) {
            guard let newBlock = AsynchronousBlock(carry: carry + [.process(block: process)]) else {
                return nil
            }
            self = newBlock
            return
        }
        // Check for single semicolon.
        if
            trimmedString.firstIndex(of: ";") == trimmedString.lastIndex(of: ";"),
            trimmedString.hasSuffix(";")
        {
            guard
                let statement = Statement(rawValue: trimmedString),
                let newBlock = AsynchronousBlock(carry: carry + [.statement(statement: statement)])
            else {
                return nil
            }
            self = newBlock
            return
        }
        let currentBlock = trimmedString.uptoSemicolon + ";"
        guard let statement = Statement(rawValue: currentBlock) else {
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
