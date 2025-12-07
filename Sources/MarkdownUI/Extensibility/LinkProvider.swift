import SwiftUI

// wangqi 2025-12-07: Updated LinkProvider to use makeLink returning View for custom link rendering

/// A type that provides custom link handling for Markdown links.
///
/// The protocol uses `linkText: String` instead of `[InlineNode]` to:
/// 1. Keep InlineNode internal to MarkdownUI (no leaking internal types)
/// 2. Allow app-side providers to work with simple strings
/// 3. Keep the API decoupled and simple
///
/// To configure the current link provider for a view hierarchy, use the `markdownLinkProvider(_:)` modifier.
///
/// The following example shows how to configure a custom link provider:
///
/// ```swift
/// Markdown {
///   "[Visit Apple](https://apple.com)"
/// }
/// .markdownLinkProvider(MyCustomLinkProvider())
/// ```
public protocol LinkProvider {
    associatedtype Body: View

    /// Creates a view for the given link.
    /// - Parameters:
    ///   - url: The destination URL
    ///   - title: The link title attribute (from markdown `[text](url "title")`)
    ///   - linkText: The plain text content of the link (extracted from children)
    @ViewBuilder func makeLink(
        url: URL,
        title: String?,
        linkText: String
    ) -> Body
}

/// Default link provider that uses SwiftUI's Link
public struct DefaultLinkProvider: LinkProvider {
    public init() {}

    public func makeLink(url: URL, title: String?, linkText: String) -> some View {
        Link(destination: url) {
            Text(linkText)
                .foregroundColor(.blue)
        }
    }
}

// Type-erased wrapper (internal to MarkdownUI)
struct AnyLinkProvider: LinkProvider {
    private let _makeLink: (URL, String?, String) -> AnyView

    init<L: LinkProvider>(_ linkProvider: L) {
        self._makeLink = { url, title, linkText in
            AnyView(linkProvider.makeLink(url: url, title: title, linkText: linkText))
        }
    }

    func makeLink(url: URL, title: String?, linkText: String) -> some View {
        self._makeLink(url, title, linkText)
    }
}

// MARK: - Environment Key

private struct LinkProviderKey: EnvironmentKey {
    static let defaultValue = AnyLinkProvider(DefaultLinkProvider())
}

extension EnvironmentValues {
    /// The link provider for Markdown views in this environment.
    var linkProvider: AnyLinkProvider {
        get { self[LinkProviderKey.self] }
        set { self[LinkProviderKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    /// Sets the link provider for Markdown links in a view hierarchy.
    ///
    /// Use this modifier to customize how links are rendered in Markdown content.
    ///
    /// - Parameter linkProvider: The link provider to use.
    /// - Returns: A view that uses the specified link provider.
    public func markdownLinkProvider<L: LinkProvider>(_ linkProvider: L) -> some View {
        self.environment(\.linkProvider, AnyLinkProvider(linkProvider))
    }
}

// MARK: - Static Provider Accessors

extension LinkProvider where Self == DefaultLinkProvider {
    /// The default link provider that uses system URL handling.
    public static var `default`: DefaultLinkProvider {
        DefaultLinkProvider()
    }
}
