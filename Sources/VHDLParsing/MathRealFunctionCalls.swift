// MathRealFunctionCalls.swift
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

/// A function call where the function being called exists within the `math_real` package.
public enum MathRealFunctionCalls: FunctionCallable, Equatable, Hashable, Codable, Sendable {

    /// The `ceil` function.
    case ceil(expression: Expression)

    /// The `floor` function.
    case floor(expression: Expression)

    /// The `round` function.
    case round(expression: Expression)

    /// The `sign` function.
    case sign(expression: Expression)

    /// The `sqrt` function.
    case sqrt(expression: Expression)

    /// The `fmax` function.
    case fmax(arg0: Expression, arg1: Expression)

    /// The `fmin` function.
    case fmin(arg0: Expression, arg1: Expression)

    /// The `VHDL` code representing this function call.
    @inlinable public var rawValue: String {
        switch self {
        case .ceil(let expression):
            return "ceil(\(expression.rawValue))"
        case .floor(let expression):
            return "floor(\(expression.rawValue))"
        case .round(let expression):
            return "round(\(expression.rawValue))"
        case .sign(let expression):
            return "sign(\(expression.rawValue))"
        case .sqrt(let expression):
            return "sqrt(\(expression.rawValue))"
        case .fmax(let arg0, let arg1):
            return "fmax(\(arg0.rawValue), \(arg1.rawValue))"
        case .fmin(let arg0, let arg1):
            return "fmin(\(arg0.rawValue), \(arg1.rawValue))"
        }
    }

    /// Create this type by specifying the function name and it's arguments.
    /// - Parameters:
    ///   - function: The name of the `math_real` function.
    ///   - arguments: The arguments passed to the function call.
    @inlinable
    public init?(function: String, arguments: [Expression]) {
        let name = function.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if arguments.count == 1 {
            switch name {
            case "ceil":
                self = .ceil(expression: arguments[0])
            case "floor":
                self = .floor(expression: arguments[0])
            case "round":
                self = .round(expression: arguments[0])
            case "sign":
                self = .sign(expression: arguments[0])
            case "sqrt":
                self = .sqrt(expression: arguments[0])
            default:
                return nil
            }
        } else if arguments.count == 2 {
            switch name {
            case "fmax":
                self = .fmax(arg0: arguments[0], arg1: arguments[1])
            case "fmin":
                self = .fmin(arg0: arguments[0], arg1: arguments[1])
            default:
                return nil
            }
        } else {
            return nil
        }
    }

}
