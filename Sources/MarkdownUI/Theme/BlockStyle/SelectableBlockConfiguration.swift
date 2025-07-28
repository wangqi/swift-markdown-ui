import SwiftUI

/// A block configuration that preserves view types for text selection support
/// This avoids AnyView wrapping which breaks SwiftUI's text selection
struct SelectableBlockConfiguration<Label: View> {
    /// The Markdown block view without type erasure
    let label: Label
    
    /// The content of the Markdown block
    let content: MarkdownContent
    
    init(label: Label, content: MarkdownContent) {
        self.label = label
        self.content = content
    }
}

/// Protocol for block styles that support text selection
protocol SelectableBlockStyle {
    associatedtype Body: View
    associatedtype Configuration
    
    @ViewBuilder
    func makeSelectableBody(configuration: Configuration) -> Body
}

/// A concrete implementation for paragraph/heading styles that preserves text selection
struct SelectableParagraphStyle<Label: View>: SelectableBlockStyle {
    typealias Configuration = SelectableBlockConfiguration<Label>
    
    private let textStyle: (Label) -> Label
    
    init(textStyle: @escaping (Label) -> Label = { $0 }) {
        self.textStyle = textStyle
    }
    
    func makeSelectableBody(configuration: Configuration) -> some View {
        textStyle(configuration.label)
            .fixedSize(horizontal: false, vertical: true)
            .relativeLineSpacing(.em(0.15))
            .markdownMargin(top: .zero, bottom: .em(1))
    }
}

/// Extension to detect if content is simple enough for selectable rendering
extension Array where Element == InlineNode {
    var isSimpleTextContent: Bool {
        for node in self {
            switch node {
            case .text, .softBreak, .lineBreak:
                continue
            case .emphasis(let children), .strong(let children):
                if !children.isSimpleTextContent {
                    return false
                }
            case .inlineMath:
                return false  // Math content requires WebView
            default:
                return false  // Complex content
            }
        }
        return true
    }
}

extension BlockNode {
    /// Checks if this block can use selectable rendering
    var canUseSelectableRendering: Bool {
        switch self {
        case .paragraph(let content), .heading(_, let content):
            return content.isSimpleTextContent
        default:
            return false
        }
    }
}
