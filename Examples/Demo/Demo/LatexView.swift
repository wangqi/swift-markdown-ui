import MarkdownUI
import SwiftUI
import WebKit

struct LatexView: View {
  private let content = """
    # LaTeX Math Examples

    ## Basic Math
    Here's a quadratic formula: $$x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}$$

    ## Calculus
    The derivative definition:
    $$\\lim_{h \\to 0} \\frac{f(x + h) - f(x)}{h}$$

    ## Linear Algebra
    A matrix equation:
    $$\\begin{bmatrix} a & b \\\\ c & d \\end{bmatrix} \\begin{bmatrix} x \\\\ y \\end{bmatrix} = \\begin{bmatrix} r \\\\ s \\end{bmatrix}$$

    ## Statistics
    The normal distribution:
    $$f(x) = \\frac{1}{\\sigma\\sqrt{2\\pi}} e^{-\\frac{(x-\\mu)^2}{2\\sigma^2}}$$

    ## Physics
    Einstein's energy-mass equivalence:
    $$E = mc^2$$

    ## Complex Analysis
    Euler's formula:
    $$e^{ix} = \\cos x + i\\sin x$$
    """

  var body: some View {
    DemoView {
      Markdown(self.content)

      Section("Customization Example") {
        Markdown("# One Big Header")
      }
      .markdownBlockStyle(\.heading1) { configuration in
        configuration.label
          .markdownMargin(top: .em(1), bottom: .em(1))
          .markdownTextStyle {
            FontFamily(.custom("Trebuchet MS"))
            FontWeight(.bold)
            FontSize(.em(2.5))
          }
      }
    }
  }
}

