import Foundation

public struct JSSource: Sendable, Equatable, ExpressibleByStringLiteral {
    public var code: String

    public init(_ code: String) {
        self.code = code
    }

    public init(stringLiteral value: String) {
        self.code = value
    }

    public func render() -> String {
        return code
    }

    public func appending(
        _ other: JSSource,
        separator: String = "\n"
    ) -> JSSource {
        guard !self.code.isEmpty else {
            return other
        }

        guard !other.code.isEmpty else {
            return self
        }

        return JSSource(
            self.code + separator + other.code
        )
    }
}

extension Array where Element == JSSource {
    public func render(
        separator: String = "\n"
    ) -> String {
        return self
            .map { $0.render() }
            .joined(separator: separator)
    }

    public func joinedSource(
        separator: String = "\n"
    ) -> JSSource {
        return JSSource(
            self.render(separator: separator)
        )
    }
}

public extension JSSource {
    static func call(
        _ fn: String,
        _ args: [JSValue] = []
    ) -> JSSource {
        return JSSource(
            JS.call(fn, args)
        )
    }

    static func assign(
        _ lhs: String,
        _ rhs: JSValue
    ) -> JSSource {
        return JSSource(
            JS.assign(lhs, rhs)
        )
    }
}

public extension Array where Element == JSScript {
    func rendered_file_contents() -> [String] {
        return self.compactMap {
            $0.rendered_file_content()
        }
    }
}
