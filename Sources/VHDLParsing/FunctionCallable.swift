// FunctionCallable.swift
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

/// Helper protocol for defining types that can be executed as a function call.
public protocol FunctionCallable: RawRepresentable {

    /// Create an instance of this type by specifying the name of the function being called and the arguments
    /// passed into the function call.
    /// - Parameters:
    ///   - function: The name of the function.
    ///   - arguments: The arguments passed into the function call.
    init?(function: String, arguments: [Expression])

}

/// Default implementation.
public extension FunctionCallable where RawValue == String {

    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity

    /// Create an instance of this type by parsing the `VHDL` code calling this function.
    /// - Parameter rawValue: The `VHDL` code that calls this function.
    @inlinable
    init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            trimmedString.count < 256,
            !trimmedString.isEmpty,
            let firstWord = trimmedString.firstWord?.lowercased(),
            !Set<String>.vhdlReservedWords.contains(firstWord)
        else {
            return nil
        }
        let expressionString = trimmedString.dropFirst(firstWord.count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let rawString = expressionString.uptoBalancedBracket,
            rawString.endIndex == expressionString.endIndex,
            rawString.hasPrefix("("),
            rawString.hasSuffix(")")
        else {
            return nil
        }
        let expressions = rawString.dropFirst().dropLast()
        var index = expressions.startIndex
        var allExpressions: [Expression] = []
        var bracketCount = 0
        while index < expressions.endIndex {
            for i in expressions[index...].indices {
                let c = expressions[i]
                if c == "(" {
                    bracketCount += 1
                } else if c == ")" {
                    bracketCount -= 1
                    if bracketCount < 0 {
                        return nil
                    }
                }
                if c == "," && bracketCount == 0 {
                    guard let expression = Expression(rawValue: String(expressions[index..<i])) else {
                        return nil
                    }
                    allExpressions.append(expression)
                    index = expressions.index(after: i)
                    if index == expressions.endIndex {
                        return nil
                    }
                    break
                }
                if i == expressions.index(before: expressions.endIndex) {
                    guard let endExpression = Expression(rawValue: String(expressions[index...])) else {
                        return nil
                    }
                    allExpressions.append(endExpression)
                    index = expressions.endIndex
                }
            }
        }
        self.init(function: firstWord, arguments: allExpressions)
    }

    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length

}
