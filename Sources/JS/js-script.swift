public enum JSScript: Sendable, Equatable {
    case inline(
        JSSource,
        attributes: JSScriptAttributes = .default
    )

    case external(
        JSExternalSource,
        attributes: JSScriptAttributes = .default
    )
}
