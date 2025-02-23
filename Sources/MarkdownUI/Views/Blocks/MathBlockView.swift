import SwiftUI
import WebKit

struct MathBlockView: View {
    let content: String
    @State private var viewHeight: CGFloat = 100
    
    var body: some View {
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
                    padding: 8px;
                    background-color: transparent;
                }
                #math {
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    min-height: 50px;
                }
                .katex { font-size: 1.1em; }
            </style>
        </head>
        <body>
            <div id="math"></div>
            <script>
                document.addEventListener('DOMContentLoaded', function() {
                    katex.render(`\(content)`, document.getElementById('math'), {
                        throwOnError: false,
                        displayMode: true,
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
    }
}

struct WebView: UIViewRepresentable {
    let htmlContent: String
    let onHeightChange: (Double) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onHeightChange: onHeightChange)
    }
    
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
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
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
