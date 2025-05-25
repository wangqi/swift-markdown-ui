import SwiftUI

extension BlockNode: View {
  var body: some View {
    switch self {
    case .blockquote(let children):
      BlockquoteView(children: children)
            .textSelection(.enabled)
    case .bulletedList(let isTight, let items):
      BulletedListView(isTight: isTight, items: items)
            .textSelection(.enabled)
    case .numberedList(let isTight, let start, let items):
      NumberedListView(isTight: isTight, start: start, items: items)
            .textSelection(.enabled)
    case .taskList(let isTight, let items):
      TaskListView(isTight: isTight, items: items)
            .textSelection(.enabled)
    case .codeBlock(let fenceInfo, let content):
      if fenceInfo == "math" {
        MathBlockView(content: content, displayMode: true)
              .textSelection(.enabled)
      } else {
        CodeBlockView(fenceInfo: fenceInfo, content: content)
              .textSelection(.enabled)
      }
    case .htmlBlock(let content):
      ParagraphView(content: content)
            .textSelection(.enabled)
    case .paragraph(let content):
      ParagraphView(content: content)
            .textSelection(.enabled)
    case .heading(let level, let content):
      HeadingView(level: level, content: content)
            .textSelection(.enabled)
    case .table(let columnAlignments, let rows):
      if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
        TableView(columnAlignments: columnAlignments, rows: rows)
              .textSelection(.enabled)
      }
    case .thematicBreak:
      ThematicBreakView()
            .textSelection(.enabled)
    case .math(let content):
      MathBlockView(content: content, displayMode: true)
            .textSelection(.enabled)
    }
  }
}
