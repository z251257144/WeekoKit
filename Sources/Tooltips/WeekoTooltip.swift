import SwiftUI

/// Tooltip 相对于锚点的首选位置。
public enum WeekoTooltipPosition: Equatable, Sendable {
  case top
  case bottom

  /// 将位置转换为布局判断使用的布尔值。
  var isTop: Bool { self == .top }
}

/// Tooltip 的背景类型。
public enum WeekoTooltipBackground {
  case regularMaterial
  case thickMaterial
  case solid(Color)
}

/// Tooltip 的视觉参数，可按需调整边框和阴影。
public struct WeekoTooltipStyle {
  public var fontSize: CGFloat
  public var cornerRadius: CGFloat
  public var horizontalPadding: CGFloat
  public var verticalPadding: CGFloat
  public var arrowSize: CGSize
  public var gap: CGFloat
  public var maximumWidth: CGFloat
  public var background: WeekoTooltipBackground
  public var borderOpacity: Double
  public var shadowOpacity: Double

  /// 创建 Tooltip 样式。
  public init(
    fontSize: CGFloat = 13,
    cornerRadius: CGFloat = 6,
    horizontalPadding: CGFloat = 10,
    verticalPadding: CGFloat = 6,
    arrowSize: CGSize = CGSize(width: 12, height: 6),
    gap: CGFloat = 10,
    maximumWidth: CGFloat = 320,
    background: WeekoTooltipBackground = .thickMaterial,
    shadowOpacity: Double = 0.06,
    borderOpacity: Double = 0.2
  ) {
    self.fontSize = fontSize
    self.cornerRadius = cornerRadius
    self.horizontalPadding = horizontalPadding
    self.verticalPadding = verticalPadding
    self.arrowSize = arrowSize
    self.gap = gap
    self.maximumWidth = maximumWidth
    self.background = background
    self.borderOpacity = borderOpacity
    self.shadowOpacity = shadowOpacity
  }

  public static let standard = Self()
}

/// Tooltip 的圆角气泡和箭头 Shape，保留公开类型以兼容已有调用方。
public struct WeekoTooltipBubble: Shape {
  public let radius: CGFloat
  public let arrowSize: CGSize
  public let position: WeekoTooltipPosition

  /// 创建 Tooltip 气泡 Shape。
  public init(radius: CGFloat, arrowSize: CGSize, position: WeekoTooltipPosition) {
    self.radius = radius
    self.arrowSize = arrowSize
    self.position = position
  }

  /// 绘制圆角气泡和箭头。
  public func path(in rect: CGRect) -> Path {
    var path = Path()
    let arrowHeight = min(arrowSize.height, rect.height / 2)
    let bubbleRect = CGRect(
      x: rect.minX,
      y: position.isTop ? rect.minY : rect.minY + arrowHeight,
      width: rect.width,
      height: max(0, rect.height - arrowHeight)
    )
    let safeRadius = min(radius, min(bubbleRect.width, bubbleRect.height) / 2)
    let centerX = bubbleRect.midX
    let arrowHalfWidth = min(arrowSize.width / 2, bubbleRect.width / 3)

    path.move(to: CGPoint(x: bubbleRect.minX + safeRadius, y: bubbleRect.minY))
    if position == .bottom {
      path.addLine(to: CGPoint(x: centerX - arrowHalfWidth, y: bubbleRect.minY))
      path.addLine(to: CGPoint(x: centerX, y: rect.minY))
      path.addLine(to: CGPoint(x: centerX + arrowHalfWidth, y: bubbleRect.minY))
    }
    path.addLine(to: CGPoint(x: bubbleRect.maxX - safeRadius, y: bubbleRect.minY))
    path.addArc(
      center: CGPoint(x: bubbleRect.maxX - safeRadius, y: bubbleRect.minY + safeRadius),
      radius: safeRadius,
      startAngle: .degrees(-90),
      endAngle: .degrees(0),
      clockwise: false
    )
    path.addLine(to: CGPoint(x: bubbleRect.maxX, y: bubbleRect.maxY - safeRadius))
    path.addArc(
      center: CGPoint(x: bubbleRect.maxX - safeRadius, y: bubbleRect.maxY - safeRadius),
      radius: safeRadius,
      startAngle: .degrees(0),
      endAngle: .degrees(90),
      clockwise: false
    )
    if position == .top {
      path.addLine(to: CGPoint(x: centerX + arrowHalfWidth, y: bubbleRect.maxY))
      path.addLine(to: CGPoint(x: centerX, y: rect.maxY))
      path.addLine(to: CGPoint(x: centerX - arrowHalfWidth, y: bubbleRect.maxY))
    }
    path.addLine(to: CGPoint(x: bubbleRect.minX + safeRadius, y: bubbleRect.maxY))
    path.addArc(
      center: CGPoint(x: bubbleRect.minX + safeRadius, y: bubbleRect.maxY - safeRadius),
      radius: safeRadius,
      startAngle: .degrees(90),
      endAngle: .degrees(180),
      clockwise: false
    )
    path.addLine(to: CGPoint(x: bubbleRect.minX, y: bubbleRect.minY + safeRadius))
    path.addArc(
      center: CGPoint(x: bubbleRect.minX + safeRadius, y: bubbleRect.minY + safeRadius),
      radius: safeRadius,
      startAngle: .degrees(180),
      endAngle: .degrees(270),
      clockwise: false
    )
    path.closeSubpath()
    return path
  }
}
