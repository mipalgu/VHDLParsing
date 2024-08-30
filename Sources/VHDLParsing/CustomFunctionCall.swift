// CustomFunctionCall.swift
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

/// A custom function call.
///
/// This struct represents a call to a function that does not exist within the standard `VHDL` packages.
public struct CustomFunctionCall: FunctionCallable, Equatable, Hashable, Codable, Sendable {

    /// The name of the function being called.
    public let name: VariableName

    /// The parameters into this function.
    ///
    /// This property may include the function labels as well.
    public let parameters: [Argument]

    /// The arguments passed to the function.
    @available(*, deprecated)
    @inlinable public var arguments: [Expression] {
        self.parameters.map { $0.argument }
    }

    /// The `VHDL` code calling function `name` with `arguments`.
    @inlinable public var rawValue: String {
        "\(self.name.rawValue)(\(self.parameters.map(\.rawValue).joined(separator: ", ")))"
    }

    /// Creates a new `CustomFunctionCall` with the given `name` and `arguments`.
    /// - Parameters:
    ///   - function: The function name as a string.
    ///   - arguments: The arguments of the function call.
    @inlinable
    @available(*, deprecated)
    public init?(function: String, arguments: [Expression]) {
        guard let name = VariableName(rawValue: function) else {
            return nil
        }
        self.init(name: name, arguments: arguments)
    }

    /// Creates a new `CustomFunctionCall` with the given `name` and `arguments`.
    /// - Parameters:
    ///   - name: The name of the function.
    ///   - arguments: The arguments of the function call.
    @inlinable
    @available(*, deprecated)
    public init(name: VariableName, arguments: [Expression]) {
        self.init(name: name, parameters: arguments.map { Argument(argument: $0) })
    }

    /// Creates a new `CustomFunctionCall` with the given `name` and `parameters`.
    /// - Parameters:
    ///   - name: The name of the function.
    ///   - parameters: The arguments of the function call.
    @inlinable
    public init(name: VariableName, parameters: [Argument]) {
        self.name = name
        self.parameters = parameters
    }

}
