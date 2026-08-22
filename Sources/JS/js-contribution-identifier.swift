public struct JSContributionIdentifier:
    Sendable,
    Hashable,
    CustomStringConvertible,
    ExpressibleByStringLiteral,
    JSContributionIdentifying
{
    public let rawValue:
        String

    public init(
        _ rawValue:
            String
    ) {
        self.rawValue =
            rawValue
    }

    public init(
        stringLiteral value:
            String
    ) {
        self.init(
            value
        )
    }

    public var jsContributionIdentifier:
        JSContributionIdentifier
    {
        self
    }

    public var description:
        String
    {
        rawValue
    }
}

public protocol JSContributionIdentifying:
    Sendable
{
    var jsContributionIdentifier:
        JSContributionIdentifier
    {
        get
    }
}

public extension JSContributionIdentifying
where
    Self:
        RawRepresentable,
    Self.RawValue == String
{
    var jsContributionIdentifier:
        JSContributionIdentifier
    {
        JSContributionIdentifier(
            rawValue
        )
    }
}
