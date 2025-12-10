import SwiftUI

/// The properties of a list marker in a markdown list.
///
/// The theme ``Theme/bulletedListMarker`` and ``Theme/numberedListMarker``
/// block styles receive a `ListMarkerConfiguration` input in their `body` closure.
public struct ListMarkerConfiguration {
  /// The list level (one-based) of the item to which the marker applies.
  public let listLevel: Int

  /// The position (one-based) of the item to which the marker applies.
  public let itemNumber: Int
}

extension BlockStyle where Configuration == ListMarkerConfiguration {
  // wangqi 2025-12-10: Reduced marker width to .em(0.3) with level cap at 3
  // Levels 3+ use zero width to stop cumulative indentation
  private static let baseMarkerWidth: RelativeSize = .em(0.3)
  private static let maxIndentLevel = 2 // Cap indentation at level 2

  /// A list marker style that uses decimal numbers beginning with 1.
  public static var decimal: Self {
    BlockStyle { configuration in
      let width: RelativeSize = configuration.listLevel <= maxIndentLevel ? baseMarkerWidth : .em(0)
      Text("\(configuration.itemNumber).")
        .monospacedDigit()
        .relativeFrame(minWidth: width, alignment: .trailing)
    }
  }

  /// A list marker style that uses uppercase roman numerals beginning with `I`.
  public static var upperRoman: Self {
    BlockStyle { configuration in
      let width: RelativeSize = configuration.listLevel <= maxIndentLevel ? baseMarkerWidth : .em(0)
      Text(configuration.itemNumber.roman + ".")
        .relativeFrame(minWidth: width, alignment: .trailing)
    }
  }

  /// A list marker style that uses lowercase roman numerals beginning with `i`.
  public static var lowerRoman: Self {
    BlockStyle { configuration in
      let width: RelativeSize = configuration.listLevel <= maxIndentLevel ? baseMarkerWidth : .em(0)
      Text(configuration.itemNumber.roman.lowercased() + ".")
        .relativeFrame(minWidth: width, alignment: .trailing)
    }
  }

  /// A list marker style that uses a dash.
  public static var dash: Self {
    BlockStyle { configuration in
      let width: RelativeSize = configuration.listLevel <= maxIndentLevel ? baseMarkerWidth : .em(0)
      Text("-")
        .relativeFrame(minWidth: width, alignment: .trailing)
    }
  }

  /// A list marker style that uses a filled circle.
  public static var disc: Self {
    BlockStyle { configuration in
      let width: RelativeSize = configuration.listLevel <= maxIndentLevel ? baseMarkerWidth : .em(0)
      ListBullet.disc
        .relativeFrame(minWidth: width, alignment: .trailing)
    }
  }

  /// A list marker style that uses a hollow circle.
  public static var circle: Self {
    BlockStyle { configuration in
      let width: RelativeSize = configuration.listLevel <= maxIndentLevel ? baseMarkerWidth : .em(0)
      ListBullet.circle
        .relativeFrame(minWidth: width, alignment: .trailing)
    }
  }

  /// A list marker style that uses a filled square.
  public static var square: Self {
    BlockStyle { configuration in
      let width: RelativeSize = configuration.listLevel <= maxIndentLevel ? baseMarkerWidth : .em(0)
      ListBullet.square
        .relativeFrame(minWidth: width, alignment: .trailing)
    }
  }

  /// A list marker style that alternates between disc, circle, and square, depending on the list level.
  public static var discCircleSquare: Self {
    BlockStyle { configuration in
      let width: RelativeSize = configuration.listLevel <= maxIndentLevel ? baseMarkerWidth : .em(0)
      let bullets: [ListBullet] = [.disc, .circle, .square]
      let bullet = bullets[min(configuration.listLevel, bullets.count) - 1]
      bullet.relativeFrame(minWidth: width, alignment: .trailing)
    }
  }
}

// MARK: Dynamic (with level cap support)

extension BlockStyle where Configuration == ListMarkerConfiguration {
  // wangqi 2025-12-10: Dynamic functions now support level cap - levels 3+ get zero width
  private static func cappedWidth(_ minWidth: RelativeSize, level: Int) -> RelativeSize {
    level <= 2 ? minWidth : .em(0)
  }

  /// A list marker style that uses decimal numbers beginning with 1.
  public static func decimal(minWidth: RelativeSize, alignment: Alignment = .center) -> Self {
    BlockStyle { configuration in
      Text("\(configuration.itemNumber).")
        .monospacedDigit()
        .relativeFrame(minWidth: cappedWidth(minWidth, level: configuration.listLevel), alignment: alignment)
    }
  }

  /// A list marker style that uses uppercase roman numerals beginning with `I`.
  public static func upperRoman(minWidth: RelativeSize, alignment: Alignment = .center) -> Self {
    BlockStyle { configuration in
      Text(configuration.itemNumber.roman + ".")
        .relativeFrame(minWidth: cappedWidth(minWidth, level: configuration.listLevel), alignment: alignment)
    }
  }

  /// A list marker style that uses lowercase roman numerals beginning with `i`.
  public static func lowerRoman(minWidth: RelativeSize, alignment: Alignment = .center) -> Self {
    BlockStyle { configuration in
      Text(configuration.itemNumber.roman.lowercased() + ".")
        .relativeFrame(minWidth: cappedWidth(minWidth, level: configuration.listLevel), alignment: alignment)
    }
  }

  /// A list marker style that uses a dash.
  public static func dash(minWidth: RelativeSize, alignment: Alignment = .center) -> Self {
    BlockStyle { configuration in
      Text("-")
        .relativeFrame(minWidth: cappedWidth(minWidth, level: configuration.listLevel), alignment: alignment)
    }
  }

  /// A list marker style that uses a filled circle.
  public static func disc(minWidth: RelativeSize, alignment: Alignment = .center) -> Self {
    BlockStyle { configuration in
      ListBullet.disc
        .relativeFrame(minWidth: cappedWidth(minWidth, level: configuration.listLevel), alignment: alignment)
    }
  }

  /// A list marker style that uses a hollow circle.
  public static func circle(minWidth: RelativeSize, alignment: Alignment = .center) -> Self {
    BlockStyle { configuration in
      ListBullet.circle
        .relativeFrame(minWidth: cappedWidth(minWidth, level: configuration.listLevel), alignment: alignment)
    }
  }

  /// A list marker style that uses a filled square.
  public static func square(minWidth: RelativeSize, alignment: Alignment = .center) -> Self {
    BlockStyle { configuration in
      ListBullet.square
        .relativeFrame(minWidth: cappedWidth(minWidth, level: configuration.listLevel), alignment: alignment)
    }
  }
}
