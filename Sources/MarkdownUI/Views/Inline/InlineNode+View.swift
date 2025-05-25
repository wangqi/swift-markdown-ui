import SwiftUI

extension InlineNode: View {
    public var body: some View {
        switch self {
        case .text(let content):
            Text(content)
                .textSelection(.enabled)
        case .softBreak:
            Text(" ")
                .textSelection(.enabled)
        case .lineBreak:
            Text("\n")
                .textSelection(.enabled)
        case .code(let content):
            Text(content)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 2)
                .background(Color(.systemGray6))
                .cornerRadius(2)
                .textSelection(.enabled)
        case .inlineMath(let content):
            InlineMathView(content: content)
                .padding(.vertical, 2)
                .padding(.horizontal, 4)
                .textSelection(.enabled)
        case .html(let content):
            Text(content)
                .textSelection(.enabled)
        case .emphasis(let children):
            ForEach(0..<children.count, id: \.self) { index in
                children[index]
                    .italic()
                    .textSelection(.enabled)
            }
        case .strong(let children):
            ForEach(0..<children.count, id: \.self) { index in
                children[index]
                    .bold()
                    .textSelection(.enabled)
            }
        case .strikethrough(let children):
            ForEach(0..<children.count, id: \.self) { index in
                children[index]
                    .strikethrough()
                    .textSelection(.enabled)
            }
        case .link(let destination, let children):
            Link(destination: URL(string: destination) ?? URL(string: "#")!) {
                HStack(spacing: 0) {
                    ForEach(0..<children.count, id: \.self) { index in
                        children[index]
                            .textSelection(.enabled)
                    }
                }
            }
        case .image(let source, _):
            AsyncImage(url: URL(string: source)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxHeight: 300)
        }
    }
}
