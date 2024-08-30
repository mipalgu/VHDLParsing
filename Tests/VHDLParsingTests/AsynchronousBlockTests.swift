// AsynchronousBlockTests.swift
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

// swiftlint:disable file_length
// swiftlint:disable type_body_length

/// Test class for ``AsynchronousBlock``.
final class AsynchronousBlockTests: XCTestCase {

    /// A variable `x`.
    let x = VariableName(text: "x")

    /// A variable `y`.
    let y = VariableName(text: "y")

    /// A variable `clk`.
    let clk = VariableName(text: "clk")

    /// An expression for `x`.
    lazy var varX = Expression.reference(variable: .variable(reference: .variable(name: x)))

    /// An expression for `y`.
    lazy var varY = Expression.reference(variable: .variable(reference: .variable(name: y)))

    /// An expression for `clk`.
    lazy var varClk = Expression.reference(variable: .variable(reference: .variable(name: clk)))

    /// Reset test data.
    override func setUp() {
        super.setUp()
        varX = Expression.reference(variable: .variable(reference: .variable(name: x)))
        varY = Expression.reference(variable: .variable(reference: .variable(name: y)))
        varClk = Expression.reference(variable: .variable(reference: .variable(name: clk)))
    }

    /// Test `rawValue` is correct.
    func testRawValue() {
        let statement = AsynchronousStatement.assignment(
            name: .variable(reference: .variable(name: x)),
            value: .expression(value: varY)
        )
        let syncStatement = Statement.assignment(name: .variable(reference: .variable(name: x)), value: varY)
        let block = AsynchronousBlock.statement(statement: statement)
        let blockRaw = "x <= y;"
        XCTAssertEqual(block.rawValue, blockRaw)
        let process = AsynchronousBlock.process(
            block: ProcessBlock(
                sensitivityList: [clk],
                code: .ifStatement(
                    block: IfBlock.ifStatement(
                        condition: .conditional(condition: .edge(value: .rising(expression: varClk))),
                        ifBlock: .statement(statement: syncStatement)
                    )
                )
            )
        )
        let expected = """
            process(clk)
            begin
                if (rising_edge(clk)) then
                    x <= y;
                end if;
            end process;
            """
        XCTAssertEqual(process.rawValue, expected)
        let blocks = [block, process, block, block]
        let expected2 = [blockRaw, expected, blockRaw, blockRaw].joined(separator: "\n")
        XCTAssertEqual(AsynchronousBlock.blocks(blocks: blocks).rawValue, expected2)
    }

    /// Test raw value init for process.
    func testProcessRawValueInit() {
        let statement = Statement.assignment(name: .variable(reference: .variable(name: x)), value: varY)
        let raw = """
            process (clk)
            begin
                if (rising_edge(clk)) then
                    x <= y;
                end if;
            end process;
            """
        let process = AsynchronousBlock.process(
            block: ProcessBlock(
                sensitivityList: [clk],
                code: .ifStatement(
                    block: IfBlock.ifStatement(
                        condition: .conditional(condition: .edge(value: .rising(expression: varClk))),
                        ifBlock: .statement(statement: statement)
                    )
                )
            )
        )
        XCTAssertEqual(AsynchronousBlock(rawValue: raw), process)
        let raw2 = """
            process (clk)
            begin
                if (rising_edge(clk)) then
                    x <= y;
                end if;
            end processs;
            """
        XCTAssertNil(AsynchronousBlock(rawValue: raw2))
        XCTAssertNil(AsynchronousBlock(rawValue: ""))
        XCTAssertNil(AsynchronousBlock(rawValue: String(repeating: "x", count: 4096)))
    }

    /// Test raw value init for statement.
    func testStatementRawValueInit() {
        let statement = AsynchronousStatement.assignment(
            name: .variable(reference: .variable(name: x)),
            value: .expression(value: varY)
        )
        let block = AsynchronousBlock.statement(statement: statement)
        let raw = "x <= y;"
        XCTAssertEqual(AsynchronousBlock(rawValue: raw), block)
        XCTAssertNil(AsynchronousBlock(rawValue: "x <== y;"))
        XCTAssertNil(AsynchronousBlock(rawValue: "x <= y;\nx <== y;"))
    }

    /// test raw value init for multiple statements.
    func testMultipleStatementsRawValueInit() {
        let statement = AsynchronousStatement.assignment(
            name: .variable(reference: .variable(name: x)),
            value: .expression(value: varY)
        )
        let block = AsynchronousBlock.statement(statement: statement)
        let raw = """
            x <= y;
            x <= y;
            x <= y;
            """
        XCTAssertEqual(AsynchronousBlock(rawValue: raw), .blocks(blocks: [block, block, block]))
    }

    // swiftlint:disable function_body_length

    /// Test init works for multiple statements.
    func testMultipleRawValueInit() {
        let statement = Statement.assignment(name: .variable(reference: .variable(name: x)), value: varY)
        let asyncStatement = AsynchronousStatement.assignment(
            name: .variable(reference: .variable(name: x)),
            value: .expression(value: varY)
        )
        let block = AsynchronousBlock.statement(statement: asyncStatement)
        let process = AsynchronousBlock.process(
            block: ProcessBlock(
                sensitivityList: [clk],
                code: .ifStatement(
                    block: IfBlock.ifStatement(
                        condition: .conditional(condition: .edge(value: .rising(expression: varClk))),
                        ifBlock: .statement(statement: statement)
                    )
                )
            )
        )
        let component = AsynchronousBlock.component(
            block: ComponentInstantiation(
                label: VariableName(text: "comp1"),
                name: VariableName(text: "C1"),
                port: PortMap(variables: [
                    VariableMap(
                        lhs: .variable(reference: .variable(name: x)),
                        rhs: .expression(
                            value: .reference(variable: .variable(reference: .variable(name: y)))
                        )
                    ),
                    VariableMap(
                        lhs: .variable(reference: .variable(name: VariableName(text: "z"))),
                        rhs: .open
                    ),
                ])
            )
        )
        let raw = """
            x <= y;
            comp1: C1 port map (
                x => y,
                z => open
            );
            process (clk)
            begin
                if (rising_edge(clk)) then
                    x <= y;
                end if;
            end process;
            x <= y;
            x <= y;
            """
        let expected = AsynchronousBlock.blocks(blocks: [block, component, process, block, block])
        let result = AsynchronousBlock(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    // swiftlint:enable function_body_length

    /// Test `init(rawValue:)` when raw value is a component.
    func testRawValueInitComponent() {
        let component = AsynchronousBlock.component(
            block: ComponentInstantiation(
                label: VariableName(text: "comp1"),
                name: VariableName(text: "C1"),
                port: PortMap(variables: [
                    VariableMap(
                        lhs: .variable(reference: .variable(name: x)),
                        rhs: .expression(
                            value: .reference(variable: .variable(reference: .variable(name: y)))
                        )
                    ),
                    VariableMap(
                        lhs: .variable(reference: .variable(name: VariableName(text: "z"))),
                        rhs: .open
                    ),
                ])
            )
        )
        let raw = """
            comp1: C1 port map (
                x => y,
                z => open
            );
            """
        XCTAssertEqual(AsynchronousBlock(rawValue: raw), component)
        let raw2 = """
            comp1: C1 port map (
                x => y,
                z => open
            )
            """
        XCTAssertNil(AsynchronousBlock(rawValue: raw2))
        let raw3 = """
            comp1: C1 port map (
                x => y,
                z => open
            ));
            """
        XCTAssertNil(AsynchronousBlock(rawValue: raw3))
    }

    // swiftlint:disable function_body_length

    /// Test function raw value initialiser functions correctly.
    func testFunctionRawValueInit() {
        let raw = """
            function max(arg1: integer := 0; arg2: integer := 0) return integer is
            begin
                if (arg1 < arg2) then
                    return arg2;
                else
                    return arg1;
                end if;
            end function;
            """
        let expected = AsynchronousBlock.function(
            block: FunctionImplementation(
                name: VariableName(text: "max"),
                arguments: [
                    ArgumentDefinition(
                        name: VariableName(text: "arg1"),
                        type: .signal(type: .integer),
                        defaultValue: .literal(value: .integer(value: 0))
                    ),
                    ArgumentDefinition(
                        name: VariableName(text: "arg2"),
                        type: .signal(type: .integer),
                        defaultValue: .literal(value: .integer(value: 0))
                    ),
                ],
                returnType: .signal(type: .integer),
                body: .ifStatement(
                    block: .ifElse(
                        condition: .conditional(
                            condition: .comparison(
                                value: .lessThan(
                                    lhs: .reference(
                                        variable: .variable(
                                            reference: .variable(name: VariableName(text: "arg1"))
                                        )
                                    ),
                                    rhs: .reference(
                                        variable: .variable(
                                            reference: .variable(name: VariableName(text: "arg2"))
                                        )
                                    )
                                )
                            )
                        ),
                        ifBlock: .statement(
                            statement: .returns(
                                value: .reference(
                                    variable: .variable(
                                        reference: .variable(name: VariableName(text: "arg2"))
                                    )
                                )
                            )
                        ),
                        elseBlock: .statement(
                            statement: .returns(
                                value: .reference(
                                    variable: .variable(
                                        reference: .variable(name: VariableName(text: "arg1"))
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
        XCTAssertEqual(AsynchronousBlock(rawValue: raw), expected)
        let raw2 = raw + "\n" + "x <= 5;"
        let expected2 = AsynchronousBlock.blocks(blocks: [
            expected,
            .statement(
                statement: .assignment(
                    name: .variable(reference: .variable(name: VariableName(text: "x"))),
                    value: .expression(value: .literal(value: .integer(value: 5)))
                )
            ),
        ])
        XCTAssertEqual(AsynchronousBlock(rawValue: raw2), expected2)
    }

    // swiftlint:enable function_body_length

    /// Test function `init(rawValue:)` detects invalid code.
    func testFunctionRawValueInitFails() {
        let raw = """
            function max(arg1: integer := 0; arg2: integer := 0) return integer is
            begin
                if (arg1 < arg2) then
                    return arg2;
                else
                    return arg1;
                end if;
            end function;
            """
        XCTAssertNil(AsynchronousBlock(rawValue: String(raw.dropLast()) + "\nx <= 5;"))
        let invalid = """
            function max(arg1:: integer := 0; arg2: integer := 0) return integer is
            begin
                if (arg1 < arg2) then
                    return arg2;
                else
                    return arg1;
                end if;
            end function;
            x <= 5;
            """
        XCTAssertNil(AsynchronousBlock(rawValue: invalid))
    }

    /// Test `generate` blocks.
    func testGenerateRawValueInit() {
        let raw = """
            generator_inst: for i in 0 to 3 generate
                ys(i) <= xs(i);
            end generate generator_inst;
            """
        let body = AsynchronousBlock.statement(
            statement: .assignment(
                name: .indexed(
                    name: .reference(
                        variable: .variable(reference: .variable(name: VariableName(text: "ys")))
                    ),
                    index: .index(
                        value: .reference(
                            variable: .variable(
                                reference: .variable(name: VariableName(text: "i"))
                            )
                        )
                    )
                ),
                value: .expression(
                    value: .reference(
                        variable: .indexed(
                            name: .reference(
                                variable: .variable(reference: .variable(name: VariableName(text: "xs")))
                            ),
                            index: .index(
                                value: .reference(
                                    variable: .variable(
                                        reference: .variable(name: VariableName(text: "i"))
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
        let forLoop = ForGenerate(
            label: VariableName(text: "generator_inst"),
            iterator: VariableName(text: "i"),
            range: .to(
                lower: .literal(value: .integer(value: 0)),
                upper: .literal(value: .integer(value: 3))
            ),
            body: body
        )
        XCTAssertEqual(AsynchronousBlock(rawValue: raw), .generate(block: .forLoop(block: forLoop)))
    }

    // swiftlint:disable function_body_length

    /// Test `generate` multiple.
    func testMultipleGenerate() {
        let raw = """
            y <= x;
            generator_inst: for i in 0 to 3 generate
                ys(i) <= xs(i);
            end generate generator_inst;
            x <= y;
            """
        let body = AsynchronousBlock.statement(
            statement: .assignment(
                name: .indexed(
                    name: .reference(
                        variable: .variable(reference: .variable(name: VariableName(text: "ys")))
                    ),
                    index: .index(
                        value: .reference(
                            variable: .variable(
                                reference: .variable(name: VariableName(text: "i"))
                            )
                        )
                    )
                ),
                value: .expression(
                    value: .reference(
                        variable: .indexed(
                            name: .reference(
                                variable: .variable(reference: .variable(name: VariableName(text: "xs")))
                            ),
                            index: .index(
                                value: .reference(
                                    variable: .variable(
                                        reference: .variable(name: VariableName(text: "i"))
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
        let forLoop = ForGenerate(
            label: VariableName(text: "generator_inst"),
            iterator: VariableName(text: "i"),
            range: .to(
                lower: .literal(value: .integer(value: 0)),
                upper: .literal(value: .integer(value: 3))
            ),
            body: body
        )
        let yAssignment = AsynchronousBlock.statement(
            statement: .assignment(
                name: .variable(reference: .variable(name: y)),
                value: .expression(value: varX)
            )
        )
        let xAssignment = AsynchronousBlock.statement(
            statement: .assignment(
                name: .variable(reference: .variable(name: x)),
                value: .expression(value: varY)
            )
        )

        let forBlock = AsynchronousBlock.generate(block: .forLoop(block: forLoop))
        XCTAssertEqual(
            AsynchronousBlock(rawValue: raw),
            .blocks(blocks: [yAssignment, forBlock, xAssignment])
        )
        let raw2 = """
            y <= x;
            generator_inst: for i in 0 to 3 generate
                ys(i) <= xs(i);
            end generate generator_inst;
            """
        XCTAssertEqual(AsynchronousBlock(rawValue: raw2), .blocks(blocks: [yAssignment, forBlock]))
    }

    // swiftlint:enable function_body_length

    /// Test invalid multiple generate statements.
    func testInvalidMultipleGenerate() {
        let raw = """
            y <= x;
            label: for i in 0 to 3 generate
                ys(i) <= xs(i);
            end generate generator_inst;
            x <= y;
            """
        XCTAssertNil(AsynchronousBlock(rawValue: raw))
        let raw2 = """
            y <= x;
            generator_inst: for i in 0 to 3 generate
                ys(i) <= xs(i);
            end generate generator_inst
            x <= y;
            """
        XCTAssertNil(AsynchronousBlock(rawValue: raw2))
        let raw3 = """
            y <= x;
            generator_inst: for i in 0 to 3 generate
                ys(i) <= xs(i!);
            end generate generator_inst
            x <= y;
            """
        XCTAssertNil(AsynchronousBlock(rawValue: raw3))
    }

}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
