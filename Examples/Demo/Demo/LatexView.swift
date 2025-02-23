import MarkdownUI
import SwiftUI

struct LatexView: View {
  private let content = """
    This is an inline equation: $$V_{sphere} = \frac{4}{3}\pi r^3$$,<br>
    followed by a display style equation:

    $$V_{sphere} = \frac{4}{3}\pi r^3$$
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

