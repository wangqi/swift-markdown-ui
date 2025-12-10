import SwiftUI

struct BlockSequence<Data, Content>: View
where
  Data: Sequence,
  Data.Element: Hashable,
  Content: View
{
  @Environment(\.multilineTextAlignment) private var textAlignment
  @Environment(\.tightSpacingEnabled) private var tightSpacingEnabled

  // wangqi 2025-12-10: Removed @State blockMargins to eliminate PreferenceKey cascade
  // Using static spacing instead for better layout stability
  private static var defaultBlockSpacing: CGFloat { 8 }

  private let data: [Indexed<Data.Element>]
  private let content: (Int, Data.Element) -> Content

  init(
    _ data: Data,
    @ViewBuilder content: @escaping (_ index: Int, _ element: Data.Element) -> Content
  ) {
    self.data = data.indexed()
    self.content = content
  }

  var body: some View {
    // wangqi 2025-12-10: Added transaction modifier to disable animations for stability
    VStack(alignment: self.textAlignment.alignment.horizontal, spacing: 0) {
      ForEach(self.data, id: \.self) { element in
        self.content(element.index, element.value)
          // wangqi 2025-12-10: Removed onPreferenceChange to eliminate layout cascade
          .padding(.top, self.topPaddingLength(for: element))
          .textSelection(.enabled)
      }
    }
    .transaction { $0.disablesAnimations = true }
  }

  // wangqi 2025-12-10: Simplified to use static spacing
  private func topPaddingLength(for element: Indexed<Data.Element>) -> CGFloat {
    guard element.index > 0 else {
      return 0
    }
    // Use tight spacing (0) or default block spacing
    return self.tightSpacingEnabled ? 0 : Self.defaultBlockSpacing
  }
}

extension BlockSequence where Data == [BlockNode], Content == BlockNode {
  init(_ blocks: [BlockNode]) {
    self.init(blocks) { $1 }
  }
}

extension TextAlignment {
  fileprivate var alignment: Alignment {
    switch self {
    case .leading:
      return .leading
    case .center:
      return .center
    case .trailing:
      return .trailing
    }
  }
}
