import DSL

public struct JSBundledScript: Sendable, Equatable {
    public let scope: ScopeIdentifier
    public let script: JSScript

    public init(
        scope: ScopeIdentifier,
        script: JSScript
    ) {
        self.scope = scope
        self.script = script
    }
}

@inlinable
public func bundle<Scope: ScopeIdentifying>(
    _ scope: Scope,
    _ script: JSScript
) -> JSBundledScript {
    JSBundledScript(
        scope: scope.scope,
        script: script
    )
}

@inlinable
public func bundle(
    _ scope: ScopeIdentifier,
    _ script: JSScript
) -> JSBundledScript {
    JSBundledScript(
        scope: scope,
        script: script
    )
}
