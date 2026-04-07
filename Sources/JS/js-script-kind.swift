public enum JSScriptKind: Sendable, Equatable {
    case classic
    case module

    public var html_type_attribute: String? {
        switch self {
        case .classic:
            return nil
        case .module:
            return "module"
        }
    }
}
