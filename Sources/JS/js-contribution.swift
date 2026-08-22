import DSL

/// One reusable JavaScript dependency.
///
/// Contribution identity and scope are deliberately distinct:
///
/// - `identifier` answers which reusable dependency this is;
/// - `scope` answers where that dependency participates in selection;
/// - `script` retains inline/external source and script attributes.
///
/// `nil` scope means unscoped and is not an absence of dependency identity.
public struct JSContribution:
    Sendable,
    Equatable
{
    public let identifier:
        JSContributionIdentifier

    public let scope:
        ScopeIdentifier?

    public let script:
        JSScript

    public init(
        identifier:
            JSContributionIdentifier,
        scope:
            ScopeIdentifier? = nil,
        script:
            JSScript
    ) {
        self.identifier =
            identifier

        self.scope =
            scope

        self.script =
            script
    }
}

public extension JS {
    static func contribution<
        Identifier:
            JSContributionIdentifying
    >(
        _ identifier:
            Identifier,
        script:
            JSScript
    ) -> JSContribution {
        JSContribution(
            identifier:
                identifier
                    .jsContributionIdentifier,
            script:
                script
        )
    }

    static func contribution<
        Identifier:
            JSContributionIdentifying,
        Scope:
            ScopeIdentifying
    >(
        _ identifier:
            Identifier,
        scope:
            Scope,
        script:
            JSScript
    ) -> JSContribution {
        JSContribution(
            identifier:
                identifier
                    .jsContributionIdentifier,
            scope:
                scope.scope,
            script:
                script
        )
    }

    static func contribution<
        Identifier:
            JSContributionIdentifying
    >(
        _ identifier:
            Identifier,
        scope:
            ScopeIdentifier,
        script:
            JSScript
    ) -> JSContribution {
        JSContribution(
            identifier:
                identifier
                    .jsContributionIdentifier,
            scope:
                scope,
            script:
                script
        )
    }
}
