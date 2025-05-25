import SwiftUI
import WebKit

#if canImport(UIKit)
import UIKit
/// Maps to UIViewRepresentable for iOS
typealias PlatformViewRepresentable = UIViewRepresentable
#elseif canImport(AppKit)
import AppKit
/// Maps to NSViewRepresentable for macOS
typealias PlatformViewRepresentable = NSViewRepresentable
#endif

// MARK: - MathBlockView
struct MathBlockView: View {
    let content: String
    let displayMode: Bool
    @State private var viewHeight: CGFloat = 100
    @Environment(\.colorScheme) private var colorScheme
    
    init(content: String, displayMode: Bool = true) {
        // Normalize backslashes to ensure consistent LaTeX command handling
        self.content = content.replacingOccurrences(of: "\\\\(", with: "\\(")  // Unescape \\( to \(
                            .replacingOccurrences(of: "\\\\)", with: "\\)")    // Unescape \\) to \)
                            .replacingOccurrences(of: "\\\\", with: "\\")      // Normalize double backslashes
        self.displayMode = displayMode
    }
    
    var body: some View {
        let escapedContent = content
            .replacingOccurrences(of: "\\", with: "\\\\")   // Escape backslashes for JS
            .replacingOccurrences(of: "`", with: "\\`")      // Escape backticks
        
        let htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
            <style>
                :root {
                    --bg-color: #ffffff;
                    --text-color: #000000;
                }
                @media (prefers-color-scheme: dark) {
                    :root {
                        --bg-color: #1e1e1e;
                        --text-color: #ffffff;
                    }
                }
                body {
                    margin: 0;
                    padding: 8px;
                    background-color: transparent;
                    color: var(--text-color);
                }
                #math {
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    min-height: 50px;
                    background-color: transparent;
                }
                .katex { 
                    color: var(--text-color);
                    background-color: transparent;
                }
                .katex { font-size: 1.1em; }
            </style>
        </head>
        <body>
            <div id="math"></div>
            <script>
                document.addEventListener('DOMContentLoaded', function() {
                    katex.render(`\(escapedContent)`, document.getElementById('math'), {
                        throwOnError: false,
                        displayMode: \(displayMode),
                        output: 'html',
                        trust: true
                    });
                    
                    // Send height to Swift
                    const height = document.documentElement.scrollHeight;
                    window.webkit.messageHandlers.heightHandler.postMessage(height);
                });
            </script>
        </body>
        </html>
        """
        
        WebView(htmlContent: htmlContent, onHeightChange: { height in
            viewHeight = CGFloat(height)
        })
        .frame(height: viewHeight)
        .animation(.easeInOut, value: viewHeight)
        .textSelection(.enabled)
    }
}

// MARK: - WebView
struct WebView: PlatformViewRepresentable {
    let htmlContent: String
    let onHeightChange: (Double) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onHeightChange: onHeightChange)
    }
    
    // iOS-specific
    #if canImport(UIKit)
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        controller.add(context.coordinator, name: "heightHandler")
        config.userContentController = controller
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    // macOS-specific
    #elseif canImport(AppKit)
    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        controller.add(context.coordinator, name: "heightHandler")
        config.userContentController = controller
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")  // Another way to make background clear on macOS
#if os(iOS)
        webView.scrollView.isScrollEnabled = false
#endif
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(htmlContent, baseURL: nil)
    }
    #endif
    
    // MARK: - Coordinator
    class Coordinator: NSObject, WKScriptMessageHandler {
        let onHeightChange: (Double) -> Void
        
        init(onHeightChange: @escaping (Double) -> Void) {
            self.onHeightChange = onHeightChange
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "heightHandler",
               let height = message.body as? Double {
                onHeightChange(height)
            }
        }
    }
}
