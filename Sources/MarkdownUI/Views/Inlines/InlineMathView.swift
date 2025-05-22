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

// MARK: - InlineMathView
struct InlineMathView: View {
    let latexContent: String
    @State private var viewHeight: CGFloat = 20 // Default height for inline content
    // @State private var viewWidth: CGFloat = 50 // Optional: if dynamic width is needed

    init(latexContent: String) {
        self.latexContent = latexContent
    }

    var body: some View {
        if latexContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            EmptyView()
        } else {
            // Escape the LaTeX content for JavaScript
            // 1. Escape backslashes: \ -> \\
            // 2. Escape backticks: ` -> \`
            // 3. Escape single quotes: ' -> \' (optional, but good practice for JS strings)
            // 4. Escape double quotes: " -> \" (optional, but good practice for JS strings)
            let escapedContent = latexContent
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "`", with: "\\`")
                .replacingOccurrences(of: "'", with: "\\'")
                .replacingOccurrences(of: "\"", with: "\\\"")

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
                        padding: 0; /* Adjust if needed based on visual output */
                        background-color: transparent;
                        display: inline-block; /* Critical for inline flow */
                    }
                    .katex { 
                        font-size: 1em; /* Match surrounding text size */
                        vertical-align: middle; /* Align with surrounding text */
                    }
                    /* KaTeX itself might add .katex-display for block, ensure inline for this view */
                    .katex-display {
                        display: inline-block; /* Override if KaTeX tries to make it block */
                    }
                    #math {
                        display: inline-block; /* Ensure the container is inline */
                        /* No explicit padding here, let KaTeX decide spacing unless issues arise */
                    }
                </style>
            </head>
            <body>
                <div id="math"></div>
                <script>
                    document.addEventListener('DOMContentLoaded', function() {
                        try {
                            katex.render(`\(escapedContent)`, document.getElementById('math'), {
                                throwOnError: false,
                                displayMode: false, // Crucial for inline rendering
                                output: 'html',
                                trust: true // Consider security implications if content is user-generated
                            });
                        } catch (e) {
                            console.error("KaTeX rendering error:", e);
                            // Optionally display an error message in the div
                            document.getElementById('math').innerText = "Error rendering LaTeX";
                        }
                        
                        // Send height to Swift
                        // Use scrollHeight for dynamically sized content.
                        // For inline, clientWidth might also be relevant if width needs to be dynamic.
                        const height = document.documentElement.scrollHeight;
                        // const width = document.documentElement.scrollWidth; // If width is also needed
                        window.webkit.messageHandlers.heightHandler.postMessage(height);
                        // if (window.webkit.messageHandlers.widthHandler) { // If width handler exists
                        //     window.webkit.messageHandlers.widthHandler.postMessage(width);
                        // }
                    });
                </script>
            </body>
            </html>
            """
            
            WebView(htmlContent: htmlContent, onHeightChange: { height in
                // Add a small buffer if necessary, or ensure CSS is perfect
                self.viewHeight = CGFloat(height)
            }
            //, onWidthChange: { width in // Optional: if dynamic width is needed
            //    self.viewWidth = CGFloat(width)
            //}
            )
            .frame(height: viewHeight)
            // .frame(width: viewWidth, height: viewHeight) // Optional: if dynamic width
            // For true inline, width should ideally be intrinsic.
            // If the width is consistently too large or small, CSS adjustments are better.
        }
    }
}

// MARK: - WebView
fileprivate struct WebView: PlatformViewRepresentable {
    let htmlContent: String
    let onHeightChange: (Double) -> Void
    // let onWidthChange: ((Double) -> Void)? // Optional for dynamic width

    func makeCoordinator() -> Coordinator {
        Coordinator(onHeightChange: onHeightChange /*, onWidthChange: onWidthChange */)
    }
    
    private func makeWebView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        controller.add(context.coordinator, name: "heightHandler")
        // if onWidthChange != nil { // Optional for dynamic width
        //     controller.add(context.coordinator, name: "widthHandler")
        // }
        config.userContentController = controller
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    // iOS-specific
    #if canImport(UIKit)
    func makeUIView(context: Context) -> WKWebView {
        let webView = makeWebView(context: context)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear // Ensure scroll view bg is also clear
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Avoid reloading if content is the same and view is already loaded,
        // though for inline math, it's usually created fresh.
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    // macOS-specific
    #elseif canImport(AppKit)
    func makeNSView(context: Context) -> WKWebView {
        let webView = makeWebView(context: context)
        webView.setValue(false, forKey: "drawsBackground") // Make background clear
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Avoid reloading if content is the same and view is already loaded
        nsView.loadHTMLString(htmlContent, baseURL: nil)
    }
    #endif
    
    // MARK: - Coordinator
    class Coordinator: NSObject, WKScriptMessageHandler {
        let onHeightChange: (Double) -> Void
        // let onWidthChange: ((Double) -> Void)? // Optional

        init(onHeightChange: @escaping (Double) -> Void /*, onWidthChange: ((Double) -> Void)? = nil */) {
            self.onHeightChange = onHeightChange
            // self.onWidthChange = onWidthChange
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "heightHandler", let height = message.body as? Double {
                onHeightChange(height)
            }
            // else if message.name == "widthHandler", let width = message.body as? Double { // Optional
            //     onWidthChange?(width)
            // }
        }
    }
}

// Preview (Optional - for development in Xcode)
#if DEBUG
struct InlineMathView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("This is some inline math: ") +
            Text(verbatim: "") + // Placeholder for InlineMathView if direct concat is tricky
            InlineMathView(latexContent: "c = \\sqrt{a^2 + b^2}") +
            Text(" and some more text.")
            
            Text("Another example: \(InlineMathView(latexContent: "\\sum_{i=0}^n i^2 = \\frac{n(n+1)(2n+1)}{6}"))")
                .font(.title)
            
            Text("Inline with fraction $\\frac{1}{2}$: \(InlineMathView(latexContent: "\\frac{1}{2}"))")

            Text("Empty LaTeX: \(InlineMathView(latexContent: ""))")
            Text("Blank LaTeX: \(InlineMathView(latexContent: "   "))")
        }
        .padding()
    }
}
#endif
