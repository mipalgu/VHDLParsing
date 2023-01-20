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

/// Test class for ``AsynchronousBlock``.
final class AsynchronousBlockTests: XCTestCase {

    /// A variable `x`.
    let x = VariableName(text: "x")

    /// A variable `y`.
    let y = VariableName(text: "y")

    /// A variable `clk`.
    let clk = VariableName(text: "clk")

    /// An expression for `x`.
    lazy var varX = Expression.variable(name: x)

    /// An expression for `y`.
    lazy var varY = Expression.variable(name: y)

    /// An expression for `clk`.
    lazy var varClk = Expression.variable(name: clk)

    /// Reset test data.
    override func setUp() {
        super.setUp()
        varX = Expression.variable(name: x)
        varY = Expression.variable(name: y)
        varClk = Expression.variable(name: clk)
    }

    /// Test `rawValue` is correct.
    func testRawValue() {
        let statement = Statement.assignment(name: x, value: varY)
        let block = AsynchronousBlock.statement(statement: statement)
        XCTAssertEqual(block.rawValue, "x <= y;")
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
        let expected = """
        process (clk)
        begin
            if (rising_edge(clk)) then
                x <= y;
            end if;
        end process;
        """
        XCTAssertEqual(process.rawValue, expected)
        let blocks = [block, process, block, block]
        let blockRaw = "x <= y;"
        let expected2 = [blockRaw, expected, blockRaw, blockRaw].joined(separator: "\n")
        XCTAssertEqual(AsynchronousBlock.blocks(blocks: blocks).rawValue, expected2)
    }

}
