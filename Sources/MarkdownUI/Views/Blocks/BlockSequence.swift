import SwiftUI

// wangqi 2025-12-10: Custom Layout for single-pass block rendering
// Benefits: Better caching, no preference propagation, predictable layout
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct BlockLayout: Layout {
  let alignment: HorizontalAlignment
  let spacing: CGFloat

  struct CacheData {
    var sizes: [CGSize] = []
    var totalHeight: CGFloat = 0
    var maxWidth: CGFloat = 0
  }

  func makeCache(subviews: Subviews) -> CacheData {
    CacheData()
  }

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout CacheData) -> CGSize {
    guard !subviews.isEmpty else {
      return .zero
    }

    // Measure all subviews in single pass
    let proposedWidth = proposal.width ?? .infinity
    let childProposal = ProposedViewSize(width: proposedWidth, height: nil)

    cache.sizes = subviews.map { $0.sizeThatFits(childProposal) }
    cache.maxWidth = cache.sizes.reduce(0) { max($0, $1.width) }

    // Calculate total height with spacing
    let heights = cache.sizes.map { $0.height }
    let totalSpacing = spacing * CGFloat(max(0, subviews.count - 1))
    cache.totalHeight = heights.reduce(0, +) + totalSpacing

    return CGSize(
      width: min(proposedWidth, cache.maxWidth),
      height: cache.totalHeight
    )
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout CacheData) {
    guard !subviews.isEmpty else { return }

    var y = bounds.minY

    for (index, subview) in subviews.enumerated() {
      let size = cache.sizes.indices.contains(index) ? cache.sizes[index] : subview.sizeThatFits(.unspecified)

      // Calculate x position based on alignment
      let x: CGFloat
      switch alignment {
      case .leading:
        x = bounds.minX
      case .center:
        x = bounds.minX + (bounds.width - size.width) / 2
      case .trailing:
        x = bounds.maxX - size.width
      default:
        x = bounds.minX
      }

      subview.place(
        at: CGPoint(x: x, y: y),
        proposal: ProposedViewSize(width: bounds.width, height: size.height)
      )

      y += size.height
      if index < subviews.count - 1 {
        y += spacing
      }
    }
  }
}

struct BlockSequence<Data, Content>: View
where
  Data: Sequence,
  Data.Element: Hashable,
  Content: View
{
  @Environment(\.multilineTextAlignment) private var textAlignment
  @Environment(\.tightSpacingEnabled) private var tightSpacingEnabled

  // wangqi 2025-12-10: Spacing between blocks
  // - Normal spacing: 12pt for comfortable reading
  // - Tight spacing: 6pt minimum for readability (was 0, caused cramped lists)
  private static var defaultBlockSpacing: CGFloat { 12 }
  private static var tightBlockSpacing: CGFloat { 6 }

  private let data: [Indexed<Data.Element>]
  private let content: (Int, Data.Element) -> Content

  init(
    _ data: Data,
    @ViewBuilder content: @escaping (_ index: Int, _ element: Data.Element) -> Content
  ) {
    self.data = data.indexed()
    self.content = content
  }

  @ViewBuilder
  var body: some View {
    // wangqi 2025-12-10: Use custom Layout for single-pass rendering (iOS 16+/macOS 13+)
    // wangqi 2026-01-08: Added availability check for macOS 12 compatibility
    if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
      BlockLayout(
        alignment: self.textAlignment.alignment.horizontal,
        spacing: self.tightSpacingEnabled ? Self.tightBlockSpacing : Self.defaultBlockSpacing
      ) {
        ForEach(self.data, id: \.self) { element in
          self.content(element.index, element.value)
            .textSelection(.enabled)
        }
      }
      .transaction { $0.disablesAnimations = true }
    } else {
      // Fallback for older macOS versions: use VStack
      VStack(alignment: self.textAlignment.alignment.horizontal, spacing: self.tightSpacingEnabled ? Self.tightBlockSpacing : Self.defaultBlockSpacing) {
        ForEach(self.data, id: \.self) { element in
          self.content(element.index, element.value)
            .textSelection(.enabled)
        }
      }
      .transaction { $0.disablesAnimations = true }
    }
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
