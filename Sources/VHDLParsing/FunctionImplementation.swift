// FunctionImplementation.swift
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

/// A type that represents a function definition with a body. This type represents the case where the
/// implementation of the function is provided.
public struct FunctionImplementation: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The name of the function.
    public let name: VariableName

    /// The arguments of the function.
    public let arguments: [ArgumentDefinition]

    /// The return type of the function.
    public let returnType: Type

    /// The body of the function. This is the code enacted when the function is called.
    public let body: SynchronousBlock

    /// The `VHDL` code defining this function implementation.
    @inlinable public var rawValue: String {
        let arguments = self.arguments.map { $0.rawValue }.joined(separator: "; ")
        return """
        function \(self.name.rawValue)(\(arguments)) return \(self.returnType.rawValue) is
        begin
        \(body.rawValue.indent(amount: 1))
        end function;
        """
    }

    /// Creates a new `FunctionImplementation` instance from its properties.
    /// - Parameters:
    ///   - name: The name of the function.
    ///   - arguments: The arguments of the function.
    ///   - returnTube: The return type of the function.
    ///   - body: The body of the function.
    @inlinable
    public init(
        name: VariableName,
        arguments: [ArgumentDefinition],
        returnTube: Type,
        body: SynchronousBlock
    ) {
        self.name = name
        self.arguments = arguments
        self.returnType = returnTube
        self.body = body
    }

    /// Creates a new `FunctionImplementation` instance from the definition of the function and its body.
    /// - Parameters:
    ///   - definition: The definition of the function.
    ///   - body: The body of this function.
    @inlinable
    public init(definition: FunctionDefinition, body: SynchronousBlock) {
        self.init(
            name: definition.name,
            arguments: definition.arguments,
            returnTube: definition.returnType,
            body: body
        )
    }

    /// Creates a new `FunctionImplementation` instance from its `VHDL` code.
    /// - Parameter rawValue: The `VHDL` code defining this function implementation.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let isIndexes = trimmedString.indexes(for: ["is"], isCaseSensitive: false)
        guard
            let firstIndex = isIndexes.first,
            firstIndex.0 > trimmedString.startIndex,
            firstIndex.1 < trimmedString.index(before: trimmedString.endIndex)
        else {
            return nil
        }
        let definitionRaw = trimmedString[trimmedString.startIndex..<firstIndex.0]
            .trimmingCharacters(in: .whitespacesAndNewlines) + ";"
        guard let functionDefinition = FunctionDefinition(rawValue: definitionRaw) else {
            return nil
        }
        let bodyRaw = trimmedString[firstIndex.1...].trimmingCharacters(in: .whitespacesAndNewlines)
        guard bodyRaw.hasSuffix(";") else {
            return nil
        }
        let withoutSemicolon = bodyRaw.dropLast().trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutSemicolon.lastWord?.lowercased() == "function" else {
            return nil
        }
        let withoutFunction = withoutSemicolon.dropLast("function".count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutFunction.lastWord?.lowercased() == "end" else {
            return nil
        }
        let withoutEnd = withoutFunction.dropLast("end".count).trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutEnd.firstWord?.lowercased() == "begin" else {
            return nil
        }
        let withoutBegin = withoutEnd.dropFirst("begin".count).trimmingCharacters(in: .whitespacesAndNewlines)
        guard let block = SynchronousBlock(rawValue: withoutBegin) else {
            return nil
        }
        self.init(definition: functionDefinition, body: block)
    }

}
