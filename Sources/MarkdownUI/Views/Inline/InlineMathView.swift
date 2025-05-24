import SwiftUI
import WebKit

// MARK: - InlineMathView
struct InlineMathView: View {
    @State var latexContent: String
    @State private var viewHeight: CGFloat = 20 // Default height for inline content
    @State private var viewWidth: CGFloat = 50 // Optional: if dynamic width is needed
    @Environment(\.colorScheme) private var colorScheme

    init(content: String) {
        self.latexContent = content
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
                        padding: 0;
                        background-color: transparent;
                        display: inline-block; /* Critical for inline flow */
                        color: var(--text-color);
                    }
                    .katex { 
                        font-size: 1em; /* Match surrounding text size */
                        vertical-align: middle; /* Align with surrounding text */
                        color: var(--text-color);
                        background-color: transparent;
                    }
                    /* KaTeX itself might add .katex-display for block, ensure inline for this view */
                    .katex-display {
                        display: inline-block; /* Override if KaTeX tries to make it block */
                        margin: 0; /* Remove default margin for inline display */
                    }
                    #math {
                        display: inline-block; /* Ensure the container is inline */
                        background-color: transparent;
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
//            , onWidthChange: { width in // Optional: if dynamic width is needed
//                self.viewWidth = CGFloat(width)
//            }
            )
            .frame(height: viewHeight)
            //.frame(width: viewWidth, height: viewHeight) // Optional: if dynamic width
            // For true inline, width should ideally be intrinsic.
            // If the width is consistently too large or small, CSS adjustments are better.
        }
    }
}
