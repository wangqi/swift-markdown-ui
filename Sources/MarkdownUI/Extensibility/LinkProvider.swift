import SwiftUI

// wangqi 2025-12-07: Added LinkProvider for custom link handling in Markdown

/// A type that provides custom link handling behavior in a Markdown view.
///
/// To configure the current link provider for a view hierarchy, use the `markdownLinkProvider(_:)` modifier.
///
/// The following example shows how to configure a custom link provider that opens links in an in-app browser:
///
/// ```swift
/// Markdown {
///   "[Visit Apple](https://apple.com)"
/// }
/// .markdownLinkProvider(.inAppBrowser)
/// ```
public protocol LinkProvider {
    /// Called when a link is tapped in the Markdown content.
    ///
    /// - Parameters:
    ///   - url: The URL of the link that was tapped.
    ///   - title: The display title/text of the link.
    /// - Returns: `true` if the link was handled, `false` to allow default system handling.
    func handleLink(url: URL, title: String?) -> Bool
}

/// Default link provider that uses system URL handling.
public struct DefaultLinkProvider: LinkProvider {
    public init() {}

    public func handleLink(url: URL, title: String?) -> Bool {
        // Return false to allow system default handling (open in Safari)
        return false
    }
}

/// Type-erased wrapper for LinkProvider
struct AnyLinkProvider: LinkProvider {
    private let _handleLink: (URL, String?) -> Bool

    init<L: LinkProvider>(_ linkProvider: L) {
        self._handleLink = linkProvider.handleLink
    }

    func handleLink(url: URL, title: String?) -> Bool {
        self._handleLink(url, title)
    }
}

// MARK: - Environment Key

private struct LinkProviderKey: EnvironmentKey {
    static let defaultValue = AnyLinkProvider(DefaultLinkProvider())
}

extension EnvironmentValues {
    /// The link provider for Markdown views in this environment.
    var markdownLinkProvider: AnyLinkProvider {
        get { self[LinkProviderKey.self] }
        set { self[LinkProviderKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    /// Sets the link provider for Markdown views within this view hierarchy.
    ///
    /// Use this modifier to customize how links are handled when tapped in Markdown content.
    ///
    /// - Parameter linkProvider: The link provider to use.
    /// - Returns: A view that uses the specified link provider.
    public func markdownLinkProvider<L: LinkProvider>(_ linkProvider: L) -> some View {
        self.environment(\.markdownLinkProvider, AnyLinkProvider(linkProvider))
    }
}

// MARK: - Static Provider Accessors

extension LinkProvider where Self == DefaultLinkProvider {
    /// The default link provider that uses system URL handling.
    public static var `default`: DefaultLinkProvider {
        DefaultLinkProvider()
    }
}
