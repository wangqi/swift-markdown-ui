import MarkdownUI
import SwiftUI

struct TextSelectionView: View {
    private let content = """
    # Text Selection Test
    
    This view is specifically designed to test text selection functionality outside of a Form container.
    
    ## Features
    
    - Regular text that should be selectable
    - **Bold text** that should be selectable
    - *Italic text* that should be selectable
    - `Code blocks` that should be selectable
    - [Links](https://example.com) that should be selectable
    
    ### Code Block Example
    
    ```swift
    struct TextSelectionView: View {
        var body: some View {
            ScrollView {
                Markdown(content)
                    .textSelection(.enabled)
                    .padding()
            }
        }
    }
    ```
    
    > Blockquotes should also be selectable
    
    1. Numbered lists should be selectable
    2. Second item should be selectable
    
    - Bullet lists should be selectable
    - Second item should be selectable
    
    ![Image alt text](https://via.placeholder.com/150)
    
    $E = mc^2$ (LaTeX formula should be selectable)
    """
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Text Selection Test View")
                    .font(.largeTitle)
                    .padding(.bottom)
                
                Text("This view uses ScrollView instead of Form to test text selection")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                Markdown(self.content)
                    .textSelection(.enabled)
                    .markdownTheme(.gitHub)
                
                Text("Plain SwiftUI Text View")
                    .font(.headline)
                    .padding(.top)
                
                Text("This is a regular SwiftUI Text view with text selection enabled")
                    .textSelection(.enabled)
                    .padding(.bottom)
            }
            .padding()
        }
        .navigationTitle("Text Selection")
        .navigationBarTitleDisplayMode(.inline)
    }
}
