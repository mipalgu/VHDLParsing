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

/// A type for representing statements inside a package body.
public indirect enum PackageBodyBlock: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// Multiple statements.
    case blocks(values: [PackageBodyBlock])

    /// A comment.
    case comment(value: Comment)

    /// A function definition.
    case fnDefinition(value: FunctionDefinition)

    /// A function implementation.
    case fnImplementation(value: FunctionImplementation)

    /// A constant definition.
    case constant(value: ConstantSignal)

    /// A type definition.
    case type(value: TypeDefinition)

    /// An include statement.
    case include(statement: UseStatement)

    /// The equivalent `VHDL` code for this statement.
    @inlinable public var rawValue: String {
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
            return value.rawValue
        }
    }

    /// Creates a new `PackageBodyBlock` from the specified `VHDL` code.
    /// - Parameter rawValue: The `VHDL` code to parse in this package body.
    public init?(rawValue: String) {
        self.init(rawValue: rawValue, carry: [])
    }

    /// Creates a new `PackageBodyBlock` from the a block of statements.
    ///
    /// This initialiser will check to see if the blocks are valid first. You must have at least one block to
    /// be valid. A block with exactly one statement will be returned as that statement.
    /// - Parameter blocks: The blocks in this package body.
    @inlinable
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

    /// Creates a new `PackageBodyBlock` from the specified `VHDL` code with a carry accumulator.
    /// - Parameters:
    ///   - rawValue: The `VHDL` code that has not been parsed yet.
    ///   - carry: The accumulator of parsed statements.
    private init?(rawValue: String, carry: [PackageBodyBlock]) {
        let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else {
            self.init(blocks: carry)
            return
        }
        guard trimmedValue.count < 8192 else {
            return nil
        }
        guard !trimmedValue.hasPrefix("--") else {
            self.init(comment: trimmedValue, carry: carry)
            return
        }
        switch trimmedValue.firstWord?.lowercased() {
        case "use":
            self.init(include: trimmedValue, carry: carry)
        case "type":
            self.init(type: trimmedValue, carry: carry)
        case "constant":
            self.init(constant: trimmedValue, carry: carry)
        case "function":
            self.init(function: trimmedValue, carry: carry)
        default:
            return nil
        }
    }

    /// Creates a new `PackageBodyBlock` from the specified `VHDL` code with a carry accumulator.
    ///
    /// This initialiser expectes the value to be a comment.
    /// - Parameters:
    ///   - value: The `VHDL` code that has not been parsed yet.
    ///   - carry: The accumulator of parsed statements.
    private init?(comment value: String, carry: [PackageBodyBlock]) {
        let firstLine = value.firstLine
        guard let comment = Comment(rawValue: firstLine) else {
            return nil
        }
        self.init(
            rawValue: String(value.dropFirst(firstLine.count)),
            carry: carry + [.comment(value: comment)]
        )
    }

    /// Creates a new `PackageBodyBlock` from the specified `VHDL` code with a carry accumulator.
    ///
    /// This initialiser expectes the value to be a constant.
    /// - Parameters:
    ///   - value: The `VHDL` code that has not been parsed yet.
    ///   - carry: The accumulator of parsed statements.
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

    /// Creates a new `PackageBodyBlock` from the specified `VHDL` code with a carry accumulator.
    ///
    /// This initialiser expectes the value to be a function.
    /// - Parameters:
    ///   - value: The `VHDL` code that has not been parsed yet.
    ///   - carry: The accumulator of parsed statements.
    private init?(function value: String, carry: [PackageBodyBlock]) {
        guard
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

    /// Creates a new `PackageBodyBlock` from the specified `VHDL` code with a carry accumulator.
    ///
    /// This initialiser expectes the value to be a function definition.
    /// - Parameters:
    ///   - value: The `VHDL` code that has not been parsed yet.
    ///   - carry: The accumulator of parsed statements.
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

    /// Creates a new `PackageBodyBlock` from the specified `VHDL` code with a carry accumulator.
    ///
    /// This initialiser expectes the value to be an include.
    /// - Parameters:
    ///   - value: The `VHDL` code that has not been parsed yet.
    ///   - carry: The accumulator of parsed statements.
    private init?(include value: String, carry: [PackageBodyBlock]) {
        guard let semicolonIndex = value.firstIndex(of: ";"), semicolonIndex > value.startIndex else {
            return nil
        }
        let data = String(value[...semicolonIndex])
        guard let include = UseStatement(rawValue: data) else {
            return nil
        }
        self.init(
            rawValue: String(value.dropFirst(data.count)),
            carry: carry + [.include(statement: include)]
        )
    }

    /// Creates a new `PackageBodyBlock` from the specified `VHDL` code with a carry accumulator.
    ///
    /// This initialiser expectes the value to be a type definition.
    /// - Parameters:
    ///   - value: The `VHDL` code that has not been parsed yet.
    ///   - carry: The accumulator of parsed statements.
    private init?(type value: String, carry: [PackageBodyBlock]) {
        guard
            let semicolonIndex = value.firstIndex(of: ";"),
            semicolonIndex > value.startIndex
        else {
            return nil
        }
        let data = String(value[...semicolonIndex])
        let words = data.words.lazy.map { $0.lowercased() }
        guard words.count >= 4, words[0] == "type", words[2] == "is" else {
            return nil
        }
        let type = words[3]
        guard type != "record" else {
            self.init(record: value, carry: carry)
            return
        }
        guard let definition = TypeDefinition(rawValue: data) else {
            return nil
        }
        self.init(
            rawValue: String(value.dropFirst(data.count)),
            carry: carry + [.type(value: definition)]
        )
    }

    /// Creates a new `PackageBodyBlock` from the specified `VHDL` code with a carry accumulator.
    ///
    /// This initialiser expectes the value to be a record.
    /// - Parameters:
    ///   - value: The `VHDL` code that has not been parsed yet.
    ///   - carry: The accumulator of parsed statements.
    private init?(record value: String, carry: [PackageBodyBlock]) {
        guard
            let endIndex = value.indexes(for: ["end", "record"], isCaseSensitive: false).first?.1,
            value.endIndex > endIndex,
            let semicolonIndex = value[endIndex...].firstIndex(of: ";")
        else {
            return nil
        }
        let data = String(value[...semicolonIndex])
        guard let definition = TypeDefinition(rawValue: data) else {
            return nil
        }
        self.init(rawValue: String(value.dropFirst(data.count)), carry: carry + [.type(value: definition)])
    }

}
