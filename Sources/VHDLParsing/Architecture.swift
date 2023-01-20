// Architecture.swift
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

public struct Architecture: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    public let body: AsynchronousBlock

    public let entity: VariableName

    public let head: ArchitectureHead

    public let name: VariableName

    public var rawValue: String {
        """
        architecture \(name.rawValue) of \(entity.rawValue) is
        \(head.rawValue.indent(amount: 1))
        begin
        \(body.rawValue.indent(amount: 1))
        end \(name.rawValue);
        """
    }

    public init(body: AsynchronousBlock, entity: VariableName, head: ArchitectureHead, name: VariableName) {
        self.body = body
        self.entity = entity
        self.head = head
        self.name = name
    }

    public init?(rawValue: String) {
        let trimmedString = rawValue.withoutComments.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let isIndex = trimmedString.startIndex(word: "is") else {
            return nil
        }
        let definition = String(trimmedString[..<isIndex])
        let definitionWords = definition.words
        guard
            definitionWords.count == 4,
            definitionWords[0].lowercased() == "architecture",
            definitionWords[2].lowercased() == "of",
            let name = VariableName(rawValue: definitionWords[1]),
            let entityName = VariableName(rawValue: definitionWords[3]),
            trimmedString.hasSuffix(";")
        else {
            return nil
        }
        let withoutSemicolon = trimmedString.dropLast().trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutSemicolon.lastWord?.lowercased() == name.rawValue.lowercased() else {
            return nil
        }
        let withoutEndName = withoutSemicolon.dropLast(name.rawValue.count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutEndName.lastWord?.lowercased() == "end" else {
            return nil
        }
        let headAndBodyString = withoutEndName[isIndex...].dropFirst(2)
            .dropLast(3)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let beginIndex = headAndBodyString.startIndex(word: "begin") else {
            return nil
        }
        let head = headAndBodyString[..<beginIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let architectureHead = ArchitectureHead(rawValue: head),
            let architectureBody = AsynchronousBlock(
                rawValue: headAndBodyString[beginIndex...].dropFirst(5)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            )
        else {
            return nil
        }
        self.init(body: architectureBody, entity: entityName, head: architectureHead, name: name)
    }

}
