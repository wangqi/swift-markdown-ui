import SwiftUI

struct ParagraphView: View {
  @Environment(\.theme.paragraph) private var paragraph

  private let content: [InlineNode]

  init(content: String) {
    self.init(
      content: [
        .text(content.hasSuffix("\n") ? String(content.dropLast()) : content)
      ]
    )
  }

  init(content: [InlineNode]) {
    self.content = content
  }

  var body: some View {
    // Check if content is simple enough for selectable rendering
    if content.isSimpleTextContent {
      // Use direct rendering without AnyView wrapping
      InlineText(content)
        .fixedSize(horizontal: false, vertical: true)
        .relativeLineSpacing(.em(0.15))
        .markdownMargin(top: .zero, bottom: .em(1))
    } else {
      // Fall back to themed rendering for complex content
      self.paragraph.makeBody(
        configuration: .init(
          label: .init(self.label),
          content: .init(block: .paragraph(content: self.content))
        )
      )
    }
  }

  @ViewBuilder private var label: some View {
    if let imageView = ImageView(content) {
      imageView
    } else if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *),
      let imageFlow = ImageFlow(content)
    {
      imageFlow
    } else {
      InlineText(content)
    }
  }
}
