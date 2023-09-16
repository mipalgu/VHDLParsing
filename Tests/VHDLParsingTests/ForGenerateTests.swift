// ForGenerateTests.swift
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

/// Test class for ``ForGenerate``.
final class ForGenerateTests: XCTestCase {

    /// The label.
    let label = VariableName(text: "generator_inst")

    /// The iterator.
    let iterator = VariableName(text: "i")

    /// The range.
    let range = VectorSize.to(
        lower: .literal(value: .integer(value: 0)), upper: .literal(value: .integer(value: 3))
    )

    /// The body.
    let body = AsynchronousBlock.statement(statement: .assignment(
        name: .indexed(
            name: .reference(variable: .variable(reference: .variable(name: VariableName(text: "ys")))),
            index: .index(value: .reference(variable: .variable(
                reference: .variable(name: VariableName(text: "i"))
            )))
        ),
        value: .expression(value: .reference(variable: .indexed(
            name: .reference(variable: .variable(reference: .variable(name: VariableName(text: "xs")))),
            index: .index(value: .reference(variable: .variable(
                reference: .variable(name: VariableName(text: "i"))
            )))
        )))
    ))

    /// The generate expression under test.
    var generate: ForGenerate {
        ForGenerate(label: label, iterator: iterator, range: range, body: body)
    }

    /// Test the init works correctly.
    func testPropertyInit() {
        let generate = generate
        XCTAssertEqual(generate.label, label)
        XCTAssertEqual(generate.iterator, iterator)
        XCTAssertEqual(generate.range, range)
        XCTAssertEqual(generate.body, body)
    }

    /// Test the `rawValue` generates the correct `VHDL` code.
    func testRawValue() {
        let expected = """
        generator_inst: for i in 0 to 3 generate
            ys(i) <= xs(i);
        end generate generator_inst;
        """
        XCTAssertEqual(generate.rawValue, expected)
    }

}
