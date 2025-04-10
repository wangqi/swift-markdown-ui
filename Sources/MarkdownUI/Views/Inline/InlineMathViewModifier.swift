import SwiftUI

// MARK: - InlineMathViewModifier
struct InlineMathViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .transformEnvironment(\.viewModifiers) { viewModifiers in
                viewModifiers.append(InlineMathTextModifier.self)
            }
    }
}

// MARK: - Environment Key for View Modifiers
struct ViewModifiersKey: EnvironmentKey {
    static let defaultValue: [Any.Type] = []
}

extension EnvironmentValues {
    var viewModifiers: [Any.Type] {
        get { self[ViewModifiersKey.self] }
        set { self[ViewModifiersKey.self] = newValue }
    }
}

// MARK: - View Extension
extension View {
    func renderingInlineMath() -> some View {
        modifier(InlineMathViewModifier())
    }
}
