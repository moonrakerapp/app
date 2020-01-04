import NaturalLanguage

extension String {
    static func key(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}
