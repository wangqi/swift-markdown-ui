import Foundation

/// A protocol that represents any Markdown content.
public protocol MarkdownContentProtocol {
  var _markdownContent: MarkdownContent { get }
}

/// A Markdown content value.
///
/// A Markdown content value consists of a sequence of blocks – structural elements like paragraphs, blockquotes, lists,
/// headings, thematic breaks, and code blocks. Some blocks, like blockquotes and list items, contain other blocks; others,
/// like headings and paragraphs, have inline text, links, emphasized text, etc.
///
/// You can create a Markdown content value by passing a Markdown-formatted string to ``init(_:)``.
///
/// ```swift
/// let content = MarkdownContent("You can try **CommonMark** [here](https://spec.commonmark.org/dingus/).")
/// ```
///
/// Alternatively, you can build a Markdown content value using a domain-specific language for blocks and inline text.
///
/// ```swift
/// let content = MarkdownContent {
///   Paragraph {
///     "You can try "
///     Strong("CommonMark")
///     SoftBreak()
///     InlineLink("here", destination: URL(string: "https://spec.commonmark.org/dingus/")!)
///     "."
///   }
/// }
/// ```
///
/// Once you have created a Markdown content value, you can display it using a ``Markdown`` view.
///
/// ```swift
/// var body: some View {
///   Markdown(self.content)
/// }
/// ```
///
/// A Markdown view also offers initializers that take a Markdown-formatted string ``Markdown/init(_:baseURL:imageBaseURL:)-63py1``,
/// or a Markdown content builder ``Markdown/init(baseURL:imageBaseURL:content:)``, so you don't need to create a
/// Markdown content value before displaying it.
///
/// ```swift
/// var body: some View {
///   VStack {
///     Markdown("You can try **CommonMark** [here](https://spec.commonmark.org/dingus/).")
///     Markdown {
///       Paragraph {
///         "You can try "
///         Strong("CommonMark")
///         SoftBreak()
///         InlineLink("here", destination: URL(string: "https://spec.commonmark.org/dingus/")!)
///         "."
///       }
///     }
///   }
/// }
/// ```
public struct MarkdownContent: Equatable, MarkdownContentProtocol {
  /// Returns a Markdown content value with the sum of the contents of all the container blocks
  /// present in this content.
  ///
  /// You can use this property to access the contents of a blockquote or a list. Returns `nil` if
  /// there are no container blocks.
  public var childContent: MarkdownContent? {
    let children = self.blocks.map(\.children).flatMap { $0 }
    return children.isEmpty ? nil : .init(blocks: children)
  }

  public var _markdownContent: MarkdownContent { self }
  let blocks: [BlockNode]

  init(blocks: [BlockNode] = []) {
    self.blocks = blocks
  }

  init(block: BlockNode) {
    self.init(blocks: [block])
  }

  init(_ components: [MarkdownContentProtocol]) {
    self.init(blocks: components.map(\._markdownContent).flatMap(\.blocks))
  }

  /// Creates a Markdown content value from a Markdown-formatted string.
  /// - Parameter markdown: A Markdown-formatted string.
  public init(_ markdown: String) {
    self.init(blocks: .init(markdown: markdown))
  }

  /// Creates a Markdown content value composed of any number of blocks.
  /// - Parameter content: A Markdown content builder that returns the blocks that form the Markdown content.
  public init(@MarkdownContentBuilder content: () -> MarkdownContent) {
    self.init(blocks: content().blocks)
  }

  /// Renders this Markdown content value as a Markdown-formatted text.
  public func renderMarkdown() -> String {
    let result = self.blocks.renderMarkdown()
    return result.hasSuffix("\n") ? String(result.dropLast()) : result
  }

  /// Renders this Markdown content value as plain text.
  public func renderPlainText() -> String {
    let result = self.blocks.renderPlainText()
    return result.hasSuffix("\n") ? String(result.dropLast()) : result
  }

  /// Renders this Markdown content value as HTML code with LaTeX math support.
  public func renderHTML() -> String {
    let originalMarkdown = self.renderMarkdown()
    let html = self.blocks.renderHTML()
    return preserveLatexInHTML(html, originalMarkdown: originalMarkdown)
  }
  
  /// Preserves LaTeX math expressions in HTML output
  private func preserveLatexInHTML(_ html: String, originalMarkdown: String) -> String {
    var result = html
    
    // Extract and preserve block math expressions first
    result = preserveBlockMath(in: result, from: originalMarkdown)
    
    // Then preserve inline math expressions
    result = preserveInlineMath(in: result, from: originalMarkdown)
    
    return result
  }
  
  private func preserveBlockMath(in html: String, from markdown: String) -> String {
    let blockMathPattern = #"\$\$([^$]+)\$\$"#
    let regex = try! NSRegularExpression(pattern: blockMathPattern, options: [.dotMatchesLineSeparators])
    let matches = regex.matches(in: markdown, options: [], range: NSRange(location: 0, length: markdown.count))
    
    var result = html
    var insertionIndex = 0
    
    for match in matches {
      if let range = Range(match.range(at: 1), in: markdown) {
        let mathContent = String(markdown[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        let mathHTML = "<div class=\"math-block\">$$\(mathContent)$$</div>"
        
        // Find a good place to insert this block math
        if let insertionPoint = findBlockInsertionPoint(in: result, at: insertionIndex) {
          result.insert(contentsOf: "\n\(mathHTML)\n", at: insertionPoint)
          insertionIndex += 1
        }
      }
    }
    
    return result
  }
  
  private func preserveInlineMath(in html: String, from markdown: String) -> String {
    let inlineMathPattern = #"\$([^$\n]+)\$"#
    let regex = try! NSRegularExpression(pattern: inlineMathPattern, options: [])
    let matches = regex.matches(in: markdown, options: [], range: NSRange(location: 0, length: markdown.count))
    
    var result = html
    
    for match in matches.reversed() { // Process in reverse to maintain indices
      if let range = Range(match.range(at: 1), in: markdown) {
        let mathContent = String(markdown[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        let mathHTML = "<span class=\"math-inline\">$\(mathContent)$</span>"
        
        // Simple approach: append to the end of the last paragraph
        if let lastParagraphEnd = result.range(of: "</p>", options: .backwards) {
          result.insert(contentsOf: " \(mathHTML)", at: lastParagraphEnd.lowerBound)
        } else {
          // Fallback: append to the end
          result.append(" \(mathHTML)")
        }
      }
    }
    
    return result
  }
  
  private func findBlockInsertionPoint(in html: String, at index: Int) -> String.Index? {
    // Find paragraph or div endings to insert block math
    let patterns = ["</p>", "</div>", "</blockquote>"]
    var currentIndex = html.startIndex
    var foundCount = 0
    
    for pattern in patterns {
      while let range = html.range(of: pattern, range: currentIndex..<html.endIndex) {
        if foundCount == index {
          return range.upperBound
        }
        foundCount += 1
        currentIndex = range.upperBound
      }
    }
    
    // Fallback: end of HTML
    return html.endIndex
  }
}
