import SwiftUI

struct InlineText: View {
  @Environment(\.inlineImageProvider) private var inlineImageProvider
  @Environment(\.baseURL) private var baseURL
  @Environment(\.imageBaseURL) private var imageBaseURL
  @Environment(\.softBreakMode) private var softBreakMode
  @Environment(\.theme) private var theme

  @State private var inlineImages: [String: Image] = [:]

  private let inlines: [InlineNode]

  init(_ inlines: [InlineNode]) {
    self.inlines = inlines
  }

  var body: some View {
    // Check if there are any inline math nodes
    if inlines.contains(where: { if case .inlineMath = $0 { return true } else { return false } }) {
      // If there are inline math nodes, use the custom renderer
      CustomInlineRenderer(
        inlines: inlines,
        baseURL: baseURL,
        textStyles: .init(
          code: self.theme.code,
          emphasis: self.theme.emphasis,
          strong: self.theme.strong,
          strikethrough: self.theme.strikethrough,
          link: self.theme.link
        ),
        images: inlineImages,
        softBreakMode: softBreakMode
      )
      .task(id: self.inlines) {
        self.inlineImages = (try? await self.loadInlineImages()) ?? [:]
      }
    } else {
      // If no inline math nodes, use the standard text renderer
      TextStyleAttributesReader { attributes in
        self.inlines.renderText(
          baseURL: self.baseURL,
          textStyles: .init(
            code: self.theme.code,
            emphasis: self.theme.emphasis,
            strong: self.theme.strong,
            strikethrough: self.theme.strikethrough,
            link: self.theme.link
          ),
          images: self.inlineImages,
          softBreakMode: self.softBreakMode,
          attributes: attributes
        )
      }
      .task(id: self.inlines) {
        self.inlineImages = (try? await self.loadInlineImages()) ?? [:]
      }
    }
  }

  private func loadInlineImages() async throws -> [String: Image] {
    let images = Set(self.inlines.compactMap(\.imageData))
    guard !images.isEmpty else { return [:] }

    return try await withThrowingTaskGroup(of: (String, Image).self) { taskGroup in
      for image in images {
        guard let url = URL(string: image.source, relativeTo: self.imageBaseURL) else {
          continue
        }

        taskGroup.addTask {
          (image.source, try await self.inlineImageProvider.image(with: url, label: image.alt))
        }
      }

      var inlineImages: [String: Image] = [:]

      for try await result in taskGroup {
        inlineImages[result.0] = result.1
      }

      return inlineImages
    }
  }
}

// MARK: - CustomInlineRenderer

/// A custom renderer that can handle both regular text and LaTeX content
struct CustomInlineRenderer: View {
  let inlines: [InlineNode]
  let baseURL: URL?
  let textStyles: InlineTextStyles
  let images: [String: Image]
  let softBreakMode: SoftBreak.Mode
  
  @Environment(\.theme) private var theme
  
    var body: some View {
        VStack(alignment: .leading, spacing: 2) { // Narrow spacing for inline-as-block
            ForEach(Array(inlines.enumerated()), id: \.offset) { _, inline in
                switch inline {
                case .inlineMath(let content):
                    // Render LaTeX content using InlineMathView (now block-style)
                    InlineMathView(content: content)
                    
                default:
                    // For all other inline nodes, use the standard rendering
                    TextStyleAttributesReader { attributes in
                        [inline].renderText(
                            baseURL: baseURL,
                            textStyles: textStyles,
                            images: images,
                            softBreakMode: softBreakMode,
                            attributes: attributes
                        )
                    }
                }
            }
        }
    }
}
