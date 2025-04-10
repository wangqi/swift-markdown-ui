import SwiftUI

// MARK: - InlineMathTextModifier
struct InlineMathTextModifier: ViewModifier {
    @State private var attributedString: AttributedString
    
    init(attributedString: AttributedString) {
        self._attributedString = State(initialValue: attributedString)
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                InlineMathTextReplacer(attributedString: attributedString)
                    .opacity(0) // Make invisible but still layout-affecting
            )
    }
}

// MARK: - InlineMathTextReplacer
struct InlineMathTextReplacer: View {
    let attributedString: AttributedString
    
    var body: some View {
        let mathExpressions = extractMathExpressions(from: attributedString)
        
        ZStack(alignment: .leading) {
            ForEach(mathExpressions.indices, id: \.self) { index in
                let expression = mathExpressions[index]
                InlineMathText(content: expression.content)
                    .fixedSize(horizontal: true, vertical: true)
                    .alignmentGuide(.leading) { _ in
                        // Position based on the index in the runs array
                        CGFloat(expression.index * 10) // Simple offset based on index position
                    }
            }
        }
    }
    
    // Extract math expressions from the attributed string
    private func extractMathExpressions(from attributedString: AttributedString) -> [(content: String, index: Int)] {
        var expressions: [(content: String, index: Int)] = []
        var index = 0
        
        for run in attributedString.runs {
            // Access the InlineMathAttribute using the AttributeScopes.MarkdownAttributes
            if let mathContent = run.inlineMath {
                expressions.append((content: mathContent, index: index))
            }
            index += 1
        }
        
        return expressions
    }
}

// MARK: - View Extension
extension View {
    func inlineMathRenderer(attributedString: AttributedString) -> some View {
        self.modifier(InlineMathTextModifier(attributedString: attributedString))
    }
}
