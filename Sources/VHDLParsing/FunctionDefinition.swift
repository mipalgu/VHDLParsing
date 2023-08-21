// FunctionDefinition.swift
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

public struct FunctionDefinition: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    public let name: VariableName

    public let arguments: [ArgumentDefinition]

    public let returnType: Type

    public var rawValue: String {
        let argumentList = arguments.map(\.rawValue).joined(separator: "; ")
        return "function \(self.name.rawValue)(\(argumentList)) return \(self.returnType.rawValue);"
    }

    public init(name: VariableName, arguments: [ArgumentDefinition], returnType: Type) {
        self.name = name
        self.arguments = arguments
        self.returnType = returnType
    }

    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count < 2048 else {
            return nil
        }
        guard trimmedString.firstWord?.lowercased() == "function" else {
            return nil
        }
        let definition = trimmedString.dropFirst("function".count)
        guard let bracketIndex = definition.firstIndex(of: "("), bracketIndex > definition.startIndex else {
            return nil
        }
        let rawName = String(definition[definition.startIndex..<bracketIndex])
        guard let name = VariableName(rawValue: rawName) else {
            return nil
        }
        let parameterList = String(definition.dropFirst(rawName.count))
        let returnIndexes = parameterList.indexes(for: ["return"])
        guard !returnIndexes.isEmpty, returnIndexes[0].1 < parameterList.endIndex else {
            return nil
        }
        let returnIndex = returnIndexes[0].0
        let parametersRaw = String(parameterList[parameterList.startIndex..<returnIndex])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard parametersRaw.first == "(" && parametersRaw.last == ")" else {
            return nil
        }
        let parameters = parametersRaw.dropFirst().dropLast().components(separatedBy: ";")
        let arguments = parameters.compactMap { ArgumentDefinition(rawValue: $0) }
        guard parameters.count == arguments.count else {
            return nil
        }
        let returnRaw = parameterList[returnIndexes[0].1..<parameterList.endIndex]
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard returnRaw.last == ";" else {
            return nil
        }
        let typeRaw = returnRaw.dropLast().trimmingCharacters(in: .whitespacesAndNewlines)
        guard let type = Type(rawValue: typeRaw) else {
            return nil
        }
        self.init(name: name, arguments: arguments, returnType: type)
    }

}
