// PackageBody.swift
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

/// A package body implementation. This type represents a `package body` block in `VHDL` and represents an
/// implementation of a pre-defined ``VHDLPackage``.
/// 
/// - SeeAlso: ``VHDLPackage``.
public struct PackageBody: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The name of the package that is implemented by this body.
    public let name: VariableName

    /// The statements in the body declaration.
    public let body: PackageBodyBlock

    /// The equivalent `VHDL` code for this package body.
    @inlinable public var rawValue: String {
        """
        package body \(self.name.rawValue) is
        \(body.rawValue.indent(amount: 1))
        end package body \(self.name.rawValue);
        """
    }

    /// Creates a new package body with the name and implementation.
    /// - Parameters:
    ///   - name: The name of the package this body is implementing.
    ///   - body: The implementation of the package.
    @inlinable
    public init(name: VariableName, body: PackageBodyBlock) {
        self.name = name
        self.body = body
    }

    /// Creates a new package body from the specified `VHDL` code.
    /// - Parameter rawValue: The `VHDL` code representing a package body.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count < 4096, trimmedString.hasSuffix(";") else {
            return nil
        }
        let withoutSemicolon = trimmedString.dropLast().trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutSemicolon.firstWord?.lowercased() == "package" else {
            return nil
        }
        let withoutPackage = withoutSemicolon.dropFirst("package".count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutPackage.firstWord?.lowercased() == "body" else {
            return nil
        }
        let withoutBody = withoutPackage.dropFirst("body".count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let nameRaw = withoutBody.firstWord,
            let name = VariableName(rawValue: nameRaw),
            withoutBody.lastWord?.lowercased() == nameRaw.lowercased()
        else {
            return nil
        }
        let withoutName = withoutBody.dropFirst(nameRaw.count)
            .dropLast(nameRaw.count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutName.firstWord?.lowercased() == "is", withoutName.lastWord?.lowercased() == "body" else {
            return nil
        }
        let withoutEndBody = withoutName.dropFirst("is".count)
            .dropLast("body".count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutEndBody.lastWord?.lowercased() == "package" else {
            return nil
        }
        let withoutEndPackage = withoutEndBody.dropLast("package".count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutEndPackage.lastWord?.lowercased() == "end" else {
            return nil
        }
        let bodyRaw = withoutEndPackage.dropLast("end".count).trimmingCharacters(in: .whitespacesAndNewlines)
        guard let body = PackageBodyBlock(rawValue: bodyRaw) else {
            return nil
        }
        self.init(name: name, body: body)
    }

}
