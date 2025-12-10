import SwiftUI

struct ListItemView: View {
  @Environment(\.theme.listItem) private var listItem
  @Environment(\.listLevel) private var listLevel

  private let item: RawListItem
  private let number: Int
  private let markerStyle: BlockStyle<ListMarkerConfiguration>
  private let markerWidth: CGFloat?

  init(
    item: RawListItem,
    number: Int,
    markerStyle: BlockStyle<ListMarkerConfiguration>,
    markerWidth: CGFloat?
  ) {
    self.item = item
    self.number = number
    self.markerStyle = markerStyle
    self.markerWidth = markerWidth
  }

  var body: some View {
    self.listItem.makeBody(
      configuration: .init(
        label: .init(self.label),
        content: .init(blocks: item.children)
      )
    )
    .textSelection(.enabled)
  }

  // wangqi 2025-12-10: Simplified label using HStack directly instead of Label
  // Reduces view hierarchy depth and eliminates LabelStyle overhead
  private var label: some View {
    HStack(alignment: .centerOfFirstLine, spacing: 4) {
      self.markerStyle
        .makeBody(configuration: .init(listLevel: self.listLevel, itemNumber: self.number))
        .textStyleFont()
        // wangqi 2025-12-10: Removed .readWidth() - marker width is pre-calculated
        .frame(width: self.markerWidth, alignment: .trailing)
      BlockSequence(self.item.children)
    }
    .textSelection(.enabled)
  }
}

extension VerticalAlignment {
  private enum CenterOfFirstLine: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      let heightAfterFirstLine = context[.lastTextBaseline] - context[.firstTextBaseline]
      let heightOfFirstLine = context.height - heightAfterFirstLine
      return heightOfFirstLine / 2
    }
  }
  static let centerOfFirstLine = Self(CenterOfFirstLine.self)
}

// wangqi 2025-12-10: BulletItemStyle removed - using HStack directly in ListItemView now
