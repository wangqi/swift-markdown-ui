import SwiftUI
import WebKit

struct MathBlockView: View {
    let content: String
    
    var body: some View {
        // Create a WebView to render LaTeX content using KaTeX or MathJax
        let htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
        </head>
        <body>
            <div id="math"></div>
            <script>
                katex.render(`\(content)`, document.getElementById('math'), {
                    throwOnError: false,
                    displayMode: true
                });
            </script>
        </body>
        </html>
        """
        
        WebView(htmlContent: htmlContent)
            .frame(height: 100) // Adjust height based on content
    }
}

struct WebView: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
