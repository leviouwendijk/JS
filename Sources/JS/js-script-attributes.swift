public struct JSScriptAttributes: Sendable, Equatable {
    public var kind: JSScriptKind
    public var defer_loading: Bool
    public var async_loading: Bool
    public var integrity: String?
    public var crossorigin: String?
    public var nonce: String?

    public init(
        kind: JSScriptKind = .classic,
        defer_loading: Bool = false,
        async_loading: Bool = false,
        integrity: String? = nil,
        crossorigin: String? = nil,
        nonce: String? = nil
    ) {
        self.kind = kind
        self.defer_loading = defer_loading
        self.async_loading = async_loading
        self.integrity = integrity
        self.crossorigin = crossorigin
        self.nonce = nonce
    }

    public static let `default` = JSScriptAttributes()

    public static let module = JSScriptAttributes(
        kind: .module
    )
}

extension JSScriptAttributes {
    internal func render_html_attributes() -> String {
        var parts: [String] = []

        if let type = kind.html_type_attribute {
            parts.append("type=\"\(type)\"")
        }

        if defer_loading {
            parts.append("defer")
        }

        if async_loading {
            parts.append("async")
        }

        if let integrity {
            parts.append("integrity=\"\(integrity)\"")
        }

        if let crossorigin {
            parts.append("crossorigin=\"\(crossorigin)\"")
        }

        if let nonce {
            parts.append("nonce=\"\(nonce)\"")
        }

        return parts.joined(separator: " ")
    }
}
