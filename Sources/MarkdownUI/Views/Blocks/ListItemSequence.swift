import SwiftUI

struct ListItemSequence: View {
  private let items: [RawListItem]
  private let start: Int
  private let markerStyle: BlockStyle<ListMarkerConfiguration>
  private let markerWidth: CGFloat?

  init(
    items: [RawListItem],
    start: Int = 1,
    markerStyle: BlockStyle<ListMarkerConfiguration>,
    markerWidth: CGFloat? = nil
  ) {
    self.items = items
    self.start = start
    self.markerStyle = markerStyle
    self.markerWidth = markerWidth
  }

  var body: some View {
    // wangqi 2025-12-10: Removed .labelStyle(.titleAndIcon) - ListItemView uses HStack directly now
    BlockSequence(self.items) { index, item in
      ListItemView(
        item: item,
        number: self.start + index,
        markerStyle: self.markerStyle,
        markerWidth: self.markerWidth
      )
      .textSelection(.enabled)
    }
    .textSelection(.enabled)
  }
}
