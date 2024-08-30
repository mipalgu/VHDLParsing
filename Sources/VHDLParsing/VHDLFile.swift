// VHDLFile.swift
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

import Foundation
import StringHelpers

/// A file containing `VHDL` code.
public struct VHDLFile: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The architectures in the file.
    public let architectures: [Architecture]

    /// The entities in the file.
    public let entities: [Entity]

    /// The includes in the file.
    public let includes: [Include]

    /// The packages in the file.
    public let packages: [VHDLPackage]

    /// The package bodies in this file.
    public let packageBodies: [PackageBody]

    /// The equivalent `VHDL` code for this file.
    @inlinable public var rawValue: String {
        let includesString = includes.map { $0.rawValue }.joined(separator: "\n")
        let entitiesString = entities.sorted { $0.name < $1.name }.map(\.rawValue).joined(separator: "\n\n")
        let architecturesString = architectures.sorted { $0.entity < $1.entity }
            .map(\.rawValue)
            .joined(separator: "\n\n")
        let packagesString = packages.sorted { $0.name < $1.name }
            .map { $0.rawValue }
            .joined(separator: "\n\n")
        let bodiesString = packageBodies.sorted { $0.name < $1.name }
            .map { $0.rawValue }
            .joined(separator: "\n\n")
        return [includesString, entitiesString, architecturesString, packagesString, bodiesString]
            .filter {
                !$0.isEmpty
            }
            .joined(separator: "\n\n")
            .trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
    }

    /// Creates a new `VHDLFile` from the given parameters.
    /// - Parameters:
    ///   - architectures: The architectures in the file.
    ///   - entities: The entities in the file.
    ///   - includes: The includes in the file.
    ///   - packages: The packages in the file.
    ///   - packageBodies: The package bodies in the file.
    @inlinable
    public init(
        architectures: [Architecture],
        entities: [Entity],
        includes: [Include],
        packages: [VHDLPackage] = [],
        packageBodies: [PackageBody] = []
    ) {
        self.architectures = architectures
        self.entities = entities
        self.includes = includes
        self.packages = packages
        self.packageBodies = packageBodies
    }

    /// Creates a new `VHDLFile` from the `VHDL` code within it.
    /// - Parameter rawValue: The `VHDL` code in the file.
    public init?(rawValue: String) {
        let trimmedString = rawValue.withoutComments.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedString.isEmpty else {
            return nil
        }
        self.init(remaining: trimmedString)
    }

    /// An accumulator function for iteratively creating a `VHDLFile`.
    /// - Parameters:
    ///   - remaining: The remaining string to parse.
    ///   - architectures: The architectures that have been previously parsed.
    ///   - entities: The entities that have been previously parsed.
    ///   - includes: The includes that have been previously parsed.
    ///   - packages: The packages already parsed.
    ///   - packageBodies: The package bodies already parsed.
    private init?(
        remaining: String,
        architectures: [Architecture] = [],
        entities: [Entity] = [],
        includes: [Include] = [],
        packages: [VHDLPackage] = [],
        packageBodies: [PackageBody] = []
    ) {
        let trimmedString = remaining.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedString.isEmpty else {
            self.init(
                architectures: architectures,
                entities: entities,
                includes: includes,
                packages: packages,
                packageBodies: packageBodies
            )
            return
        }
        self.init(
            remaining: trimmedString,
            architectures: architectures,
            entities: entities,
            includes: includes,
            packages: packages,
            packageBodies: packageBodies,
            firstWord: trimmedString.firstWord?.lowercased()
        )
    }

    /// An accumulator function for iteratively creating a `VHDLFile`. This uses the first word to determine
    /// what to parse.
    /// - Parameters:
    ///   - trimmedString: The remaining string to parse.
    ///   - architectures: The architectures that have been previously parsed.
    ///   - entities: The entities that have been previously parsed.
    ///   - includes: The includes that have been previously parsed.
    ///   - packages: The packages already parsed.
    ///   - packageBodies: The package bodies already parsed.
    ///   - firstWord: The first word in the string.
    private init?(
        remaining trimmedString: String,
        architectures: [Architecture] = [],
        entities: [Entity] = [],
        includes: [Include] = [],
        packages: [VHDLPackage] = [],
        packageBodies: [PackageBody] = [],
        firstWord: String?
    ) {
        switch firstWord {
        case "use", "library":
            self.init(
                include: trimmedString,
                architectures: architectures,
                entities: entities,
                includes: includes,
                packages: packages,
                packageBodies: packageBodies
            )
        case "entity":
            self.init(
                entity: trimmedString,
                architectures: architectures,
                entities: entities,
                includes: includes,
                packages: packages,
                packageBodies: packageBodies
            )
        case "architecture":
            self.init(
                architecture: trimmedString,
                architectures: architectures,
                entities: entities,
                includes: includes,
                packages: packages,
                packageBodies: packageBodies
            )
        case "package":
            self.init(
                package: trimmedString,
                architectures: architectures,
                entities: entities,
                includes: includes,
                packages: packages,
                packageBodies: packageBodies
            )
        default:
            return nil
        }
    }

}

/// Private functions for parsing a `VHDLFile`.
extension VHDLFile {

    /// Parse a package in the given string.
    /// - Parameters:
    ///   - trimmedString: The package to parse.
    ///   - architectures: The architectures already parsed.
    ///   - entities: The entities already parsed.
    ///   - includes: The includes already parsed.
    ///   - packages: The packages already parsed.
    ///   - packageBodies: The package bodies already parsed.
    private init?(
        package trimmedString: String,
        architectures: [Architecture],
        entities: [Entity],
        includes: [Include],
        packages: [VHDLPackage],
        packageBodies: [PackageBody]
    ) {
        guard
            let firstWord = trimmedString.firstWord,
            let secondWord = String(trimmedString.dropFirst(firstWord.count)).firstWord?.lowercased()
        else {
            return nil
        }
        guard secondWord == "body" else {
            self.init(
                packageHead: trimmedString,
                architectures: architectures,
                entities: entities,
                includes: includes,
                packages: packages,
                packageBodies: packageBodies
            )
            return
        }
        self.init(
            packageBody: trimmedString,
            architectures: architectures,
            entities: entities,
            includes: includes,
            packages: packages,
            packageBodies: packageBodies
        )
    }

    /// Parse a package definition in the given string.
    /// - Parameters:
    ///   - trimmedString: The package to parse.
    ///   - architectures: The architectures already parsed.
    ///   - entities: The entities already parsed.
    ///   - includes: The includes already parsed.
    ///   - packages: The packages already parsed.
    ///   - packageBodies: The package bodies already parsed.
    private init?(
        packageBody trimmedString: String,
        architectures: [Architecture],
        entities: [Entity],
        includes: [Include],
        packages: [VHDLPackage],
        packageBodies: [PackageBody]
    ) {
        guard let isIndex = trimmedString.startIndex(word: "is") else {
            return nil
        }
        let words = String(trimmedString[..<isIndex]).words
        guard words.count == 3, words[0].lowercased() == "package", words[1].lowercased() == "body" else {
            return nil
        }
        let name = words[2]
        guard
            let expression = trimmedString.subExpression(
                beginningWith: ["package", "body", name, "is"],
                endingWith: ["end", "package", "body", name + ";"]
            ),
            let body = PackageBody(rawValue: String(expression))
        else {
            return nil
        }
        let newRemaining = trimmedString.dropFirst(expression.count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        self.init(
            remaining: newRemaining,
            architectures: architectures,
            entities: entities,
            includes: includes,
            packages: packages,
            packageBodies: packageBodies + [body]
        )
    }

    /// Parse a package definition in the given string.
    /// - Parameters:
    ///   - trimmedString: The package to parse.
    ///   - architectures: The architectures already parsed.
    ///   - entities: The entities already parsed.
    ///   - includes: The includes already parsed.
    ///   - packages: The packages already parsed.
    ///   - packageBodies: The package bodies already parsed.
    private init?(
        packageHead trimmedString: String,
        architectures: [Architecture],
        entities: [Entity],
        includes: [Include],
        packages: [VHDLPackage],
        packageBodies: [PackageBody]
    ) {
        guard let isIndex = trimmedString.startIndex(word: "is") else {
            return nil
        }
        let words = String(trimmedString[..<isIndex]).words
        guard words.count == 2, words[0].lowercased() == "package" else {
            return nil
        }
        let name = words[1]
        guard
            let expression = trimmedString.subExpression(
                beginningWith: ["package", name, "is"],
                endingWith: ["end", "package", name + ";"]
            ),
            let package = VHDLPackage(rawValue: String(expression))
        else {
            return nil
        }
        let newRemaining = trimmedString.dropFirst(expression.count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        self.init(
            remaining: newRemaining,
            architectures: architectures,
            entities: entities,
            includes: includes,
            packages: packages + [package],
            packageBodies: packageBodies
        )
    }

    /// Parse an include in the given string.
    /// - Parameters:
    ///   - trimmedString: The include to parse.
    ///   - architectures: The architectures already parsed.
    ///   - entities: The entities already parsed.
    ///   - includes: The includes already parsed.
    ///   - packages: The packages already parsed.
    ///   - packageBodies: The package bodies already parsed.
    private init?(
        include trimmedString: String,
        architectures: [Architecture],
        entities: [Entity],
        includes: [Include],
        packages: [VHDLPackage],
        packageBodies: [PackageBody]
    ) {
        let include = trimmedString.uptoSemicolon + ";"
        guard trimmedString.contains(";"), let newInclude = Include(rawValue: include) else {
            return nil
        }
        let newRemaining = String(trimmedString.dropFirst(include.count))
        self.init(
            remaining: newRemaining,
            architectures: architectures,
            entities: entities,
            includes: includes + [newInclude],
            packages: packages,
            packageBodies: packageBodies
        )
    }

    /// Parse an entity in the given string.
    /// - Parameters:
    ///   - trimmedString: The entity to parse.
    ///   - architectures: The architectures already parsed.
    ///   - entities: The entities already parsed.
    ///   - includes: The includes already parsed.
    ///   - packages: The packages already parsed.
    ///   - packageBodies: The package bodies already parsed.
    private init?(
        entity trimmedString: String,
        architectures: [Architecture],
        entities: [Entity],
        includes: [Include],
        packages: [VHDLPackage],
        packageBodies: [PackageBody]
    ) {
        guard let isIndex = trimmedString.startIndex(word: "is") else {
            return nil
        }
        let words = String(trimmedString[..<isIndex]).words
        guard words.count == 2, words[0].lowercased() == "entity" else {
            return nil
        }
        let name = words[1]
        guard
            let expression = trimmedString.subExpression(
                beginningWith: ["entity", name],
                endingWith: ["end", name + ";"]
            ),
            let entity = Entity(rawValue: String(expression))
        else {
            return nil
        }
        let newRemaining = trimmedString.dropFirst(expression.count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        self.init(
            remaining: newRemaining,
            architectures: architectures,
            entities: entities + [entity],
            includes: includes,
            packages: packages,
            packageBodies: packageBodies
        )
    }

    /// Parse an architecture in the given string.
    /// - Parameters:
    ///   - trimmedString: The architecture to parse.
    ///   - architectures: The architectures already parsed.
    ///   - entities: The entities already parsed.
    ///   - includes: The includes already parsed.
    ///   - packages: The packages already parsed.
    ///   - packageBodies: The package bodies already parsed.
    private init?(
        architecture trimmedString: String,
        architectures: [Architecture],
        entities: [Entity],
        includes: [Include],
        packages: [VHDLPackage],
        packageBodies: [PackageBody]
    ) {
        guard let isIndex = trimmedString.startIndex(word: "is") else {
            return nil
        }
        let words = String(trimmedString[..<isIndex]).words
        guard words.count == 4, words[0].lowercased() == "architecture", words[2].lowercased() == "of" else {
            return nil
        }
        let name = words[1]
        let entity = words[3]
        guard
            let expression = trimmedString.subExpression(
                beginningWith: ["architecture", name, "of", entity],
                endingWith: ["end", name + ";"]
            ),
            let architecture = Architecture(rawValue: String(expression))
        else {
            return nil
        }
        let newRemaining = trimmedString.dropFirst(expression.count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        self.init(
            remaining: newRemaining,
            architectures: architectures + [architecture],
            entities: entities,
            includes: includes,
            packages: packages,
            packageBodies: packageBodies
        )
    }

}
