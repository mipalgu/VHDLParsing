// ForLoop.swift
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

public struct ForLoop: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    public let iterator: VariableName

    public let range: VectorSize

    public let body: SynchronousBlock

    public var rawValue: String {
        """
        for \(iterator.rawValue) in \(range.rawValue) loop
        \(body.rawValue.indent(amount: 1))
        end loop;
        """
    }

    public init(iterator: VariableName, range: VectorSize, body: SynchronousBlock) {
        self.iterator = iterator
        self.range = range
        self.body = body
    }

    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            trimmedString.count >= 3,
            trimmedString[
                trimmedString.startIndex...trimmedString.index(trimmedString.startIndex, offsetBy: 2)
            ].lowercased() == "for"
        else {
            return nil
        }
        let trimmedStringWithoutFor = trimmedString
            .dropFirst(3).trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let components = trimmedStringWithoutFor.split(words: ["loop"])?.0,
            components.count >= 2,
            let iteratorAndRange = components.first
        else {
            return nil
        }
        let size = iteratorAndRange.count + "loop".count + 1
        guard trimmedString.count >= size else {
            return nil
        }
        let body = trimmedStringWithoutFor[
            trimmedStringWithoutFor.index(trimmedStringWithoutFor.startIndex, offsetBy: size)...
        ].trimmingCharacters(in: .whitespacesAndNewlines)
        guard body.hasSuffix(";") else {
            return nil
        }
        let bodyWithoutSemicolon = body.dropLast().trimmingCharacters(in: .whitespacesAndNewlines)
        guard bodyWithoutSemicolon.lastWord?.lowercased() == "loop" else {
            return nil
        }
        let bodyWithoutLoop = bodyWithoutSemicolon.dropLast(4).trimmingCharacters(in: .whitespacesAndNewlines)
        guard bodyWithoutLoop.lastWord?.lowercased() == "end" else {
            return nil
        }
        let bodyRaw = bodyWithoutLoop.dropLast(3).trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let iteratorAndRangeComponents = iteratorAndRange.split(words: ["in"])?.0,
            iteratorAndRangeComponents.count == 2,
            let iterator = VariableName(rawValue: iteratorAndRangeComponents[0]),
            let range = VectorSize(rawValue: iteratorAndRangeComponents[1]),
            let block = SynchronousBlock(rawValue: bodyRaw)
        else {
            return nil
        }
        self.init(iterator: iterator, range: range, body: block)
    }

}
