import SwiftUI
import WebKit

// MARK: - InlineMathView
struct InlineMathView: View {
    let content: String
    @State private var viewHeight: CGFloat = 30 // Smaller default for inline-as-block
    @Environment(\.colorScheme) private var colorScheme

    init(content: String) {
        self.content = content
    }

    var body: some View {
        if content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            EmptyView()
        } else {
            // Create a minimal block-style math view with inline-friendly properties
            InlineMathWebView(content: content, onHeightChange: { height in
                self.viewHeight = CGFloat(height)
            })
            .frame(height: viewHeight)
            .padding(.vertical, 1)    // Very narrow vertical spacing
            .padding(.horizontal, 2)   // Minimal horizontal padding
            .background(Color.secondary.opacity(0.03)) // Very subtle background
            .cornerRadius(3)          // Slight rounding for distinction
        }
    }
}

// MARK: - InlineMathWebView
struct InlineMathWebView: View {
    let content: String
    let onHeightChange: (Double) -> Void
    @Environment(\.colorScheme) private var colorScheme
    
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
                    padding: 4px;
                    background-color: transparent;
                    color: var(--text-color);
                }
                #math {
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    min-height: 20px;
                    background-color: transparent;
                }
                .katex { 
                    color: var(--text-color);
                    background-color: transparent;
                    font-size: 1em;
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
                            displayMode: false, // Keep inline rendering
                            output: 'html',
                            trust: true
                        });
                    } catch (e) {
                        console.error("KaTeX rendering error:", e);
                        document.getElementById('math').innerText = "Error rendering LaTeX";
                    }
                    
                    // Send height to Swift
                    const height = document.documentElement.scrollHeight;
                    window.webkit.messageHandlers.heightHandler.postMessage(height);
                });
            </script>
        </body>
        </html>
        """
        
        WebView(htmlContent: htmlContent, onHeightChange: onHeightChange)
    }
}
