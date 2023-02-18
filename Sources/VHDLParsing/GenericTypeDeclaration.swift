// GenericType.swift
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

public struct GenericTypeDeclaration: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    public var name: VariableName

    public var type: SignalType

    public var defaultValue: Expression?

    public var rawValue: String {
        let declaration = "\(name.rawValue): \(type.rawValue)"
        guard let value = defaultValue else {
            return declaration + ";"
        }
        return declaration + " := \(value.rawValue);"
    }

    public init(name: VariableName, type: SignalType, defaultValue: Expression? = nil) {
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
    }

    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count < 256, !trimmedString.isEmpty else {
            return nil
        }
        let declaration = trimmedString.uptoSemicolon
        let assignmentComponents = declaration.components(separatedBy: ":=")
        guard assignmentComponents.count <= 2, let typeDeclaration = assignmentComponents.first else {
            return nil
        }
        let typeComponents = typeDeclaration.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        guard typeComponents.count >= 2 else {
            return nil
        }
        let hasColonComponents = typeComponents[1].trimmingCharacters(in: .whitespaces) == ":"
        let nameComponents = typeComponents[0]
        let minCount = hasColonComponents ? 3 : 2
        guard typeComponents.count >= minCount else {
            return nil
        }
        let typeString = typeComponents[(minCount - 1)...].joined(separator: " ")
        let nameString = hasColonComponents ? nameComponents : String(nameComponents.dropLast())
        guard
            let name = VariableName(rawValue: nameString), let type = SignalType(rawValue: typeString)
        else {
            return nil
        }
        let defaultValue = assignmentComponents.count == 2 ? Expression(rawValue: assignmentComponents[1])
            : nil
        self.init(name: name, type: type, defaultValue: defaultValue)
    }

}
