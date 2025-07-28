import SwiftUI

struct HeadingView: View {
  @Environment(\.theme.headings) private var headings
  @Environment(\.theme) private var theme

  private let level: Int
  private let content: [InlineNode]

  init(level: Int, content: [InlineNode]) {
    self.level = level
    self.content = content
  }

  var body: some View {
    // Check if content is simple enough for selectable rendering
    if content.isSimpleTextContent {
      // Use direct rendering without AnyView wrapping
      InlineText(content)
        .markdownMargin(top: .rem(1.5), bottom: .rem(1))
        .markdownTextStyle {
          FontWeight(.semibold)
          // Apply font size based on heading level
          switch level {
          case 1: FontSize(.em(2))
          case 2: FontSize(.em(1.5))
          case 3: FontSize(.em(1.17))
          case 4: FontSize(.em(1))
          case 5: FontSize(.em(0.83))
          case 6: FontSize(.em(0.67))
          default: FontSize(.em(1))
          }
        }
        .id(content.renderPlainText().kebabCased())
    } else {
      // Fall back to themed rendering for complex content
      self.headings[self.level - 1].makeBody(
        configuration: .init(
          label: .init(InlineText(self.content)),
          content: .init(block: .heading(level: self.level, content: self.content))
        )
      )
      .id(content.renderPlainText().kebabCased())
    }
  }
}
