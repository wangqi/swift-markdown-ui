import SwiftUI

// MARK: - InlineMathTextModifier
/// A view modifier that processes text with inline math expressions
struct InlineMathTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    InlineMathRenderer(size: geometry.size)
                        .allowsHitTesting(false) // Don't interfere with text interaction
                }
            )
    }
}

// MARK: - MathExpressionExtractor
/// A view that extracts math expressions from text and renders them
struct MathExpressionExtractor: View {
    let content: Any
    
    @State private var attributedString: AttributedString?
    @State private var mathExpressions: [MathExpression] = []
    
    var body: some View {
        ZStack {
            // Render math expressions if we have any
            ForEach(mathExpressions, id: \.id) { expression in
                InlineMathText(content: expression.content)
                    .position(x: expression.position.x, y: expression.position.y)
                    .zIndex(1) // Ensure math is rendered on top
            }
        }
        .onAppear {
            // Extract the attributed string from the content if possible
            if let text = content as? Text {
                extractAttributedStringFromText(text)
            }
        }
    }
    
    // Extract the AttributedString from a Text view using reflection
    private func extractAttributedStringFromText(_ text: Text) {
        // Use Mirror to access the private storage of the Text view
        let mirror = Mirror(reflecting: text)
        
        // Look for the storage property
        if let storageChild = mirror.children.first(where: { $0.label == "storage" }),
           let storage = storageChild.value as? NSAttributedString {
            // Convert to AttributedString
            let attributedString = AttributedString(storage)
            self.attributedString = attributedString
            
            // Extract math expressions
            self.mathExpressions = extractMathExpressions(from: attributedString)
        }
    }
    
    // Extract math expressions from the attributed string
    private func extractMathExpressions(from attributedString: AttributedString) -> [MathExpression] {
        var expressions: [MathExpression] = []
        var currentIndex = 0
        
        // Default position for math expressions
        // In a real implementation, we would calculate the actual position based on the text layout
        var currentPosition = CGPoint(x: 20, y: 20)
        
        for run in attributedString.runs {
            if let mathContent = run.inlineMath {
                // Create a unique ID for this expression
                let id = "math_\(currentIndex)_\(mathContent.hashValue)"
                
                // Create a math expression with the content and position
                let expression = MathExpression(id: id, content: mathContent, position: currentPosition)
                expressions.append(expression)
                
                // Move to the next position (simple horizontal layout)
                // This is a simplified approach; in a real implementation, we would calculate
                // the actual position based on the text layout
                currentPosition.x += 150
                if currentPosition.x > 300 { // Simple wrapping
                    currentPosition.x = 20
                    currentPosition.y += 30
                }
            }
            currentIndex += 1
        }
        
        return expressions
    }
}

// MARK: - MathExpression
/// Represents a math expression with its content and position
struct MathExpression {
    let id: String
    let content: String
    let position: CGPoint
}
