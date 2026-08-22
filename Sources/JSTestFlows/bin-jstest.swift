import DSL
import JS
import TestFlows

@main
enum JSTestFlowMain {
    static func main() async {
        await TestFlowCLI.run(
            suite:
                JSFlowSuite.self
        )
    }
}

enum JSFlowSuite:
    TestFlowRegistry
{
    static let title =
        "JS semantic flows"

    static let flows:
        [TestFlow] =
    [
        scriptSemantics,
        contributionResolution,
        contributionSelection,
    ]

    static let scriptSemantics =
        TestFlow(
            "script-semantics",
            title:
                "JavaScript script structure remains semantic around textual source",
            tags: [
                "js",
                "script",
                "semantic",
            ]
        ) {
            Step(
                "retain inline source and attributes"
            ) {
                let attributes =
                    JSScriptAttributes(
                        kind:
                            .module,
                        defer_loading:
                            true,
                        async_loading:
                            false,
                        integrity:
                            "sha256-example",
                        crossorigin:
                            "anonymous",
                        nonce:
                            "nonce-example"
                    )

                let script =
                    JS.inline_script(
                        "window.example = true;",
                        attributes:
                            attributes
                    )

                guard
                    case .inline(
                        let source,
                        let retainedAttributes
                    ) =
                        script
                else {
                    throw
                        JSFlowFailure
                            .unexpectedScriptKind
                }

                try Expect.equal(
                    source.render(),
                    "window.example = true;",
                    "script.inline.source"
                )

                try Expect.equal(
                    retainedAttributes,
                    attributes,
                    "script.inline.attributes"
                )
            }

            Step(
                "retain external source as a semantic value"
            ) {
                let script =
                    JS.external_module(
                        "/assets/navigation.js"
                    )

                guard
                    case .external(
                        let source,
                        let attributes
                    ) =
                        script
                else {
                    throw
                        JSFlowFailure
                            .unexpectedScriptKind
                }

                try Expect.equal(
                    source,
                    JSExternalSource(
                        "/assets/navigation.js"
                    ),
                    "script.external.source"
                )

                try Expect.equal(
                    attributes.kind,
                    .module,
                    "script.external.kind"
                )
            }
        }

    static let contributionResolution =
        TestFlow(
            "contribution-resolution",
            title:
                "JavaScript dependency identity resolves without erasing script semantics",
            tags: [
                "js",
                "contribution",
                "identity",
                "resolution",
            ]
        ) {
            Step(
                "deduplicate equivalent repeated identity"
            ) {
                let navigation =
                    JS.contribution(
                        ContributionIdentity
                            .navigation,
                        script:
                            JS.module(
                                "window.navigation = {};"
                            )
                    )

                let unresolved =
                    JS.contributions {
                        navigation
                        navigation

                        JS.contribution(
                            ContributionIdentity
                                .table,
                            script:
                                JS.external_script(
                                    "/assets/table.js"
                                )
                        )
                    }

                try Expect.equal(
                    unresolved
                        .contributions
                        .count,
                    3,
                    "contributions.unresolved-count"
                )

                let resolved =
                    try unresolved
                        .resolve()

                try Expect.equal(
                    resolved
                        .identifiers
                        .map(
                            \.rawValue
                        ),
                    [
                        "navigation",
                        "table",
                    ],
                    "contributions.resolved-order"
                )

                try Expect.equal(
                    resolved
                        .contributions
                        .count,
                    2,
                    "contributions.resolved-count"
                )
            }

            Step(
                "reject conflicting script for same identity"
            ) {
                let first =
                    JS.contribution(
                        ContributionIdentity
                            .navigation,
                        script:
                            JS.inline_script(
                                "window.navigation = true;"
                            )
                    )

                let conflicting =
                    JS.contribution(
                        ContributionIdentity
                            .navigation,
                        script:
                            JS.inline_script(
                                "window.navigation = false;"
                            )
                    )

                do {
                    _ =
                        try JSContributions(
                            [
                                first,
                                conflicting,
                            ]
                        )
                        .resolve()

                    throw
                        JSFlowFailure
                            .expectedContributionConflict
                } catch
                    let error
                        as JSContributionResolutionError
                {
                    try Expect.equal(
                        error,
                        .conflicting(
                            identifier:
                                ContributionIdentity
                                    .navigation
                                    .jsContributionIdentifier
                        ),
                        "contributions.script-conflict"
                    )
                }
            }

            Step(
                "reject conflicting attributes for same identity"
            ) {
                let source:
                    JSExternalSource =
                        "/assets/navigation.js"

                let classic =
                    JSContribution(
                        identifier:
                            ContributionIdentity
                                .navigation
                                .jsContributionIdentifier,
                        script:
                            .external(
                                source,
                                attributes:
                                    .default
                            )
                    )

                let module =
                    JSContribution(
                        identifier:
                            ContributionIdentity
                                .navigation
                                .jsContributionIdentifier,
                        script:
                            .external(
                                source,
                                attributes:
                                    .module
                            )
                    )

                do {
                    _ =
                        try JSContributions(
                            [
                                classic,
                                module,
                            ]
                        )
                        .resolve()

                    throw
                        JSFlowFailure
                            .expectedContributionConflict
                } catch
                    let error
                        as JSContributionResolutionError
                {
                    try Expect.equal(
                        error,
                        .conflicting(
                            identifier:
                                ContributionIdentity
                                    .navigation
                                    .jsContributionIdentifier
                        ),
                        "contributions.attribute-conflict"
                    )
                }
            }

            Step(
                "retain rich inline and external script representation"
            ) {
                let navigation =
                    JS.contribution(
                        ContributionIdentity
                            .navigation,
                        script:
                            JS.module(
                                "window.navigation = {};"
                            )
                    )

                let resolved =
                    try JSContributions(
                        [
                            navigation,
                        ]
                    )
                    .resolve()

                guard
                    let retained =
                        resolved[
                            ContributionIdentity
                                .navigation
                        ]
                else {
                    throw
                        JSFlowFailure
                            .missingContribution
                }

                try Expect.equal(
                    retained.script,
                    navigation.script,
                    "contributions.rich-script"
                )

                try Expect.equal(
                    retained.scope,
                    nil,
                    "contributions.unscoped"
                )
            }

            Step(
                "nested unresolved collections compose before resolution"
            ) {
                let shared =
                    JS.contributions {
                        JS.contribution(
                            ContributionIdentity
                                .navigation,
                            script:
                                JS.module(
                                    "window.navigation = {};"
                                )
                        )
                    }

                let composed =
                    JS.contributions {
                        shared
                        shared

                        JS.contribution(
                            ContributionIdentity
                                .table,
                            script:
                                JS.external_script(
                                    "/assets/table.js"
                                )
                        )
                    }

                try Expect.equal(
                    composed
                        .contributions
                        .count,
                    3,
                    "contributions.composed-unresolved-count"
                )

                let resolved =
                    try composed
                        .resolve()

                try Expect.equal(
                    resolved
                        .identifiers
                        .map(
                            \.rawValue
                        ),
                    [
                        "navigation",
                        "table",
                    ],
                    "contributions.composed-order"
                )
            }
        }

    static let contributionSelection =
        TestFlow(
            "contribution-selection",
            title:
                "Scope selection remains distinct from JavaScript dependency identity",
            tags: [
                "js",
                "contribution",
                "scope",
                "selection",
            ]
        ) {
            Step(
                "retain unscoped baseline plus selected scope"
            ) {
                let resolved =
                    try JS.contributions {
                        JS.contribution(
                            ContributionIdentity
                                .base,
                            script:
                                JS.inline_script(
                                    "window.base = true;"
                                )
                        )

                        JS.contribution(
                            ContributionIdentity
                                .navigation,
                            scope:
                                FeatureScope
                                    .interactive,
                            script:
                                JS.inline_script(
                                    "window.navigation = true;"
                                )
                        )

                        JS.contribution(
                            ContributionIdentity
                                .analytics,
                            scope:
                                FeatureScope
                                    .analytics,
                            script:
                                JS.inline_script(
                                    "window.analytics = true;"
                                )
                        )
                    }
                    .resolve()

                let selected =
                    resolved
                        .selecting(
                            .scoped(
                                FeatureScope
                                    .interactive
                            )
                        )

                try Expect.equal(
                    selected
                        .identifiers
                        .map(
                            \.rawValue
                        ),
                    [
                        "base",
                        "navigation",
                    ],
                    "selection.scoped-identifiers"
                )
            }

            Step(
                "unscoped selection retains only baseline dependencies"
            ) {
                let resolved =
                    try JS.contributions {
                        JS.contribution(
                            ContributionIdentity
                                .base,
                            script:
                                JS.inline_script(
                                    "window.base = true;"
                                )
                        )

                        JS.contribution(
                            ContributionIdentity
                                .navigation,
                            scope:
                                FeatureScope
                                    .interactive,
                            script:
                                JS.inline_script(
                                    "window.navigation = true;"
                                )
                        )
                    }
                    .resolve()

                let selected =
                    resolved
                        .selecting(
                            .unscoped
                        )

                try Expect.equal(
                    selected
                        .identifiers
                        .map(
                            \.rawValue
                        ),
                    [
                        "base",
                    ],
                    "selection.unscoped-identifiers"
                )
            }

            Step(
                "excluding scope preserves unscoped and other scoped dependencies"
            ) {
                let resolved =
                    try JS.contributions {
                        JS.contribution(
                            ContributionIdentity
                                .base,
                            script:
                                JS.inline_script(
                                    "window.base = true;"
                                )
                        )

                        JS.contribution(
                            ContributionIdentity
                                .navigation,
                            scope:
                                FeatureScope
                                    .interactive,
                            script:
                                JS.inline_script(
                                    "window.navigation = true;"
                                )
                        )

                        JS.contribution(
                            ContributionIdentity
                                .analytics,
                            scope:
                                FeatureScope
                                    .analytics,
                            script:
                                JS.inline_script(
                                    "window.analytics = true;"
                                )
                        )
                    }
                    .resolve()

                let selected =
                    resolved
                        .selecting(
                            .excluding(
                                FeatureScope
                                    .analytics
                            )
                        )

                try Expect.equal(
                    selected
                        .identifiers
                        .map(
                            \.rawValue
                        ),
                    [
                        "base",
                        "navigation",
                    ],
                    "selection.excluding-identifiers"
                )
            }

            Step(
                "same identity with different scope is a conflict"
            ) {
                let unscoped =
                    JS.contribution(
                        ContributionIdentity
                            .navigation,
                        script:
                            JS.inline_script(
                                "window.navigation = true;"
                            )
                    )

                let scoped =
                    JS.contribution(
                        ContributionIdentity
                            .navigation,
                        scope:
                            FeatureScope
                                .interactive,
                        script:
                            JS.inline_script(
                                "window.navigation = true;"
                            )
                    )

                do {
                    _ =
                        try JSContributions(
                            [
                                unscoped,
                                scoped,
                            ]
                        )
                        .resolve()

                    throw
                        JSFlowFailure
                            .expectedContributionConflict
                } catch
                    let error
                        as JSContributionResolutionError
                {
                    try Expect.equal(
                        error,
                        .conflicting(
                            identifier:
                                ContributionIdentity
                                    .navigation
                                    .jsContributionIdentifier
                        ),
                        "selection.scope-is-not-identity"
                    )
                }
            }
        }
}

private enum ContributionIdentity:
    String,
    JSContributionIdentifying
{
    case base
    case navigation
    case table
    case analytics
}

private enum FeatureScope:
    String,
    ScopeIdentifying
{
    case interactive
    case analytics
}

private enum JSFlowFailure:
    Error
{
    case unexpectedScriptKind
    case missingContribution
    case expectedContributionConflict
}
