@resultBuilder
public enum JSContributionsBuilder {
    public static func buildBlock(
        _ parts:
            [JSContribution]...
    ) -> [JSContribution] {
        parts
            .flatMap {
                $0
            }
    }

    public static func buildExpression(
        _ contribution:
            JSContribution
    ) -> [JSContribution] {
        [
            contribution,
        ]
    }

    public static func buildExpression(
        _ contributions:
            [JSContribution]
    ) -> [JSContribution] {
        contributions
    }

    public static func buildExpression(
        _ contributions:
            JSContributions
    ) -> [JSContribution] {
        contributions
            .contributions
    }

    public static func buildOptional(
        _ part:
            [JSContribution]?
    ) -> [JSContribution] {
        part
            ?? []
    }

    public static func buildEither(
        first:
            [JSContribution]
    ) -> [JSContribution] {
        first
    }

    public static func buildEither(
        second:
            [JSContribution]
    ) -> [JSContribution] {
        second
    }

    public static func buildArray(
        _ parts:
            [[JSContribution]]
    ) -> [JSContribution] {
        parts
            .flatMap {
                $0
            }
    }
}
