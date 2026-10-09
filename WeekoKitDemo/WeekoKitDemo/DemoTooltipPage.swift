import SwiftUI
import WeekoKit

/// Tooltip 交互演示页，覆盖方向、延迟、样式和父容器裁剪场景。
struct DemoTooltipPage: View {
  @Environment(\.weekoMacTheme) private var theme
  @State private var position: WeekoTooltipPosition = .top
  @State private var delay = 0.3
  @State private var usesRegularMaterial = false

  /// 构建 Tooltip 演示页面。
  var body: some View {
    WeekoSettingsFormPage {
      WeekoSettingSection(DemoText.localized("tooltip_preview"), icon: "text.bubble") {
        LazyVGrid(
          columns: [GridItem(.adaptive(minimum: 150), spacing: 10)],
          spacing: 10
        ) {
          previewButton(
            title: DemoText.localized("tooltip_top"),
            icon: "arrow.up",
            tooltip: DemoText.localized("tooltip_top_help"),
            position: .top
          )

          previewButton(
            title: DemoText.localized("tooltip_bottom"),
            icon: "arrow.down",
            tooltip: DemoText.localized("tooltip_bottom_help"),
            position: .bottom
          )

          previewButton(
            title: DemoText.localized("tooltip_selected"),
            icon: "scope",
            tooltip: DemoText.localized("tooltip_selected_help"),
            position: position
          )
        }
        .padding(14)
        .frame(maxWidth: .infinity)
      }

      WeekoSettingSection(DemoText.localized("configuration"), icon: "slider.horizontal.3") {
        WeekoSettingActionRow(
          icon: "arrow.up.and.down",
          tint: theme.accentColor,
          title: DemoText.localized("tooltip_preferred_direction"),
          subtitle: DemoText.localized("tooltip_preferred_direction_subtitle")
        ) {
          Picker(DemoText.localized("tooltip_preferred_direction"), selection: $position) {
            Text(DemoText.localized("tooltip_position_top")).tag(WeekoTooltipPosition.top)
            Text(DemoText.localized("tooltip_position_bottom")).tag(WeekoTooltipPosition.bottom)
          }
          .labelsHidden()
          .pickerStyle(.segmented)
          .frame(width: 140)
        }

        WeekoSettingDivider()

        WeekoSettingActionRow(
          icon: "timer",
          tint: .orange,
          title: DemoText.localized("tooltip_hover_delay"),
          subtitle: DemoText.localized("tooltip_hover_delay_subtitle")
        ) {
          HStack(spacing: 8) {
            Slider(value: $delay, in: 0...1, step: 0.05)
            Text(delay, format: .number.precision(.fractionLength(2)))
              .font(.system(size: 11, design: .monospaced))
              .foregroundStyle(.secondary)
              .frame(width: 38, alignment: .trailing)
          }
          .frame(width: 180)
        }

        WeekoSettingDivider()

        WeekoSettingActionRow(
          icon: "square.2.layers.3d.top.filled",
          tint: .blue,
          title: DemoText.localized("tooltip_background_material"),
          subtitle: DemoText.localized("tooltip_background_material_subtitle")
        ) {
          Toggle(DemoText.localized("tooltip_regular_material"), isOn: $usesRegularMaterial)
            .labelsHidden()
            .toggleStyle(.switch)
        }
      }
    }
  }

  /// 创建一个带图标和 Tooltip 的演示按钮。
  @ViewBuilder
  private func previewButton(
    title: String,
    icon: String,
    tooltip: String,
    position: WeekoTooltipPosition
  ) -> some View {
    Button {} label: {
      Label(title, systemImage: icon)
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(WeekoSettingsActionButtonStyle(tint: theme.accentColor))
    .weekoTooltip(tooltip, delay: delay, position: position, style: tooltipStyle)
  }

  /// 生成当前控件状态对应的 Tooltip 样式。
  private var tooltipStyle: WeekoTooltipStyle {
    WeekoTooltipStyle(
      fontSize: 12,
      cornerRadius: 6,
      horizontalPadding: 9,
      verticalPadding: 5,
      arrowSize: CGSize(width: 11, height: 6),
      gap: 8,
      maximumWidth: 280,
      background: usesRegularMaterial ? .regularMaterial : .thickMaterial,
      borderOpacity: 0.2
    )
  }
}

#Preview {
  DemoTooltipPage()
    .frame(width: 680, height: 560)
}
