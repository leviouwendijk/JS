import DSL

public enum JSContributionResolutionError:
    Error,
    Sendable,
    Equatable
{
    case conflicting(
        identifier:
            JSContributionIdentifier
    )
}

/// Unresolved JavaScript dependency contributions.
///
/// Composition may contain repeated identities. Resolution is the boundary
/// that establishes uniqueness and conflict freedom.
public struct JSContributions:
    Sendable,
    Equatable
{
    public let contributions:
        [JSContribution]

    public init(
        _ contributions:
            [JSContribution]
    ) {
        self.contributions =
            contributions
    }

    public init(
        @JSContributionsBuilder _ content:
            () -> [JSContribution]
    ) {
        self.contributions =
            content()
    }

    public func resolve()
        throws -> ResolvedJSContributions
    {
        var resolved:
            [JSContribution] =
                []

        var indexByIdentifier:
            [
                JSContributionIdentifier:
                    Int
            ] =
                [:]

        resolved.reserveCapacity(
            contributions.count
        )

        for contribution
            in contributions
        {
            let identifier =
                contribution
                    .identifier

            guard
                let existingIndex =
                    indexByIdentifier[
                        identifier
                    ]
            else {
                indexByIdentifier[
                    identifier
                ] =
                    resolved.count

                resolved.append(
                    contribution
                )

                continue
            }

            let existing =
                resolved[
                    existingIndex
                ]

            guard
                existing.scope
                    == contribution.scope,
                existing.script
                    == contribution.script
            else {
                throw
                    JSContributionResolutionError
                        .conflicting(
                            identifier:
                                identifier
                        )
            }

            // Equivalent repeated identity:
            // retain the first semantic occurrence.
        }

        return
            ResolvedJSContributions(
                resolved:
                    resolved
            )
    }
}

/// JavaScript dependencies after identity resolution.
///
/// Construction is restricted to resolution so identifier uniqueness and
/// conflict freedom are structural invariants.
public struct ResolvedJSContributions:
    Sendable,
    Equatable
{
    public let contributions:
        [JSContribution]

    fileprivate init(
        resolved contributions:
            [JSContribution]
    ) {
        self.contributions =
            contributions
    }

    public var identifiers:
        [JSContributionIdentifier]
    {
        contributions
            .map(
                \.identifier
            )
    }

    public subscript(
        _ identifier:
            JSContributionIdentifier
    ) -> JSContribution? {
        contributions
            .first {
                $0.identifier
                    == identifier
            }
    }

    public subscript<
        Identifier:
            JSContributionIdentifying
    >(
        _ identifier:
            Identifier
    ) -> JSContribution? {
        self[
            identifier
                .jsContributionIdentifier
        ]
    }

    /// Apply scope selection without erasing resolved dependency identity.
    ///
    /// Unscoped dependencies are baseline content and survive every
    /// selection. Scoped dependencies additionally participate when the DSL
    /// scope selection includes their scope.
    public func selecting(
        _ selection:
            ScopeSelection
    ) -> ResolvedJSContributions {
        let selected =
            contributions
                .filter { contribution in
                    guard
                        let scope =
                            contribution.scope
                    else {
                        return true
                    }

                    return
                        selection
                            .includes(
                                scope:
                                    scope
                            )
                }

        return
            ResolvedJSContributions(
                resolved:
                    selected
            )
    }
}

public extension JS {
    static func contributions(
        @JSContributionsBuilder _ content:
            () -> [JSContribution]
    ) -> JSContributions {
        JSContributions(
            content
        )
    }
}
