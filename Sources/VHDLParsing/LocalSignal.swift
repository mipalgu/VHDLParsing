//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

/// A local signal is a signal that exists within the scope of a VHDL entity. It is a signal that is defined
/// within a machine/arrangement and can be though of as a type of machine variable in VHDL.
public struct LocalSignal: RawRepresentable, Codable, Equatable, Hashable, Sendable {

    /// The type of the signal.
    public var type: Type

    /// The name of the signal.
    public var name: VariableName

    /// The default value of the signal.
    public var defaultValue: Expression?

    /// The comment of the signal.
    public var comment: Comment?

    /// The VHDL code that represents this signals definition.
    @inlinable public var rawValue: String {
        let declaration = "signal \(name.rawValue): \(type.rawValue)"
        let comment = self.comment.map { " " + $0.rawValue } ?? ""
        guard let defaultValue = defaultValue else {
            return declaration + ";\(comment)"
        }
        return declaration + " := \(defaultValue.rawValue);\(comment)"
    }

    /// Initialises a new machine signal with the given type, name, default value and comment.
    /// - Parameters:
    ///   - type: The type of the signal.
    ///   - name: The name of the signal.
    ///   - defaultValue: The default value of the signal.
    ///   - comment: The comment of the signal.
    /// - Warning: Make sure the `defaultValue` is valid for the given signal `type`. The program will crash
    /// if this is not the case.
    @inlinable
    public init(
        type: Type, name: VariableName, defaultValue: Expression? = nil, comment: Comment? = nil
    ) {
        if let defaultValue = defaultValue, case .literal(let literal) = defaultValue {
            if case .signal(let type) = type {
                guard literal.isValid(for: type) else {
                    fatalError("Invalid literal \(defaultValue) for signal type \(type).")
                }
            }
        }
        self.type = type
        self.name = name
        self.defaultValue = defaultValue
        self.comment = comment
    }

    /// Initialises a new machine signal with the given type, name, default value and comment.
    /// - Parameters:
    ///   - type: The type of the signal.
    ///   - name: The name of the signal.
    ///   - defaultValue: The default value of the signal.
    ///   - comment: The comment of the signal.
    /// - Warning: Make sure the `defaultValue` is valid for the given signal `type`. The program will crash
    /// if this is not the case.
    @inlinable
    public init(
        type: SignalType, name: VariableName, defaultValue: Expression? = nil, comment: Comment? = nil
    ) {
        self.init(type: .signal(type: type), name: name, defaultValue: defaultValue, comment: comment)
    }

    /// Initialises a new local signal from the VHDL code that defines it.
    /// - Parameter rawValue: The VHDL code that defines this signal.
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            trimmedString.count < 2048, trimmedString.hasPrefix("signal "), trimmedString.contains(";")
        else {
            return nil
        }
        let components = trimmedString.components(separatedBy: ";")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let comment: Comment?
        if components.count >= 2 {
            guard let newComment = Comment(rawValue: components[1...].joined(separator: ";")) else {
                return nil
            }
            comment = newComment
        } else {
            comment = nil
        }
        guard let declaration = components.first else {
            return nil
        }
        guard declaration.contains(":=") else {
            guard let signal = LocalSignal(declaration: declaration, comment: comment) else {
                return nil
            }
            self = signal
            return
        }
        let declComponents = declaration.components(separatedBy: ":=")
        guard declComponents.count == 2 else {
            return nil
        }
        self.init(
            declaration: declComponents[0].trimmingCharacters(in: .whitespaces),
            defaultValue: declComponents[1].trimmingCharacters(in: .whitespaces),
            comment: comment
        )
    }

    /// Initialises a new local signal from the given declaration, default value and comment VHDL components.
    /// - Parameters:
    ///   - declaration: The declaration string consisting of the signal name and type definition.
    ///   - defaultValue: The default value of the signal. This value appears on the rhs of the `:=` operator.
    ///   - comment: The comment that appears on the rhs of the `--` operator.
    private init?(declaration: String, defaultValue: String? = nil, comment: Comment? = nil) {
        let signalComponents = declaration.components(separatedBy: .whitespacesAndNewlines)
        let value = Expression(rawValue: defaultValue ?? "")
        if defaultValue != nil, value == nil {
            return nil
        }
        guard signalComponents.count >= 2 else {
            return nil
        }
        let hasColonSuffix = signalComponents[1].hasSuffix(":")
        let colonComponents = signalComponents.filter { $0.contains(":") }
        guard
            signalComponents.count >= 3,
            hasColonSuffix || signalComponents[2] == ":",
            colonComponents.count == 1,
            colonComponents[0].filter({ $0 == ":" }).count == 1
        else {
            return nil
        }
        let typeIndex = hasColonSuffix ? 2 : 3
        guard
            signalComponents.first == "signal",
            signalComponents.count >= typeIndex,
            let type = Type(rawValue: signalComponents[typeIndex...].joined(separator: " "))
        else {
            return nil
        }
        let name = hasColonSuffix ? String(signalComponents[1].dropLast()) : signalComponents[1]
        guard let varName = VariableName(rawValue: name) else {
            return nil
        }
        if let val = value, case .literal(let literal) = val, case .signal(let type) = type {
            guard literal.isValid(for: type) else {
                return nil
            }
        }
        self.name = varName
        self.type = type
        self.comment = comment
        self.defaultValue = value
    }

}
