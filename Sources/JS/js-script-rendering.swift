import DSL

public extension JSSource {
    func rendered_file_content(
        ensure_trailing_newline: Bool = true
    ) -> String {
        if ensure_trailing_newline && !code.hasSuffix("\n") {
            return code + "\n"
        }

        return code
    }

    func as_inline_script(
        _ attributes: JSScriptAttributes = .default
    ) -> JSScript {
        return .inline(
            self,
            attributes: attributes
        )
    }
}

public extension JSExternalSource {
    func as_external_script(
        _ attributes: JSScriptAttributes = .default
    ) -> JSScript {
        return .external(
            self,
            attributes: attributes
        )
    }
}

public extension JSScript {
    func rendered_file_content(
        ensure_trailing_newline: Bool = true
    ) -> String? {
        switch self {
        case .inline(let source, _):
            return source.rendered_file_content(
                ensure_trailing_newline: ensure_trailing_newline
            )

        case .external:
            return nil
        }
    }
}

public extension JSScript {
    func scoped<Scope: ScopeIdentifying>(
        _ scope: Scope
    ) -> JSBundledScript {
        JSBundledScript(
            scope: scope.scope,
            script: self
        )
    }

    func scoped(
        _ scope: ScopeIdentifier
    ) -> JSBundledScript {
        JSBundledScript(
            scope: scope,
            script: self
        )
    }
}
