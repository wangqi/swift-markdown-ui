import MarkdownUI
import SwiftUI
import WebKit

struct LatexView: View {
  @State private var showingHTMLPreview = false
  @State private var htmlContent = ""
  
  private let markdownContent = """
    # LaTeX Math Examples
    
    ## New Test
    $$
    F(\\omega) = \\int_{-\\infty}^{\\infty} e^{-j\\omega t} f(t)\\,\\mathrm{d}t
    $$
    
    Inline math:
    It is an inline math expression: $ x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a} $. It is used in many fields.

    ## Basic Math
    Here's a quadratic formula: $ x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a} $

    ## Calculus
    The derivative definition:
    $$
    \\lim_{h \\to 0} \\frac{f(x + h) - f(x)}{h}
    $$

    ## Linear Algebra
    A matrix equation:
    $$
    \\begin{bmatrix} a & b \\\\ c & d \\end{bmatrix} \\begin{bmatrix} x \\\\ y \\end{bmatrix} = \\begin{bmatrix} r \\\\ s \\end{bmatrix}
    $$

    ## Statistics
    The normal distribution:
    $$
    f(x) = \\frac{1}{\\sigma\\sqrt{2\\pi}} e^{-\\frac{(x-\\mu)^2}{2\\sigma^2}}
    $$

    ## Physics
    Einstein's energy-mass equivalence: $E = mc^2$

    ## Complex Analysis
    Euler's formula:
    $$
    e^{ix} = \\cos x + i\\sin x
    $$
    
    ## inline math
    $a^2 + b^2 = c^2$
    
    $\\frac{13}{3} \\approx 4.333...$
    
    # Physics Equations

      The famous mass-energy equivalence is $E = mc^2$ where $E$ is energy, $m$ is mass, and $c$ is the speed of light.

      For quadratic equations $ax^2 + bx + c = 0$, the solutions are given by:

      $$x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}$$

      The area of a circle with radius $r$ is $A = \\pi r^2$. The circumference is $C = 2\\pi r$.

      ## Calculus Examples

      The derivative of $f(x) = x^n$ is $f'(x) = nx^{n-1}$.

      Integration: $\\int x^n dx = \\frac{x^{n+1}}{n+1} + C$ for $n \\neq -1$.

      The fundamental theorem of calculus states that $\\int_a^b f'(x) dx = f(b) - f(a)$.

      ## More Complex Examples

      The Gaussian integral: $\\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}$

      Euler's identity: $e^{i\\pi} + 1 = 0$ connects five fundamental mathematical constants.

      The probability density function of a normal distribution is $f(x) = \\frac{1}{\\sigma\\sqrt{2\\pi}} e^{-\\frac{1}{2}\\left(\\frac{x-\\mu}{\\sigma}\\right)^2}$.

      Matrix multiplication: If $A$ is an $m \\times n$ matrix and $B$ is an $n \\times p$ matrix, then $(AB)_{ij} = \\sum_{k=1}^{n} A_{ik}B_{kj}$.

      This example contains:
      - Simple inline math: $E = mc^2$, $A = \\pi r^2$
      - Complex inline expressions: $\\frac{1}{\\sigma\\sqrt{2\\pi}} e^{-\\frac{1}{2}\\left(\\frac{x-\\mu}{\\sigma}\\right)^2}$
      - Block math: $$x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}$$
      - Mixed content with text, inline math, and regular formatting

      With your inline-as-block implementation, the inline math expressions should now appear as mini-blocks with narrow spacing instead of
      creating the table-like column layout you were experiencing before.

    """

  var body: some View {
    VStack(spacing: 0) {
      // Markdown content
      ScrollView {
        Markdown(markdownContent)
          .padding()
      }
      
      // Bottom button
      VStack {
        Divider()
        
        Button(action: {
          generateHTMLPreview()
        }) {
          HStack {
            Image(systemName: "globe")
            Text("Preview HTML with LaTeX")
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(10)
        }
        .padding()
      }
      .background(Color(UIColor.systemBackground))
    }
    .navigationTitle("LaTeX Examples")
    .sheet(isPresented: $showingHTMLPreview) {
      HTMLPreviewView(htmlContent: htmlContent)
    }
  }
  
  private func generateHTMLPreview() {
    let markdownContentObj = MarkdownContent(markdownContent)
    htmlContent = createFullHTMLDocument(body: markdownContentObj.renderHTML())
    showingHTMLPreview = true
  }
  
  private func createFullHTMLDocument(body: String) -> String {
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>LaTeX Preview</title>
        <script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
        <script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
        <script>
        window.MathJax = {
          tex: {
            inlineMath: [['$', '$']],
            displayMath: [['$$', '$$']],
            processEscapes: true
          },
          options: {
            skipHtmlTags: ['script', 'noscript', 'style', 'textarea', 'pre']
          }
        };
        </script>
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                line-height: 1.6;
                margin: 20px;
                color: #333;
            }
            .math-block {
                margin: 20px 0;
                text-align: center;
            }
            .math-inline {
                display: inline;
            }
            h1, h2, h3 {
                color: #2c3e50;
            }
            p {
                margin: 10px 0;
            }
        </style>
    </head>
    <body>
        \(body)
    </body>
    </html>
    """
  }
}

struct HTMLPreviewView: View {
  let htmlContent: String
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    NavigationView {
      WebView(htmlContent: htmlContent)
        .navigationTitle("HTML Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button("Done") {
              dismiss()
            }
          }
          
          ToolbarItem(placement: .navigationBarTrailing) {
            Button("Copy HTML") {
              UIPasteboard.general.string = htmlContent
            }
          }
        }
    }
  }
}

struct WebView: UIViewRepresentable {
  let htmlContent: String
  
  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView()
    webView.navigationDelegate = context.coordinator
    return webView
  }
  
  func updateUIView(_ webView: WKWebView, context: Context) {
    webView.loadHTMLString(htmlContent, baseURL: nil)
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  class Coordinator: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      // Web view finished loading
    }
  }
}
