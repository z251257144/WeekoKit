import SwiftUI

struct WeekoAppearanceModeSettingsRow: View {
  @Environment(\.weekoTheme) private var theme
  @Environment(\.weekoMacTheme) private var macTheme
  @ObservedObject var store: WeekoAppearanceModeStore

  var body: some View {
    HStack(alignment: .center, spacing: theme.spacingSection) {
      WeekoSettingRowLabel(
        icon: "circle.lefthalf.filled",
        tint: .purple,
        title: WeekoSettingsText.localized("weeko_appearance_mode_title"),
        subtitle: WeekoSettingsText.localized("weeko_appearance_mode_subtitle")
      )
      .frame(maxWidth: .infinity, alignment: .leading)
      .layoutPriority(1)

      modePicker
        .frame(
          width: macTheme.trailingColumnWidth.upperBound,
          alignment: .trailing
        )
        .layoutPriority(2)
    }
    .padding(.vertical, WeekoSettingMetrics.rowVerticalPadding)
    .padding(.horizontal, theme.spacingInset / 2)
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  @ViewBuilder
  private var modePicker: some View {
    Picker("", selection: Binding(
      get: { store.selectedMode },
      set: { store.setMode($0) }
    )) {
      ForEach(WeekoAppearanceMode.allCases) { mode in
        HStack(spacing: 8) {
          Image(systemName: mode.symbolName)
            .font(.system(size: 13))
          Text(WeekoSettingsText.localized(mode.localizationKey))
            .font(.system(size: 13))
        }
        .tag(mode)
      }
    }
    .pickerStyle(.menu)
    .frame(minWidth: 140)
  }
}
