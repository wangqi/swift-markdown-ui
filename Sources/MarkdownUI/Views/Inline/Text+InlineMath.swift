import SwiftUI

extension Text {
    func renderingInlineMath() -> some View {
        self.background(
            GeometryReader { geometry in
                InlineMathRenderer(text: self, size: geometry.size)
            }
        )
    }
}

struct InlineMathRenderer: View {
    let text: Text
    let size: CGSize
    
    @State private var attributedString: AttributedString?
    
    var body: some View {
        ZStack {
            // Render the original text with opacity 0 to maintain layout
            text.opacity(0)
            
            // Overlay with our custom math rendering
            if let attributedString = attributedString {
                MathContentView(attributedString: attributedString)
            }
        }
        .onAppear {
            // In a real implementation, we would extract the AttributedString from the Text
            // This is a simplified version for demonstration
            if let mirror = Mirror(reflecting: text).children.first(where: { $0.label == "storage" }),
               let storage = mirror.value as? NSAttributedString {
                self.attributedString = AttributedString(storage)
            }
        }
    }
}

struct MathContentView: View {
    let attributedString: AttributedString
    
    // Helper function to extract text from a run
    private func getTextFromRun(_ run: AttributedString.Runs.Element, in attributedString: AttributedString) -> String {
        // Extract the text content from the run
        // Create a substring from the attributedString using the run's range
        let substring = attributedString[run.range]
        
        // Convert to string - use the description property which returns a String
        return substring.description
    }
    
    var body: some View {
        HStack(spacing: 0) {
            let runs = Array(attributedString.runs)
            ForEach(0..<runs.count, id: \.self) { index in
                let run = runs[index]
                if let mathContent = run.attributes[InlineMathAttribute.self] as? String {
                    InlineMathView(content: mathContent)
                        .textSelection(.enabled)
                } else {
                    // Create a text view for the non-math content
                    // We'll use a substring approach instead of ranges
                    let text = getTextFromRun(run, in: attributedString)
                    Text(text)
                        .textSelection(.enabled)
                }
            }
        }
    }
}
