public struct JSExternalSource: Sendable, Equatable, ExpressibleByStringLiteral {
    public var src: String

    public init(
        _ src: String
    ) {
        self.src = src
    }

    public init(stringLiteral value: String) {
        self.src = value
    }

    public func render() -> String {
        return src
    }
}
