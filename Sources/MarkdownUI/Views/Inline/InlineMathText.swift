import SwiftUI

struct InlineMathText: View {
    let content: String
    
    var body: some View {
        InlineMathView(content: content)
            .fixedSize(horizontal: true, vertical: true)
            .padding(.vertical, 2)
    }
}
