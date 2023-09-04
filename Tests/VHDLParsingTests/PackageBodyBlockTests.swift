// PackageBodyBlockTests.swift
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

@testable import VHDLParsing
import XCTest

/// Test class for ``PackageBodyBlock``.
final class PackageBodyBlockTests: XCTestCase {

    /// A type alias.
    let alias = PackageBodyBlock.type(value: .alias(name: VariableName(text: "x"), type: .stdLogic))

    /// The equivalent `VHDL` code for `alias`.
    let aliasRaw = "type x is std_logic;"

    /// A comment.
    let comment = PackageBodyBlock.comment(value: Comment(text: "This is a comment!"))

    /// The equivalent `VHDL` code for `comment`.
    let commentRaw = "-- This is a comment!"

    // swiftlint:disable force_unwrapping

    /// A constant.
    let constant = PackageBodyBlock.constant(value: ConstantSignal(
        name: VariableName(text: "zero"),
        type: .signal(type: .stdLogic),
        value: .literal(value: .bit(value: .low))
    )!)

    // swiftlint:enable force_unwrapping

    /// The equivalent `VHDL` code for `constant`.
    let constantRaw = "constant zero: std_logic := '0';"

    /// A function definition.
    let definition = PackageBodyBlock.fnDefinition(value: FunctionDefinition(
        name: VariableName(text: "max"),
        arguments: [
            ArgumentDefinition(name: VariableName(text: "x"), type: .signal(type: .real)),
            ArgumentDefinition(name: VariableName(text: "y"), type: .signal(type: .real))
        ],
        returnType: .signal(type: .real)
    ))

    /// The equivalent `VHDL` code for `definition`.
    let definitionRaw = "function max(x: real; y: real) return real;"

    /// A function implementation.
    let implementation = PackageBodyBlock.fnImplementation(value: FunctionImplementation(
        name: VariableName(text: "max"),
        arguments: [
            ArgumentDefinition(name: VariableName(text: "x"), type: .signal(type: .real)),
            ArgumentDefinition(name: VariableName(text: "y"), type: .signal(type: .real))
        ],
        returnTube: .signal(type: .real),
        body: .ifStatement(block: .ifElse(
            condition: .conditional(condition: .comparison(value: .lessThan(
                lhs: .reference(variable: .variable(reference: .variable(name: VariableName(text: "x")))),
                rhs: .reference(variable: .variable(reference: .variable(name: VariableName(text: "y"))))
            ))),
            ifBlock: .statement(statement: .returns(value: .reference(
                variable: .variable(reference: .variable(name: VariableName(text: "y")))
            ))),
            elseBlock: .statement(statement: .returns(value: .reference(
                variable: .variable(reference: .variable(name: VariableName(text: "x")))
            )))
        ))
    ))

    /// The equivalent `VHDL` code for `implementation`.
    let implementationRaw = """
    function max(x: real; y: real) return real is
    begin
        if (x < y) then
            return y;
        else
            return x;
        end if;
    end function;
    """

    /// An include statement.
    let include = PackageBodyBlock.include(value: "IEEE.std_logic_1164.all")

    /// The equivalent `VHDL` code for `include`.
    let includeRaw = "use IEEE.std_logic_1164.all;"

    /// A record.
    let record = PackageBodyBlock.type(value: .record(value: Record(
        name: VariableName(text: "Record_t"),
        types: [
            RecordTypeDeclaration(name: VariableName(text: "x"), type: .signal(type: .stdLogic)),
            RecordTypeDeclaration(name: VariableName(text: "y"), type: .signal(type: .stdLogic))
        ]
    )))

    /// The equivalent `VHDL` code for `record`.
    let recordRaw = """
    type Record_t is record
        x: std_logic;
        y: std_logic;
    end record Record_t;
    """

    /// Test `init(blocks:)` correctly handles all possible cases.
    func testBlocksInit() {
        XCTAssertNil(PackageBodyBlock(blocks: []))
        XCTAssertEqual(PackageBodyBlock(blocks: [include]), include)
        let blocks = [include, alias]
        XCTAssertEqual(PackageBodyBlock(blocks: blocks), .blocks(values: blocks))
    }

    /// Test that `rawValue` returns the correct `VHDL` code.
    func testRawValue() {
        XCTAssertEqual(alias.rawValue, aliasRaw)
        XCTAssertEqual(comment.rawValue, commentRaw)
        XCTAssertEqual(constant.rawValue, constantRaw)
        XCTAssertEqual(definition.rawValue, definitionRaw)
        XCTAssertEqual(implementation.rawValue, implementationRaw)
        XCTAssertEqual(include.rawValue, includeRaw)
        XCTAssertEqual(record.rawValue, recordRaw)
    }

    /// Test that type aliases are parsed correctly.
    func testAlias() {
        XCTAssertEqual(PackageBodyBlock(rawValue: aliasRaw), alias)
    }

    /// Test that comments are parsed correctly.
    func testComment() {
        XCTAssertEqual(PackageBodyBlock(rawValue: commentRaw), comment)
    }

    /// Test that constants are parsed correctly.
    func testConstant() {
        XCTAssertEqual(PackageBodyBlock(rawValue: constantRaw), constant)
    }

    /// Test that function definitions are parsed correctly.
    func testDefinition() {
        XCTAssertEqual(PackageBodyBlock(rawValue: definitionRaw), definition)
    }

    /// Test that function implementations are parsed correctly.
    func testImplementation() {
        XCTAssertEqual(PackageBodyBlock(rawValue: implementationRaw), implementation)
    }

    /// Test that include statements are parsed correctly.
    func testInclude() {
        XCTAssertEqual(PackageBodyBlock(rawValue: includeRaw), include)
    }

    /// Test that records are parsed correctly.
    func testRecord() {
        XCTAssertEqual(PackageBodyBlock(rawValue: recordRaw), record)
    }

    /// Test that multiple blocks are parsed correctly.
    func testMultiple() {
        let raw = aliasRaw + "\n" + commentRaw + "\n" + constantRaw + "\n" + definitionRaw + "\n" +
            implementationRaw + "\n" + includeRaw + "\n" + recordRaw
        let blocks = [alias, comment, constant, definition, implementation, include, record]
        XCTAssertEqual(PackageBodyBlock(rawValue: raw), .blocks(values: blocks))
    }

    /// Test that multiple aliases are parsed correctly.
    func testMultipleAlias() {
        let raw = aliasRaw + "\n" + aliasRaw + "\n" + aliasRaw
        let blocks = [alias, alias, alias]
        XCTAssertEqual(PackageBodyBlock(rawValue: raw), .blocks(values: blocks))
    }

    /// Test that multiple comments are parsed correctly.
    func testMultipleComment() {
        let raw = commentRaw + "\n" + commentRaw + "\n" + commentRaw
        let blocks = [comment, comment, comment]
        XCTAssertEqual(PackageBodyBlock(rawValue: raw), .blocks(values: blocks))
    }

    /// Test that multiple constants are parsed correctly.
    func testMultipleConstant() {
        let raw = constantRaw + "\n" + constantRaw + "\n" + constantRaw
        let blocks = [constant, constant, constant]
        XCTAssertEqual(PackageBodyBlock(rawValue: raw), .blocks(values: blocks))
    }

    /// Test that multiple function definitions are parsed correctly.
    func testMultipleDefinition() {
        let raw = definitionRaw + "\n" + definitionRaw + "\n" + definitionRaw
        let blocks = [definition, definition, definition]
        XCTAssertEqual(PackageBodyBlock(rawValue: raw), .blocks(values: blocks))
    }

    /// Test that multiple function implementations are parsed correctly.
    func testMultipleImplementation() {
        let raw = implementationRaw + "\n" + implementationRaw + "\n" + implementationRaw
        let blocks = [implementation, implementation, implementation]
        XCTAssertEqual(PackageBodyBlock(rawValue: raw), .blocks(values: blocks))
    }

    /// Test that multiple include statements are parsed correctly.
    func testMultipleInclude() {
        let raw = includeRaw + "\n" + includeRaw + "\n" + includeRaw
        let blocks = [include, include, include]
        XCTAssertEqual(PackageBodyBlock(rawValue: raw), .blocks(values: blocks))
    }

    /// Test that multiple records are parsed correctly.
    func testMultipleRecord() {
        let raw = recordRaw + "\n" + recordRaw + "\n" + recordRaw
        let blocks = [record, record, record]
        XCTAssertEqual(PackageBodyBlock(rawValue: raw), .blocks(values: blocks))
    }

}
