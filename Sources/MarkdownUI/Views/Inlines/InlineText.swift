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
    TextStyleAttributesReader { attributes in
      let textStyles = InlineTextStyles(
        code: self.theme.code,
        emphasis: self.theme.emphasis,
        strong: self.theme.strong,
        strikethrough: self.theme.strikethrough,
        link: self.theme.link
      )

      let attributedString = self.inlines.reduce(into: AttributedString()) { result, inlineNode in
        result.append(
          inlineNode.renderAttributedString(
            baseURL: self.baseURL,
            textStyles: textStyles,
            softBreakMode: self.softBreakMode,
            attributes: attributes
          )
        )
      }

      var viewComponents: [AnyView] = []
      for run in attributedString.runs {
        if let latexContent = run.inlineMath, !latexContent.isEmpty {
          viewComponents.append(AnyView(InlineMathView(latexContent: latexContent)))
        } else {
          var runAttributedString = AttributedString(String(run.characters)) // Initialize with characters of the run
          runAttributedString.setAttributes(run.attributes) // Apply all attributes from the run

          let runText = String(run.characters)
          // Check if the runText is the specific placeholder AND if inlineMath attribute was present for this run
          // This avoids removing text that coincidentally matches the placeholder but isn't math.
          let isMathPlaceholder = (runText == "\\u{200B}MATH\\u{200B}" && run.inlineMath != nil)
          
          if !isMathPlaceholder && !runText.isEmpty {
            viewComponents.append(AnyView(Text(runAttributedString)))
          }
        }
      }
      
      // Using a simple Group for now as FlowLayout might not be directly available
      // or its usage might need more context (like horizontal/vertical configuration)
      // Replace with FlowLayout if it's confirmed to be available and suitable.
      FlowLayout(spacing: 0) { // Assuming FlowLayout is available and default horizontal flow
          ForEach(viewComponents.indices, id: \.self) { index in
              viewComponents[index]
          }
      }
    }
    .task(id: self.inlines) {
      self.inlineImages = (try? await self.loadInlineImages()) ?? [:]
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
