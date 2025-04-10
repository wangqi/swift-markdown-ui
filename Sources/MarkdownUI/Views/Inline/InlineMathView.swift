import SwiftUI
import WebKit

// MARK: - InlineMathView
struct InlineMathView: View {
    let content: String
    @State private var viewHeight: CGFloat = 24
    @State private var viewWidth: CGFloat = 100
    
    init(content: String) {
        // Normalize backslashes to ensure consistent LaTeX command handling
        self.content = content.replacingOccurrences(of: "\\\\(", with: "\\(")
                            .replacingOccurrences(of: "\\\\)", with: "\\)")
                            .replacingOccurrences(of: "\\\\", with: "\\")
    }
    
    var body: some View {
        let escapedContent = content
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "`", with: "\\`")
        
        let htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
            <style>
                body {
                    margin: 0;
                    padding: 0;
                    background-color: transparent;
                    display: inline-block;
                }
                #math {
                    display: inline-flex;
                    align-items: center;
                    min-height: 24px;
                }
                .katex { font-size: 1.1em; }
            </style>
        </head>
        <body>
            <span id="math"></span>
            <script>
                document.addEventListener('DOMContentLoaded', function() {
                    katex.render(`\(escapedContent)`, document.getElementById('math'), {
                        throwOnError: false,
                        displayMode: false,
                        output: 'html',
                        trust: true
                    });
                    
                    // Send dimensions to Swift
                    const height = document.getElementById('math').offsetHeight;
                    const width = document.getElementById('math').offsetWidth;
                    
                    // Ensure minimum dimensions
                    const finalHeight = Math.max(height, 24);
                    const finalWidth = Math.max(width, 50);
                    
                    window.webkit.messageHandlers.dimensionsHandler.postMessage({
                        height: finalHeight,
                        width: finalWidth
                    });
                });
            </script>
        </body>
        </html>
        """
        
        InlineMathWebView(htmlContent: htmlContent, onDimensionsChange: { height, width in
            viewHeight = CGFloat(height)
            viewWidth = CGFloat(width)
        })
        .frame(width: viewWidth, height: viewHeight)
        .fixedSize(horizontal: true, vertical: true)
    }
}

// MARK: - InlineMathWebView
struct InlineMathWebView: PlatformViewRepresentable {
    let htmlContent: String
    let onDimensionsChange: (Double, Double) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onDimensionsChange: onDimensionsChange)
    }
    
    // iOS-specific
    #if canImport(UIKit)
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        controller.add(context.coordinator, name: "dimensionsHandler")
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
        controller.add(context.coordinator, name: "dimensionsHandler")
        config.userContentController = controller
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
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
        let onDimensionsChange: (Double, Double) -> Void
        
        init(onDimensionsChange: @escaping (Double, Double) -> Void) {
            self.onDimensionsChange = onDimensionsChange
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "dimensionsHandler",
               let dimensions = message.body as? [String: Double],
               let height = dimensions["height"],
               let width = dimensions["width"] {
                onDimensionsChange(height, width)
            }
        }
    }
}
