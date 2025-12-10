import SwiftUI

struct NumberedListView: View {
  @Environment(\.theme.list) private var list
  @Environment(\.theme.numberedListMarker) private var numberedListMarker
  @Environment(\.listLevel) private var listLevel

  // wangqi 2025-12-10: Removed @State markerWidth to eliminate dynamic measurement
  // Pre-calculate marker width based on list length instead

  private let isTight: Bool
  private let start: Int
  private let items: [RawListItem]

  init(isTight: Bool, start: Int, items: [RawListItem]) {
    self.isTight = isTight
    self.start = start
    self.items = items
  }

  var body: some View {
    self.list.makeBody(
      configuration: .init(
        label: .init(self.label),
        content: .init(
          block: .numberedList(
            isTight: self.isTight,
            start: self.start,
            items: self.items
          )
        )
      )
    )
    .textSelection(.enabled)
  }

  // wangqi 2025-12-10: Pre-calculate marker width based on max number in list
  private var calculatedMarkerWidth: CGFloat {
    let maxNumber = start + items.count - 1
    // Estimate width: ~8pt per digit + padding for "." and spacing
    let digitCount = String(maxNumber).count
    return CGFloat(digitCount * 8 + 8)
  }

  private var label: some View {
    ListItemSequence(
      items: self.items,
      start: self.start,
      markerStyle: self.numberedListMarker,
      markerWidth: self.calculatedMarkerWidth
    )
    .environment(\.listLevel, self.listLevel + 1)
    .environment(\.tightSpacingEnabled, self.isTight)
    // wangqi 2025-12-10: Removed onColumnWidthChange to eliminate layout pass
    .textSelection(.enabled)
  }
}
