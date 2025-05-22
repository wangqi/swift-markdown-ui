import SwiftUI

extension InlineNode: View {
    public var body: some View {
        switch self {
        case .text(let content):
            Text(content)
        case .softBreak:
            Text(" ")
        case .lineBreak:
            Text("\n")
        case .code(let content):
            Text(content)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 2)
                .background(Color(.systemGray6))
                .cornerRadius(2)
        case .inlineMath(let content):
            InlineMathView(content: content)
                .padding(.vertical, 2)
                .padding(.horizontal, 4)
        case .html(let content):
            Text(content)
        case .emphasis(let children):
            ForEach(0..<children.count, id: \.self) { index in
                children[index]
                    .italic()
            }
        case .strong(let children):
            ForEach(0..<children.count, id: \.self) { index in
                children[index]
                    .bold()
            }
        case .strikethrough(let children):
            ForEach(0..<children.count, id: \.self) { index in
                children[index]
                    .strikethrough()
            }
        case .link(let destination, let children):
            Link(destination: URL(string: destination) ?? URL(string: "#")!) {
                HStack(spacing: 0) {
                    ForEach(0..<children.count, id: \.self) { index in
                        children[index]
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
