// PackageBodyBlock.swift
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

public indirect enum PackageBodyBlock: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    case blocks(values: [PackageBodyBlock])

    case comment(value: Comment)

    case fnDefinition(value: FunctionDefinition)

    case fnImplementation(value: FunctionImplementation)

    case constant(value: ConstantSignal)

    case type(value: TypeDefinition)

    case include(value: String)

    public var rawValue: String {
        switch self {
        case .blocks(let values):
            return values.map { $0.rawValue }.joined(separator: "\n")
        case .comment(let value):
            return value.rawValue
        case .fnDefinition(let value):
            return value.rawValue
        case .fnImplementation(let value):
            return value.rawValue
        case .constant(let value):
            return value.rawValue
        case .type(let value):
            return value.rawValue
        case .include(let value):
            return "use \(value);"
        }
    }

    public init?(rawValue: String) {
        self.init(rawValue: rawValue, carry: [])
    }

    init?(blocks: [PackageBodyBlock]) {
        guard !blocks.isEmpty else {
            return nil
        }
        guard blocks.count > 1 else {
            self = blocks[0]
            return
        }
        self = .blocks(values: blocks)
    }

    private init?(rawValue: String, carry: [PackageBodyBlock]) {
        let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else {
            self.init(blocks: carry)
            return
        }
        guard trimmedValue.count < 8192 else {
            return nil
        }
        if trimmedValue.hasPrefix("--") {
            self.init(comment: trimmedValue, carry: carry)
            return
        }
        guard let firstWord = trimmedValue.firstWord?.lowercased() else {
            return nil
        }
        if firstWord == "use" {
            self.init(include: trimmedValue, carry: carry)
            return
        }
        if firstWord == "type" {
            self.init(type: trimmedValue, carry: carry)
            return
        }
        if firstWord == "constant" {
            self.init(constant: trimmedValue, carry: carry)
            return
        }
        if firstWord == "function" {
            self.init(function: trimmedValue, carry: carry)
            return
        }
        return nil
    }

    private init?(comment value: String, carry: [PackageBodyBlock]) {
        guard value.hasPrefix("--") else {
            return nil
        }
        let firstLine = value.firstLine
        guard let comment = Comment(rawValue: firstLine) else {
            return nil
        }
        self.init(
            rawValue: String(value.dropFirst(firstLine.count)), carry: carry + [.comment(value: comment)]
        )
    }

    private init?(constant value: String, carry: [PackageBodyBlock]) {
        guard let semicolonIndex = value.firstIndex(of: ";"), semicolonIndex > value.startIndex else {
            return nil
        }
        let data = String(value[...semicolonIndex])
        guard let constant = ConstantSignal(rawValue: data) else {
            return nil
        }
        self.init(rawValue: String(value.dropFirst(data.count)), carry: carry + [.constant(value: constant)])
    }

    private init?(function value: String, carry: [PackageBodyBlock]) {
        guard
            value.firstWord?.lowercased() == "function",
            let returnIndex = value.indexes(for: ["return"], isCaseSensitive: false).first,
            value.endIndex > returnIndex.1
        else {
            return nil
        }
        let afterReturn = value[returnIndex.1...]
        guard
            let semicolonIndex = afterReturn.firstIndex(of: ";"), semicolonIndex > afterReturn.startIndex
        else {
            return nil
        }
        guard String(afterReturn[..<semicolonIndex]).words.contains(where: { $0.lowercased() == "is" }) else {
            self.init(functionDefinition: value, carry: carry, afterReturn: afterReturn)
            return
        }
        guard let endIndex = value.indexes(for: ["end", "function;"], isCaseSensitive: false).first?.1 else {
            return nil
        }
        let data = String(value[..<endIndex])
        guard let implementation = FunctionImplementation(rawValue: data) else {
            return nil
        }
        self.init(
            rawValue: String(value.dropFirst(data.count)),
            carry: carry + [.fnImplementation(value: implementation)]
        )
    }

    private init?(functionDefinition value: String, carry: [PackageBodyBlock], afterReturn: Substring) {
        guard let semicolonIndex = afterReturn.firstIndex(of: ";"), semicolonIndex > value.startIndex else {
            return nil
        }
        let data = String(value[...semicolonIndex])
        guard let definition = FunctionDefinition(rawValue: data) else {
            return nil
        }
        self.init(
            rawValue: String(value.dropFirst(data.count)),
            carry: carry + [.fnDefinition(value: definition)]
        )
        return
    }

    private init?(include value: String, carry: [PackageBodyBlock]) {
        guard let semicolonIndex = value.firstIndex(of: ";"), semicolonIndex > value.startIndex else {
            return nil
        }
        let data = String(value[...semicolonIndex])
        guard let include = Include(rawValue: data), case .include(let includeValue) = include else {
            return nil
        }
        self.init(
            rawValue: String(value.dropFirst(data.count)), carry: carry + [.include(value: includeValue)]
        )
    }

    private init?(type value: String, carry: [PackageBodyBlock]) {
        let words = value.words.lazy.map { $0.lowercased() }
        guard words.count >= 4, words[0] == "type", words[2] == "is" else {
            return nil
        }
        let type = words[3]
        guard type != "record" else {
            self.init(record: value, carry: carry)
            return
        }
        guard let semicolonIndex = value.firstIndex(of: ";"), semicolonIndex > value.startIndex else {
            return nil
        }
        let data = String(value[...semicolonIndex])
        guard let definition = TypeDefinition(rawValue: data) else {
            return nil
        }
        self.init(
            rawValue: String(value.dropFirst(data.count)), carry: carry + [.type(value: definition)]
        )
    }

    private init?(record value: String, carry: [PackageBodyBlock]) {
        guard
            let endIndex = value.indexes(for: ["end", "record;"], isCaseSensitive: false).first?.1,
            endIndex > value.startIndex
        else {
            return nil
        }
        let data = String(value[..<endIndex])
        guard let definition = TypeDefinition(rawValue: data) else {
            return nil
        }
        self.init(rawValue: String(value.dropFirst(data.count)), carry: carry + [.type(value: definition)])
    }

}
