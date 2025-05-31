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
  
  // Store the original markdown for LaTeX extraction during HTML rendering
  private let originalMarkdown: String?

  init(blocks: [BlockNode] = []) {
    self.blocks = blocks
    self.originalMarkdown = nil
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
    // Store the original markdown unchanged
    self.originalMarkdown = markdown
    
    // Parse the original markdown normally
    self.blocks = .init(markdown: markdown)
  }

  /// Creates a Markdown content value composed of any number of blocks.
  /// - Parameter content: A Markdown content builder that returns the blocks that form the Markdown content.
  public init(@MarkdownContentBuilder content: () -> MarkdownContent) {
    let contentResult = content()
    self.blocks = contentResult.blocks
    self.originalMarkdown = contentResult.originalMarkdown
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
    let html = self.blocks.renderHTML()
    
    // If we have original markdown, try to restore LaTeX expressions
    if let originalMarkdown = originalMarkdown {
      return Self.injectLatexIntoHTML(html, from: originalMarkdown)
    }
    
    return html
  }
    
    //MARK: - rendering html
  
  /// Inject LaTeX expressions from original markdown into HTML at appropriate positions
  private static func injectLatexIntoHTML(_ html: String, from originalMarkdown: String) -> String {
    // Extract LaTeX expressions from original markdown
    let latexExpressions = extractLatexExpressions(from: originalMarkdown)
    
    if latexExpressions.isEmpty {
      return html
    }
    
    var result = html
    
    // Simple approach: append all LaTeX expressions to the end
    // This ensures they're included even if positioning isn't perfect
    for expression in latexExpressions {
      if expression.isBlock {
        let mathHTML = "<div class=\"math-block\">\(expression.originalText)</div>"
        result += "\n\(mathHTML)"
      } else {
        let mathHTML = "<span class=\"math-inline\">\(expression.originalText)</span>"
        result += " \(mathHTML)"
      }
    }
    
    return result
  }
  
  private struct LatexExpression {
    let content: String
    let isBlock: Bool
    let originalText: String
  }
  
  private static func extractLatexExpressions(from markdown: String) -> [LatexExpression] {
    var expressions: [LatexExpression] = []
    
    // Extract block math expressions: $$...$$
    let blockMathPattern = #"\$\$([^$]+)\$\$"#
    let blockRegex = try! NSRegularExpression(pattern: blockMathPattern, options: [.dotMatchesLineSeparators])
    let blockMatches = blockRegex.matches(in: markdown, options: [], range: NSRange(location: 0, length: markdown.count))
    
    for match in blockMatches {
      if let fullRange = Range(match.range, in: markdown),
         let contentRange = Range(match.range(at: 1), in: markdown) {
        let content = String(markdown[contentRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        let originalText = String(markdown[fullRange])
        expressions.append(LatexExpression(content: content, isBlock: true, originalText: originalText))
      }
    }
    
    // Extract inline math expressions: $...$
    let inlineMathPattern = #"\$([^$\n]+)\$"#
    let inlineRegex = try! NSRegularExpression(pattern: inlineMathPattern, options: [])
    let inlineMatches = inlineRegex.matches(in: markdown, options: [], range: NSRange(location: 0, length: markdown.count))
    
    for match in inlineMatches {
      if let fullRange = Range(match.range, in: markdown),
         let contentRange = Range(match.range(at: 1), in: markdown) {
        let content = String(markdown[contentRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        let originalText = String(markdown[fullRange])
        expressions.append(LatexExpression(content: content, isBlock: false, originalText: originalText))
      }
    }
    
    return expressions
  }
}

