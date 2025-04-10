import Foundation
import SwiftUI

// MARK: - InlineMathAttribute
struct InlineMathAttribute: AttributedStringKey {
    typealias Value = String
    static let name = "inlineMath"
}

// MARK: - AttributeScopes Extension
extension AttributeScopes {
    struct MarkdownAttributes: AttributeScope {
        let inlineMath: InlineMathAttribute
    }
    
    var markdown: MarkdownAttributes.Type { MarkdownAttributes.self }
}

// Register the attribute scope
extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<AttributeScopes.MarkdownAttributes, T>) -> T {
        return self[T.self]
    }
}



// MARK: - AttributeContainer Extension
extension AttributeContainer {
    var inlineMath: String? {
        get { self[InlineMathAttribute.self] }
        set { self[InlineMathAttribute.self] = newValue }
    }
}
