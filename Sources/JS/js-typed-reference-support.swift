import DSL

public extension JS {
    static func on<Namespace>(
        _ event: DOMEvent,
        target: DOMSelectorTarget<Namespace>,
        body: String
    ) -> String {
        on(
            event.rawValue,
            selector: target.rawValue,
            body: body
        )
    }

    static func on<Namespace>(
        _ event: DOMEvent,
        target: DOMSelectorTarget<Namespace>,
        body: JSSource
    ) -> JSSource {
        JSSource(
            on(
                event.rawValue,
                selector: target.rawValue,
                body: body.render()
            )
        )
    }
}
