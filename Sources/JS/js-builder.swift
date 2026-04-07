public enum JS {
    public static func call(_ fn: String, _ args: [JSValue] = []) -> String {
        let rendered = args.map { $0.render() }.joined(separator: ",")
        return "\(fn)(\(rendered));"
    }

    public static func assign(_ lhs: String, _ rhs: JSValue) -> String {
        "\(lhs) = \(rhs.render());"
    }

    /// `document.addEventListener('DOMContentLoaded', () => { ... })`
    public static func onDomReady(_ body: String) -> String {
        "document.addEventListener('DOMContentLoaded',()=>{\(body)});"
    }

    /// Delegated event listener: document.addEventListener('click', e => if (e.target.matches(sel)) { ... })
    public static func on(_ event: String, selector: String, body: String) -> String {
        """
        document.addEventListener(\("\(event)".debugDescription), (e) => {
          const el = e.target.closest(\("\(selector)".debugDescription));
          if (el) { \(body) }
        });
        """
    }

    /// Wrap a one-time initializer with a guard by ID or dataset flag
    public static func guardOnce(flagExpr: String, setExpr: String, body: String) -> String {
        "if(!(\(flagExpr))){ \(setExpr) = true; \(body) }"
    }
}

public extension JS {
    static func source(
        _ code: String
    ) -> JSSource {
        return JSSource(code)
    }

    static func source(
        _ parts: [JSSource],
        separator: String = "\n"
    ) -> JSSource {
        return parts.joinedSource(
            separator: separator
        )
    }

    static func onDomReady(
        _ body: JSSource
    ) -> JSSource {
        return JSSource(
            onDomReady(body.render())
        )
    }

    static func on(
        _ event: String,
        selector: String,
        body: JSSource
    ) -> JSSource {
        return JSSource(
            on(
                event,
                selector: selector,
                body: body.render()
            )
        )
    }

    static func guardOnce(
        flagExpr: String,
        setExpr: String,
        body: JSSource
    ) -> JSSource {
        return JSSource(
            guardOnce(
                flagExpr: flagExpr,
                setExpr: setExpr,
                body: body.render()
            )
        )
    }
}

public extension JS {
    static func inline_script(
        _ source: JSSource,
        attributes: JSScriptAttributes = .default
    ) -> JSScript {
        return .inline(
            source,
            attributes: attributes
        )
    }

    static func external_script(
        _ src: String,
        attributes: JSScriptAttributes = .default
    ) -> JSScript {
        return .external(
            JSExternalSource(src),
            attributes: attributes
        )
    }

    static func module(
        _ source: JSSource
    ) -> JSScript {
        return .inline(
            source,
            attributes: .module
        )
    }

    static func external_module(
        _ src: String
    ) -> JSScript {
        return .external(
            JSExternalSource(src),
            attributes: .module
        )
    }
}
